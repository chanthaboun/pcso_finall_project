
// // lib/screens/notification_settings_screen.dart - Fixed to use EnhancedNotificationService
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../services/enhanced_notification_service.dart'; // ✅ Changed to enhanced service

// class NotificationSettingsScreen extends StatefulWidget {
//   const NotificationSettingsScreen({super.key});

//   @override
//   State<NotificationSettingsScreen> createState() =>
//       _NotificationSettingsScreenState();
// }

// class _NotificationSettingsScreenState
//     extends State<NotificationSettingsScreen> {
//   Map<NotificationType, bool> _settings = {};
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//   }

//   void _loadSettings() {
//     setState(() {
//       _settings = EnhancedNotificationService.getAllSettings(); // ✅ Changed
//       _isLoading = false;
//     });
//   }

//   void _updateSetting(NotificationType type, bool value) async {
//     await EnhancedNotificationService.updateNotificationSetting(
//         type, value); // ✅ Changed
//     setState(() {
//       _settings[type] = value;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           value
//               ? 'ເປີດການແຈ້ງເຕືອນ ${_getTypeLabel(type)}'
//               : 'ປິດການແຈ້ງເຕືອນ ${_getTypeLabel(type)}',
//         ),
//         backgroundColor: value ? Colors.green : Colors.orange,
//       ),
//     );
//   }

//   void _scheduleTestNotification(NotificationType type) async {
//     final testTime = DateTime.now().add(const Duration(seconds: 5));

//     await EnhancedNotificationService.scheduleNotification(
//       // ✅ Changed
//       title: 'ທົດສອບການແຈ້ງເຕືອນ ${_getTypeLabel(type)}',
//       body:
//           'ນີ້ແມ່ນການທົດສອບການແຈ້ງເຕືອນ ຖ້າເຈົ້າເຫັນຂໍ້ຄວາມນີ້ ແມ່ນການແຈ້ງເຕືອນເຮັດວຽກປົກກະຕິ',
//       type: type,
//       scheduledTime: testTime,
//       data: {'test': true},
//     );

//     if (mounted) {
//       // ✅ Check mounted before using context
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('ສົ່ງການທົດສອບແລ້ວ ລໍຖ້າ 5 ວິນາທີ...'),
//           backgroundColor: Colors.blue,
//         ),
//       );
//     }
//   }

//   void _showScheduleDialog(NotificationType type) {
//     showDialog(
//       context: context,
//       builder: (context) => _ScheduleDialog(
//         type: type,
//         onScheduled: () {
//           if (mounted) {
//             // ✅ Check mounted before using context
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content:
//                     Text('ກຳນົດການແຈ້ງເຕືອນ ${_getTypeLabel(type)} ສຳເລັດ'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   IconData _getTypeIcon(NotificationType type) {
//     switch (type) {
//       case NotificationType.medication:
//         return Icons.medication;
//       case NotificationType.sleep:
//         return Icons.bedtime;
//       case NotificationType.exercise:
//         return Icons.fitness_center;
//       case NotificationType.period:
//         return Icons.calendar_today;
//       case NotificationType.report:
//         return Icons.analytics;
//       case NotificationType.goal:
//         return Icons.flag;
//     }
//   }

//   Color _getTypeColor(NotificationType type) {
//     switch (type) {
//       case NotificationType.medication:
//         return Colors.blue;
//       case NotificationType.sleep:
//         return Colors.purple;
//       case NotificationType.exercise:
//         return Colors.orange;
//       case NotificationType.period:
//         return Colors.red;
//       case NotificationType.report:
//         return Colors.green;
//       case NotificationType.goal:
//         return Colors.teal;
//     }
//   }

//   String _getTypeLabel(NotificationType type) {
//     switch (type) {
//       case NotificationType.medication:
//         return 'ການກິນຢາ';
//       case NotificationType.sleep:
//         return 'ການນອນ';
//       case NotificationType.exercise:
//         return 'ອອກກຳລັງກາຍ';
//       case NotificationType.period:
//         return 'ປະຈຳເດືອນ';
//       case NotificationType.report:
//         return 'ລາຍງານ';
//       case NotificationType.goal:
//         return 'ເປົ້າຫມາຍ';
//     }
//   }

//   String _getTypeDescription(NotificationType type) {
//     switch (type) {
//       case NotificationType.medication:
//         return 'ແຈ້ງເຕືອນເວລາກິນຢາຕາມກຳນົດ';
//       case NotificationType.sleep:
//         return 'ແຈ້ງເຕືອນເວລານອນແລະຕື່ນ';
//       case NotificationType.exercise:
//         return 'ແຈ້ງເຕືອນເວລາອອກກຳລັງກາຍ';
//       case NotificationType.period:
//         return 'ແຈ້ງເຕືອນການຄາດການປະຈຳເດືອນ';
//       case NotificationType.report:
//         return 'ລາຍງານສຸຂະພາບປະຈຳອາທິດ';
//       case NotificationType.goal:
//         return 'ການບັນລຸເປົ້າຫມາຍ';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFFCE4EC),
//       appBar: AppBar(
//         title: const Text(
//           'ຕັ້ງຄ່າການແຈ້ງເຕືອນ',
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
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           // Header info
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 5,
//                   offset: const Offset(0, 1),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE91E63).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   child: const Icon(
//                     Icons.notifications_active,
//                     color: Color(0xFFE91E63),
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'ການຈັດການການແຈ້ງເຕືອນ',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'ເປີດ/ປິດການແຈ້ງເຕືອນຕາມປະເພດ',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Notification types
//           ...NotificationType.values.map((type) {
//             final isEnabled = _settings[type] ?? false;
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 5,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: _getTypeColor(type).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Icon(
//                         _getTypeIcon(type),
//                         color: _getTypeColor(type),
//                         size: 24,
//                       ),
//                     ),
//                     title: Text(
//                       _getTypeLabel(type),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle: Text(
//                       _getTypeDescription(type),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     trailing: Switch(
//                       value: isEnabled,
//                       onChanged: (value) => _updateSetting(type, value),
//                       activeColor: _getTypeColor(type),
//                     ),
//                   ),
//                   if (isEnabled) ...[
//                     const Divider(height: 1),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton.icon(
//                               onPressed: () {
//                                 HapticFeedback.lightImpact();
//                                 _scheduleTestNotification(type);
//                               },
//                               icon: const Icon(Icons.play_arrow, size: 16),
//                               label: const Text(
//                                 'ທົດສອບ',
//                                 style: TextStyle(fontSize: 12),
//                               ),
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: _getTypeColor(type),
//                                 side: BorderSide(color: _getTypeColor(type)),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 8),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 HapticFeedback.lightImpact();
//                                 _showScheduleDialog(type);
//                               },
//                               icon: const Icon(Icons.schedule, size: 16),
//                               label: const Text(
//                                 'ກຳນົດເວລາ',
//                                 style: TextStyle(fontSize: 12),
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: _getTypeColor(type),
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 8),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           }).toList(),

