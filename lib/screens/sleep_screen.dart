// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class SleepScreen extends StatefulWidget {
//   const SleepScreen({super.key});

//   @override
//   State<SleepScreen> createState() => _SleepScreenState();
// }

// class _SleepScreenState extends State<SleepScreen> {
//   TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
//   TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
//   int _sleepQuality = 3;
//   List<Map<String, dynamic>> _sleepRecords = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadSleepData();
//   }

//   Future<void> _loadSleepData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final sleepData = prefs.getString('sleep_records');
//     if (sleepData != null) {
//       setState(() {
//         _sleepRecords = List<Map<String, dynamic>>.from(jsonDecode(sleepData));
//       });
//     }
//   }

//   Future<void> _saveSleepRecord() async {
//     final record = {
//       'date': DateTime.now().toIso8601String(),
//       'bedTime': '${_bedTime.hour}:${_bedTime.minute.toString().padLeft(2, '0')}',
//       'wakeTime': '${_wakeTime.hour}:${_wakeTime.minute.toString().padLeft(2, '0')}',
//       'quality': _sleepQuality,
//       'duration': _calculateSleepDuration(),
//     };

//     setState(() {
//       _sleepRecords.insert(0, record);
//     });

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('sleep_records', jsonEncode(_sleepRecords));

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('ບັນທຶກຂໍ້ມູນການນອນສຳເລັດ!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   String _calculateSleepDuration() {
//     final bedTimeMinutes = _bedTime.hour * 60 + _bedTime.minute;
//     final wakeTimeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    
//     int durationMinutes;
//     if (wakeTimeMinutes >= bedTimeMinutes) {
//       durationMinutes = wakeTimeMinutes - bedTimeMinutes;
//     } else {
//       durationMinutes = (24 * 60) - bedTimeMinutes + wakeTimeMinutes;
//     }
    
//     final hours = durationMinutes ~/ 60;
//     final minutes = durationMinutes % 60;
//     return '${hours}h ${minutes}m';
//   }

//   String _getQualityText(int quality) {
//     switch (quality) {
//       case 1: return 'ແຍ່ຫຼາຍ';
//       case 2: return 'ແຍ່';
//       case 3: return 'ປົກກະຕິ';
//       case 4: return 'ດີ';
//       case 5: return 'ດີຫຼາຍ';
//       default: return 'ປົກກະຕິ';
//     }
//   }

//   Color _getQualityColor(int quality) {
//     switch (quality) {
//       case 1: return Colors.red;
//       case 2: return Colors.orange;
//       case 3: return Colors.yellow[700]!;
//       case 4: return Colors.lightGreen;
//       case 5: return Colors.green;
//       default: return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCE4EC),
//       appBar: AppBar(
//         title: const Text(
//           'ການນອນ',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
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
//               // Sleep input section
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'ບັນທຶກການນອນມື້ນີ້',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFFE91E63),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Bed time
//                     Row(
//                       children: [
//                         const Icon(Icons.bedtime, color: Color(0xFFE91E63)),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'ເວລານອນ:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: () async {
//                             final time = await showTimePicker(
//                               context: context,
//                               initialTime: _bedTime,
//                             );
//                             if (time != null) {
//                               setState(() {
//                                 _bedTime = time;
//                               });
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFE91E63).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               '${_bedTime.hour}:${_bedTime.minute.toString().padLeft(2, '0')}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFFE91E63),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Wake time
//                     Row(
//                       children: [
//                         const Icon(Icons.wb_sunny, color: Color(0xFFE91E63)),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'ເວລາຕື່ນ:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: () async {
//                             final time = await showTimePicker(
//                               context: context,
//                               initialTime: _wakeTime,
//                             );
//                             if (time != null) {
//                               setState(() {
//                                 _wakeTime = time;
//                               });
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFE91E63).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               '${_wakeTime.hour}:${_wakeTime.minute.toString().padLeft(2, '0')}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFFE91E63),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Sleep duration
//                     Row(
//                       children: [
//                         const Icon(Icons.access_time, color: Color(0xFFE91E63)),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'ໄລຍະເວລານອນ:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const Spacer(),
//                         Text(
//                           _calculateSleepDuration(),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFFE91E63),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Sleep quality
//                     const Text(
//                       'ຄຸນນະພາບການນອນ:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: List.generate(5, (index) {
//                         final quality = index + 1;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _sleepQuality = quality;
//                             });
//                           },
//                           child: Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: _sleepQuality == quality
//                                   ? _getQualityColor(quality)
//                                   : Colors.grey[200],
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 quality.toString(),
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: _sleepQuality == quality
//                                       ? Colors.white
//                                       : Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                     const SizedBox(height: 8),
//                     Center(
//                       child: Text(
//                         _getQualityText(_sleepQuality),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: _getQualityColor(_sleepQuality),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Save button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 45,
//                       child: ElevatedButton(
//                         onPressed: _saveSleepRecord,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFE91E63),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'ບັນທຶກ',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Sleep history
//               const Text(
//                 'ປະຫວັດການນອນ',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               Expanded(
//                 child: _sleepRecords.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'ຍັງບໍ່ມີຂໍ້ມູນການນອນ',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: _sleepRecords.length,
//                         itemBuilder: (context, index) {
//                           final record = _sleepRecords[index];
//                           final date = DateTime.parse(record['date']);
                          
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 5,
//                                   offset: const Offset(0, 1),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 8,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     color: _getQualityColor(record['quality']),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${date.day}/${date.month}/${date.year}',
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         '${record['bedTime']} - ${record['wakeTime']}',
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       record['duration'],
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: Color(0xFFE91E63),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       _getQualityText(record['quality']),
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: _getQualityColor(record['quality']),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen>
    with TickerProviderStateMixin {
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _sleepQuality = 3;
  List<Map<String, dynamic>> _sleepRecords = [];
  bool _isTracking = false;
  DateTime? _sleepStartTime;
  String _sleepGoal = "8h 0m";
  final List<String> _sleepNotes = [];
  final String _selectedNote = "";
  late TabController _tabController;

  // Sleep goal options
  final List<String> _goalOptions = [
    "6h 0m",
    "6h 30m",
    "7h 0m",
    "7h 30m",
    "8h 0m",
    "8h 30m",
    "9h 0m",
    "9h 30m"
  ];

  // Sleep notes/factors
  final List<String> _noteOptions = [
    "ດື່ມກາເຟ",
    "ອອກກຳລັງກາຍ",
    "ເຄັ່ງຕຶງ",
    "ໃຊ້ໂທລະສັບ",
    "ກິນອາຫານຫນັກ",
    "ຫ້ອງເຢັນ",
    "ຫ້ອງຮ້ອນ",
    "ມີສຽງດັງ"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSleepData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    final sleepData = prefs.getString('sleep_records');
    final goal = prefs.getString('sleep_goal');

    if (sleepData != null) {
      setState(() {
        _sleepRecords = List<Map<String, dynamic>>.from(jsonDecode(sleepData));
      });
    }

    if (goal != null) {
      setState(() {
        _sleepGoal = goal;
      });
    }
  }

  Future<void> _saveSleepRecord() async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'bedTime':
          '${_bedTime.hour}:${_bedTime.minute.toString().padLeft(2, '0')}',
      'wakeTime':
          '${_wakeTime.hour}:${_wakeTime.minute.toString().padLeft(2, '0')}',
      'quality': _sleepQuality,
      'duration': _calculateSleepDuration(),
      'notes': _sleepNotes,
      'goalAchieved': _isGoalAchieved(),
    };

    setState(() {
      _sleepRecords.insert(0, record);
      _sleepNotes.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_records', jsonEncode(_sleepRecords));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'ບັນທຶກຂໍ້ມູນການນອນສຳເລັດ! ${_isGoalAchieved() ? "🎯 ບັນລຸເປົ້າໝາຍ!" : ""}'),
          backgroundColor: _isGoalAchieved() ? Colors.green : Colors.blue,
        ),
      );
    }
  }

  bool _isGoalAchieved() {
    final goalMinutes = _parseGoalToMinutes(_sleepGoal);
    final actualMinutes = _getSleepDurationInMinutes();
    return actualMinutes >= goalMinutes;
  }

  int _parseGoalToMinutes(String goal) {
    final parts = goal.split(' ');
    final hours = int.parse(parts[0].replaceAll('h', ''));
    final minutes = int.parse(parts[1].replaceAll('m', ''));
    return hours * 60 + minutes;
  }

  int _getSleepDurationInMinutes() {
    final bedTimeMinutes = _bedTime.hour * 60 + _bedTime.minute;
    final wakeTimeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;

    if (wakeTimeMinutes >= bedTimeMinutes) {
      return wakeTimeMinutes - bedTimeMinutes;
    } else {
      return (24 * 60) - bedTimeMinutes + wakeTimeMinutes;
    }
  }

  String _calculateSleepDuration() {
    final durationMinutes = _getSleepDurationInMinutes();
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  double _getAverageQuality() {
    if (_sleepRecords.isEmpty) return 0;
    final sum = _sleepRecords
        .take(7)
        .fold<int>(0, (sum, record) => sum + (record['quality'] as int));
    return sum / min(7, _sleepRecords.length);
  }

  String _getAverageDuration() {
    if (_sleepRecords.isEmpty) return "0h 0m";
    final totalMinutes = _sleepRecords.take(7).fold<int>(0, (sum, record) {
      final duration = record['duration'] as String;
      final parts = duration.split(' ');
      final hours = int.parse(parts[0].replaceAll('h', ''));
      final minutes = int.parse(parts[1].replaceAll('m', ''));
      return sum + (hours * 60) + minutes;
    });
    final avgMinutes = totalMinutes ~/ min(7, _sleepRecords.length);
    final hours = avgMinutes ~/ 60;
    final minutes = avgMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _getQualityText(int quality) {
    switch (quality) {
      case 1:
        return 'ແຍ່ຫຼາຍ';
      case 2:
        return 'ແຍ່';
      case 3:
        return 'ປົກກະຕິ';
      case 4:
        return 'ດີ';
      case 5:
        return 'ດີຫຼາຍ';
      default:
        return 'ປົກກະຕິ';
    }
  }

  Color _getQualityColor(int quality) {
    switch (quality) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Sleep Tracking Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A5ACD), Color(0xFF9370DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.bedtime, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'ຕິດຕາມການນອນ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_isTracking) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isTracking = true;
                        _sleepStartTime = DateTime.now();
                      });
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ເລີ່ມຕິດຕາມ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6A5ACD),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'ກຳລັງຕິດຕາມ...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ເລີ່ມ: ${_sleepStartTime!.hour}:${_sleepStartTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isTracking = false;
                        _wakeTime = TimeOfDay.now();
                        _bedTime = TimeOfDay(
                          hour: _sleepStartTime!.hour,
                          minute: _sleepStartTime!.minute,
                        );
                      });
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('ຢຸດຕິດຕາມ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sleep Input Card
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
                  'ບັນທຶກການນອນ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: 16),

                // Bed and Wake Time Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        icon: Icons.bedtime,
                        label: 'ເວລານອນ',
                        time: _bedTime,
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeSelector(
                        icon: Icons.wb_sunny,
                        label: 'ເວລາຕື່ນ',
                        time: _wakeTime,
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Duration and Goal Achievement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isGoalAchieved()
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isGoalAchieved()
                            ? Icons.check_circle
                            : Icons.access_time,
                        color: _isGoalAchieved() ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ໄລຍະເວລານອນ: ${_calculateSleepDuration()}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      if (_isGoalAchieved())
                        const Text('🎯', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sleep Quality
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: _sleepQuality == quality
                              ? _getQualityColor(quality)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(22.5),
                          boxShadow: _sleepQuality == quality
                              ? [
                                  BoxShadow(
                                    color: _getQualityColor(quality)
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            quality.toString(),
                            style: TextStyle(
                              fontSize: 16,
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

                const SizedBox(height: 16),

                // Sleep Notes
                const Text(
                  'ປັດໃຈທີ່ສົ່ງຜົນ:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _noteOptions.map((note) {
                    final isSelected = _sleepNotes.contains(note);
                    return FilterChip(
                      label: Text(note),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _sleepNotes.add(note);
                          } else {
                            _sleepNotes.remove(note);
                          }
                        });
                      },
                      selectedColor: const Color(0xFFE91E63).withOpacity(0.2),
                      checkmarkColor: const Color(0xFFE91E63),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Save Button
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
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required IconData icon,
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE91E63), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'ຄຸນນະພາບເຉລີ່ຍ',
                  '${_getAverageQuality().toStringAsFixed(1)}/5',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'ເວລາເຉລີ່ຍ',
                  _getAverageDuration(),
                  Icons.access_time,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'ເປົ້າໝາຍ',
                  _sleepGoal,
                  Icons.flag,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'ບັນທຶກທັງໝົດ',
                  '${_sleepRecords.length}',
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sleep Goal Setting
          Container(
            padding: const EdgeInsets.all(16),
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
                  'ກຳນົດເປົ້າໝາຍການນອນ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _sleepGoal,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _goalOptions.map((goal) {
                    return DropdownMenuItem(
                      value: goal,
                      child: Text(goal),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        _sleepGoal = value;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('sleep_goal', value);
                    }
                  },
                ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return _sleepRecords.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bedtime,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ຍັງບໍ່ມີຂໍ້ມູນການນອນ',
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
            itemCount: _sleepRecords.length,
            itemBuilder: (context, index) {
              final record = _sleepRecords[index];
              final date = DateTime.parse(record['date']);
              final notes = record['notes'] as List<dynamic>? ?? [];

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
                              Row(
                                children: [
                                  Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (record['goalAchieved'] == true) ...[
                                    const SizedBox(width: 8),
                                    const Text('🎯', style: TextStyle(fontSize: 16)),
                                  ],
                                ],
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
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: notes.map<Widget>((note) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              note,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }).toList(),
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
          _buildTrackingTab(),
          _buildStatsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }
}
