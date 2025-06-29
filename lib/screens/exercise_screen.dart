import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with TickerProviderStateMixin {
  String _selectedExercise = 'ແລ່ນ';
  int _duration = 30;
  int _intensity = 3;
  int _calories = 0;
  String _notes = '';
  List<Map<String, dynamic>> _exerciseRecords = [];

  // Real-time workout tracking
  bool _isWorkoutActive = false;
  DateTime? _workoutStartTime;
  Timer? _workoutTimer;
  int _currentWorkoutSeconds = 0;

  // Goals and stats
  int _weeklyGoal = 150; // minutes per week

  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'ແລ່ນ',
      'icon': Icons.directions_run,
      'color': Colors.blue,
      'calories': 10
    },
    {
      'name': 'ເດີນ',
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'calories': 4
    },
    {
      'name': 'ໂຢຄະ',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
      'calories': 3
    },
    {
      'name': 'ຖີບດິນ',
      'icon': Icons.fitness_center,
      'color': Colors.red,
      'calories': 8
    },
    {
      'name': 'ຫຼີ້ນກີລາ',
      'icon': Icons.sports,
      'color': Colors.orange,
      'calories': 12
    },
    {
      'name': 'ລອຍນ້ຳ',
      'icon': Icons.pool,
      'color': Colors.cyan,
      'calories': 11
    },
    {
      'name': 'ປັ່ນລົດຖິບ',
      'icon': Icons.directions_bike,
      'color': Colors.indigo,
      'calories': 9
    },
    {
      'name': 'ຍົກນ້ຳໜັກ',
      'icon': Icons.fitness_center,
      'color': Colors.brown,
      'calories': 6
    },
  ];

  // Quick workout templates with editable durations
  List<Map<String, dynamic>> _workoutTemplates = [
    {
      'name': 'ເຊົ້າໄວ',
      'exercises': ['ແລ່ນ'],
      'duration': 20,
      'description': 'ແລ່ນເບົາໆ'
    },
    {
      'name': 'ຄາດິໂອ',
      'exercises': ['ແລ່ນ', 'ຖີບດິນ'],
      'duration': 30,
      'description': 'ແລ່ນ + ຖີບດິນ'
    },
    {
      'name': 'ແຂງແຮງ',
      'exercises': ['ຍົກນ້ຳໜັກ', 'ຖີບດິນ'],
      'duration': 45,
      'description': 'ຝຶກຄວາມແຂງແຮງ'
    },
    {
      'name': 'ຜ່ອນຄາຍ',
      'exercises': ['ຢູຄະ', 'ເດີນ'],
      'duration': 25,
      'description': 'ຢູຄະ + ເດີນ'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadExerciseData();
    _calculateCalories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _workoutTimer?.cancel();
    super.dispose();
  }

  void _calculateCalories() {
    final exercise = _exercises.firstWhere(
      (e) => e['name'] == _selectedExercise,
      orElse: () => {'calories': 5},
    );
    setState(() {
      _calories = (exercise['calories'] * _duration * _intensity / 3).round();
    });
  }

  Future<void> _loadExerciseData() async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseData = prefs.getString('exercise_records');
    final weeklyGoalData = prefs.getInt('weekly_goal');
    final templatesData = prefs.getString('workout_templates');

    if (exerciseData != null) {
      setState(() {
        _exerciseRecords =
            List<Map<String, dynamic>>.from(jsonDecode(exerciseData));
      });
    }

    if (weeklyGoalData != null) {
      setState(() {
        _weeklyGoal = weeklyGoalData;
      });
    }

    if (templatesData != null) {
      setState(() {
        _workoutTemplates =
            List<Map<String, dynamic>>.from(jsonDecode(templatesData));
      });
    }
  }

  Future<void> _saveWorkoutTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_templates', jsonEncode(_workoutTemplates));
  }

  Future<void> _saveExerciseRecord() async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'exercise': _selectedExercise,
      'duration': _duration,
      'intensity': _intensity,
      'calories': _calories,
      'notes': _notes,
      'isCompleted': true,
    };

    setState(() {
      _exerciseRecords.insert(0, record);
      _notes = '';
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exercise_records', jsonEncode(_exerciseRecords));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ບັນທຶກການອອກກຳລັງກາຍສຳເລັດ! 🔥 $_calories Cal'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _startWorkout(Map<String, dynamic>? template) {
    if (template != null) {
      setState(() {
        _selectedExercise = template['exercises'][0];
        _duration = template['duration'];
      });
      _calculateCalories();
    }

    setState(() {
      _isWorkoutActive = true;
      _workoutStartTime = DateTime.now();
      _currentWorkoutSeconds = 0;
    });

    _workoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_workoutStartTime != null && _isWorkoutActive) {
        final elapsed = DateTime.now().difference(_workoutStartTime!).inSeconds;
        setState(() {
          _currentWorkoutSeconds = elapsed;
        });
      }
    });

    _pulseController.repeat(reverse: true);
  }

  void _pauseWorkout() {
    if (_isWorkoutActive) {
      _workoutTimer?.cancel();
      _pulseController.stop();
    } else {
      // Resume - recalculate from start time
      _workoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_workoutStartTime != null && _isWorkoutActive) {
          final elapsed =
              DateTime.now().difference(_workoutStartTime!).inSeconds;
          setState(() {
            _currentWorkoutSeconds = elapsed;
          });
        }
      });
      _pulseController.repeat(reverse: true);
    }
    setState(() {
      _isWorkoutActive = !_isWorkoutActive;
    });
  }

  void _stopWorkout() {
    _workoutTimer?.cancel();

    if (_workoutStartTime != null && _currentWorkoutSeconds > 60) {
      final actualDuration = (_currentWorkoutSeconds / 60).round();
      setState(() {
        _duration = actualDuration > 0 ? actualDuration : 1;
      });
      _calculateCalories();

      // Auto-save if workout was longer than 2 minutes
      if (actualDuration >= 2) {
        _saveExerciseRecord();
      }
    }

    setState(() {
      _isWorkoutActive = false;
      _workoutStartTime = null;
      _currentWorkoutSeconds = 0;
    });

    _pulseController.stop();
    _pulseController.reset();
  }

  String _formatWorkoutTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Show dialog to edit workout template duration
  void _editTemplateDuration(int index) {
    final TextEditingController controller = TextEditingController(
      text: _workoutTemplates[index]['duration'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ແກ້ໄຂເວລາ ${_workoutTemplates[index]['name']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'ເວລາ (ນາທີ)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ຍົກເລີກ'),
          ),
          ElevatedButton(
            onPressed: () {
              final newDuration = int.tryParse(controller.text);
              if (newDuration != null && newDuration > 0) {
                setState(() {
                  _workoutTemplates[index]['duration'] = newDuration;
                });
                _saveWorkoutTemplates();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ປັບປຸງເວລາແລ້ວ!')),
                );
              }
            },
            child: Text('ບັນທຶກ'),
          ),
        ],
      ),
    );
  }

  int _getWeeklyMinutes() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _exerciseRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekStart) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    }).fold<int>(0, (sum, record) => sum + (record['duration'] as int));
  }

  int _getTodayMinutes() {
    final today = DateTime.now();
    return _exerciseRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day;
    }).fold<int>(0, (sum, record) => sum + (record['duration'] as int));
  }

  int _getTodayCalories() {
    final today = DateTime.now();
    return _exerciseRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day;
    }).fold<int>(0, (sum, record) => sum + (record['calories'] as int? ?? 0));
  }

  String _getIntensityText(int intensity) {
    switch (intensity) {
      case 1:
        return 'ເບົາໆ';
      case 2:
        return 'ປານກາງ';
      case 3:
        return 'ປົກກະຕິ';
      case 4:
        return 'ແຮງ';
      case 5:
        return 'ແຮງຫຼາຍ';
      default:
        return 'ປົກກະຕິ';
    }
  }

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
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

  Map<String, dynamic> _getExerciseInfo(String exerciseName) {
    return _exercises.firstWhere(
      (exercise) => exercise['name'] == exerciseName,
      orElse: () => {
        'name': exerciseName,
        'icon': Icons.fitness_center,
        'color': Colors.grey,
        'calories': 5
      },
    );
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Live workout tracker - more compact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isWorkoutActive
                    ? [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]
                    : [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_isWorkoutActive ? Colors.red : Colors.teal)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isWorkoutActive
                                  ? _pulseAnimation.value
                                  : 1.0,
                              child: Icon(
                                _isWorkoutActive
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Colors.white,
                                size: 28,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _workoutStartTime != null
                                  ? _selectedExercise
                                  : 'ເລີ່ມອອກກຳລັງກາຍ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_workoutStartTime != null)
                              Text(
                                _formatWorkoutTime(_currentWorkoutSeconds),
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    if (_workoutStartTime != null) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pauseWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                              _isWorkoutActive ? 'ຢຸດຊົ່ວຄາວ' : 'ສືບຕໍ່',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _stopWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text('ຢຸດ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _startWorkout(null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text('ເລີ່ມ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Today's stats - more compact
          Row(
            children: [
              Expanded(
                  child: _buildCompactStatCard('ມື້ນີ້',
                      '${_getTodayMinutes()}m', Icons.timer, Colors.blue)),
              SizedBox(width: 8),
              Expanded(
                  child: _buildCompactStatCard('Cal', '${_getTodayCalories()}',
                      Icons.local_fire_department, Colors.orange)),
              SizedBox(width: 8),
              Expanded(
                  child: _buildCompactStatCard(
                      'ອາທິດ',
                      '${_getWeeklyMinutes()}m',
                      Icons.date_range,
                      Colors.purple)),
            ],
          ),
          SizedBox(height: 12),

          // Quick workouts - improved design with editable durations
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout ດ່ວນ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63)),
                ),
                SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: _workoutTemplates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final template = entry.value;
                    return GestureDetector(
                      onTap: () => _startWorkout(template),
                      onLongPress: () => _editTemplateDuration(index),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.1),
                              Colors.blue.withOpacity(0.05)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fitness_center,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    template['name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.blue[800]),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _editTemplateDuration(index),
                                  child: Icon(Icons.edit,
                                      color: Colors.blue, size: 14),
                                ),
                              ],
                            ),
                            Text(
                              '${template['duration']} ນາທີ',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Exercise input form - more compact
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ບັນທຶກແບບລະອຽດ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63)),
                ),
                SizedBox(height: 12),

                // Exercise selection grid - more compact
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                  children: _exercises.map((exercise) {
                    final isSelected = _selectedExercise == exercise['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedExercise = exercise['name'];
                        });
                        _calculateCalories();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? exercise['color'].withOpacity(0.2)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: exercise['color'], width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(exercise['icon'],
                                color: isSelected
                                    ? exercise['color']
                                    : Colors.grey,
                                size: 20),
                            SizedBox(height: 2),
                            Text(
                              exercise['name'],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? exercise['color']
                                    : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 12),

                // Duration and intensity - more compact
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ເວລາ (ນາທີ):',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _duration > 5
                                    ? () {
                                        setState(() => _duration -= 5);
                                        _calculateCalories();
                                      }
                                    : null,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _duration > 5
                                        ? Colors.red[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.remove,
                                      size: 16,
                                      color: _duration > 5
                                          ? Colors.red
                                          : Colors.grey),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 40,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE91E63).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text('$_duration',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE91E63),
                                          fontSize: 12)),
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: _duration < 180
                                    ? () {
                                        setState(() => _duration += 5);
                                        _calculateCalories();
                                      }
                                    : null,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _duration < 180
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.add,
                                      size: 16,
                                      color: _duration < 180
                                          ? Colors.green
                                          : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ຄວາມແຮງ:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12)),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (index) {
                              final intensity = index + 1;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _intensity = intensity);
                                  _calculateCalories();
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _intensity == intensity
                                        ? _getIntensityColor(intensity)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      intensity.toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _intensity == intensity
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Calories and notes
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department,
                              color: Colors.orange, size: 14),
                          SizedBox(width: 4),
                          Text('$_calories Cal',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => _notes = value,
                        decoration: InputDecoration(
                          hintText: 'ໝາຍເຫດ...',
                          hintStyle: TextStyle(fontSize: 11),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 11),
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
                    onPressed: _saveExerciseRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ບັນທຶກ',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final weeklyMinutes = _getWeeklyMinutes();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekly goal progress
          Container(
            padding: EdgeInsets.all(16),
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
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'ເປົ້າໝາຍອາທິດນີ້',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: weeklyMinutes / _weeklyGoal > 1.0
                            ? 1.0
                            : weeklyMinutes / _weeklyGoal,
                        strokeWidth: 8,
                        backgroundColor: Colors.green.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$weeklyMinutes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '/ $_weeklyGoal ນາທີ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Slider(
                  value: _weeklyGoal.toDouble(),
                  min: 75,
                  max: 300,
                  divisions: 15,
                  label: '$_weeklyGoal ນາທີ',
                  onChanged: (value) async {
                    setState(() {
                      _weeklyGoal = value.toInt();
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('weekly_goal', _weeklyGoal);
                  },
                ),
                Text(
                  'ກຳນົດເປົ້າໝາຍອາທິດ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Exercise distribution
          Container(
            padding: EdgeInsets.all(16),
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
                  'ການແຈກຢາຍການອອກກຳລັງກາຍ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ...(_getExerciseDistribution().entries.map((entry) {
                  final exerciseInfo = _getExerciseInfo(entry.key);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          exerciseInfo['icon'],
                          color: exerciseInfo['color'],
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: exerciseInfo['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value} ນາທີ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: exerciseInfo['color'],
                              fontSize: 12,
                            ),
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

          // Weekly summary
          Container(
            padding: EdgeInsets.all(16),
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
                  'ສະຖິຕິ 7 ວັນຜ່ານມາ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatCard(
                        'ຈຳນວນຄັ້ງ',
                        '${_getWeeklyWorkouts()}',
                        Icons.fitness_center,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactStatCard(
                        'Calories',
                        '${_getWeeklyCalories()}',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getExerciseDistribution() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final weeklyRecords = _exerciseRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekAgo) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    });

    final distribution = <String, int>{};
    for (final record in weeklyRecords) {
      final exercise = record['exercise'] as String;
      final duration = record['duration'] as int;
      distribution[exercise] = (distribution[exercise] ?? 0) + duration;
    }
    return distribution;
  }

  int _getWeeklyWorkouts() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return _exerciseRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekAgo) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    }).length;
  }

  int _getWeeklyCalories() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return _exerciseRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekAgo) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    }).fold<int>(0, (sum, record) => sum + (record['calories'] as int? ?? 0));
  }

  Widget _buildHistoryTab() {
    return _exerciseRecords.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'ຍັງບໍ່ມີຂໍ້ມູນການອອກກຳລັງກາຍ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ເລີ່ມອອກກຳລັງກາຍແລ້ວບັນທຶກກິດຈະກຳ!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _exerciseRecords.length,
            itemBuilder: (context, index) {
              final record = _exerciseRecords[index];
              final date = DateTime.parse(record['date']);
              final exerciseInfo = _getExerciseInfo(record['exercise']);
              final notes = record['notes'] as String? ?? '';

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
                      offset: const Offset(0, 1),
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
                            color: exerciseInfo['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            exerciseInfo['icon'],
                            color: exerciseInfo['color'],
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      record['exercise'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (record['calories'] != null &&
                                      record['calories'] > 0)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${record['calories']} Cal',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${record['duration']} ນາທີ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getIntensityColor(record['intensity'])
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getIntensityText(record['intensity']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      _getIntensityColor(record['intensity']),
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
                              _exerciseRecords.removeAt(index);
                            });
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('exercise_records',
                                  jsonEncode(_exerciseRecords));
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ລຶບບັນທຶກແລ້ວ'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    if (notes.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notes,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
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
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'ອອກກຳລັງກາຍ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFE91E63),
          tabs: [
            Tab(icon: Icon(Icons.add), text: 'ບັນທຶກ'),
            Tab(icon: Icon(Icons.analytics), text: 'ສະຖິຕິ'),
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





