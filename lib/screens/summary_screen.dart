import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, List<Map<String, dynamic>>> _allData = {
    'sleep': [],
    'nutrition': [],
    'exercise': [],
    'stress': [],
    'period': [],
  };

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _allData['sleep'] = _getData(prefs, 'sleep_records');
      _allData['nutrition'] = _getData(prefs, 'nutrition_records');
      _allData['exercise'] = _getData(prefs, 'exercise_records');
      _allData['stress'] = _getData(prefs, 'stress_records');
      _allData['period'] = _getData(prefs, 'period_records');
    });
  }

  List<Map<String, dynamic>> _getData(SharedPreferences prefs, String key) {
    final data = prefs.getString(key);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  List<Map<String, dynamic>> _getRecentData(
    List<Map<String, dynamic>> data,
    int days,
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return data.where((record) {
      final date = DateTime.parse(record['date']);
      return date.isAfter(cutoffDate);
    }).toList();
  }

  double _getAverageSleepHours() {
    final recentSleep = _getRecentData(_allData['sleep']!, 7);
    if (recentSleep.isEmpty) return 0;

    double totalHours = 0;
    for (var record in recentSleep) {
      final duration = record['duration'] as String;
      final parts = duration.split('h ');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1].replaceAll('m', '')) ?? 0;
        totalHours += hours + (minutes / 60);
      }
    }
    return totalHours / recentSleep.length;
  }

  double _getAverageSleepQuality() {
    final recentSleep = _getRecentData(_allData['sleep']!, 7);
    if (recentSleep.isEmpty) return 0;

    int totalQuality = 0;
    for (var record in recentSleep) {
      totalQuality += record['quality'] as int;
    }
    return totalQuality / recentSleep.length;
  }

  int _getExerciseCount() {
    return _getRecentData(_allData['exercise']!, 7).length;
  }

  int _getTotalExerciseMinutes() {
    final recentExercise = _getRecentData(_allData['exercise']!, 7);
    int totalMinutes = 0;
    for (var record in recentExercise) {
      totalMinutes += record['duration'] as int;
    }
    return totalMinutes;
  }

  double _getAverageStressLevel() {
    final recentStress = _getRecentData(_allData['stress']!, 7);
    if (recentStress.isEmpty) return 0;

    int totalStress = 0;
    for (var record in recentStress) {
      totalStress += record['stressLevel'] as int;
    }
    return totalStress / recentStress.length;
  }

  int _getMealsCount() {
    return _getRecentData(_allData['nutrition']!, 7).length;
  }

  String _getHealthStatus() {
    final sleepQuality = _getAverageSleepQuality();
    final stressLevel = _getAverageStressLevel();
    final exerciseCount = _getExerciseCount();

    if (sleepQuality >= 4 && stressLevel <= 2 && exerciseCount >= 3) {
      return 'ດີເລີດ';
    } else if (sleepQuality >= 3 && stressLevel <= 3 && exerciseCount >= 2) {
      return 'ດີ';
    } else if (sleepQuality >= 2 && stressLevel <= 4 && exerciseCount >= 1) {
      return 'ປົກກະຕິ';
    } else {
      return 'ຕ້ອງປັບປຸງ';
    }
  }

  Color _getHealthStatusColor() {
    final status = _getHealthStatus();
    switch (status) {
      case 'ດີເລີດ':
        return Colors.green;
      case 'ດີ':
        return Colors.lightGreen;
      case 'ປົກກະຕິ':
        return Colors.orange;
      case 'ຕ້ອງປັບປຸງ':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'ສະຫຼູບຜົນ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall health status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getHealthStatusColor().withOpacity(0.8),
                      _getHealthStatusColor(),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'ສະຖານະສຸຂະພາບໂດຍລວມ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getHealthStatus(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ຈາກຂໍ້ມູນ 7 ວັນທີ່ຜ່ານມາ',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics grid
              const Text(
                'ສະຖິຕິ 7 ວັນທີ່ຜ່ານມາ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      title: 'ການນອນເສຍງ',
                      value: '${_getAverageSleepHours().toStringAsFixed(1)}h',
                      icon: Icons.bedtime,
                      color: Colors.purple,
                      subtitle:
                          'ຄຸນນະພາບ: ${_getAverageSleepQuality().toStringAsFixed(1)}/5',
                    ),
                    _buildStatCard(
                      title: 'ອອກກຳລັງກາຍ',
                      value: '${_getExerciseCount()}',
                      icon: Icons.fitness_center,
                      color: Colors.blue,
                      subtitle: '${_getTotalExerciseMinutes()} ນາທີ',
                    ),
                    _buildStatCard(
                      title: 'ລະດັບຄວາມຄຽດ',
                      value: '${_getAverageStressLevel().toStringAsFixed(1)}/5',
                      icon: Icons.psychology,
                      color:
                          _getAverageStressLevel() <= 2
                              ? Colors.green
                              : _getAverageStressLevel() <= 3
                              ? Colors.orange
                              : Colors.red,
                      subtitle: 'ເສຍງສະເລ່ຍ',
                    ),
                    _buildStatCard(
                      title: 'ການກິນ',
                      value: '${_getMealsCount()}',
                      icon: Icons.restaurant,
                      color: Colors.orange,
                      subtitle: 'ມື້ອາຫານທີ່ບັນທຶກ',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Recommendations
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: Color(0xFFE91E63),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ຄຳແນະນຳ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._getRecommendations()
                        .map(
                          (recommendation) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFE91E63),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    recommendation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getRecommendations() {
    List<String> recommendations = [];

    // Sleep recommendations
    final sleepHours = _getAverageSleepHours();
    final sleepQuality = _getAverageSleepQuality();

    if (sleepHours < 7) {
      recommendations.add('ພະຍາຍາມນອນໃຫ້ຄົບ 7-9 ຊົ່ວໂມງຕໍ່ຄືນ');
    }
    if (sleepQuality < 3) {
      recommendations.add('ປັບປຸງຄຸນນະພາບການນອນດ້ວຍການສ້າງບັນຍາກາດທີ່ສະຫງົບ');
    }

    // Exercise recommendations
    final exerciseCount = _getExerciseCount();
    if (exerciseCount < 3) {
      recommendations.add('ເພີ່ມການອອກກຳລັງກາຍເປັນຢ່າງນ້ອຍ 3 ຄັ້ງຕໍ່ອາທິດ');
    }

    // Stress recommendations
    final stressLevel = _getAverageStressLevel();
    if (stressLevel > 3) {
      recommendations.add('ຝຶກເຕັກນິກການຜ່ອນຄາຍ ເຊັ່ນ: ການຫາຍໃຈເລິກ ຫຼື ຢູຄະ');
    }

    // General recommendations
    if (recommendations.isEmpty) {
      recommendations.add('ສຸຂະພາບຂອງເຈົ້າດີຫຼາຍ! ສືບຕໍ່ຮັກສານີ້ປະແບບນີ້ຕໍ່ໄປ');
    }

    if (_getMealsCount() < 14) {
      // Less than 2 meals per day average
      recommendations.add('ບັນທຶກການກິນໃຫ້ສົມ່ຳສະເມີເພື່ອຕິດຕາມໂພຊະນາການ');
    }

    return recommendations;
  }
}




