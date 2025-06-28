// lib/screens/enhanced_notifications_screen.dart
import 'package:flutter/material.dart';
import '../services/enhanced_notification_service.dart';

class EnhancedNotificationsScreen extends StatefulWidget {
  const EnhancedNotificationsScreen({super.key});

  @override
  State<EnhancedNotificationsScreen> createState() =>
      _EnhancedNotificationsScreenState();
}

class _EnhancedNotificationsScreenState
    extends State<EnhancedNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifications = EnhancedNotificationService.getAllNotifications();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ການແຈ້ງເຕືອນ'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              EnhancedNotificationService.markAllAsRead();
              setState(() {});
            },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('ບໍ່ມີການແຈ້ງເຕືອນ'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: Icon(
                    _getTypeIcon(notification.type),
                    color: notification.isRead
                        ? Colors.grey
                        : const Color(0xFFE91E63),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notification.body),
                  trailing: notification.isRead
                      ? null
                      : const Icon(Icons.circle, color: Colors.red, size: 8),
                  onTap: () {
                    EnhancedNotificationService.markAsRead(notification.id);
                    setState(() {});
                  },
                );
              },
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
}
