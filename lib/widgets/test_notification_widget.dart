// lib/widgets/test_notification_widget.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class TestNotificationWidget extends StatelessWidget {
  const TestNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.bug_report,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ທົດສອບການແຈ້ງເຕືອນ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'ກົດປຸ່ມເພື່ອທົດສອບການແຈ້ງເຕືອນແຕ່ລະປະເພດ:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _scheduleMultipleTests(context),
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text(
                    'ທົດສອບທັງໝົດ',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _clearAllNotifications(context),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text(
                    'ລຶບທັງໝົດ',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      onTap: onPressed,
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

  Future<void> _testMedicationNotification(BuildContext context) async {
    await NotificationService.scheduleNotification(
      title: '💊 ທົດສອບການແຈ້ງເຕືອນກິນຢາ',
      body:
          'ນີ້ແມ່ນການທົດສອບການແຈ້ງເຕືອນກິນຢາ ຖ້າເຈົ້າເຫັນຂໍ້ຄວາມນີ້ ແມ່ນການແຈ້ງເຕືອນເຮັດວຽກປົກກະຕິ',
      type: NotificationType.medication,
      scheduledTime: DateTime.now().add(const Duration(seconds: 3)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ທົດສອບການແຈ້ງເຕືອນກິນຢາໃນ 3 ວິນາທີ...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testSleepNotification(BuildContext context) async {
    await NotificationService.scheduleNotification(
      title: '😴 ທົດສອບການແຈ້ງເຕືອນນອນ',
      body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
      type: NotificationType.sleep,
      scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ທົດສອບການແຈ້ງເຕືອນນອນໃນ 5 ວິນາທີ...'),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testExerciseNotification(BuildContext context) async {
    await NotificationService.scheduleNotification(
      title: '🏃‍♀️ ທົດສອບການແຈ້ງເຕືອນອອກກຳລັງກາຍ',
      body: 'ມາອອກກຳລັງກາຍເພື່ອສຸຂະພາບທີ່ດີກັນເຖາະ!',
      type: NotificationType.exercise,
      scheduledTime: DateTime.now().add(const Duration(seconds: 7)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ທົດສອບການແຈ້ງເຕືອນອອກກຳລັງກາຍໃນ 7 ວິນາທີ...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testPeriodNotification(BuildContext context) async {
    await NotificationService.scheduleNotification(
      title: '🩸 ທົດສອບການແຈ້ງເຕືອນປະຈຳເດືອນ',
      body: 'ການແຈ້ງເຕືອນກ່ຽວກັບປະຈຳເດືອນຂອງເຈົ້າ',
      type: NotificationType.period,
      scheduledTime: DateTime.now().add(const Duration(seconds: 9)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ທົດສອບການແຈ້ງເຕືອນປະຈຳເດືອນໃນ 9 ວິນາທີ...'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testReportNotification(BuildContext context) async {
    await NotificationService.scheduleNotification(
      title: '📊 ທົດສອບລາຍງານປະຈຳອາທິດ',
      body: 'ລາຍງານສຸຂະພາບປະຈຳອາທິດຂອງເຈົ້າພ້ອມແລ້ວ!',
      type: NotificationType.report,
      scheduledTime: DateTime.now().add(const Duration(seconds: 11)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ທົດສອບລາຍງານໃນ 11 ວິນາທີ...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testGoalNotification(BuildContext context) async {
    await NotificationService.scheduleNotification(
      title: '🎯 ທົດສອບການແຈ້ງເຕືອນເປົ້າຫມາຍ',
      body: 'ມາຕິດຕາມຄວາມຄືບໜ້າເປົ້າຫມາຍຂອງເຈົ້າ!',
      type: NotificationType.goal,
      scheduledTime: DateTime.now().add(const Duration(seconds: 13)),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ທົດສອບເປົ້າຫມາຍໃນ 13 ວິນາທີ...'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _scheduleMultipleTests(BuildContext context) async {
    // Schedule all types with different intervals
    _testMedicationNotification(context);
    await Future.delayed(const Duration(milliseconds: 500));
    _testSleepNotification(context);
    await Future.delayed(const Duration(milliseconds: 500));
    _testExerciseNotification(context);
    await Future.delayed(const Duration(milliseconds: 500));
    _testPeriodNotification(context);
    await Future.delayed(const Duration(milliseconds: 500));
    _testReportNotification(context);
    await Future.delayed(const Duration(milliseconds: 500));
    _testGoalNotification(context);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ກຳລັງທົດສອບການແຈ້ງເຕືອນທັງໝົດ! ລໍຖ້າ...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _clearAllNotifications(BuildContext context) async {
    // Get all notifications
    final notifications = NotificationService.getAllNotifications();

    // Cancel all notifications
    for (var notification in notifications) {
      await NotificationService.cancelNotification(notification.id);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ລຶບການແຈ້ງເຕືອນ ${notifications.length} ອັນແລ້ວ'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
