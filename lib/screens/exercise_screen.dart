import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String _selectedExercise = 'ແລ່ນ';
  int _duration = 30; // in minutes
  int _intensity = 3; // 1-5 scale
  List<Map<String, dynamic>> _exerciseRecords = [];
  
  final List<Map<String, dynamic>> _exercises = [
    {'name': 'ແລ່ນ', 'icon': Icons.directions_run, 'color': Colors.blue},
    {'name': 'ເດີນ', 'icon': Icons.directions_walk, 'color': Colors.green},
    {'name': 'ຢູຄະ', 'icon': Icons.self_improvement, 'color': Colors.purple},
    {'name': 'ຖີບດິນ', 'icon': Icons.fitness_center, 'color': Colors.red},
    {'name': 'ລີ້ນກີລາ', 'icon': Icons.sports, 'color': Colors.orange},
    {'name': 'ວ່າຍນ້ຳ', 'icon': Icons.pool, 'color': Colors.cyan},
  ];

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseData = prefs.getString('exercise_records');
    if (exerciseData != null) {
      setState(() {
        _exerciseRecords = List<Map<String, dynamic>>.from(jsonDecode(exerciseData));
      });
    }
  }

  Future<void> _saveExerciseRecord() async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'exercise': _selectedExercise,
      'duration': _duration,
      'intensity': _intensity,
    };

    setState(() {
      _exerciseRecords.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exercise_records', jsonEncode(_exerciseRecords));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ບັນທຶກການອອກກຳລັງກາຍສຳເລັດ!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getIntensityText(int intensity) {
    switch (intensity) {
      case 1: return 'ເບົາໆ';
      case 2: return 'ປານກາງ';
      case 3: return 'ປົກກະຕິ';
      case 4: return 'ແຮງ';
      case 5: return 'ແຮງຫຼາຍ';
      default: return 'ປົກກະຕິ';
    }
  }

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.yellow[700]!;
      case 4: return Colors.orange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  Map<String, dynamic> _getExerciseInfo(String exerciseName) {
    return _exercises.firstWhere(
      (exercise) => exercise['name'] == exerciseName,
      orElse: () => {'name': exerciseName, 'icon': Icons.fitness_center, 'color': Colors.grey},
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise input section
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
                      'ບັນທຶກການອອກກຳລັງກາຍ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Exercise type selection
                    const Text(
                      'ປະເພດການອອກກຳລັງກາຍ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          final isSelected = _selectedExercise == exercise['name'];
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedExercise = exercise['name'];
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? exercise['color'].withOpacity(0.2)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: exercise['color'], width: 2)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    exercise['icon'],
                                    color: isSelected ? exercise['color'] : Colors.grey,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    exercise['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? exercise['color'] : Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Duration
                    const Text(
                      'ເວລາ (ນາທີ):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _duration > 5
                              ? () {
                                  setState(() {
                                    _duration -= 5;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFFE91E63),
                        ),
                        Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$_duration',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _duration < 180
                              ? () {
                                  setState(() {
                                    _duration += 5;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFFE91E63),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ນາທີ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Intensity
                    const Text(
                      'ຄວາມແຮງ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final intensity = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _intensity = intensity;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _intensity == intensity
                                  ? _getIntensityColor(intensity)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                intensity.toString(),
                                style: TextStyle(
                                  fontSize: 18,
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
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _getIntensityText(_intensity),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getIntensityColor(_intensity),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _saveExerciseRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ບັນທຶກ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Exercise history
              const Text(
                'ປະຫວັດການອອກກຳລັງກາຍ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: _exerciseRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'ຍັງບໍ່ມີຂໍ້ມູນການອອກກຳລັງກາຍ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _exerciseRecords.length,
                        itemBuilder: (context, index) {
                          final record = _exerciseRecords[index];
                          final date = DateTime.parse(record['date']);
                          final exerciseInfo = _getExerciseInfo(record['exercise']);
                          
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
                            child: Row(
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
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record['exercise'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFE91E63),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getIntensityColor(record['intensity']).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _getIntensityText(record['intensity']),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _getIntensityColor(record['intensity']),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}