//           const SizedBox(height: 24),

//           // Global actions
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 5,
//                   offset: const Offset(0, 1),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'ການກະທຳອື່ນໆ',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () async {
//                           HapticFeedback.lightImpact();
//                           await EnhancedNotificationService
//                               .cleanupOldNotifications();
//                           if (mounted) {
//                             // ✅ Check mounted before using context
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('ລຶບການແຈ້ງເຕືອນເກົ່າແລ້ວ'),
//                                 backgroundColor: Colors.orange,
//                               ),
//                             );
//                           }
//                         },
//                         icon: const Icon(Icons.cleaning_services),
//                         label: const Text('ລຶບເກົ່າ'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.orange,
//                           side: const BorderSide(color: Colors.orange),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () async {
//                           HapticFeedback.lightImpact();
//                           // ✅ Enhanced service may not have this method, so use basic schedule
//                           await EnhancedNotificationService
//                               .scheduleNotification(
//                             title: '📊 ລາຍງານປະຈຳອາທິດ',
//                             body: 'ລາຍງານສຸຂະພາບປະຈຳອາທິດຂອງເຈົ້າພ້ອມແລ້ວ!',
//                             type: NotificationType.report,
//                             scheduledTime:
//                                 DateTime.now().add(const Duration(days: 7)),
//                           );
//                           if (mounted) {
//                             // ✅ Check mounted before using context
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('ກຳນົດລາຍງານປະຈຳອາທິດແລ້ວ'),
//                                 backgroundColor: Colors.green,
//                               ),
//                             );
//                           }
//                         },
//                         icon: const Icon(Icons.analytics),
//                         label: const Text('ລາຍງານ'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.green,
//                           side: const BorderSide(color: Colors.green),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Schedule Dialog for different notification types
// class _ScheduleDialog extends StatefulWidget {
//   final NotificationType type;
//   final VoidCallback onScheduled;

//   const _ScheduleDialog({
//     required this.type,
//     required this.onScheduled,
//   });

//   @override
//   State<_ScheduleDialog> createState() => _ScheduleDialogState();
// }

// class _ScheduleDialogState extends State<_ScheduleDialog> {
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   final List<TimeOfDay> _medicationTimes = [];
//   final List<int> _selectedWeekdays = [];
//   DateTime _selectedDate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text('ກຳນົດ${_getTypeLabel(widget.type)}'),
//       content: _buildContent(),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('ຍົກເລີກ'),
//         ),
//         ElevatedButton(
//           onPressed: _scheduleNotification,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFE91E63),
//             foregroundColor: Colors.white,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           child: const Text('ກຳນົດ'),
//         ),
//       ],
//     );
//   }

//   Widget _buildContent() {
//     switch (widget.type) {
//       case NotificationType.medication:
//         return _buildMedicationContent();
//       case NotificationType.sleep:
//         return _buildSleepContent();
//       case NotificationType.exercise:
//         return _buildExerciseContent();
//       case NotificationType.period:
//         return _buildPeriodContent();
//       default:
//         return _buildDefaultContent();
//     }
//   }

//   Widget _buildMedicationContent() {
//     return SizedBox(
//       width: double.maxFinite,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('ເພີ່ມເວລາກິນຢາ:'),
//           const SizedBox(height: 16),

//           // Time picker
//           ListTile(
//             leading: const Icon(Icons.access_time),
//             title: Text(
//                 '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
//             trailing: const Icon(Icons.keyboard_arrow_right),
//             onTap: () async {
//               final time = await showTimePicker(
//                 context: context,
//                 initialTime: _selectedTime,
//                 builder: (context, child) {
//                   return Theme(
//                     data: Theme.of(context).copyWith(
//                       colorScheme:
//                           const ColorScheme.light(primary: Colors.blue),
//                     ),
//                     child: child!,
//                   );
//                 },
//               );
//               if (time != null) {
//                 setState(() {
//                   _selectedTime = time;
//                 });
//               }
//             },
//           ),

//           ElevatedButton(
//             onPressed: () {
//               if (!_medicationTimes.any((t) =>
//                   t.hour == _selectedTime.hour &&
//                   t.minute == _selectedTime.minute)) {
//                 setState(() {
//                   _medicationTimes.add(_selectedTime);
//                 });
//               }
//             },
//             child: const Text('ເພີ່ມເວລາ'),
//           ),

//           const SizedBox(height: 16),

