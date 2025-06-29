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
  bool _isLoading = true;

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
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _allData['sleep'] = _getData(prefs, 'sleep_records');
        _allData['nutrition'] = _getData(prefs, 'nutrition_records');
        _allData['exercise'] = _getData(prefs, 'exercise_records');
        _allData['stress'] = _getData(prefs, 'stress_records');
        _allData['period'] = _getData(prefs, 'period_records');
        _allData['goals'] = _getData(prefs, 'user_goals');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading data: $e');
    }
  }

  List<Map<String, dynamic>> _getData(SharedPreferences prefs, String key) {
    try {
      final data = prefs.getString(key);
      if (data != null && data.isNotEmpty) {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      }
    } catch (e) {
      debugPrint('Error parsing data for $key: $e');
    }
    return [];
  }

  List<Map<String, dynamic>> _getRecentData(
    List<Map<String, dynamic>> data,
    int days,
  ) {
    if (data.isEmpty) return [];

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return data.where((record) {
        try {
          final dateStr = record['date'] ??
              record['startDate'] ??
              DateTime.now().toIso8601String();
          final date = DateTime.parse(dateStr);
          return date.isAfter(cutoffDate);
        } catch (e) {
          debugPrint('Error parsing date: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('Error filtering recent data: $e');
      return [];
    }
  }

  // ========== SLEEP ANALYTICS ==========
  double _getAverageSleepHours() {
    try {
      final recentSleep = _getRecentData(_allData['sleep']!, _selectedPeriod);
      if (recentSleep.isEmpty) return 0;

      double totalHours = 0;
      int validRecords = 0;

      for (var record in recentSleep) {
        try {
          final duration = record['duration'];
          if (duration != null) {
            if (duration is num) {
              totalHours += duration.toDouble();
              validRecords++;
            } else if (duration is String) {
              // Handle "8h 30m" format
              final parts = duration.split('h ');
              if (parts.length == 2) {
                final hours = int.tryParse(parts[0]) ?? 0;
                final minutes = int.tryParse(parts[1].replaceAll('m', '')) ?? 0;
                totalHours += hours + (minutes / 60);
                validRecords++;
              } else {
                // Handle simple hour format
                final hours = double.tryParse(
                        duration.replaceAll('h', '').replaceAll('m', '')) ??
                    0;
                totalHours += hours;
                validRecords++;
              }
            }
          }
        } catch (e) {
          debugPrint('Error parsing sleep duration: $e');
        }
      }

      return validRecords > 0 ? totalHours / validRecords : 0;
    } catch (e) {
      debugPrint('Error calculating average sleep hours: $e');
      return 0;
    }
  }

  double _getAverageSleepQuality() {
    try {
      final recentSleep = _getRecentData(_allData['sleep']!, _selectedPeriod);
      if (recentSleep.isEmpty) return 0;

      int totalQuality = 0;
      int validRecords = 0;

      for (var record in recentSleep) {
        try {
          final quality = record['quality'];
          if (quality != null && quality is num) {
            totalQuality += quality.toInt();
            validRecords++;
          }
        } catch (e) {
          debugPrint('Error parsing sleep quality: $e');
        }
      }

      return validRecords > 0 ? totalQuality / validRecords : 0;
    } catch (e) {
      debugPrint('Error calculating average sleep quality: $e');
      return 0;
    }
  }

  int _getSleepConsistencyScore() {
    try {
      final recentSleep = _getRecentData(_allData['sleep']!, _selectedPeriod);
      if (recentSleep.length < 3) return 0;

      List<DateTime> bedtimes = [];
      for (var record in recentSleep) {
        try {
          final bedtimeStr = record['bedtime'] ?? record['date'];
          if (bedtimeStr != null) {
            final bedtime = DateTime.parse(bedtimeStr);
            bedtimes.add(bedtime);
          }
        } catch (e) {
          debugPrint('Error parsing bedtime: $e');
        }
      }

      if (bedtimes.length < 2) return 0;

      // Calculate variance in sleep times
      double totalVariance = 0;
      for (int i = 1; i < bedtimes.length; i++) {
        final diff = bedtimes[i].difference(bedtimes[i - 1]).inMinutes.abs();
        totalVariance += diff;
      }

      final avgVariance = totalVariance / (bedtimes.length - 1);
      return math.max(0, (100 - (avgVariance / 60 * 20)).round());
    } catch (e) {
      debugPrint('Error calculating sleep consistency: $e');
      return 0;
    }
  }

  // ========== EXERCISE ANALYTICS ==========
  int _getExerciseCount() {
    try {
      return _getRecentData(_allData['exercise']!, _selectedPeriod).length;
    } catch (e) {
      debugPrint('Error getting exercise count: $e');
      return 0;
    }
  }

  int _getTotalExerciseMinutes() {
    try {
      final recentExercise =
          _getRecentData(_allData['exercise']!, _selectedPeriod);
      int totalMinutes = 0;

      for (var record in recentExercise) {
        try {
          final duration = record['duration'];
          if (duration != null && duration is num) {
            totalMinutes += duration.toInt();
          }
        } catch (e) {
          debugPrint('Error parsing exercise duration: $e');
        }
      }

      return totalMinutes;
    } catch (e) {
      debugPrint('Error calculating total exercise minutes: $e');
      return 0;
    }
  }

  double _getExerciseFrequency() {
    try {
      final exerciseCount = _getExerciseCount();
      final weeks = _selectedPeriod / 7;
      return weeks > 0 ? exerciseCount / weeks : 0;
    } catch (e) {
      debugPrint('Error calculating exercise frequency: $e');
      return 0;
    }
  }

  Map<String, int> _getExerciseByType() {
    try {
      final recentExercise =
          _getRecentData(_allData['exercise']!, _selectedPeriod);
      Map<String, int> typeCount = {};

      for (var record in recentExercise) {
        try {
          final type = record['type']?.toString() ?? 'Unknown';
          typeCount[type] = (typeCount[type] ?? 0) + 1;
        } catch (e) {
          debugPrint('Error parsing exercise type: $e');
        }
      }

      return typeCount;
    } catch (e) {
      debugPrint('Error getting exercise by type: $e');
      return {};
    }
  }

  // ========== STRESS ANALYTICS ==========
  double _getAverageStressLevel() {
    try {
      final recentStress = _getRecentData(_allData['stress']!, _selectedPeriod);
      if (recentStress.isEmpty) return 0;

      int totalStress = 0;
      int validRecords = 0;

      for (var record in recentStress) {
        try {
          final stressLevel = record['stressLevel'];
          if (stressLevel != null && stressLevel is num) {
            totalStress += stressLevel.toInt();
            validRecords++;
          }
        } catch (e) {
          debugPrint('Error parsing stress level: $e');
        }
      }

      return validRecords > 0 ? totalStress / validRecords : 0;
    } catch (e) {
      debugPrint('Error calculating average stress level: $e');
      return 0;
    }
  }

  Map<String, int> _getStressTriggers() {
    try {
      final recentStress = _getRecentData(_allData['stress']!, _selectedPeriod);
      Map<String, int> triggers = {};

      for (var record in recentStress) {
        try {
          final cause = record['cause']?.toString() ?? 'Unknown';
          triggers[cause] = (triggers[cause] ?? 0) + 1;
        } catch (e) {
          debugPrint('Error parsing stress cause: $e');
        }
      }

      return triggers;
    } catch (e) {
      debugPrint('Error getting stress triggers: $e');
      return {};
    }
  }

  List<Map<String, dynamic>> _getStressTrend() {
    try {
      final recentStress = _getRecentData(_allData['stress']!, _selectedPeriod);
      Map<String, List<int>> dailyStress = {};

      for (var record in recentStress) {
        try {
          final dateStr = record['date'];
          final stressLevel = record['stressLevel'];

          if (dateStr != null && stressLevel != null && stressLevel is num) {
            final date = DateTime.parse(dateStr);
            final dateKey = '${date.day}/${date.month}';
            dailyStress[dateKey] = dailyStress[dateKey] ?? [];
            dailyStress[dateKey]!.add(stressLevel.toInt());
          }
        } catch (e) {
          debugPrint('Error parsing stress trend data: $e');
        }
      }

      List<Map<String, dynamic>> trend = [];
      dailyStress.forEach((date, levels) {
        if (levels.isNotEmpty) {
          final avg = levels.reduce((a, b) => a + b) / levels.length;
          trend.add({'date': date, 'level': avg});
        }
      });

      return trend
        ..sort((a, b) => a['date'].toString().compareTo(b['date'].toString()));
    } catch (e) {
      debugPrint('Error getting stress trend: $e');
      return [];
    }
  }

  // ========== NUTRITION ANALYTICS ==========
  int _getMealsCount() {
    try {
      return _getRecentData(_allData['nutrition']!, _selectedPeriod).length;
    } catch (e) {
      debugPrint('Error getting meals count: $e');
      return 0;
    }
  }

  double _getNutritionScore() {
    try {
      final recentNutrition =
          _getRecentData(_allData['nutrition']!, _selectedPeriod);
      if (recentNutrition.isEmpty) return 0;

      double totalScore = 0;
      int validRecords = 0;

      for (var record in recentNutrition) {
        try {
          int score = 0;
          if (record['hasProtein'] == true) score += 25;
          if (record['hasVegetables'] == true) score += 25;
          if (record['hasCarbs'] == true) score += 25;

          final waterIntake = record['waterIntake'];
          if (waterIntake != null && waterIntake is num && waterIntake > 0) {
            score += 25;
          }

          totalScore += score;
          validRecords++;
        } catch (e) {
          debugPrint('Error parsing nutrition record: $e');
        }
      }

      return validRecords > 0 ? totalScore / validRecords : 0;
    } catch (e) {
      debugPrint('Error calculating nutrition score: $e');
      return 0;
    }
  }

  // ========== GOALS ANALYTICS ==========
  Map<String, dynamic> _getGoalsProgress() {
    try {
      final goals = _allData['goals']!;
      if (goals.isEmpty) return {'total': 0, 'completed': 0, 'rate': 0.0};

      int totalGoals = goals.length;
      int completedGoals = 0;

      for (var goal in goals) {
        try {
          if (goal['isCompleted'] == true || goal['completed'] == true) {
            completedGoals++;
          }
        } catch (e) {
          debugPrint('Error checking goal completion: $e');
        }
      }

      double completionRate =
          totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0.0;

      return {
        'total': totalGoals,
        'completed': completedGoals,
        'rate': completionRate,
      };
    } catch (e) {
      debugPrint('Error getting goals progress: $e');
      return {'total': 0, 'completed': 0, 'rate': 0.0};
    }
  }

  // ========== OVERALL HEALTH SCORE ==========
  int _getOverallHealthScore() {
    try {
      final sleepQuality = _getAverageSleepQuality();
      final sleepScore = sleepQuality > 0 ? (sleepQuality / 5 * 100) : 0;

      final exerciseFreq = _getExerciseFrequency();
      final exerciseScore = math.min(exerciseFreq / 3 * 100, 100);

      final stressLevel = _getAverageStressLevel();
      final stressScore =
          stressLevel > 0 ? math.max(0, 100 - (stressLevel / 5 * 100)) : 80;

      final nutritionScore = _getNutritionScore();
      final consistencyScore = _getSleepConsistencyScore().toDouble();

      final scores = [
        sleepScore,
        exerciseScore,
        stressScore,
        nutritionScore,
        consistencyScore
      ];
      final validScores = scores.where((score) => score > 0).toList();

      if (validScores.isEmpty) return 50; // Default score if no data

      final overallScore =
          validScores.reduce((a, b) => a + b) / validScores.length;
      return math.max(0, math.min(100, overallScore.round()));
    } catch (e) {
      debugPrint('Error calculating overall health score: $e');
      return 50;
    }
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
            )
          : TabBarView(
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
                  progress: _getAverageSleepQuality() > 0
                      ? _getAverageSleepQuality() / 5
                      : 0,
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
                  progress: _getAverageStressLevel() > 0
                      ? 1 - (_getAverageStressLevel() / 5)
                      : 0.8,
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
                      value: math.max(0, math.min(1, progress)),
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
                        value: (goalsData['rate'] as double) / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE91E63)),
                        strokeWidth: 4,
                      ),
                    ),
                    Text(
                      '${(goalsData['rate'] as double).toStringAsFixed(0)}%',
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

    try {
      // Sleep insights
      final sleepHours = _getAverageSleepHours();
      final sleepQuality = _getAverageSleepQuality();
      final consistency = _getSleepConsistencyScore();

      if (sleepHours > 0 && sleepHours < 7) {
        insights.add({
          'text': _isLaoLanguage
              ? 'ເພີ່ມເວລານອນ ${(7 - sleepHours).toStringAsFixed(1)} ຊົ່ວໂມງ ເພື່ອສຸຂະພາບທີ່ດີຂຶ້ນ'
              : 'Increase sleep by ${(7 - sleepHours).toStringAsFixed(1)} hours for better health',
          'icon': Icons.bedtime,
          'color': Colors.purple,
        });
      }

      if (consistency > 0 && consistency < 70) {
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
      if (exerciseFreq > 0 && exerciseFreq < 3) {
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
        final triggers = _getStressTriggers();
        if (triggers.isNotEmpty) {
          final topTrigger =
              triggers.entries.reduce((a, b) => a.value > b.value ? a : b);

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

      // Default insight if no data
      if (insights.isEmpty) {
        insights.add({
          'text': _isLaoLanguage
              ? 'ເລີ່ມບັນທຶກຂໍ້ມູນສຸຂະພາບເພື່ອໄດ້ຮັບຄຳແນະນຳ AI'
              : 'Start logging health data to receive AI insights',
          'icon': Icons.lightbulb,
          'color': Colors.blue,
        });
      }
    } catch (e) {
      debugPrint('Error generating AI insights: $e');
      // Return default insight
      insights.add({
        'text': _isLaoLanguage
            ? 'ສຸຂະພາບຂອງເຈົ້າສຳຄັນ - ສືບຕໍ່ຮັກສາຕົວເອງໃຫ້ດີ!'
            : 'Your health matters - keep taking care of yourself!',
        'icon': Icons.favorite,
        'color': Colors.red,
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
    try {
      final exerciseTypes = _getExerciseByType();
      if (exerciseTypes.isEmpty) {
        return [
          _buildAnalysisItem(
            _isLaoLanguage ? 'ບໍ່ມີຂໍ້ມູນ' : 'No data',
            '-',
            Icons.info,
          ),
        ];
      }

      return exerciseTypes.entries.take(3).map((entry) {
        return _buildAnalysisItem(
          entry.key,
          '${entry.value} ${_isLaoLanguage ? 'ຄັ້ງ' : 'times'}',
          Icons.sports,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error building exercise types list: $e');
      return [
        _buildAnalysisItem(
          _isLaoLanguage ? 'ຜິດພາດ' : 'Error',
          '-',
          Icons.error,
        ),
      ];
    }
  }

  List<Widget> _buildStressTriggersList() {
    try {
      final triggers = _getStressTriggers();
      if (triggers.isEmpty) {
        return [
          _buildAnalysisItem(
            _isLaoLanguage ? 'ບໍ່ມີຂໍ້ມູນ' : 'No data',
            '-',
            Icons.info,
          ),
        ];
      }

      return triggers.entries.take(3).map((entry) {
        return _buildAnalysisItem(
          entry.key,
          '${entry.value} ${_isLaoLanguage ? 'ຄັ້ງ' : 'times'}',
          Icons.warning,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error building stress triggers list: $e');
      return [
        _buildAnalysisItem(
          _isLaoLanguage ? 'ຜິດພາດ' : 'Error',
          '-',
          Icons.error,
        ),
      ];
    }
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
    try {
      // Simulate daily health scores for the selected period
      List<double> scores = [];
      final daysToShow = math.min(_selectedPeriod, 30);

      for (int i = 0; i < daysToShow; i++) {
        // Generate realistic health score variations
        final baseScore = _getOverallHealthScore().toDouble();
        final variation = (math.Random().nextDouble() - 0.5) * 20;
        scores.add(math.max(0, math.min(100, baseScore + variation)));
      }

      if (scores.isEmpty) {
        return Container(
          height: 100,
          child: Center(
            child: Text(
              _isLaoLanguage ? 'ບໍ່ມີຂໍ້ມູນ' : 'No data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          painter: _LineChartPainter(scores, _getHealthStatusColor()),
          size: Size.infinite,
        ),
      );
    } catch (e) {
      debugPrint('Error building health score chart: $e');
      return Container(
        height: 100,
        child: Center(
          child: Text(
            _isLaoLanguage ? 'ຜິດພາດໃນການສະແດງຜົນ' : 'Chart error',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
  }

  Widget _buildStressTrendChart() {
    try {
      final stressTrend = _getStressTrend();
      if (stressTrend.isEmpty) {
        return Container(
          height: 100,
          child: Center(
            child: Text(
              _isLaoLanguage ? 'ບໍ່ມີຂໍ້ມູນຄວາມຄຽດ' : 'No stress data',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }

      List<double> stressLevels =
          stressTrend.map((e) => (e['level'] as num).toDouble()).toList();

      return Container(
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          painter: _LineChartPainter(stressLevels, Colors.red),
          size: Size.infinite,
        ),
      );
    } catch (e) {
      debugPrint('Error building stress trend chart: $e');
      return Container(
        height: 100,
        child: Center(
          child: Text(
            _isLaoLanguage ? 'ຜິດພາດໃນການສະແດງຜົນ' : 'Chart error',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
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
    try {
      // Calculate activity by day of week
      Map<int, Map<String, int>> weeklyData = {};
      for (int i = 1; i <= 7; i++) {
        weeklyData[i] = {'exercise': 0, 'sleep': 0, 'stress': 0};
      }

      // Process exercise data
      final exerciseData =
          _getRecentData(_allData['exercise']!, _selectedPeriod);
      for (var record in exerciseData) {
        try {
          final dateStr = record['date'];
          if (dateStr != null) {
            final date = DateTime.parse(dateStr);
            weeklyData[date.weekday]!['exercise'] =
                (weeklyData[date.weekday]!['exercise']! + 1);
          }
        } catch (e) {
          debugPrint('Error processing exercise date: $e');
        }
      }

      // Process sleep data
      final sleepData = _getRecentData(_allData['sleep']!, _selectedPeriod);
      for (var record in sleepData) {
        try {
          final dateStr = record['date'];
          if (dateStr != null) {
            final date = DateTime.parse(dateStr);
            weeklyData[date.weekday]!['sleep'] =
                (weeklyData[date.weekday]!['sleep']! + 1);
          }
        } catch (e) {
          debugPrint('Error processing sleep date: $e');
        }
      }

      // Process stress data
      final stressData = _getRecentData(_allData['stress']!, _selectedPeriod);
      for (var record in stressData) {
        try {
          final dateStr = record['date'];
          final stressLevel = record['stressLevel'];
          if (dateStr != null && stressLevel != null && stressLevel is num) {
            final date = DateTime.parse(dateStr);
            if (stressLevel.toInt() > 3) {
              weeklyData[date.weekday]!['stress'] =
                  (weeklyData[date.weekday]!['stress']! + 1);
            }
          }
        } catch (e) {
          debugPrint('Error processing stress date: $e');
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
                        width: math.max(4, 20 + (dayData['exercise']! * 4.0)),
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Sleep indicator
                      Container(
                        width: math.max(4, 20 + (dayData['sleep']! * 4.0)),
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Stress indicator
                      Container(
                        width: math.max(4, 20 + (dayData['stress']! * 4.0)),
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
    } catch (e) {
      debugPrint('Error building weekly pattern: $e');
      return Container(
        child: Text(
          _isLaoLanguage
              ? 'ຜິດພາດໃນການສະແດງຮູບແບບອາທິດ'
              : 'Error displaying weekly pattern',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      final maxValue = data.isNotEmpty ? data.reduce(math.max) : 1.0;
      final minValue = data.isNotEmpty ? data.reduce(math.min) : 0.0;
      final range = maxValue - minValue;

      for (int i = 0; i < data.length; i++) {
        final x = (i / math.max(1, data.length - 1)) * size.width;
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
        final x = (i / math.max(1, data.length - 1)) * size.width;
        final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
        final y = size.height - (normalizedValue * size.height);
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }
    } catch (e) {
      debugPrint('Error painting chart: $e');
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


