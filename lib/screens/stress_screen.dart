// stress_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen>
    with TickerProviderStateMixin {
  int _stressLevel = 3;
  String _selectedCause = 'ວຽກງານ';
  final _noteController = TextEditingController();
  List<Map<String, dynamic>> _stressRecords = [];

  late TabController _tabController;

  final List<String> _stressCauses = [
    'ວຽກງານ',
    'ຄອບຄົວ',
    'ເງິນ',
    'ສຸຂະພາບ',
    'ຄວາມສຳພັນ',
    'ການຮຽນ',
    'ສິ່ງແວດລ້ອມ',
    'ສື່ສັງຄົມ',
    'ອື່ນໆ'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStressData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStressData() async {
    final prefs = await SharedPreferences.getInstance();
    final stressData = prefs.getString('stress_records');
    if (stressData != null) {
      setState(() {
        _stressRecords =
            List<Map<String, dynamic>>.from(jsonDecode(stressData));
      });
    }
  }

  Future<void> _saveStressRecord() async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'stressLevel': _stressLevel,
      'cause': _selectedCause,
      'note': _noteController.text.trim(),
    };

    setState(() {
      _stressRecords.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stress_records', jsonEncode(_stressRecords));

    _noteController.clear();
    setState(() {
      _stressLevel = 3;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'ບັນທຶກຄວາມຄຽດສຳເລັດ! ${_getRecommendationBasedOnLevel(_stressLevel)}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _getRecommendationBasedOnLevel(int level) {
    if (level >= 4) {
      return '💡 ແນະນຳ: ລອງເຮັດກິດຈະກຳຜ່ອນຄາຍ';
    } else if (level <= 2) {
      return '😊 ເຮັດໄດ້ດີຫຼາຍ!';
    }
    return '';
  }

  String _getStressLevelText(int level) {
    switch (level) {
      case 1:
        return 'ຜ່ອນຄາຍ';
      case 2:
        return 'ເບົາໆ';
      case 3:
        return 'ປົກກະຕິ';
      case 4:
        return 'ຄຽດ';
      case 5:
        return 'ຄຽດຫຼາຍ';
      default:
        return 'ປົກກະຕິ';
    }
  }

  Color _getStressLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCauseIcon(String cause) {
    switch (cause) {
      case 'ວຽກງານ':
        return Icons.work;
      case 'ຄອບຄົວ':
        return Icons.family_restroom;
      case 'ເງິນ':
        return Icons.monetization_on;
      case 'ສຸຂະພາບ':
        return Icons.health_and_safety;
      case 'ຄວາມສຳພັນ':
        return Icons.favorite;
      case 'ການຮຽນ':
        return Icons.school;
      case 'ສິ່ງແວດລ້ອມ':
        return Icons.nature;
      case 'ສື່ສັງຄົມ':
        return Icons.smartphone;
      default:
        return Icons.more_horiz;
    }
  }

  // Calculate stress statistics
  Map<String, dynamic> _getStressStats() {
    if (_stressRecords.isEmpty)
      return {'avg': 0.0, 'trend': 'stable', 'weeklyAvg': 0.0};

    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));

    // Weekly records
    final weeklyRecords = _stressRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekAgo);
    }).toList();

    if (weeklyRecords.isEmpty)
      return {'avg': 0.0, 'trend': 'stable', 'weeklyAvg': 0.0};

    final weeklyAvg = weeklyRecords.fold<double>(
            0, (sum, record) => sum + record['stressLevel']) /
        weeklyRecords.length;

    // Trend calculation (compare first half vs second half of week)
    final midWeek = weekAgo.add(Duration(days: 3, hours: 12));
    final firstHalf = weeklyRecords
        .where((r) => DateTime.parse(r['date']).isBefore(midWeek))
        .toList();
    final secondHalf = weeklyRecords
        .where((r) => DateTime.parse(r['date']).isAfter(midWeek))
        .toList();

    String trend = 'stable';
    if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
      final firstAvg =
          firstHalf.fold<double>(0, (sum, r) => sum + r['stressLevel']) /
              firstHalf.length;
      final secondAvg =
          secondHalf.fold<double>(0, (sum, r) => sum + r['stressLevel']) /
              secondHalf.length;

      if (secondAvg > firstAvg + 0.5)
        trend = 'increasing';
      else if (secondAvg < firstAvg - 0.5) trend = 'decreasing';
    }

    return {'avg': weeklyAvg, 'trend': trend, 'weeklyAvg': weeklyAvg};
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick stress level indicator
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE91E63).withOpacity(0.1),
                  Color(0xFFE91E63).withOpacity(0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE91E63).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Color(0xFFE91E63), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'ບັນທຶກຄວາມຄຽດມື້ນີ້',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63)),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Compact stress level selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final level = index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _stressLevel = level),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _stressLevel == level
                                  ? _getStressLevelColor(level)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                level.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _stressLevel == level
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getStressLevelText(level),
                            style: TextStyle(
                              fontSize: 9,
                              color: _stressLevel == level
                                  ? _getStressLevelColor(level)
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                SizedBox(height: 16),

                // Compact cause and note
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCause,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          items: _stressCauses.map((cause) {
                            return DropdownMenuItem(
                              value: cause,
                              child: Row(
                                children: [
                                  Icon(_getCauseIcon(cause),
                                      color: Color(0xFFE91E63), size: 16),
                                  SizedBox(width: 6),
                                  Text(cause, style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _selectedCause = value);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'ໝາຍເຫດ...',
                          hintStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: _saveStressRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('ບັນທຶກ',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = _getStressStats();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekly overview
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('ສະຖິຕິ 7 ວັນຜ່ານມາ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'ຄ່າສະເລ່ຍ',
                        stats['weeklyAvg'].toStringAsFixed(1),
                        Icons.analytics,
                        _getStressLevelColor(stats['weeklyAvg'].round()),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'ແນວໂນ້ມ',
                        stats['trend'] == 'increasing'
                            ? 'ເພີ່ມຂຶ້ນ'
                            : stats['trend'] == 'decreasing'
                                ? 'ລຸດລົງ'
                                : 'ສະຖຽນ',
                        stats['trend'] == 'increasing'
                            ? Icons.trending_up
                            : stats['trend'] == 'decreasing'
                                ? Icons.trending_down
                                : Icons.trending_flat,
                        stats['trend'] == 'increasing'
                            ? Colors.red
                            : stats['trend'] == 'decreasing'
                                ? Colors.green
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Stress causes analysis
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ສາເຫດຄວາມຄຽດຫຼັກ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                ...(_getStressCauseDistribution().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(_getCauseIcon(entry.key),
                            color: Color(0xFFE91E63), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                            child: Text(entry.key,
                                style: TextStyle(fontSize: 14))),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE91E63).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value} ຄັ້ງ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Stress level distribution chart
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ການແຈກຢາຍລະດັບຄວາມຄຽດ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                ...List.generate(5, (index) {
                  final level = index + 1;
                  final count = _getStressLevelCount(level);
                  final total = _stressRecords.length;
                  final percentage =
                      total > 0 ? (count / total * 100).round() : 0;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _getStressLevelColor(level).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              level.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStressLevelColor(level),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getStressLevelText(level),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: total > 0 ? count / total : 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _getStressLevelColor(level),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('$count ($percentage%)',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Map<String, int> _getStressCauseDistribution() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final weeklyRecords = _stressRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekAgo);
    });

    final distribution = <String, int>{};
    for (final record in weeklyRecords) {
      final cause = record['cause'] as String;
      distribution[cause] = (distribution[cause] ?? 0) + 1;
    }
    return distribution;
  }

  int _getStressLevelCount(int level) {
    return _stressRecords
        .where((record) => record['stressLevel'] == level)
        .length;
  }

  Widget _buildHistoryTab() {
    return _stressRecords.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text('ຍັງບໍ່ມີຂໍ້ມູນຄວາມຄຽດ',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                SizedBox(height: 8),
                Text('ເລີ່ມບັນທຶກຄວາມຄຽດປະຈຳວັນ!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _stressRecords.length,
            itemBuilder: (context, index) {
              final record = _stressRecords[index];
              final date = DateTime.parse(record['date']);

              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _getStressLevelColor(record['stressLevel']),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(_getCauseIcon(record['cause']),
                                      size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(record['cause'],
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ລະດັບ ${record['stressLevel']}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE91E63)),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    _getStressLevelColor(record['stressLevel'])
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStressLevelText(record['stressLevel']),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: _getStressLevelColor(
                                      record['stressLevel']),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _stressRecords.removeAt(index);
                            });
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString(
                                  'stress_records', jsonEncode(_stressRecords));
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('ລຶບບັນທຶກແລ້ວ'),
                                  backgroundColor: Colors.orange),
                            );
                          },
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red, size: 18),
                          padding: EdgeInsets.zero,
                          constraints:
                              BoxConstraints(minWidth: 30, minHeight: 30),
                        ),
                      ],
                    ),
                    if (record['note'].isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          record['note'],
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCE4EC),
      appBar: AppBar(
        title: Text(
          'ຄວາມຄຽດ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFE91E63),
          tabs: [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'ບັນທຶກ'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'ສະຖິຕິ'),
            Tab(icon: Icon(Icons.history), text: 'ປະຫວັດ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrackingTab(),
          _buildStatsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }
}
