// lib/widgets/enhanced_test_notification_widget.dart - Real-time Schedule Version
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/enhanced_notification_service.dart';

class EnhancedTestNotificationWidget extends StatefulWidget {
  const EnhancedTestNotificationWidget({super.key});

  @override
  State<EnhancedTestNotificationWidget> createState() =>
      _EnhancedTestNotificationWidgetState();
}

class _EnhancedTestNotificationWidgetState
    extends State<EnhancedTestNotificationWidget> {
  Map<String, dynamic> _debugInfo = {};
  TimeOfDay _selectedTime = TimeOfDay.now();
  Timer? _clockTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateDebugInfo();
    _startClock();

    // Update debug info every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _updateDebugInfo();
      } else {
        timer.cancel();
      }
    });
  }

  void _startClock() {
    _updateCurrentTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCurrentTime();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  void _updateDebugInfo() {
    setState(() {
      _debugInfo = EnhancedNotificationService.getDebugInfo();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(22.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⏰ ກຳນົດການແຈ້ງເຕືອນ Real-time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ເວລາປັດຈຸບັນ: $_currentTime',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Debug Info Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'ຂໍ້ມູນລະບົບ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _debugInfo['timer_active'] == true
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _debugInfo['timer_active'] == true ? 'ເຮັດວຽກ' : 'ຢຸດ',
                      style: TextStyle(
                        fontSize: 10,
                        color: _debugInfo['timer_active'] == true
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ທັງໝົດ: ${_debugInfo['total_notifications']} | '
                  'ເຮັດວຽກ: ${_debugInfo['active_notifications']} | '
                  'ຍັງບໍ່ອ່ານ: ${_debugInfo['unread_notifications']}',
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'ຕໍ່ໄປ: ${_getNextNotificationText()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Time picker section
          const Text(
            'ເລືອກເວລາແຈ້ງເຕືອນ:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Time picker card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ເວລາທີ່ເລືອກ:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('ເປลີ່ຍນ'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick time buttons
          const Text(
            'ເວລາດ່ວນ:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickTimeButton(
                  context,
                  '+1 ນາທີ',
                  Colors.green,
                  () => _setQuickTime(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickTimeButton(
                  context,
                  '+2 ນາທີ',
                  Colors.blue,
                  () => _setQuickTime(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickTimeButton(
                  context,
                  '+5 ນາທີ',
                  Colors.purple,
                  () => _setQuickTime(5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Type-based schedule
          const Text(
            'ກຳນົດຕາມປະເພດ:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildScheduleButton(
                context,
                'ຢາ',
                Icons.medication,
                Colors.blue,
                () => _scheduleTypeNotification(
                    context, NotificationType.medication, 'ຢາ'),
              ),
              _buildScheduleButton(
                context,
                'ນອນ',
                Icons.bedtime,
                Colors.purple,
                () => _scheduleTypeNotification(
                    context, NotificationType.sleep, 'ນອນ'),
              ),
              _buildScheduleButton(
                context,
                'ອອກກຳລັງ',
                Icons.fitness_center,
                Colors.orange,
                () => _scheduleTypeNotification(
                    context, NotificationType.exercise, 'ອອກກຳລັງ'),
              ),
              _buildScheduleButton(
                context,
                'ເປົ້າຫມາຍ',
                Icons.flag,
                Colors.teal,
                () => _scheduleTypeNotification(
                    context, NotificationType.goal, 'ເປົ້າຫມາຍ'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _forceCheck(context),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(
                    'ກວດສອບ',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _markAllAsRead(context),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text(
                    'ອ່ານທັງໝົດ',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Clear button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _clearAllNotifications(context),
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text(
                'ລຶບການແຈ້ງເຕືອນທັງໝົດ',
                style: TextStyle(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildScheduleButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Set quick time (current time + minutes)
  void _setQuickTime(int addMinutes) {
    final now = DateTime.now();
    final futureTime = now.add(Duration(minutes: addMinutes));
    setState(() {
      _selectedTime =
          TimeOfDay(hour: futureTime.hour, minute: futureTime.minute);
    });
  }

  // Schedule notification for selected type
  Future<void> _scheduleTypeNotification(
      BuildContext context, NotificationType type, String typeName) async {
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If the time has passed today, schedule for tomorrow
    final actualDateTime = scheduledDateTime.isBefore(now)
        ? scheduledDateTime.add(const Duration(days: 1))
        : scheduledDateTime;

    await EnhancedNotificationService.scheduleNotification(
      title: '${_getTypeEmoji(type)} ເວລາ$typeName',
      body: 'ຖືງເວລາ$typeName ແລ້ວ! (${_selectedTime.format(context)})',
      type: type,
      scheduledTime: actualDateTime,
      data: {'scheduled_time': _selectedTime.format(context)},
    );

    _updateDebugInfo();

    if (context.mounted) {
      final dayText = actualDateTime.day == now.day ? 'ມື້ນີ້' : 'ມື້ອື່ນ';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_getTypeEmoji(type)} ກຳນົດ$typeName ເວລາ ${_selectedTime.format(context)} $dayText'),
          backgroundColor: _getTypeColor(type),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Force check notifications
  void _forceCheck(BuildContext context) {
    EnhancedNotificationService.forceCheckNotifications();
    _updateDebugInfo();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 ກວດສອບການແຈ້ງເຕືອນແລ້ວ'),
        backgroundColor: Colors.indigo,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Mark all as read
  Future<void> _markAllAsRead(BuildContext context) async {
    await EnhancedNotificationService.markAllAsRead();
    _updateDebugInfo();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ໝາຍການແຈ້ງເຕືອນທັງໝົດເປັນອ່ານແລ້ວ'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Clear all notifications
  Future<void> _clearAllNotifications(BuildContext context) async {
    final notifications = EnhancedNotificationService.getAllNotifications();
    await EnhancedNotificationService.resetAllNotifications();
    _updateDebugInfo();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ ລຶບການແຈ້ງເຕືອນ ${notifications.length} ອັນແລ້ວ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper methods
  String _getNextNotificationText() {
    final nextNotificationStr = _debugInfo['next_notification']?.toString();
    if (nextNotificationStr == null || nextNotificationStr == 'None') {
      return 'ບໍ່ມີ';
    }
    return nextNotificationStr.split('.')[0];
  }

  String _getTypeEmoji(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return '💊';
      case NotificationType.sleep:
        return '😴';
      case NotificationType.exercise:
        return '🏃‍♀️';
      case NotificationType.period:
        return '🩸';
      case NotificationType.report:
        return '📊';
      case NotificationType.goal:
        return '🎯';
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
}
