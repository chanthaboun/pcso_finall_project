import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class WeightRecord {
  final String id;
  final double weight;
  final DateTime date;
  final String? notes;
  final double? bodyFat; // ເພີ່ມເປີເຊັນໄຂມັນ
  final double? muscleMass; // ເພີ່ມມວນກ້າມ

  WeightRecord({
    required this.id,
    required this.weight,
    required this.date,
    this.notes,
    this.bodyFat,
    this.muscleMass,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
      'bodyFat': bodyFat,
      'muscleMass': muscleMass,
    };
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      bodyFat: json['bodyFat']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
    );
  }
}

class WeightGoal {
  final double targetWeight;
  final DateTime targetDate;
  final String goalType; // 'lose', 'gain', 'maintain'

  WeightGoal({
    required this.targetWeight,
    required this.targetDate,
    required this.goalType,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetWeight': targetWeight,
      'targetDate': targetDate.toIso8601String(),
      'goalType': goalType,
    };
  }

  factory WeightGoal.fromJson(Map<String, dynamic> json) {
    return WeightGoal(
      targetWeight: json['targetWeight']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate']),
      goalType: json['goalType'] ?? 'maintain',
    );
  }
}

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen>
    with TickerProviderStateMixin {
  List<WeightRecord> _weightRecords = [];
  WeightGoal? _weightGoal;
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  late TabController _tabController;
  int _selectedTimeRange = 30; // 7, 30, 90 days

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWeightRecords();
    _loadWeightGoal();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeightRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weightData = prefs.getString('weight_records');
      if (weightData != null) {
        final List<dynamic> decoded = jsonDecode(weightData);
        setState(() {
          _weightRecords =
              decoded.map((item) => WeightRecord.fromJson(item)).toList();
          _weightRecords.sort((a, b) => b.date.compareTo(a.date));
        });
      }
    } catch (e) {
      print('Error loading weight records: $e');
    }
  }

  Future<void> _loadWeightGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalData = prefs.getString('weight_goal');
      if (goalData != null) {
        setState(() {
          _weightGoal = WeightGoal.fromJson(jsonDecode(goalData));
        });
      }
    } catch (e) {
      print('Error loading weight goal: $e');
    }
  }

  Future<void> _saveWeightRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_weightRecords.map((record) => record.toJson()).toList());
      await prefs.setString('weight_records', encoded);
    } catch (e) {
      print('Error saving weight records: $e');
    }
  }

  Future<void> _saveWeightGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_weightGoal != null) {
        await prefs.setString('weight_goal', jsonEncode(_weightGoal!.toJson()));
      }
    } catch (e) {
      print('Error saving weight goal: $e');
    }
  }

  Future<void> _addWeightRecord() async {
    if (_weightController.text.isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      if (weight != null && weight > 0) {
        final bodyFat = _bodyFatController.text.isNotEmpty
            ? double.tryParse(_bodyFatController.text)
            : null;
        final muscleMass = _muscleMassController.text.isNotEmpty
            ? double.tryParse(_muscleMassController.text)
            : null;

        final record = WeightRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          weight: weight,
          date: DateTime.now(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          bodyFat: bodyFat,
          muscleMass: muscleMass,
        );

        setState(() {
          _weightRecords.insert(0, record);
        });

        await _saveWeightRecords();
        _weightController.clear();
        _notesController.clear();
        _bodyFatController.clear();
        _muscleMassController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ບັນທຶກນ້ຳໜັກສຳເລັດ! 📊'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _showGoalDialog() {
    final targetWeightController =
        TextEditingController(text: _weightGoal?.targetWeight.toString() ?? '');
    String selectedGoalType = _weightGoal?.goalType ?? 'maintain';
    DateTime selectedDate =
        _weightGoal?.targetDate ?? DateTime.now().add(const Duration(days: 90));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ຕັ້ງເປົ້າຫມາຍນ້ຳໜັກ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: targetWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ນ້ຳໜັກເປົ້າຫມາຍ (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGoalType,
                  decoration: const InputDecoration(
                    labelText: 'ປະເພດເປົ້າຫມາຍ',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'lose', child: Text('ຫຼຸດນ້ຳໜັກ')),
                    DropdownMenuItem(value: 'gain', child: Text('ເພີ່ມນ້ຳໜັກ')),
                    DropdownMenuItem(
                        value: 'maintain', child: Text('ຮັກສານ້ຳໜັກ')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedGoalType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ຍົກເລີກ'),
            ),
            TextButton(
              onPressed: () {
                final targetWeight =
                    double.tryParse(targetWeightController.text);
                if (targetWeight != null) {
                  setState(() {
                    _weightGoal = WeightGoal(
                      targetWeight: targetWeight,
                      targetDate: selectedDate,
                      goalType: selectedGoalType,
                    );
                  });
                  _saveWeightGoal();
                  Navigator.pop(context);
                }
              },
              child: const Text('ບັນທຶກ'),
            ),
          ],
        ),
      ),
    );
  }

  double? get _currentWeight =>
      _weightRecords.isNotEmpty ? _weightRecords.first.weight : null;

  double? get _previousWeight =>
      _weightRecords.length > 1 ? _weightRecords[1].weight : null;

  double? get _weightChange {
    if (_currentWeight != null && _previousWeight != null) {
      return _currentWeight! - _previousWeight!;
    }
    return null;
  }

  double? get _averageWeight {
    if (_weightRecords.isEmpty) return null;
    final recent = _getRecentRecords(_selectedTimeRange);
    if (recent.isEmpty) return null;
    return recent.fold<double>(0, (sum, record) => sum + record.weight) /
        recent.length;
  }

  double? get _weightTrend {
    final recent = _getRecentRecords(_selectedTimeRange);
    if (recent.length < 2) return null;

    final firstHalf = recent.take(recent.length ~/ 2).toList();
    final secondHalf = recent.skip(recent.length ~/ 2).toList();

    if (firstHalf.isEmpty || secondHalf.isEmpty) return null;

    final firstAvg = firstHalf.fold<double>(0, (sum, r) => sum + r.weight) /
        firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0, (sum, r) => sum + r.weight) /
        secondHalf.length;

    return secondAvg - firstAvg;
  }

  List<WeightRecord> _getRecentRecords(int days) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    return _weightRecords
        .where((record) => record.date.isAfter(cutoffDate))
        .toList();
  }

  String _getGoalProgress() {
    if (_weightGoal == null || _currentWeight == null) return '';

    final remaining = (_weightGoal!.targetWeight - _currentWeight!).abs();
    final daysLeft = _weightGoal!.targetDate.difference(DateTime.now()).inDays;

    if (daysLeft <= 0) return 'ໝົດກຳນົດແລ້ວ';

    return 'ເຫຼືອ ${remaining.toStringAsFixed(1)} kg ໃນ $daysLeft ວັນ';
  }

  double _getGoalProgressPercentage() {
    if (_weightGoal == null ||
        _currentWeight == null ||
        _weightRecords.length < 2) return 0;

    final startWeight = _weightRecords.last.weight;
    final targetWeight = _weightGoal!.targetWeight;
    final currentWeight = _currentWeight!;

    final totalChange = (targetWeight - startWeight).abs();
    final currentChange = (currentWeight - startWeight).abs();

    if (totalChange == 0) return 100;

    return math.min(currentChange / totalChange * 100, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('📈 ນ້ຳໜັກ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showGoalDialog,
            icon: const Icon(Icons.flag),
            tooltip: 'ຕັ້ງເປົ້າຫມາຍ',
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (period) {
              setState(() {
                _selectedTimeRange = period;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('7 ວັນ')),
              const PopupMenuItem(value: 30, child: Text('30 ວັນ')),
              const PopupMenuItem(value: 90, child: Text('90 ວັນ')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFE91E63),
          tabs: const [
            Tab(icon: Icon(Icons.add), text: 'ບັນທຶກ'),
            Tab(icon: Icon(Icons.analytics), text: 'ສະຖິຕິ'),
            Tab(icon: Icon(Icons.history), text: 'ປະຫວັດ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddTab(),
          _buildStatsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Goal progress card
          if (_weightGoal != null && _currentWeight != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.8),
                    const Color(0xFFE91E63),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'เປົ້າຫມາຍ: ${_weightGoal!.targetWeight} kg',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _getGoalProgressPercentage() / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getGoalProgress(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Add weight card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ບັນທຶກນ້ຳໜັກມື້ນີ້',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: 16),

                // Weight input
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ນ້ຳໜັກ (kg)',
                    hintText: 'ເຊັ່ນ: 65.5',
                    prefixIcon: const Icon(
                      Icons.scale,
                      color: Color(0xFFE91E63),
                    ),
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),

                // Body composition inputs
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bodyFatController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ໄຂມັນ (%)',
                          hintText: '15.5',
                          prefixIcon: const Icon(
                            Icons.fitness_center,
                            color: Color(0xFFE91E63),
                          ),
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _muscleMassController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ກ້າມເນື້ອ (kg)',
                          hintText: '45.2',
                          prefixIcon: const Icon(
                            Icons.accessibility_new,
                            color: Color(0xFFE91E63),
                          ),
                          suffixText: 'kg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes input
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'ໝາຍເຫດ (ເສີມ)',
                    hintText: 'ເຊັ່ນ: ຫຼັງອາຫານເຊົ້າ',
                    prefixIcon: const Icon(
                      Icons.note,
                      color: Color(0xFFE91E63),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addWeightRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ບັນທຶກ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
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
    final recentRecords = _getRecentRecords(_selectedTimeRange);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current stats
          if (_currentWeight != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.8),
                    const Color(0xFFE91E63),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'ນ້ຳໜັກປັດຈຸບັນ',
                        '${_currentWeight!.toStringAsFixed(1)} kg',
                        Colors.white,
                      ),
                      if (_weightChange != null)
                        _buildStatItem(
                          'ການປ່ຽນແປງ',
                          '${_weightChange! > 0 ? '+' : ''}${_weightChange!.toStringAsFixed(1)} kg',
                          Colors.white,
                          icon: _weightChange! > 0
                              ? Icons.trending_up
                              : _weightChange! < 0
                                  ? Icons.trending_down
                                  : Icons.trending_flat,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Statistics cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'ຄ່າສະເລ່ຍ',
                  _averageWeight != null
                      ? '${_averageWeight!.toStringAsFixed(1)} kg'
                      : 'N/A',
                  Icons.analytics,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'ແນວໂນ້ມ',
                  _weightTrend != null
                      ? '${_weightTrend! > 0 ? '+' : ''}${_weightTrend!.toStringAsFixed(1)} kg'
                      : 'N/A',
                  _weightTrend != null && _weightTrend! > 0
                      ? Icons.trending_up
                      : _weightTrend != null && _weightTrend! < 0
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  _weightTrend != null && _weightTrend! > 0
                      ? Colors.red
                      : _weightTrend != null && _weightTrend! < 0
                          ? Colors.green
                          : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart section
          if (recentRecords.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ກາຟິກນ້ຳໜັກ ($_selectedTimeRange ວັນ)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child:
                        _WeightChart(records: recentRecords.reversed.toList()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // BMI Calculator (if available)
          _buildBMICard(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return _weightRecords.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.scale,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'ຍັງບໍ່ມີການບັນທຶກນ້ຳໜັກ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _weightRecords.length,
            itemBuilder: (context, index) {
              final record = _weightRecords[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.scale,
                            color: Color(0xFFE91E63),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${record.weight.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${record.date.day}/${record.date.month}/${record.date.year} • ${record.date.hour}:${record.date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (record.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  record.notes!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Show change indicator
                        if (index < _weightRecords.length - 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getChangeColor(
                                      _weightRecords[index].weight -
                                          _weightRecords[index + 1].weight)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_weightRecords[index].weight - _weightRecords[index + 1].weight > 0 ? '+' : ''}${(_weightRecords[index].weight - _weightRecords[index + 1].weight).toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getChangeColor(
                                    _weightRecords[index].weight -
                                        _weightRecords[index + 1].weight),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Body composition data
                    if (record.bodyFat != null ||
                        record.muscleMass != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (record.bodyFat != null)
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.fitness_center,
                                      size: 16, color: Colors.orange[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ໄຂມັນ: ${record.bodyFat!.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (record.muscleMass != null)
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.accessibility_new,
                                      size: 16, color: Colors.green[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ກ້າມເນື້ອ: ${record.muscleMass!.toStringAsFixed(1)}kg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
  }

  Widget _buildStatItem(String label, String value, Color color,
      {IconData? icon}) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
        ],
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard() {
    if (_currentWeight == null) return const SizedBox.shrink();

    // Assuming average height - in real app, this should be user input
    const double averageHeight = 1.65; // meters
    final bmi = _currentWeight! / (averageHeight * averageHeight);

    String bmiCategory;
    Color bmiColor;

    if (bmi < 18.5) {
      bmiCategory = 'ຈ່ອຍເກີນໄປ';
      bmiColor = Colors.blue;
    } else if (bmi < 25) {
      bmiCategory = 'ປົກກະຕິ';
      bmiColor = Colors.green;
    } else if (bmi < 30) {
      bmiCategory = 'ໜ້ອຍເກີນໄປ';
      bmiColor = Colors.orange;
    } else {
      bmiCategory = 'ອ້ວນ';
      bmiColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI (ສົມມຸດສູງ 165cm)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  Text(
                    bmiCategory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: bmiColor,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: math.min(
                          bmi / 40, 1.0), // Max BMI 40 for visualization
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
                      strokeWidth: 6,
                    ),
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: bmiColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'BMI ແມ່ນການວັດແທກສະພາບຂອງຮ່າງກາຍໂດຍອິງຕາມນ້ຳໜັກແລະສູງ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getChangeColor(double change) {
    if (change > 0) return Colors.red;
    if (change < 0) return Colors.green;
    return Colors.grey;
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightRecord> records;

  const _WeightChart({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.length < 2) return const SizedBox.shrink();

    final minWeight = records.map((r) => r.weight).reduce(math.min) - 1;
    final maxWeight = records.map((r) => r.weight).reduce(math.max) + 1;
    final weightRange = maxWeight - minWeight;

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _WeightChartPainter(
        records: records,
        minWeight: minWeight,
        maxWeight: maxWeight,
        weightRange: weightRange,
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightRecord> records;
  final double minWeight;
  final double maxWeight;
  final double weightRange;

  _WeightChartPainter({
    required this.records,
    required this.minWeight,
    required this.maxWeight,
    required this.weightRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE91E63)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.fill;

    // Draw background grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical grid lines
    for (int i = 0; i <= 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw gradient area under the line
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE91E63).withOpacity(0.3),
          const Color(0xFFE91E63).withOpacity(0.1),
          const Color(0xFFE91E63).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final gradientPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < records.length; i++) {
      final x = (i / (records.length - 1)) * size.width;
      final y = size.height -
          ((records[i].weight - minWeight) / weightRange) * size.height;

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    // Complete gradient path
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    // Draw gradient area
    canvas.drawPath(gradientPath, gradientPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points with animation effect
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Outer circle (white border)
      canvas.drawCircle(
          point,
          6,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);

      // Inner circle (colored)
      canvas.drawCircle(point, 4, pointPaint);

      // Pulse effect for latest point
      if (i == points.length - 1) {
        canvas.drawCircle(
            point,
            8,
            Paint()
              ..color = const Color(0xFFE91E63).withOpacity(0.3)
              ..style = PaintingStyle.fill);
      }
    }

    // Draw weight labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < points.length; i++) {
      if (i % math.max(1, points.length ~/ 5) == 0 || i == points.length - 1) {
        final point = points[i];
        textPainter.text = TextSpan(
          text: records[i].weight.toStringAsFixed(1),
          style: const TextStyle(
            color: Color(0xFFE91E63),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(point.dx - textPainter.width / 2, point.dy - 20),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
