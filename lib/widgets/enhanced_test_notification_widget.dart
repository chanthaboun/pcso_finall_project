// lib/widgets/enhanced_test_notification_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/enhanced_notification_service.dart';

class EnhancedTestNotificationWidget extends StatelessWidget {
  const EnhancedTestNotificationWidget({super.key});

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
                  Icons.bug_report,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧪 ທົດສອບການແຈ້ງເຕືອນ Real-time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ກົດເພື່ອທົດສອບການແຈ້ງເຕືອນແບບ real-time',
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
          const SizedBox(height: 20),

          // Quick test buttons
          const Text(
            'ທົດສອບໄວ (Real-time):',
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
                child: _buildQuickTestButton(
                  context,
                  '⚡ 5 ວິນາທີ',
                  Colors.red,
                  () => _testQuickNotification(context, 5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickTestButton(
                  context,
                  '🚀 10 ວິນາທີ',
                  Colors.blue,
                  () => _testQuickNotification(context, 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Type-based tests
          const Text(
            'ທົດສອບຕາມປະເພດ:',
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
              _buildTestButton(
                context,
                'ຢາ',
                Icons.medication,
                Colors.blue,
                () => _testMedicationNotification(context),
              ),
              _buildTestButton(
                context,
                'ນອນ',
                Icons.bedtime,
                Colors.purple,
                () => _testSleepNotification(context),
              ),
              _buildTestButton(
                context,
                'ອອກກຳລັງ',
                Icons.fitness_center,
                Colors.orange,
                () => _testExerciseNotification(context),
              ),
              _buildTestButton(
                context,
                'ປະຈຳເດືອນ',
                Icons.calendar_today,
                Colors.red,
                () => _testPeriodNotification(context),
              ),
              _buildTestButton(
                context,
                'ລາຍງານ',
                Icons.analytics,
                Colors.green,
                () => _testReportNotification(context),
              ),
              _buildTestButton(
                context,
                'ເປົ້າຫມາຍ',
                Icons.flag,
                Colors.teal,
                () => _testGoalNotification(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _scheduleExactTimeTest(context),
                  icon: const Icon(Icons.schedule_outlined, size: 18),
                  label: const Text(
                    'ທົດສອບເວລາ 23:45',
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

  Widget _buildQuickTestButton(
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
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTestButton(
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

  // Quick notification test
  Future<void> _testQuickNotification(BuildContext context, int seconds) async {
    await EnhancedNotificationService.scheduleNotification(
      title: '⚡ ທົດສອບການແຈ້ງເຕືອນໄວ',
      body: 'ນີ້ແມ່ນການທົດສອບການແຈ້ງເຕືອນໃນ $seconds ວິນາທີ!',
      type: NotificationType.goal,
      scheduledTime: DateTime.now().add(Duration(seconds: seconds)),
      data: {'test_type': 'quick', 'seconds': seconds},
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚀 ກຳນົດການແຈ້ງເຕືອນໃນ $seconds ວິນາທີແລ້ວ'),
          backgroundColor: seconds == 5 ? Colors.red : Colors.blue,
          duration: Duration(seconds: seconds),
        ),
      );
    }
  }

  // Test exact time (23:45)
  Future<void> _scheduleExactTimeTest(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Set to 23:45
    DateTime bedtime = DateTime(today.year, today.month, today.day, 23, 45);

    // If already passed today, schedule for tomorrow
    if (bedtime.isBefore(now)) {
      bedtime = bedtime.add(const Duration(days: 1));
    }

    await EnhancedNotificationService.scheduleNotification(
      title: '🌙 ເວລານອນ 23:45',
      body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
      type: NotificationType.sleep,
      scheduledTime: bedtime,
      data: {'exact_time': '23:45', 'test': true},
    );

    if (context.mounted) {
      final dayText = bedtime.day == now.day ? 'ມື້ນີ້' : 'ມື້ອື່ນ';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏰ ກຳນົດການແຈ້ງເຕືອນນອນເວລາ 23:45 $dayText ແລ້ວ'),
          backgroundColor: Colors.indigo,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Test medication notification
  Future<void> _testMedicationNotification(BuildContext context) async {
    await EnhancedNotificationService.scheduleNotification(
      title: '💊 ທົດສອບການແຈ້ງເຕືອນກິນຢາ',
      body: 'ຖືງເວລາກິນຢາແລ້ວ! ນີ້ແມ່ນການທົດສອບ',
      type: NotificationType.medication,
      scheduledTime: DateTime.now().add(const Duration(seconds: 3)),
      data: {'medication': 'ຢາທົດສອບ'},
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💊 ທົດສອບການແຈ້ງເຕືອນກິນຢາໃນ 3 ວິນາທີ'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // Test sleep notification
  Future<void> _testSleepNotification(BuildContext context) async {
    await EnhancedNotificationService.scheduleNotification(
      title: '😴 ທົດສອບການແຈ້ງເຕືອນນອນ',
      body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
      type: NotificationType.sleep,
      scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('😴 ທົດສອບການແຈ້ງເຕືອນນອນໃນ 5 ວິນາທີ'),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  // Test exercise notification
  Future<void> _testExerciseNotification(BuildContext context) async {
    await EnhancedNotificationService.scheduleNotification(
      title: '🏃‍♀️ ທົດສອບການແຈ້ງເຕືອນອອກກຳລັງກາຍ',
      body: 'ມາອອກກຳລັງກາຍເພື່ອສຸຂະພາບທີ່ດີກັນເຖາະ!',
      type: NotificationType.exercise,
      scheduledTime: DateTime.now().add(const Duration(seconds: 7)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🏃‍♀️ ທົດສອບການແຈ້ງເຕືອນອອກກຳລັງກາຍໃນ 7 ວິນາທີ'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Test period notification
  Future<void> _testPeriodNotification(BuildContext context) async {
    await EnhancedNotificationService.scheduleNotification(
      title: '🩸 ທົດສອບການແຈ້ງເຕືອນປະຈຳເດືອນ',
      body: 'ການແຈ້ງເຕືອນກ່ຽວກັບປະຈຳເດືອນຂອງເຈົ້າ',
      type: NotificationType.period,
      scheduledTime: DateTime.now().add(const Duration(seconds: 9)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🩸 ທົດສອບການແຈ້ງເຕືອນປະຈຳເດືອນໃນ 9 ວິນາທີ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Test report notification
  Future<void> _testReportNotification(BuildContext context) async {
    await EnhancedNotificationService.scheduleNotification(
      title: '📊 ທົດສອບລາຍງານປະຈຳອາທິດ',
      body: 'ລາຍງານສຸຂະພາບປະຈຳອາທິດຂອງເຈົ້າພ້ອມແລ້ວ!',
      type: NotificationType.report,
      scheduledTime: DateTime.now().add(const Duration(seconds: 11)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📊 ທົດສອບລາຍງານໃນ 11 ວິນາທີ'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Test goal notification
  Future<void> _testGoalNotification(BuildContext context) async {
    await EnhancedNotificationService.scheduleNotification(
      title: '🎯 ທົດສອບການແຈ້ງເຕືອນເປົ້າຫມາຍ',
      body: 'ມາຕິດຕາມຄວາມຄືບໜ້າເປົ້າຫມາຍຂອງເຈົ້າ!',
      type: NotificationType.goal,
      scheduledTime: DateTime.now().add(const Duration(seconds: 13)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎯 ທົດສອບເປົ້າຫມາຍໃນ 13 ວິນາທີ'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  // Mark all as read
  Future<void> _markAllAsRead(BuildContext context) async {
    await EnhancedNotificationService.markAllAsRead();

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

    for (var notification in notifications) {
      await EnhancedNotificationService.cancelNotification(notification.id);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ ລຶບການແຈ້ງເຕືອນ ${notifications.length} ອັນແລ້ວ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}







