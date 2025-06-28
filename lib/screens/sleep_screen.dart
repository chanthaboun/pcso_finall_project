import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _sleepQuality = 3;
  List<Map<String, dynamic>> _sleepRecords = [];

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    final sleepData = prefs.getString('sleep_records');
    if (sleepData != null) {
      setState(() {
        _sleepRecords = List<Map<String, dynamic>>.from(jsonDecode(sleepData));
      });
    }
  }

  Future<void> _saveSleepRecord() async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'bedTime': '${_bedTime.hour}:${_bedTime.minute.toString().padLeft(2, '0')}',
      'wakeTime': '${_wakeTime.hour}:${_wakeTime.minute.toString().padLeft(2, '0')}',
      'quality': _sleepQuality,
      'duration': _calculateSleepDuration(),
    };

    setState(() {
      _sleepRecords.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_records', jsonEncode(_sleepRecords));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ບັນທຶກຂໍ້ມູນການນອນສຳເລັດ!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _calculateSleepDuration() {
    final bedTimeMinutes = _bedTime.hour * 60 + _bedTime.minute;
    final wakeTimeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    
    int durationMinutes;
    if (wakeTimeMinutes >= bedTimeMinutes) {
      durationMinutes = wakeTimeMinutes - bedTimeMinutes;
    } else {
      durationMinutes = (24 * 60) - bedTimeMinutes + wakeTimeMinutes;
    }
    
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _getQualityText(int quality) {
    switch (quality) {
      case 1: return 'ແຍ່ຫຼາຍ';
      case 2: return 'ແຍ່';
      case 3: return 'ປົກກະຕິ';
      case 4: return 'ດີ';
      case 5: return 'ດີຫຼາຍ';
      default: return 'ປົກກະຕິ';
    }
  }

  Color _getQualityColor(int quality) {
    switch (quality) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.yellow[700]!;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'ການນອນ',
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
              // Sleep input section
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
                      'ບັນທຶກການນອນມື້ນີ້',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Bed time
                    Row(
                      children: [
                        const Icon(Icons.bedtime, color: Color(0xFFE91E63)),
                        const SizedBox(width: 12),
                        const Text(
                          'ເວລານອນ:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _bedTime,
                            );
                            if (time != null) {
                              setState(() {
                                _bedTime = time;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_bedTime.hour}:${_bedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Wake time
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: Color(0xFFE91E63)),
                        const SizedBox(width: 12),
                        const Text(
                          'ເວລາຕື່ນ:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _wakeTime,
                            );
                            if (time != null) {
                              setState(() {
                                _wakeTime = time;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_wakeTime.hour}:${_wakeTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Sleep duration
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Color(0xFFE91E63)),
                        const SizedBox(width: 12),
                        const Text(
                          'ໄລຍະເວລານອນ:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _calculateSleepDuration(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Sleep quality
                    const Text(
                      'ຄຸນນະພາບການນອນ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final quality = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _sleepQuality = quality;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _sleepQuality == quality
                                  ? _getQualityColor(quality)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                quality.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _sleepQuality == quality
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
                        _getQualityText(_sleepQuality),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getQualityColor(_sleepQuality),
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
                        onPressed: _saveSleepRecord,
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
              
              // Sleep history
              const Text(
                'ປະຫວັດການນອນ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: _sleepRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'ຍັງບໍ່ມີຂໍ້ມູນການນອນ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _sleepRecords.length,
                        itemBuilder: (context, index) {
                          final record = _sleepRecords[index];
                          final date = DateTime.parse(record['date']);
                          
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
                                  width: 8,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getQualityColor(record['quality']),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${date.day}/${date.month}/${date.year}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${record['bedTime']} - ${record['wakeTime']}',
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
                                      record['duration'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFE91E63),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getQualityText(record['quality']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getQualityColor(record['quality']),
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