//           // Selected times
//           if (_medicationTimes.isNotEmpty) ...[
//             const Text('ເວລາທີ່ເລືອກ:'),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: _medicationTimes.map((time) {
//                 return Chip(
//                   label: Text(
//                       '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
//                   deleteIcon: const Icon(Icons.close, size: 18),
//                   onDeleted: () {
//                     setState(() {
//                       _medicationTimes.remove(time);
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildSleepContent() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('ຕັ້ງເວລານອນ:'),
//         const SizedBox(height: 16),
//         ListTile(
//           leading: const Icon(Icons.bedtime),
//           title: const Text('ເວລານອນ'),
//           subtitle: Text(
//               '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
//           trailing: const Icon(Icons.keyboard_arrow_right),
//           onTap: () async {
//             final time = await showTimePicker(
//               context: context,
//               initialTime: _selectedTime,
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme:
//                         const ColorScheme.light(primary: Colors.purple),
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//             if (time != null) {
//               setState(() {
//                 _selectedTime = time;
//               });
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildExerciseContent() {
//     return SizedBox(
//       width: double.maxFinite,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('ເລືອກເວລາອອກກຳລັງກາຍ:'),
//           const SizedBox(height: 16),

//           // Time picker
//           ListTile(
//             leading: const Icon(Icons.access_time),
//             title: Text(
//                 '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
//             trailing: const Icon(Icons.keyboard_arrow_right),
//             onTap: () async {
//               final time = await showTimePicker(
//                 context: context,
//                 initialTime: _selectedTime,
//                 builder: (context, child) {
//                   return Theme(
//                     data: Theme.of(context).copyWith(
//                       colorScheme:
//                           const ColorScheme.light(primary: Colors.orange),
//                     ),
//                     child: child!,
//                   );
//                 },
//               );
//               if (time != null) {
//                 setState(() {
//                   _selectedTime = time;
//                 });
//               }
//             },
//           ),

//           const SizedBox(height: 16),

//           // Weekday selection
//           const Text('ເລືອກວັນ:'),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             children: [
//               for (int i = 1; i <= 7; i++)
//                 FilterChip(
//                   label: Text(_getWeekdayName(i)),
//                   selected: _selectedWeekdays.contains(i),
//                   onSelected: (selected) {
//                     setState(() {
//                       if (selected) {
//                         _selectedWeekdays.add(i);
//                       } else {
//                         _selectedWeekdays.remove(i);
//                       }
//                     });
//                   },
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPeriodContent() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('ຄາດການວັນປະຈຳເດືອນຄັ້ງຕໍ່ໄປ:'),
//         const SizedBox(height: 16),
//         ListTile(
//           leading: const Icon(Icons.calendar_today),
//           title: Text(
//               '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
//           trailing: const Icon(Icons.keyboard_arrow_right),
//           onTap: () async {
//             final date = await showDatePicker(
//               context: context,
//               initialDate: _selectedDate,
//               firstDate: DateTime.now(),
//               lastDate: DateTime.now().add(const Duration(days: 365)),
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: const ColorScheme.light(primary: Colors.red),
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//             if (date != null) {
//               setState(() {
//                 _selectedDate = date;
//               });
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDefaultContent() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ListTile(
//           leading: const Icon(Icons.access_time),
//           title: Text(
//               '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
//           trailing: const Icon(Icons.keyboard_arrow_right),
//           onTap: () async {
//             final time = await showTimePicker(
//               context: context,
//               initialTime: _selectedTime,
//             );
//             if (time != null) {
//               setState(() {
//                 _selectedTime = time;
//               });
//             }
//           },
//         ),
//       ],
//     );
//   }

//   String _getWeekdayName(int weekday) {
//     const names = ['ຈັນ', 'ອັງຄານ', 'ພຸດ', 'ພະຫັດ', 'ສຸກ', 'ເສົາ', 'ອາທິດ'];
//     return names[weekday - 1];
//   }

//   String _getTypeLabel(NotificationType type) {
//     switch (type) {
//       case NotificationType.medication:
//         return 'ການກິນຢາ';
//       case NotificationType.sleep:
//         return 'ການນອນ';
//       case NotificationType.exercise:
//         return 'ອອກກຳລັງກາຍ';
//       case NotificationType.period:
//         return 'ປະຈຳເດືອນ';
//       case NotificationType.report:
//         return 'ລາຍງານ';
//       case NotificationType.goal:
//         return 'ເປົ້າຫມາຍ';
//     }
//   }

//   void _scheduleNotification() async {
//     try {
//       switch (widget.type) {
//         case NotificationType.medication:
//           if (_medicationTimes.isNotEmpty) {
//             // Schedule multiple medication reminders
//             for (var time in _medicationTimes) {
//               final now = DateTime.now();
//               final scheduledTime = DateTime(
//                 now.year,
//                 now.month,
//                 now.day,
//                 time.hour,
//                 time.minute,
//               );

//               // If time has passed today, schedule for tomorrow
//               final actualTime = scheduledTime.isBefore(now)
//                   ? scheduledTime.add(const Duration(days: 1))
//                   : scheduledTime;

//               await EnhancedNotificationService.scheduleNotification(
//                 // ✅ Changed
//                 title: '💊 ເວລາກິນຢາ',
//                 body: 'ຖືງເວລາກິນຢາແລ້ວ (${time.format(context)})',
//                 type: NotificationType.medication,
//                 scheduledTime: actualTime,
//                 data: {'medication_time': time.format(context)},
//               );
//             }
//           }
//           break;

//         case NotificationType.sleep:
//           final now = DateTime.now();
//           final bedtime = DateTime(
//             now.year,
//             now.month,
//             now.day,
//             _selectedTime.hour,
//             _selectedTime.minute,
//           );

//           // If bedtime has passed today, schedule for tomorrow
//           final actualBedtime = bedtime.isBefore(now)
//               ? bedtime.add(const Duration(days: 1))
//               : bedtime;

//           await EnhancedNotificationService.scheduleNotification(
//             // ✅ Changed
//             title: '😴 ເວລານອນ',
//             body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
//             type: NotificationType.sleep,
//             scheduledTime: actualBedtime,
//             data: {'bedtime': _selectedTime.format(context)},
//           );
//           break;

//         case NotificationType.exercise:
//           if (_selectedWeekdays.isNotEmpty) {
//             // Schedule for next 4 weeks
//             final now = DateTime.now();
//             for (int week = 0; week < 4; week++) {
//               for (int weekday in _selectedWeekdays) {
//                 final targetDate =
//                     _getNextWeekday(now.add(Duration(days: week * 7)), weekday);
//                 final scheduledTime = DateTime(
//                   targetDate.year,
//                   targetDate.month,
//                   targetDate.day,
//                   _selectedTime.hour,
//                   _selectedTime.minute,
//                 );

//                 if (scheduledTime.isAfter(now)) {
//                   await EnhancedNotificationService.scheduleNotification(
//                     // ✅ Changed
//                     title: '🏃‍♀️ ເວລາອອກກຳລັງກາຍ',
//                     body: 'ມາອອກກຳລັງກາຍເພື່ອສຸຂະພາບທີ່ດີກັນເຖາະ!',
//                     type: NotificationType.exercise,
//                     scheduledTime: scheduledTime,
//                     data: {
//                       'exercise_time': _selectedTime.format(context),
//                       'weekday': weekday,
//                     },
//                   );
//                 }
//               }
//             }
//           }
//           break;

//         case NotificationType.period:
//           // Schedule period predictions
//           await EnhancedNotificationService.scheduleNotification(
//             // ✅ Changed
//             title: '🩸 ການແຈ້ງເຕືອນປະຈຳເດືອນ',
//             body: 'ປະຈຳເດືອນອາດຈະມາໃນອີກ 3 ວັນ ຈະຕຽມພ້ອມບໍ່?',
//             type: NotificationType.period,
//             scheduledTime: _selectedDate.subtract(const Duration(days: 3)),
//             data: {'days_until': 3, 'type': 'warning'},
//           );

//           await EnhancedNotificationService.scheduleNotification(
//             // ✅ Changed
//             title: '🩸 ວັນປະຈຳເດືອນ',
//             body: 'ວັນນີ້ອາດເປັນວັນປະຈຳເດືອນ ດູແລຕົນເອງໃຫ້ດີ',
//             type: NotificationType.period,
//             scheduledTime: _selectedDate,
//             data: {'days_until': 0, 'type': 'today'},
//           );
//           break;

//         default:
//           // For other types, schedule a simple reminder
//           final now = DateTime.now();
//           final scheduledTime = DateTime(
//             now.year,
//             now.month,
//             now.day,
//             _selectedTime.hour,
//             _selectedTime.minute,
//           );

//           final actualTime = scheduledTime.isBefore(now)
//               ? scheduledTime.add(const Duration(days: 1))
//               : scheduledTime;

//           await EnhancedNotificationService.scheduleNotification(
//             // ✅ Changed
//             title: 'ການແຈ້ງເຕືອນ ${_getTypeLabel(widget.type)}',
//             body: 'ນີ້ແມ່ນການແຈ້ງເຕືອນທີ່ເຈົ້າຕັ້ງໄວ້',
//             type: widget.type,
//             scheduledTime: actualTime,
//             data: {'scheduled_time': _selectedTime.format(context)},
//           );
//           break;
//       }

//       widget.onScheduled();
//       if (mounted) {
//         // ✅ Check mounted before using context
//         Navigator.of(context).pop();
//       }
//     } catch (e) {
//       if (mounted) {
//         // ✅ Check mounted before using context
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('ເກີດຂໍ້ຜິດພາດ: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Helper method to get next weekday
//   DateTime _getNextWeekday(DateTime date, int weekday) {
//     final daysUntil = (weekday - date.weekday) % 7;
//     return date.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
//   }
// }





// lib/screens/notification_settings_screen.dart - Fixed all syntax errors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/enhanced_notification_service.dart';

// Enhanced TimeOfDay with seconds
class PreciseTime {
  final int hour;
  final int minute;
  final int second;

  PreciseTime({required this.hour, required this.minute, this.second = 0});

  String format() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  DateTime toDateTime([DateTime? baseDate]) {
    final base = baseDate ?? DateTime.now();
    return DateTime(base.year, base.month, base.day, hour, minute, second);
  }

  static PreciseTime fromTimeOfDay(TimeOfDay time, [int seconds = 0]) {
    return PreciseTime(hour: time.hour, minute: time.minute, second: seconds);
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  Map<NotificationType, bool> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _settings = EnhancedNotificationService.getAllSettings();
      _isLoading = false;
    });
  }

  void _updateSetting(NotificationType type, bool value) async {
    await EnhancedNotificationService.updateNotificationSetting(type, value);
    setState(() {
      _settings[type] = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'ເປີດການແຈ້ງເຕືອນ ${_getTypeLabel(type)}'
                : 'ປິດການແຈ້ງເຕືອນ ${_getTypeLabel(type)}',
          ),
          backgroundColor: value ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _scheduleTestNotification(NotificationType type) async {
    // ທົດສອບດ້ວຍ 10 ວິນາທີ
    final testTime = DateTime.now().add(const Duration(seconds: 10));

    await EnhancedNotificationService.scheduleNotification(
      title: '🧪 ທົດສອບ ${_getTypeLabel(type)}',
      body:
          'ນີ້ແມ່ນການທົດສອບການແຈ້ງເຕືອນ ຖ້າເຈົ້າເຫັນຂໍ້ຄວາມນີ້ແມ່ນເຮັດວຽກປົກກະຕິ',
      type: type,
      scheduledTime: testTime,
      data: {'test': true, 'original_time': DateTime.now().toString()},
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📱 ສົ່ງການທົດສອບແລ້ວ ລໍຖ້າ 10 ວິນາທີ...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showScheduleDialog(NotificationType type) async {
    // ເຮັດໃຫ້ແນ່ໃຈວ່າ context ຍັງມີຢູ່
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => _EnhancedScheduleDialog(
        type: type,
        onScheduled: () {
          // ໃຊ້ context ຂອງ dialog ແທນ
          Navigator.of(dialogContext).pop(true);
        },
      ),
    );

    // ຖ້າ dialog ສຳເລັດ
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ກຳນົດການແຈ້ງເຕືອນ ${_getTypeLabel(type)} ສຳເລັດ'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ສ້າງ testing notification ດ້ວຍເວລາທີ່ກຳນົດເອງ
  void _showQuickTestDialog(NotificationType type) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => _QuickTestDialog(type: type),
    );
  }

  // ສະແດງ dialog ເພື່ອຢືນຢັນການລົບປະຫວັດ
  void _showClearHistoryDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('⚠️ ເຕືອນ'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ເຈົ້າຕ້ອງການລົບປະຫວັດການແຈ້ງເຕືອນທັງໝົດບໍ່?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text(
                '📝 ການກະທຳນີ້ຈະລົບ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• ການແຈ້ງເຕືອນທີ່ຍັງບໍ່ທັນມີຂຶ້ນ'),
              Text('• ການແຈ້ງເຕືອນທີ່ສຳເລັດແລ້ວ'),
              Text('• ການແຈ້ງເຕືອນທີ່ກຳລັງລໍຖ້າ'),
              SizedBox(height: 12),
              Text(
                '⚠️ ການກະທຳນີ້ບໍ່ສາມາດຍົກເລີກໄດ້!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ຍົກເລີກ'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearAllHistory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('🗑️ ລົບທັງໝົດ'),
            ),
          ],
        );
      },
    );
  }

  // ລົບປະຫວັດການແຈ້ງເຕືອນທັງໝົດ
  Future<void> _clearAllHistory() async {
    try {
      await EnhancedNotificationService.resetAllNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ ລົບປະຫວັດການແຈ້ງເຕືອນທັງໝົດແລ້ວ'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ເກີດຂໍ້ຜິດພາດ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ສະແດງຂໍ້ມູນ debug
  void _showDebugInfo() {
    if (!mounted) return;

    final debugInfo = EnhancedNotificationService.getDebugInfo();
    final notifications = EnhancedNotificationService.getAllNotifications();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🔍 ຂໍ້ມູນການແຈ້ງເຕືອນ'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ສະຖິຕິທົ່ວໄປ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 ສະຖິຕິ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('⏰ ເວລາປັດຈຸບັນ: ${debugInfo['current_time']}'),
                        Text(
                            '📱 ການແຈ້ງເຕືອນທັງໝົດ: ${debugInfo['total_notifications']}'),
                        Text(
                            '✅ ການແຈ້ງເຕືອນທີ່ຍັງເຮັດວຽກ: ${debugInfo['active_notifications']}'),
                        Text(
                            '🔔 ການແຈ້ງເຕືອນທີ່ສຳເລັດແລ້ວ: ${debugInfo['triggered_notifications']}'),
                        Text(
                            '🔕 ການແຈ້ງເຕືອນທີ່ຍັງບໍ່ອ່ານ: ${debugInfo['unread_notifications']}'),
                        Text(
                            '⏭️ ການແຈ້ງເຕືອນຕໍ່ໄປ: ${debugInfo['next_notification']}'),
                        Text('🔄 Timer ເຮັດວຽກ: ${debugInfo['timer_active']}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ລາຍການການແຈ້ງເຕືອນ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📋 ລາຍການການແຈ້ງເຕືອນ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (notifications.isEmpty) ...[
                          const Text('ບໍ່ມີການແຈ້ງເຕືອນ'),
                        ] else ...[
                          for (var notification in notifications.take(5)) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'ເວລາ: ${notification.scheduledTime.toString().substring(11, 19)}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'ສະຖານະ: ${notification.isTriggered ? "✅ ສົ່ງແລ້ວ" : "⏳ ລໍຖ້າ"}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (notifications.length > 5) ...[
                            Text(
                                '... ແລະອີກ ${notifications.length - 5} ລາຍການ'),
                          ],
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ການທົດສອບ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🧪 ການທົດສອບ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            EnhancedNotificationService
                                .forceCheckNotifications();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🔍 ກວດສອບການແຈ້ງເຕືອນແລ້ວ'),
                                backgroundColor: Colors.purple,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('🔍 ກວດສອບດ່ວນ'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ປິດ'),
            ),
          ],
        );
      },
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return Icons.medication;
      case NotificationType.sleep:
        return Icons.bedtime;
      case NotificationType.exercise:
        return Icons.fitness_center;
      case NotificationType.period:
        return Icons.calendar_today;
      case NotificationType.report:
        return Icons.analytics;
      case NotificationType.goal:
        return Icons.flag;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return Colors.blue;
      case NotificationType.sleep:
        return Colors.purple;
      case NotificationType.exercise:
        return Colors.orange;
      case NotificationType.period:
        return Colors.red;
      case NotificationType.report:
        return Colors.green;
      case NotificationType.goal:
        return Colors.teal;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return 'ການກິນຢາ';
      case NotificationType.sleep:
        return 'ການນອນ';
      case NotificationType.exercise:
        return 'ອອກກຳລັງກາຍ';
      case NotificationType.period:
        return 'ປະຈຳເດືອນ';
      case NotificationType.report:
        return 'ລາຍງານ';
      case NotificationType.goal:
        return 'ເປົ້າຫມາຍ';
    }
  }

  String _getTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return 'ແຈ້ງເຕືອນເວລາກິນຢາຕາມກຳນົດ';
      case NotificationType.sleep:
        return 'ແຈ້ງເຕືອນເວລານອນແລະຕື່ນ';
      case NotificationType.exercise:
        return 'ແຈ້ງເຕືອນເວລາອອກກຳລັງກາຍ';
      case NotificationType.period:
        return 'ແຈ້ງເຕືອນການຄາດການປະຈຳເດືອນ';
      case NotificationType.report:
        return 'ລາຍງານສຸຂະພາບປະຈຳອາທິດ';
      case NotificationType.goal:
        return 'ການບັນລຸເປົ້າຫມາຍ';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'ຕັ້ງຄ່າການແຈ້ງເຕືອນ',
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header info
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFE91E63),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ການຈັດການການແຈ້ງເຕືອນ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ເປີດ/ປິດການແຈ້ງເຕືອນຕາມປະເພດ (ຮອງຮັບວິນາທີ)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification types
          ...NotificationType.values.map((type) {
            final isEnabled = _settings[type] ?? false;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                  ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      _getTypeLabel(type),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      _getTypeDescription(type),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (value) => _updateSetting(type, value),
                      activeColor: _getTypeColor(type),
                    ),
                  ),
                  if (isEnabled) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // ແຖວທີ 1: ທົດສອບ ແລະ ກຳນົດເວລາ
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _scheduleTestNotification(type);
                                  },
                                  icon: const Icon(Icons.play_arrow, size: 16),
                                  label: const Text(
                                    'ທົດສອບ 10s',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _getTypeColor(type),
                                    side:
                                        BorderSide(color: _getTypeColor(type)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _showScheduleDialog(type);
                                  },
                                  icon: const Icon(Icons.schedule, size: 16),
                                  label: const Text(
                                    'ກຳນົດເວລາ',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getTypeColor(type),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // ແຖວທີ 2: ທົດສອບແບບກຳນົດເວລາເອງ
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _showQuickTestDialog(type);
                              },
                              icon: const Icon(Icons.timer, size: 16),
                              label: const Text(
                                'ທົດສອບກຳນົດເວລາເອງ (ວິນາທີ)',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepPurple,
                                side:
                                    const BorderSide(color: Colors.deepPurple),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Global actions
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
                const Text(
                  'ການກະທຳອື່ນໆ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // ແຖວທີ 1: ລຶບເກົ່າ ແລະ ລາຍງານ
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await EnhancedNotificationService
                              .cleanupOldNotifications();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🧹 ລຶບການແຈ້ງເຕືອນເກົ່າແລ້ວ'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.cleaning_services),
                        label: const Text('ລຶບເກົ່າ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await EnhancedNotificationService
                              .scheduleNotification(
                            title: '📊 ລາຍງານປະຈຳອາທິດ',
                            body: 'ລາຍງານສຸຂະພາບປະຈຳອາທິດຂອງເຈົ້າພ້ອມແລ້ວ!',
                            type: NotificationType.report,
                            scheduledTime:
                                DateTime.now().add(const Duration(days: 7)),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📊 ກຳນົດລາຍງານປະຈຳອາທິດແລ້ວ'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('ລາຍງານ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ແຖວທີ 2: ລົບປະຫວັດ (ເຕັມແຖວ)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      _showClearHistoryDialog();
                    },
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('🗑️ ລົບປະຫວັດການແຈ້ງເຕືອນທັງໝົດ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ແຖວທີ 3: Debug info (ສຳລັບນັກພັດທະນາ)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showDebugInfo();
                    },
                    icon: const Icon(Icons.bug_report, size: 16),
                    label: const Text('🔍 ຂໍ້ມູນການແຈ້ງເຕືອນ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
}

// Quick Test Dialog ສໍາລັບທົດສອບດ້ວຍເວລາທີ່ກຳນົດເອງ
class _QuickTestDialog extends StatefulWidget {
  final NotificationType type;

  const _QuickTestDialog({required this.type});

  @override
  State<_QuickTestDialog> createState() => _QuickTestDialogState();
}

class _QuickTestDialogState extends State<_QuickTestDialog> {
  int _seconds = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('🧪 ທົດສອບດ່ວນ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ເລືອກເວລາສໍາລັບການທົດສອບ ${_getTypeLabel(widget.type)}:'),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('ເວລາ: '),
              Expanded(
                child: Slider(
                  value: _seconds.toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: '$_seconds ວິນາທີ',
                  onChanged: (value) {
                    setState(() {
                      _seconds = value.round();
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            '$_seconds ວິນາທີ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ຍົກເລີກ'),
        ),
        ElevatedButton(
          onPressed: () async {
            final testTime = DateTime.now().add(Duration(seconds: _seconds));

            await EnhancedNotificationService.scheduleNotification(
              title: '⚡ ທົດສອບດ່ວນ ${_getTypeLabel(widget.type)}',
              body:
                  'ການທົດສອບໃນ $_seconds ວິນາທີ ສຳເລັດ! ເວລາປັດຈຸບັນ: ${DateTime.now().toString().substring(11, 19)}',
              type: widget.type,
              scheduledTime: testTime,
              data: {
                'test': true,
                'quick_test': true,
                'seconds': _seconds,
                'scheduled_at': DateTime.now().toString(),
              },
            );

            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⏱️ ກຳນົດການທົດສອບໃນ $_seconds ວິນາທີ'),
                  backgroundColor: Colors.purple,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('ທົດສອບ'),
        ),
      ],
    );
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return 'ການກິນຢາ';
      case NotificationType.sleep:
        return 'ການນອນ';
      case NotificationType.exercise:
        return 'ອອກກຳລັງກາຍ';
      case NotificationType.period:
        return 'ປະຈຳເດືອນ';
      case NotificationType.report:
        return 'ລາຍງານ';
      case NotificationType.goal:
        return 'ເປົ້າຫມາຍ';
    }
  }
}

// Enhanced Schedule Dialog ດ້ວຍ second precision
class _EnhancedScheduleDialog extends StatefulWidget {
  final NotificationType type;
  final VoidCallback onScheduled;

  const _EnhancedScheduleDialog({
    required this.type,
    required this.onScheduled,
  });

  @override
  State<_EnhancedScheduleDialog> createState() =>
      _EnhancedScheduleDialogState();
}

class _EnhancedScheduleDialogState extends State<_EnhancedScheduleDialog> {
  PreciseTime _selectedTime = PreciseTime(
    hour: TimeOfDay.now().hour,
    minute: TimeOfDay.now().minute,
    second: 0,
  );
  final List<PreciseTime> _medicationTimes = [];
  final List<int> _selectedWeekdays = [];
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('⏰ ກຳນົດ${_getTypeLabel(widget.type)}'),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ຍົກເລີກ'),
        ),
        ElevatedButton(
          onPressed: _scheduleNotification,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('ກຳນົດ'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (widget.type) {
      case NotificationType.medication:
        return _buildMedicationContent();
      case NotificationType.sleep:
        return _buildSleepContent();
      case NotificationType.exercise:
        return _buildExerciseContent();
      case NotificationType.period:
        return _buildPeriodContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildMedicationContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⏰ ເພີ່ມເວລາກິນຢາ (ລະອຽດເຖິງວິນາທີ):'),
        const SizedBox(height: 16),

        // Time picker with seconds
        _buildPreciseTimePicker(),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          onPressed: () {
            if (!_medicationTimes.any((t) =>
                t.hour == _selectedTime.hour &&
                t.minute == _selectedTime.minute &&
                t.second == _selectedTime.second)) {
              setState(() {
                _medicationTimes.add(PreciseTime(
                  hour: _selectedTime.hour,
                  minute: _selectedTime.minute,
                  second: _selectedTime.second,
                ));
              });
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('ເພີ່ມເວລາ'),
        ),

        const SizedBox(height: 16),

        // Selected times
        if (_medicationTimes.isNotEmpty) ...[
          const Text('📝 ເວລາທີ່ເລືອກ:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _medicationTimes.map((time) {
              return Chip(
                label: Text(time.format()),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _medicationTimes.remove(time);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSleepContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🌙 ຕັ້ງເວລານອນ (ລະອຽດເຖິງວິນາທີ):'),
        const SizedBox(height: 16),
        _buildPreciseTimePicker(),
      ],
    );
  }

  Widget _buildExerciseContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏃‍♀️ ເລືອກເວລາອອກກຳລັງກາຍ:'),
        const SizedBox(height: 16),

        // Time picker with seconds
        _buildPreciseTimePicker(),

        const SizedBox(height: 16),

        // Weekday selection
        const Text('📅 ເລືອກວັນ:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 1; i <= 7; i++)
              FilterChip(
                label: Text(_getWeekdayName(i)),
                selected: _selectedWeekdays.contains(i),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedWeekdays.add(i);
                    } else {
                      _selectedWeekdays.remove(i);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📅 ຄາດການວັນປະຈຳເດືອນຄັ້ງຕໍ່ໄປ:'),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: Colors.red),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⏰ ຕັ້ງເວລາ (ລະອຽດເຖິງວິນາທີ):'),
        const SizedBox(height: 16),
        _buildPreciseTimePicker(),
      ],
    );
  }

  // ສ້າງ time picker ທີ່ມີວິນາທີ
  Widget _buildPreciseTimePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _selectedTime.format(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 16),

          // Hour selector
          Row(
            children: [
              const Text('ຊົ່ວໂມງ: '),
              Expanded(
                child: Slider(
                  value: _selectedTime.hour.toDouble(),
                  min: 0,
                  max: 23,
                  divisions: 23,
                  label: '${_selectedTime.hour}',
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = PreciseTime(
                        hour: value.round(),
                        minute: _selectedTime.minute,
                        second: _selectedTime.second,
                      );
                    });
                  },
                ),
              ),
              Text('${_selectedTime.hour}'),
            ],
          ),

          // Minute selector
          Row(
            children: [
              const Text('ນາທີ: '),
              Expanded(
                child: Slider(
                  value: _selectedTime.minute.toDouble(),
                  min: 0,
                  max: 59,
                  divisions: 59,
                  label: '${_selectedTime.minute}',
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = PreciseTime(
                        hour: _selectedTime.hour,
                        minute: value.round(),
                        second: _selectedTime.second,
                      );
                    });
                  },
                ),
              ),
              Text('${_selectedTime.minute}'),
            ],
          ),

          // Second selector
          Row(
            children: [
              const Text('ວິນາທີ: '),
              Expanded(
                child: Slider(
                  value: _selectedTime.second.toDouble(),
                  min: 0,
                  max: 59,
                  divisions: 59,
                  label: '${_selectedTime.second}',
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = PreciseTime(
                        hour: _selectedTime.hour,
                        minute: _selectedTime.minute,
                        second: value.round(),
                      );
                    });
                  },
                ),
              ),
              Text('${_selectedTime.second}'),
            ],
          ),

          const SizedBox(height: 16),

          // Quick time buttons
          Wrap(
            spacing: 8,
            children: [
              _buildQuickTimeButton('ຕອນນີ້', DateTime.now()),
              _buildQuickTimeButton(
                  '5 ວິນາທີ', DateTime.now().add(const Duration(seconds: 5))),
              _buildQuickTimeButton(
                  '30 ວິນາທີ', DateTime.now().add(const Duration(seconds: 30))),
              _buildQuickTimeButton(
                  '1 ນາທີ', DateTime.now().add(const Duration(minutes: 1))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeButton(String label, DateTime time) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedTime = PreciseTime(
            hour: time.hour,
            minute: time.minute,
            second: time.second,
          );
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE91E63),
        side: const BorderSide(color: Color(0xFFE91E63)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  String _getWeekdayName(int weekday) {
    const names = ['ຈັນ', 'ອັງຄານ', 'ພຸດ', 'ພະຫັດ', 'ສຸກ', 'ເສົາ', 'ອາທິດ'];
    return names[weekday - 1];
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return 'ການກິນຢາ';
      case NotificationType.sleep:
        return 'ການນອນ';
      case NotificationType.exercise:
        return 'ອອກກຳລັງກາຍ';
      case NotificationType.period:
        return 'ປະຈຳເດືອນ';
      case NotificationType.report:
        return 'ລາຍງານ';
      case NotificationType.goal:
        return 'ເປົ້າຫມາຍ';
    }
  }

  void _scheduleNotification() async {
    try {
      switch (widget.type) {
        case NotificationType.medication:
          if (_medicationTimes.isNotEmpty) {
            // Schedule multiple medication reminders with precise timing
            for (var time in _medicationTimes) {
              final now = DateTime.now();
              final scheduledTime = time.toDateTime(now);

              // If time has passed today, schedule for tomorrow
              final actualTime = scheduledTime.isBefore(now)
                  ? scheduledTime.add(const Duration(days: 1))
                  : scheduledTime;

              await EnhancedNotificationService.scheduleNotification(
                title: '💊 ເວລາກິນຢາ',
                body: 'ຖືງເວລາກິນຢາແລ້ວ (${time.format()})',
                type: NotificationType.medication,
                scheduledTime: actualTime,
                data: {
                  'medication_time': time.format(),
                  'precise_time': true,
                },
              );
            }
          }
          break;

        case NotificationType.sleep:
          final now = DateTime.now();
          final bedtime = _selectedTime.toDateTime(now);

          // If bedtime has passed today, schedule for tomorrow
          final actualBedtime = bedtime.isBefore(now)
              ? bedtime.add(const Duration(days: 1))
              : bedtime;

          await EnhancedNotificationService.scheduleNotification(
            title: '😴 ເວລານອນ',
            body:
                'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ (${_selectedTime.format()})',
            type: NotificationType.sleep,
            scheduledTime: actualBedtime,
            data: {
              'bedtime': _selectedTime.format(),
              'precise_time': true,
            },
          );
          break;

        case NotificationType.exercise:
          if (_selectedWeekdays.isNotEmpty) {
            // Schedule for next 4 weeks with precise timing
            final now = DateTime.now();
            for (int week = 0; week < 4; week++) {
              for (int weekday in _selectedWeekdays) {
                final targetDate =
                    _getNextWeekday(now.add(Duration(days: week * 7)), weekday);
                final scheduledTime = _selectedTime.toDateTime(targetDate);

                if (scheduledTime.isAfter(now)) {
                  await EnhancedNotificationService.scheduleNotification(
                    title: '🏃‍♀️ ເວລາອອກກຳລັງກາຍ',
                    body:
                        'ມາອອກກຳລັງກາຍເພື່ອສຸຂະພາບທີ່ດີກັນເຖາະ! (${_selectedTime.format()})',
                    type: NotificationType.exercise,
                    scheduledTime: scheduledTime,
                    data: {
                      'exercise_time': _selectedTime.format(),
                      'weekday': weekday,
                      'precise_time': true,
                    },
                  );
                }
              }
            }
          }
          break;

        case NotificationType.period:
          // Schedule period predictions
          await EnhancedNotificationService.scheduleNotification(
            title: '🩸 ການແຈ້ງເຕືອນປະຈຳເດືອນ',
            body: 'ປະຈຳເດືອນອາດຈະມາໃນອີກ 3 ວັນ ຈະຕຽມພ້ອມບໍ່?',
            type: NotificationType.period,
            scheduledTime: _selectedDate.subtract(const Duration(days: 3)),
            data: {'days_until': 3, 'type': 'warning'},
          );

          await EnhancedNotificationService.scheduleNotification(
            title: '🩸 ວັນປະຈຳເດືອນ',
            body: 'ວັນນີ້ອາດເປັນວັນປະຈຳເດືອນ ດູແລຕົນເອງໃຫ້ດີ',
            type: NotificationType.period,
            scheduledTime: _selectedDate,
            data: {'days_until': 0, 'type': 'today'},
          );
          break;

        default:
          // For other types, schedule a simple reminder with precise timing
          final now = DateTime.now();
          final scheduledTime = _selectedTime.toDateTime(now);

          final actualTime = scheduledTime.isBefore(now)
              ? scheduledTime.add(const Duration(days: 1))
              : scheduledTime;

          await EnhancedNotificationService.scheduleNotification(
            title: '⏰ ການແຈ້ງເຕືອນ ${_getTypeLabel(widget.type)}',
            body:
                'ນີ້ແມ່ນການແຈ້ງເຕືອນທີ່ເຈົ້າຕັ້ງໄວ້ (${_selectedTime.format()})',
            type: widget.type,
            scheduledTime: actualTime,
            data: {
              'scheduled_time': _selectedTime.format(),
              'precise_time': true,
            },
          );
          break;
      }

      widget.onScheduled();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ເກີດຂໍ້ຜິດພາດ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to get next weekday
  DateTime _getNextWeekday(DateTime date, int weekday) {
    final daysUntil = (weekday - date.weekday) % 7;
    return date.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
  }
}
