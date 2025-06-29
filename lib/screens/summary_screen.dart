// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class SummaryScreen extends StatefulWidget {
//   const SummaryScreen({super.key});

//   @override
//   State<SummaryScreen> createState() => _SummaryScreenState();
// }

// class _SummaryScreenState extends State<SummaryScreen> {
//   final Map<String, List<Map<String, dynamic>>> _allData = {
//     'sleep': [],
//     'nutrition': [],
//     'exercise': [],
//     'stress': [],
//     'period': [],
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadAllData();
//   }

//   Future<void> _loadAllData() async {
//     final prefs = await SharedPreferences.getInstance();

//     setState(() {
//       _allData['sleep'] = _getData(prefs, 'sleep_records');
//       _allData['nutrition'] = _getData(prefs, 'nutrition_records');
//       _allData['exercise'] = _getData(prefs, 'exercise_records');
//       _allData['stress'] = _getData(prefs, 'stress_records');
//       _allData['period'] = _getData(prefs, 'period_records');
//     });
//   }

//   List<Map<String, dynamic>> _getData(SharedPreferences prefs, String key) {
//     final data = prefs.getString(key);
//     if (data != null) {
//       return List<Map<String, dynamic>>.from(jsonDecode(data));
//     }
//     return [];
//   }

//   List<Map<String, dynamic>> _getRecentData(
//     List<Map<String, dynamic>> data,
//     int days,
//   ) {
//     final cutoffDate = DateTime.now().subtract(Duration(days: days));
//     return data.where((record) {
//       final date = DateTime.parse(record['date']);
//       return date.isAfter(cutoffDate);
//     }).toList();
//   }

//   double _getAverageSleepHours() {
//     final recentSleep = _getRecentData(_allData['sleep']!, 7);
//     if (recentSleep.isEmpty) return 0;

//     double totalHours = 0;
//     for (var record in recentSleep) {
//       final duration = record['duration'] as String;
//       final parts = duration.split('h ');
//       if (parts.length == 2) {
//         final hours = int.tryParse(parts[0]) ?? 0;
//         final minutes = int.tryParse(parts[1].replaceAll('m', '')) ?? 0;
//         totalHours += hours + (minutes / 60);
//       }
//     }
//     return totalHours / recentSleep.length;
//   }

//   double _getAverageSleepQuality() {
//     final recentSleep = _getRecentData(_allData['sleep']!, 7);
//     if (recentSleep.isEmpty) return 0;

//     int totalQuality = 0;
//     for (var record in recentSleep) {
//       totalQuality += record['quality'] as int;
//     }
//     return totalQuality / recentSleep.length;
//   }

//   int _getExerciseCount() {
//     return _getRecentData(_allData['exercise']!, 7).length;
//   }

//   int _getTotalExerciseMinutes() {
//     final recentExercise = _getRecentData(_allData['exercise']!, 7);
//     int totalMinutes = 0;
//     for (var record in recentExercise) {
//       totalMinutes += record['duration'] as int;
//     }
//     return totalMinutes;
//   }

//   double _getAverageStressLevel() {
//     final recentStress = _getRecentData(_allData['stress']!, 7);
//     if (recentStress.isEmpty) return 0;

//     int totalStress = 0;
//     for (var record in recentStress) {
//       totalStress += record['stressLevel'] as int;
//     }
//     return totalStress / recentStress.length;
//   }

//   int _getMealsCount() {
//     return _getRecentData(_allData['nutrition']!, 7).length;
//   }

//   String _getHealthStatus() {
//     final sleepQuality = _getAverageSleepQuality();
//     final stressLevel = _getAverageStressLevel();
//     final exerciseCount = _getExerciseCount();

//     if (sleepQuality >= 4 && stressLevel <= 2 && exerciseCount >= 3) {
//       return 'ດີເລີດ';
//     } else if (sleepQuality >= 3 && stressLevel <= 3 && exerciseCount >= 2) {
//       return 'ດີ';
//     } else if (sleepQuality >= 2 && stressLevel <= 4 && exerciseCount >= 1) {
//       return 'ປົກກະຕິ';
//     } else {
//       return 'ຕ້ອງປັບປຸງ';
//     }
//   }

