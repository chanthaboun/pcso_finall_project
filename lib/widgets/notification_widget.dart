// lib/widgets/notification_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';
import '../screens/notifications_screen.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  List<NotificationData> _recentNotifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupNotificationCallback();
  }

  void _loadNotifications() {
    setState(() {
      final allNotifications = NotificationService.getAllNotifications();
      _recentNotifications = allNotifications
          .where((n) => n.scheduledTime
              .isAfter(DateTime.now().subtract(const Duration(days: 3))))
          .take(3)
          .toList();
      _unreadCount = NotificationService.getUnreadNotifications().length;
    });
  }

  void _setupNotificationCallback() {
    NotificationService.setNotificationCallback((notification) {
      _showNotificationDialog(notification);
      _loadNotifications();
    });
  }

  void _showNotificationDialog(NotificationData notification) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getTypeIcon(notification.type),
                color: _getTypeColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              NotificationService.markAsRead(notification.id);
              _loadNotifications();
            },
            child: const Text('ປິດ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              NotificationService.markAsRead(notification.id);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
            ),
            child: const Text('ເບິ່ງທັງໝົດ'),
          ),
        ],
      ),
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
        return const Color(0xFF2196F3);
      case NotificationType.sleep:
        return const Color(0xFF9C27B0);
      case NotificationType.exercise:
        return const Color(0xFFFF6B35);
      case NotificationType.period:
        return const Color(0xFFE91E63);
      case NotificationType.report:
        return const Color(0xFF009688);
      case NotificationType.goal:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recentNotifications.isEmpty && _unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE91E63).withOpacity(0.1),
                      const Color(0xFFE91E63).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFE91E63),
                      size: 24,
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ການແຈ້ງເຕືອນ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    if (_unreadCount > 0)
                      Text(
                        '$_unreadCount ຂໍ້ຄວາມໃໝ່',
                        style: const TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      const Text(
                        'ທັງໝົດອ່ານແລ້ວ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()))
                      .then((_) => _loadNotifications());
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFE91E63).withOpacity(0.2),
                    ),
                  ),
                  child: const Text(
                    'ເບິ່ງທັງໝົດ',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Recent notifications preview
          if (_recentNotifications.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recentNotifications.first.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Quick Actions Widget for scheduling notifications
class QuickNotificationActions extends StatelessWidget {
  const QuickNotificationActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35).withOpacity(0.1),
                      const Color(0xFFFF6B35).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Color(0xFFFF6B35),
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ການແຈ້ງເຕືອນດ່ວນ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'ຕັ້ງການແຈ້ງເຕືອນໄວ',
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
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildQuickAction(
                context,
                'ຢາ 30 ນາທີ',
                Icons.medication,
                const Color(0xFF2196F3),
                () => _scheduleQuickMedication(context),
              ),
              _buildQuickAction(
                context,
                'ນອນ 22:00',
                Icons.bedtime,
                const Color(0xFF9C27B0),
                () => _scheduleQuickSleep(context),
              ),
              _buildQuickAction(
                context,
                'ອອກກຳລັງ',
                Icons.fitness_center,
                const Color(0xFFFF6B35),
                () => _scheduleQuickExercise(context),
              ),
              _buildQuickAction(
                context,
                'ດື່ມນ້ຳ',
                Icons.local_drink,
                const Color(0xFF009688),
                () => _scheduleQuickWater(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleQuickMedication(BuildContext context) async {
    final future = DateTime.now().add(const Duration(minutes: 30));
    await NotificationService.scheduleNotification(
      title: '💊 ເວລາກິນຢາ',
      body: 'ຖືງເວລາກິນຢາແລ້ວ',
      type: NotificationType.medication,
      scheduledTime: future,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ຕັ້ງການແຈ້ງເຕືອນກິນຢາໃນ 30 ນາທີແລ້ວ'),
          backgroundColor: Color(0xFF2196F3),
        ),
      );
    }
  }

  void _scheduleQuickSleep(BuildContext context) async {
    final today = DateTime.now();
    final bedtime = DateTime(today.year, today.month, today.day, 22, 0);
    final actualBedtime = bedtime.isBefore(today)
        ? bedtime.add(const Duration(days: 1))
        : bedtime;

    await NotificationService.scheduleNotification(
      title: '😴 ເວລານອນ',
      body: 'ຖືງເວລານອນແລ້ວ ພັກຜ່ອນໃຫ້ເພຽງພໍ',
      type: NotificationType.sleep,
      scheduledTime: actualBedtime,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ຕັ້ງການແຈ້ງເຕືອນນອນເວລາ 22:00 ແລ້ວ'),
          backgroundColor: Color(0xFF9C27B0),
        ),
      );
    }
  }

  void _scheduleQuickExercise(BuildContext context) async {
    final future = DateTime.now().add(const Duration(hours: 1));
    await NotificationService.scheduleNotification(
      title: '🏃‍♀️ ເວລາອອກກຳລັງກາຍ',
      body: 'ມາອອກກຳລັງກາຍເພື່ອສຸຂະພາບທີ່ດີກັນເຖາະ!',
      type: NotificationType.exercise,
      scheduledTime: future,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ຕັ້ງການແຈ້ງເຕືອນອອກກຳລັງກາຍໃນ 1 ຊົ່ວໂມງແລ້ວ'),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );
    }
  }

  void _scheduleQuickWater(BuildContext context) async {
    final future = DateTime.now().add(const Duration(hours: 2));
    await NotificationService.scheduleNotification(
      title: '💧 ດື່ມນ້ຳ',
      body: 'ຖືງເວລາດື່ມນ້ຳແລ້ວ ຮັກສາຮ່າງກາຍໃຫ້ມີນ້ຳພຽງພໍ',
      type: NotificationType.goal,
      scheduledTime: future,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ຕັ້ງການແຈ້ງເຕືອນດື່ມນ້ຳໃນ 2 ຊົ່ວໂມງແລ້ວ'),
          backgroundColor: Color(0xFF009688),
        ),
      );
    }
  }
}
