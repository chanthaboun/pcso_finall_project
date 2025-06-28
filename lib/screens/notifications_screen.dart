// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'notification_settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationData> _notifications = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = NotificationService.getAllNotifications()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    });
  }

  List<NotificationData> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'medication':
        return _notifications
            .where((n) => n.type == NotificationType.medication)
            .toList();
      case 'sleep':
        return _notifications
            .where((n) => n.type == NotificationType.sleep)
            .toList();
      case 'exercise':
        return _notifications
            .where((n) => n.type == NotificationType.exercise)
            .toList();
      case 'period':
        return _notifications
            .where((n) => n.type == NotificationType.period)
            .toList();
      default:
        return _notifications;
    }
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} ວັນກ່ອນ';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ຊົ່ວໂມງກ່ອນ';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ນາທີກ່ອນ';
    } else {
      return 'ບໍ່ດົນມານີ້';
    }
  }

  void _markAsRead(NotificationData notification) async {
    await NotificationService.markAsRead(notification.id);
    _loadNotifications();
  }

  void _showNotificationDetails(NotificationData notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NotificationDetailsSheet(
        notification: notification,
        onMarkAsRead: () => _markAsRead(notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ການແຈ້ງເຕືອນ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount ຂໍ້ຄວາມໃໝ່',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  )
                  .then((_) => _loadNotifications());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'ທັງໝົດ', Icons.notifications),
                  _buildFilterChip(
                      'unread', 'ຍັງບໍ່ໄດ້ອ່ານ', Icons.mark_email_unread),
                  _buildFilterChip('medication', 'ຢາ', Icons.medication),
                  _buildFilterChip('sleep', 'ນອນ', Icons.bedtime),
                  _buildFilterChip(
                      'exercise', 'ອອກກຳລັງ', Icons.fitness_center),
                  _buildFilterChip('period', 'ປະຈຳເດືອນ', Icons.calendar_today),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationData notification) {
    final isOverdue = notification.scheduledTime.isBefore(DateTime.now()) &&
        !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead
            ? null
            : Border.all(color: const Color(0xFFE91E63), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _showNotificationDetails(notification),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getTypeIcon(notification.type),
                color: _getTypeColor(notification.type),
                size: 24,
              ),
            ),
            if (!notification.isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ຜ່ານກຳນົດ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTypeLabel(notification.type),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTypeColor(notification.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(notification.scheduledTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : IconButton(
                icon: const Icon(Icons.mark_email_read, size: 20),
                onPressed: () => _markAsRead(notification),
                color: const Color(0xFFE91E63),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter == 'unread'
                ? Icons.mark_email_read_outlined
                : Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'unread'
                ? 'ບໍ່ມີການແຈ້ງເຕືອນທີ່ຍັງບໍ່ໄດ້ອ່ານ'
                : 'ບໍ່ມີການແຈ້ງເຕືອນ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'unread'
                ? 'ເຈົ້າໄດ້ອ່ານການແຈ້ງເຕືອນທັງໝົດແລ້ວ! 👏'
                : 'ການແຈ້ງເຕືອນຈະປາກົດຢູ່ນີ້',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Notification Details Bottom Sheet
class NotificationDetailsSheet extends StatelessWidget {
  final NotificationData notification;
  final VoidCallback onMarkAsRead;

  const NotificationDetailsSheet({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _getTypeColor(notification.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTypeLabel(notification.type),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTypeColor(notification.type),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Content
          Text(
            'ລາຍລະອຽດ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notification.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Time info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ເວລາທີ່ກຳນົດ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatDateTime(notification.scheduledTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Additional data if available
          if (notification.data != null && notification.data!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'ຂໍ້ມູນເພີ່ມເຕີມ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notification.data!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              if (!notification.isRead)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onMarkAsRead();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.mark_email_read),
                    label: const Text('ໝາຍວ່າອ່ານແລ້ວ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (!notification.isRead) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE91E63),
                    side: const BorderSide(color: Color(0xFFE91E63)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('ປິດ'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateText;
    if (targetDate == today) {
      dateText = 'ມື້ນີ້';
    } else if (targetDate == yesterday) {
      dateText = 'ມື້ວານ';
    } else if (targetDate == tomorrow) {
      dateText = 'ມື້ອື່ນ';
    } else {
      dateText = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeText =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateText ເວລາ $timeText';
  }
}