//   Color _getHealthStatusColor() {
//     final status = _getHealthStatus();
//     switch (status) {
//       case 'ດີເລີດ':
//         return Colors.green;
//       case 'ດີ':
//         return Colors.lightGreen;
//       case 'ປົກກະຕິ':
//         return Colors.orange;
//       case 'ຕ້ອງປັບປຸງ':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//     String? subtitle,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(icon, color: color, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       value,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: color,
//                       ),
//                     ),
//                     if (subtitle != null) ...[
//                       const SizedBox(height: 2),
//                       Text(
//                         subtitle,
//                         style: const TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCE4EC),
//       appBar: AppBar(
//         title: const Text(
//           'ສະຫຼູບຜົນ',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Overall health status
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       _getHealthStatusColor().withOpacity(0.8),
//                       _getHealthStatusColor(),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(Icons.favorite, color: Colors.white, size: 40),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'ສະຖານະສຸຂະພາບໂດຍລວມ',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _getHealthStatus(),
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'ຈາກຂໍ້ມູນ 7 ວັນທີ່ຜ່ານມາ',
//                       style: TextStyle(fontSize: 12, color: Colors.white70),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Statistics grid
//               const Text(
//                 'ສະຖິຕິ 7 ວັນທີ່ຜ່ານມາ',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 1.2,
//                   children: [
//                     _buildStatCard(
//                       title: 'ການນອນເສຍງ',
//                       value: '${_getAverageSleepHours().toStringAsFixed(1)}h',
//                       icon: Icons.bedtime,
//                       color: Colors.purple,
//                       subtitle:
//                           'ຄຸນນະພາບ: ${_getAverageSleepQuality().toStringAsFixed(1)}/5',
//                     ),
//                     _buildStatCard(
//                       title: 'ອອກກຳລັງກາຍ',
//                       value: '${_getExerciseCount()}',
//                       icon: Icons.fitness_center,
//                       color: Colors.blue,
//                       subtitle: '${_getTotalExerciseMinutes()} ນາທີ',
//                     ),
//                     _buildStatCard(
//                       title: 'ລະດັບຄວາມຄຽດ',
//                       value: '${_getAverageStressLevel().toStringAsFixed(1)}/5',
//                       icon: Icons.psychology,
//                       color:
//                           _getAverageStressLevel() <= 2
//                               ? Colors.green
//                               : _getAverageStressLevel() <= 3
//                               ? Colors.orange
//                               : Colors.red,
//                       subtitle: 'ເສຍງສະເລ່ຍ',
//                     ),
//                     _buildStatCard(
//                       title: 'ການກິນ',
//                       value: '${_getMealsCount()}',
//                       icon: Icons.restaurant,
//                       color: Colors.orange,
//                       subtitle: 'ມື້ອາຫານທີ່ບັນທຶກ',
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Recommendations
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 5,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Row(
//                       children: [
//                         Icon(
//                           Icons.lightbulb,
//                           color: Color(0xFFE91E63),
//                           size: 20,
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           'ຄຳແນະນຳ',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFFE91E63),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     ..._getRecommendations()
//                         .map(
//                           (recommendation) => Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   '• ',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Color(0xFFE91E63),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     recommendation,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                         ,
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<String> _getRecommendations() {
//     List<String> recommendations = [];

//     // Sleep recommendations
//     final sleepHours = _getAverageSleepHours();
//     final sleepQuality = _getAverageSleepQuality();

//     if (sleepHours < 7) {
//       recommendations.add('ພະຍາຍາມນອນໃຫ້ຄົບ 7-9 ຊົ່ວໂມງຕໍ່ຄືນ');
//     }
//     if (sleepQuality < 3) {
//       recommendations.add('ປັບປຸງຄຸນນະພາບການນອນດ້ວຍການສ້າງບັນຍາກາດທີ່ສະຫງົບ');
//     }

//     // Exercise recommendations
//     final exerciseCount = _getExerciseCount();
//     if (exerciseCount < 3) {
//       recommendations.add('ເພີ່ມການອອກກຳລັງກາຍເປັນຢ່າງນ້ອຍ 3 ຄັ້ງຕໍ່ອາທິດ');
//     }

//     // Stress recommendations
//     final stressLevel = _getAverageStressLevel();
//     if (stressLevel > 3) {
//       recommendations.add('ຝຶກເຕັກນິກການຜ່ອນຄາຍ ເຊັ່ນ: ການຫາຍໃຈເລິກ ຫຼື ຢູຄະ');
//     }

//     // General recommendations
//     if (recommendations.isEmpty) {
//       recommendations.add('ສຸຂະພາບຂອງເຈົ້າດີຫຼາຍ! ສືບຕໍ່ຮັກສານີ້ປະແບບນີ້ຕໍ່ໄປ');
//     }

//     if (_getMealsCount() < 14) {
//       // Less than 2 meals per day average
//       recommendations.add('ບັນທຶກການກິນໃຫ້ສົມ່ຳສະເມີເພື່ອຕິດຕາມໂພຊະນາການ');
//     }

//     return recommendations;
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with TickerProviderStateMixin {
  final Map<String, List<Map<String, dynamic>>> _allData = {
    'sleep': [],
    'nutrition': [],
    'exercise': [],
    'stress': [],
    'period': [],
    'goals': [],
  };

  late TabController _tabController;
  int _selectedPeriod = 7; // 7, 30, 90 days
  bool _isLaoLanguage = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _allData['sleep'] = _getData(prefs, 'sleep_records');
      _allData['nutrition'] = _getData(prefs, 'nutrition_records');
      _allData['exercise'] = _getData(prefs, 'exercise_records');
      _allData['stress'] = _getData(prefs, 'stress_records');
      _allData['period'] = _getData(prefs, 'period_records');
      _allData['goals'] = _getData(prefs, 'user_goals');
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
      final date = DateTime.parse(record['date'] ??
          record['startDate'] ??
          DateTime.now().toIso8601String());
      return date.isAfter(cutoffDate);
    }).toList();
  }

  // ========== SLEEP ANALYTICS ==========
  double _getAverageSleepHours() {
    final recentSleep = _getRecentData(_allData['sleep']!, _selectedPeriod);
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
    final recentSleep = _getRecentData(_allData['sleep']!, _selectedPeriod);
    if (recentSleep.isEmpty) return 0;

    int totalQuality = 0;
    for (var record in recentSleep) {
      totalQuality += record['quality'] as int;
    }
    return totalQuality / recentSleep.length;
  }

  int _getSleepConsistencyScore() {
    final recentSleep = _getRecentData(_allData['sleep']!, _selectedPeriod);
    if (recentSleep.length < 3) return 0;

    List<DateTime> bedtimes = [];
    for (var record in recentSleep) {
      final bedtime = DateTime.parse(record['bedtime']);
      bedtimes.add(bedtime);
    }

    // Calculate variance in sleep times
    double totalVariance = 0;
    for (int i = 1; i < bedtimes.length; i++) {
      final diff = bedtimes[i].difference(bedtimes[i - 1]).inMinutes.abs();
      totalVariance += diff;
    }

    final avgVariance = totalVariance / (bedtimes.length - 1);
    return math.max(0, (100 - (avgVariance / 60 * 20)).round());
  }

  // ========== EXERCISE ANALYTICS ==========
  int _getExerciseCount() {
    return _getRecentData(_allData['exercise']!, _selectedPeriod).length;
  }

  int _getTotalExerciseMinutes() {
    final recentExercise =
        _getRecentData(_allData['exercise']!, _selectedPeriod);
    int totalMinutes = 0;
    for (var record in recentExercise) {
      totalMinutes += record['duration'] as int;
    }
    return totalMinutes;
  }

  double _getExerciseFrequency() {
    final exerciseCount = _getExerciseCount();
    final weeks = _selectedPeriod / 7;
    return exerciseCount / weeks;
  }

  Map<String, int> _getExerciseByType() {
    final recentExercise =
        _getRecentData(_allData['exercise']!, _selectedPeriod);
    Map<String, int> typeCount = {};

    for (var record in recentExercise) {
      final type = record['type'] as String;
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }
    return typeCount;
  }

  // ========== STRESS ANALYTICS ==========
  double _getAverageStressLevel() {
    final recentStress = _getRecentData(_allData['stress']!, _selectedPeriod);
    if (recentStress.isEmpty) return 0;

    int totalStress = 0;
    for (var record in recentStress) {
      totalStress += record['stressLevel'] as int;
    }
    return totalStress / recentStress.length;
  }

  Map<String, int> _getStressTriggers() {
    final recentStress = _getRecentData(_allData['stress']!, _selectedPeriod);
    Map<String, int> triggers = {};

    for (var record in recentStress) {
      final cause = record['cause'] as String;
      triggers[cause] = (triggers[cause] ?? 0) + 1;
    }
    return triggers;
  }

  List<Map<String, dynamic>> _getStressTrend() {
    final recentStress = _getRecentData(_allData['stress']!, _selectedPeriod);
    Map<String, List<int>> dailyStress = {};

    for (var record in recentStress) {
      final date = DateTime.parse(record['date']);
      final dateKey = '${date.day}/${date.month}';
      dailyStress[dateKey] = dailyStress[dateKey] ?? [];
      dailyStress[dateKey]!.add(record['stressLevel']);
    }

    List<Map<String, dynamic>> trend = [];
    dailyStress.forEach((date, levels) {
      final avg = levels.reduce((a, b) => a + b) / levels.length;
      trend.add({'date': date, 'level': avg});
    });

    return trend..sort((a, b) => a['date'].compareTo(b['date']));
  }

  // ========== NUTRITION ANALYTICS ==========
  int _getMealsCount() {
    return _getRecentData(_allData['nutrition']!, _selectedPeriod).length;
  }

  double _getNutritionScore() {
    final recentNutrition =
        _getRecentData(_allData['nutrition']!, _selectedPeriod);
    if (recentNutrition.isEmpty) return 0;

    double totalScore = 0;
    for (var record in recentNutrition) {
      // Calculate score based on meal completeness and quality
      int score = 0;
      if (record['hasProtein'] == true) score += 25;
      if (record['hasVegetables'] == true) score += 25;
      if (record['hasCarbs'] == true) score += 25;
      if (record['waterIntake'] != null && record['waterIntake'] > 0)
        score += 25;
      totalScore += score;
    }
    return totalScore / recentNutrition.length;
  }

  // ========== GOALS ANALYTICS ==========
  Map<String, dynamic> _getGoalsProgress() {
    final goals = _allData['goals']!;
    if (goals.isEmpty) return {'total': 0, 'completed': 0, 'rate': 0.0};

    int totalGoals = goals.length;
    int completedGoals = goals.where((g) => g['isCompleted'] == true).length;
    double completionRate = completedGoals / totalGoals * 100;

    return {
      'total': totalGoals,
      'completed': completedGoals,
      'rate': completionRate,
    };
  }

  // ========== OVERALL HEALTH SCORE ==========
  int _getOverallHealthScore() {
    final sleepScore = (_getAverageSleepQuality() / 5 * 100);
    final exerciseScore = math.min(_getExerciseFrequency() / 3 * 100, 100);
    final stressScore = math.max(0, 100 - (_getAverageStressLevel() / 5 * 100));
    final nutritionScore = _getNutritionScore();
    final consistencyScore = _getSleepConsistencyScore().toDouble();

    final overallScore = (sleepScore +
            exerciseScore +
            stressScore +
            nutritionScore +
            consistencyScore) /
        5;
    return overallScore.round();
  }

  String _getHealthStatus() {
    final score = _getOverallHealthScore();
    if (score >= 80) return _isLaoLanguage ? 'ດີເລີດ' : 'Excellent';
    if (score >= 60) return _isLaoLanguage ? 'ດີ' : 'Good';
    if (score >= 40) return _isLaoLanguage ? 'ປົກກະຕິ' : 'Fair';
    return _isLaoLanguage ? 'ຕ້ອງປັບປຸງ' : 'Needs Improvement';
  }

  Color _getHealthStatusColor() {
    final score = _getOverallHealthScore();
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _isLaoLanguage ? 'ສະຫຼູບຜົນ' : 'Summary',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLaoLanguage = !_isLaoLanguage;
              });
            },
            icon: Text(
              _isLaoLanguage ? 'EN' : 'ລາວ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 7,
                child: Text(_isLaoLanguage ? '7 ວັນ' : '7 Days'),
              ),
              PopupMenuItem(
                value: 30,
                child: Text(_isLaoLanguage ? '30 ວັນ' : '30 Days'),
              ),
              PopupMenuItem(
                value: 90,
                child: Text(_isLaoLanguage ? '90 ວັນ' : '90 Days'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFE91E63),
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard),
              text: _isLaoLanguage ? 'ສະຫຼຸບ' : 'Overview',
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: _isLaoLanguage ? 'ວິເຄາະ' : 'Analytics',
            ),
            Tab(
              icon: const Icon(Icons.trending_up),
              text: _isLaoLanguage ? 'ແນວໂນ້ມ' : 'Trends',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalyticsTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall health status with score
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getHealthStatusColor(),
                    _getHealthStatusColor().withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getHealthStatusColor().withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: _getOverallHealthScore() / 100,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 6,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${_getOverallHealthScore()}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            '%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLaoLanguage
                        ? 'ສະຖານະສຸຂະພາບໂດຍລວມ'
                        : 'Overall Health Status',
                    style: const TextStyle(
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
                  Text(
                    _isLaoLanguage
                        ? 'ຈາກຂໍ້ມູນ $_selectedPeriod ວັນທີ່ຜ່ານມາ'
                        : 'Based on last $_selectedPeriod days',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildCompactStatCard(
                  title: _isLaoLanguage ? 'ການນອນ' : 'Sleep',
                  value: '${_getAverageSleepHours().toStringAsFixed(1)}h',
                  subtitle: _isLaoLanguage
                      ? 'ຄຸນນະພາບ ${_getAverageSleepQuality().toStringAsFixed(1)}/5'
                      : 'Quality ${_getAverageSleepQuality().toStringAsFixed(1)}/5',
                  icon: Icons.bedtime,
                  color: Colors.purple,
                  progress: _getAverageSleepQuality() / 5,
                ),
                _buildCompactStatCard(
                  title: _isLaoLanguage ? 'ອອກກຳລັງ' : 'Exercise',
                  value: '${_getExerciseCount()}',
                  subtitle:
                      '${_getTotalExerciseMinutes()} ${_isLaoLanguage ? 'ນາທີ' : 'min'}',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                  progress: math.min(_getExerciseFrequency() / 3, 1.0),
                ),
                _buildCompactStatCard(
                  title: _isLaoLanguage ? 'ຄວາມຄຽດ' : 'Stress',
                  value: '${_getAverageStressLevel().toStringAsFixed(1)}/5',
                  subtitle: _isLaoLanguage ? 'ເສຍງສະເລ່ຍ' : 'Average',
                  icon: Icons.psychology,
                  color: _getAverageStressLevel() <= 2
                      ? Colors.green
                      : _getAverageStressLevel() <= 3
                          ? Colors.orange
                          : Colors.red,
                  progress: 1 - (_getAverageStressLevel() / 5),
                ),
                _buildCompactStatCard(
                  title: _isLaoLanguage ? 'ໂພຊະນາການ' : 'Nutrition',
                  value: '${_getNutritionScore().toStringAsFixed(0)}%',
                  subtitle:
                      '${_getMealsCount()} ${_isLaoLanguage ? 'ມື້' : 'meals'}',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                  progress: _getNutritionScore() / 100,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Goals progress
            _buildGoalsProgress(),

            const SizedBox(height: 24),

            // AI-powered insights
            _buildInsightsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sleep analysis
          _buildAnalysisCard(
            title: _isLaoLanguage ? 'ການວິເຄາະການນອນ' : 'Sleep Analysis',
            icon: Icons.bedtime,
            color: Colors.purple,
            children: [
              _buildAnalysisItem(
                _isLaoLanguage ? 'ຄວາມສອດຄ່ອງ' : 'Consistency',
                '${_getSleepConsistencyScore()}%',
                Icons.schedule,
              ),
              _buildAnalysisItem(
                _isLaoLanguage ? 'ຊົ່ວໂມງເສຍງ' : 'Avg Hours',
                '${_getAverageSleepHours().toStringAsFixed(1)}h',
                Icons.access_time,
              ),
              _buildAnalysisItem(
                _isLaoLanguage ? 'ຄຸນນະພາບ' : 'Quality',
                '${_getAverageSleepQuality().toStringAsFixed(1)}/5',
                Icons.star,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Exercise breakdown
          _buildAnalysisCard(
            title:
                _isLaoLanguage ? 'ການວິເຄາະການອອກກຳລັງ' : 'Exercise Analysis',
            icon: Icons.fitness_center,
            color: Colors.blue,
            children: [
              _buildAnalysisItem(
                _isLaoLanguage ? 'ຄວາມຖີ່' : 'Frequency',
                '${_getExerciseFrequency().toStringAsFixed(1)}/week',
                Icons.repeat,
              ),
              _buildAnalysisItem(
                _isLaoLanguage ? 'ລວມເວລາ' : 'Total Time',
                '${_getTotalExerciseMinutes()}m',
                Icons.timer,
              ),
              // Exercise types breakdown
              ..._buildExerciseTypesList(),
            ],
          ),

          const SizedBox(height: 16),

          // Stress analysis
          _buildAnalysisCard(
            title: _isLaoLanguage ? 'ການວິເຄາະຄວາມຄຽດ' : 'Stress Analysis',
            icon: Icons.psychology,
            color: Colors.red,
            children: [
              _buildAnalysisItem(
                _isLaoLanguage ? 'ລະດັບເສຍງ' : 'Avg Level',
                '${_getAverageStressLevel().toStringAsFixed(1)}/5',
                Icons.trending_up,
              ),
              // Top stress triggers
              ..._buildStressTriggersList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health score trend
          _buildTrendCard(
            title:
                _isLaoLanguage ? 'ແນວໂນ້ມຄະແນນສຸຂະພາບ' : 'Health Score Trend',
            value: '${_getOverallHealthScore()}%',
            color: _getHealthStatusColor(),
            children: [
              Container(
                height: 100,
                child: _buildHealthScoreChart(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stress trend
          if (_getStressTrend().isNotEmpty)
            _buildTrendCard(
              title: _isLaoLanguage ? 'ແນວໂນ້ມຄວາມຄຽດ' : 'Stress Trend',
              value: '${_getAverageStressLevel().toStringAsFixed(1)}/5',
              color: Colors.red,
              children: [
                Container(
                  height: 100,
                  child: _buildStressTrendChart(),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Weekly patterns
          _buildPatternsCard(),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              // Mini progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgress() {
    final goalsData = _getGoalsProgress();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              Text(
                _isLaoLanguage ? 'ຄວາມກ້າວໜ້າເປົ້າຫມາຍ' : 'Goals Progress',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${goalsData['completed']}/${goalsData['total']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Text(
                      _isLaoLanguage ? 'ສຳເລັດ' : 'Completed',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${goalsData['rate'].toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Text(
                      _isLaoLanguage ? 'ອັດຕາສຳເລັດ' : 'Success Rate',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: goalsData['rate'] / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE91E63)),
                        strokeWidth: 4,
                      ),
                    ),
                    Text(
                      '${goalsData['rate'].toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                _isLaoLanguage ? 'AI ຄຳແນະນຳ' : 'AI Insights',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getAIInsights().map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      insight['icon'],
                      size: 16,
                      color: insight['color'],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight['text'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAIInsights() {
    List<Map<String, dynamic>> insights = [];

    // Sleep insights
    final sleepHours = _getAverageSleepHours();
    final sleepQuality = _getAverageSleepQuality();
    final consistency = _getSleepConsistencyScore();

    if (sleepHours < 7) {
      insights.add({
        'text': _isLaoLanguage
            ? 'ເພີ່ມເວລານອນ ${(7 - sleepHours).toStringAsFixed(1)} ຊົ່ວໂມງ ເພື່ອສຸຂະພາບທີ່ດີຂຶ້ນ'
            : 'Increase sleep by ${(7 - sleepHours).toStringAsFixed(1)} hours for better health',
        'icon': Icons.bedtime,
        'color': Colors.purple,
      });
    }

    if (consistency < 70) {
      insights.add({
        'text': _isLaoLanguage
            ? 'ສ້າງລູປະຈຳວັນການນອນທີ່ສະຫມໍ່າສະເຫມີ ເພື່ອປັບປຸງຄຸນນະພາບ'
            : 'Create a consistent sleep schedule to improve quality',
        'icon': Icons.schedule,
        'color': Colors.purple,
      });
    }

    // Exercise insights
    final exerciseFreq = _getExerciseFrequency();
    if (exerciseFreq < 3) {
      final needed = (3 - exerciseFreq).ceil();
      insights.add({
        'text': _isLaoLanguage
            ? 'ເພີ່ມການອອກກຳລັງ $needed ຄັ້ງຕໍ່ອາທິດ ເພື່ອບັນລຸເປົ້າຫມາຍ'
            : 'Add $needed more workout sessions per week to reach goals',
        'icon': Icons.fitness_center,
        'color': Colors.blue,
      });
    }

    // Stress insights
    final stressLevel = _getAverageStressLevel();
    if (stressLevel > 3) {
      final topTrigger = _getStressTriggers().entries.isEmpty
          ? null
          : _getStressTriggers()
              .entries
              .reduce((a, b) => a.value > b.value ? a : b);

      if (topTrigger != null) {
        insights.add({
          'text': _isLaoLanguage
              ? 'ຄວາມຄຽດຫຼັກມາຈາກ "${topTrigger.key}" - ລອງໃຊ້ເທັກນິກຜ່ອນຄາຍ'
              : 'Main stress source: "${topTrigger.key}" - try relaxation techniques',
          'icon': Icons.self_improvement,
          'color': Colors.red,
        });
      }
    }

    // Positive reinforcement
    if (insights.isEmpty || _getOverallHealthScore() > 70) {
      insights.add({
        'text': _isLaoLanguage
            ? 'ສຸຂະພາບຂອງເຈົ້າຢູ່ໃນເສັ້ນທາງທີ່ດີ! ສືບຕໍ່ຮັກສາແບບນີ້'
            : 'Your health is on track! Keep up the great work',
        'icon': Icons.emoji_emotions,
        'color': Colors.green,
      });
    }

    return insights;
  }

  Widget _buildAnalysisCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExerciseTypesList() {
    final exerciseTypes = _getExerciseByType();
    return exerciseTypes.entries.take(3).map((entry) {
      return _buildAnalysisItem(
        entry.key,
        '${entry.value} ${_isLaoLanguage ? 'ຄັ້ງ' : 'times'}',
        Icons.sports,
      );
    }).toList();
  }

  List<Widget> _buildStressTriggersList() {
    final triggers = _getStressTriggers();
    return triggers.entries.take(3).map((entry) {
      return _buildAnalysisItem(
        entry.key,
        '${entry.value} ${_isLaoLanguage ? 'ຄັ້ງ' : 'times'}',
        Icons.warning,
      );
    }).toList();
  }

  Widget _buildTrendCard({
    required String title,
    required String value,
    required Color color,
    required List<Widget> children,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHealthScoreChart() {
    // Simulate daily health scores for the selected period
    List<double> scores = [];
    for (int i = 0; i < math.min(_selectedPeriod, 30); i++) {
      // Generate realistic health score variations
      final baseScore = _getOverallHealthScore().toDouble();
      final variation = (math.Random().nextDouble() - 0.5) * 20;
      scores.add(math.max(0, math.min(100, baseScore + variation)));
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _LineChartPainter(scores, Colors.green),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildStressTrendChart() {
    final stressTrend = _getStressTrend();
    if (stressTrend.isEmpty) return Container();

    List<double> stressLevels =
        stressTrend.map((e) => e['level'] as double).toList();

    return Container(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _LineChartPainter(stressLevels, Colors.red),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildPatternsCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLaoLanguage ? 'ຮູບແບບອາທິດ' : 'Weekly Patterns',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeeklyPattern(),
        ],
      ),
    );
  }

  Widget _buildWeeklyPattern() {
    // Calculate activity by day of week
    Map<int, Map<String, int>> weeklyData = {};
    for (int i = 1; i <= 7; i++) {
      weeklyData[i] = {'exercise': 0, 'sleep': 0, 'stress': 0};
    }

    // Process exercise data
    for (var record in _getRecentData(_allData['exercise']!, _selectedPeriod)) {
      final date = DateTime.parse(record['date']);
      weeklyData[date.weekday]!['exercise'] =
          (weeklyData[date.weekday]!['exercise']! + 1);
    }

    // Process sleep data
    for (var record in _getRecentData(_allData['sleep']!, _selectedPeriod)) {
      final date = DateTime.parse(record['date']);
      weeklyData[date.weekday]!['sleep'] =
          (weeklyData[date.weekday]!['sleep']! + 1);
    }

    // Process stress data
    for (var record in _getRecentData(_allData['stress']!, _selectedPeriod)) {
      final date = DateTime.parse(record['date']);
      if ((record['stressLevel'] as int) > 3) {
        weeklyData[date.weekday]!['stress'] =
            (weeklyData[date.weekday]!['stress']! + 1);
      }
    }

    final dayNames = _isLaoLanguage
        ? ['ຈັນ', 'ອັງຄານ', 'ພຸດ', 'ພະຫັດ', 'ສຸກ', 'ເສົາ', 'ອາທິດ']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: List.generate(7, (index) {
        final dayData = weeklyData[index + 1]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  dayNames[index],
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    // Exercise indicator
                    Container(
                      width: 20 + (dayData['exercise']! * 4.0),
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Sleep indicator
                    Container(
                      width: 20 + (dayData['sleep']! * 4.0),
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Stress indicator
                    Container(
                      width: 20 + (dayData['stress']! * 4.0),
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxValue = data.reduce(math.max);
    final minValue = data.reduce(math.min);
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
