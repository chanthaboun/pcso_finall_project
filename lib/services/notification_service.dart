// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

enum NotificationType {
  medication,
  sleep,
  exercise,
  period,
  report,
  goal,
}

class NotificationData {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool isActive;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.data,
    this.isRead = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.index,
        'scheduledTime': scheduledTime.toIso8601String(),
        'data': data,
        'isRead': isRead,
        'isActive': isActive,
      };

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        type: NotificationType.values[json['type']],
        scheduledTime: DateTime.parse(json['scheduledTime']),
        data: json['data'],
        isRead: json['isRead'] ?? false,
        isActive: json['isActive'] ?? true,
      );

  NotificationData copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? scheduledTime,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isActive,
  }) =>
      NotificationData(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        data: data ?? this.data,
        isRead: isRead ?? this.isRead,
        isActive: isActive ?? this.isActive,
      );
}

class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  static const String _settingsKey = 'notification_settings';

  static List<NotificationData> _notifications = [];
  static Map<NotificationType, bool> _settings = {
    NotificationType.medication: true,
    NotificationType.sleep: true,
    NotificationType.exercise: true,
    NotificationType.period: true,
    NotificationType.report: true,
    NotificationType.goal: true,
  };

  static Timer? _checkTimer;
  static Function(NotificationData)? _onNotificationCallback;

  // Initialize notification service
  static Future<void> initialize() async {
    await _loadNotifications();
    await _loadSettings();
    _startPeriodicCheck();
  }

  // Set callback for when notification is triggered
  static void setNotificationCallback(Function(NotificationData) callback) {
    _onNotificationCallback = callback;
  }

  // Load notifications from storage
  static Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        _notifications = notificationsList
            .map((json) => NotificationData.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  // Save notifications to storage
  static Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        _notifications.map((notification) => notification.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Load notification settings
  static Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
        for (var type in NotificationType.values) {
          _settings[type] = settingsMap[type.toString()] ?? true;
        }
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  // Save notification settings
  static Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsMap = <String, bool>{};
      for (var entry in _settings.entries) {
        settingsMap[entry.key.toString()] = entry.value;
      }
      await prefs.setString(_settingsKey, jsonEncode(settingsMap));
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  // Start periodic check for due notifications
  static void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkDueNotifications();
    });
  }

  // Check for due notifications
  static void _checkDueNotifications() {
    final now = DateTime.now();
    final dueNotifications = _notifications
        .where((notification) =>
            notification.isActive &&
            !notification.isRead &&
            notification.scheduledTime.isBefore(now) &&
            (_settings[notification.type] ?? false))
        .toList();

    for (var notification in dueNotifications) {
      _onNotificationCallback?.call(notification);
    }
  }

  // Schedule a new notification
  static Future<String> scheduleNotification({
    required String title,
    required String body,
    required NotificationType type,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notification = NotificationData(
      id: id,
      title: title,
      body: body,
      type: type,
      scheduledTime: scheduledTime,
      data: data,
    );

    _notifications.add(notification);
    await _saveNotifications();

    return id;
  }

  // Cancel a notification
  static Future<void> cancelNotification(String id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await _saveNotifications();
  }

  // Mark notification as read
  static Future<void> markAsRead(String id) async {
    final index =
        _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  // Get all notifications
  static List<NotificationData> getAllNotifications() {
    return List.from(_notifications);
  }

  // Get unread notifications
  static List<NotificationData> getUnreadNotifications() {
    return _notifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  // Get notifications by type
  static List<NotificationData> getNotificationsByType(NotificationType type) {
    return _notifications
        .where((notification) => notification.type == type)
        .toList();
  }

  // Update notification settings
  static Future<void> updateNotificationSetting(
      NotificationType type, bool enabled) async {
    _settings[type] = enabled;
    await _saveSettings();
  }

  // Get notification setting
  static bool getNotificationSetting(NotificationType type) {
    return _settings[type] ?? true;
  }

  // Get all settings
  static Map<NotificationType, bool> getAllSettings() {
    return Map.from(_settings);
  }

  // Schedule medication reminders
  static Future<void> scheduleMedicationReminders({
    required String medicationName,
    required List<TimeOfDay> times,
    required int durationDays,
  }) async {
    final now = DateTime.now();

    for (int day = 0; day < durationDays; day++) {
      final date = now.add(Duration(days: day));

      for (var time in times) {
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (scheduledTime.isAfter(now)) {
          await scheduleNotification(
            title: '💊 ເວລາກິນຢາ',
            body: 'ຖືງເວລາກິນຢາ $medicationName ແລ້ວ',
            type: NotificationType.medication,
            scheduledTime: scheduledTime,
            data: {
              'medicationName': medicationName,
              'time':
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            },
          );
        }
      }
    }
  }

  // Schedule sleep reminders
  static Future<void> scheduleSleepReminders({
    required TimeOfDay bedtime,
    required TimeOfDay wakeupTime,
  }) async {
    final now = DateTime.now();

    // Schedule bedtime reminders for next 30 days
    for (int day = 0; day < 30; day++) {
      final date = now.add(Duration(days: day));

      // Bedtime reminder
      final bedtimeScheduled = DateTime(
        date.year,
        date.month,
        date.day,
        bedtime.hour,
        bedtime.minute,
      );

      if (bedtimeScheduled.isAfter(now)) {
        await scheduleNotification(
          title: '😴 ເວລານອນ',
          body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
          type: NotificationType.sleep,
          scheduledTime: bedtimeScheduled,
          data: {'type': 'bedtime'},
        );
      }

      // Wake up reminder
      final wakeupScheduled = DateTime(
        date.year,
        date.month,
        date.day + 1,
        wakeupTime.hour,
        wakeupTime.minute,
      );

      if (wakeupScheduled.isAfter(now)) {
        await scheduleNotification(
          title: '🌅 ເວລາຕື່ນ',
          body: 'ສະບາຍດີ! ເລີ່ມວັນໃໝ່ດ້ວຍພະລັງງານເຕັມທີ່',
          type: NotificationType.sleep,
          scheduledTime: wakeupScheduled,
          data: {'type': 'wakeup'},
        );
      }
    }
  }

  // Schedule exercise reminders
  static Future<void> scheduleExerciseReminders({
    required List<int> weekdays, // 1-7 (Monday-Sunday)
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();

    for (int week = 0; week < 4; week++) {
      for (int weekday in weekdays) {
        final targetDate =
            _getNextWeekday(now.add(Duration(days: week * 7)), weekday);
        final scheduledTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          time.hour,
          time.minute,
        );

        if (scheduledTime.isAfter(now)) {
          await scheduleNotification(
            title: '🏃‍♀️ ເວລາອອກກຳລັງກາຍ',
            body: 'ມາອອກກຳລັງກາຍເພື່ອສຸຂະພາບທີ່ດີກັນເຖາະ!',
            type: NotificationType.exercise,
            scheduledTime: scheduledTime,
            data: {
              'weekday': weekday,
              'time':
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            },
          );
        }
      }
    }
  }

  // Schedule period prediction
  static Future<void> schedulePeriodPrediction({
    required DateTime predictedDate,
    required int cycleDays,
  }) async {
    // 3 days before
    await scheduleNotification(
      title: '🩸 ການແຈ້ງເຕືອນປະຈຳເດືອນ',
      body: 'ປະຈຳເດືອນອາດຈະມາໃນອີກ 3 ວັນ ຈະຕຽມພ້ອມບໍ່?',
      type: NotificationType.period,
      scheduledTime: predictedDate.subtract(const Duration(days: 3)),
      data: {'days_until': 3, 'type': 'warning'},
    );

    // 1 day before
    await scheduleNotification(
      title: '🩸 ການແຈ້ງເຕືອນປະຈຳເດືອນ',
      body: 'ປະຈຳເດືອນອາດຈະມາໃນມື້ອື່ນ ກະກຽມຜະລິດຕະພັນທີ່ຈຳເປັນ',
      type: NotificationType.period,
      scheduledTime: predictedDate.subtract(const Duration(days: 1)),
      data: {'days_until': 1, 'type': 'imminent'},
    );

    // On the day
    await scheduleNotification(
      title: '🩸 ວັນປະຈຳເດືອນ',
      body: 'ວັນນີ້ອາດເປັນວັນປະຈຳເດືອນ ດູແລຕົນເອງໃຫ້ດີ',
      type: NotificationType.period,
      scheduledTime: predictedDate,
      data: {'days_until': 0, 'type': 'today'},
    );
  }

  // Schedule weekly report
  static Future<void> scheduleWeeklyReports() async {
    final now = DateTime.now();

    for (int week = 1; week <= 12; week++) {
      final reportDate = _getNextSunday(now).add(Duration(days: week * 7));
      final scheduledTime = DateTime(
        reportDate.year,
        reportDate.month,
        reportDate.day,
        9, // 9 AM
        0,
      );

      await scheduleNotification(
        title: '📊 ລາຍງານປະຈຳອາທິດ',
        body: 'ລາຍງານສຸຂະພາບປະຈຳອາທິດຂອງເຈົ້າພ້ອມແລ້ວ!',
        type: NotificationType.report,
        scheduledTime: scheduledTime,
        data: {'week': week, 'type': 'weekly'},
      );
    }
  }

  // Schedule goal achievement notifications
  static Future<void> scheduleGoalReminder({
    required String goalTitle,
    required DateTime targetDate,
  }) async {
    final now = DateTime.now();
    final daysUntil = targetDate.difference(now).inDays;

    // Weekly reminders
    if (daysUntil > 7) {
      for (int week = 1; week * 7 < daysUntil; week++) {
        final reminderDate = now.add(Duration(days: week * 7));
        await scheduleNotification(
          title: '🎯 ເປົ້າຫມາຍຂອງເຈົ້າ',
          body: 'ມາຕິດຕາມຄວາມຄືບໜ້າເປົ້າຫມາຍ: $goalTitle',
          type: NotificationType.goal,
          scheduledTime: reminderDate,
          data: {
            'goalTitle': goalTitle,
            'daysRemaining': targetDate.difference(reminderDate).inDays,
            'type': 'reminder'
          },
        );
      }
    }

    // Final reminder
    if (daysUntil > 0) {
      await scheduleNotification(
        title: '🎯 ເປົ້າຫມາຍໃກ້ສຳເລັດ',
        body: 'ເປົ້າຫມາຍ "$goalTitle" ຈະຮອດກຳນົດເວລາໃນມື້ອື່ນ!',
        type: NotificationType.goal,
        scheduledTime: targetDate.subtract(const Duration(days: 1)),
        data: {
          'goalTitle': goalTitle,
          'daysRemaining': 1,
          'type': 'final_reminder'
        },
      );
    }
  }

  // Helper methods
  static DateTime _getNextWeekday(DateTime date, int weekday) {
    final daysUntil = (weekday - date.weekday) % 7;
    return date.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
  }

  static DateTime _getNextSunday(DateTime date) {
    final daysUntil = (7 - date.weekday) % 7;
    return date.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
  }

  // Cleanup old notifications
  static Future<void> cleanupOldNotifications() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    _notifications.removeWhere((notification) =>
        notification.scheduledTime.isBefore(cutoffDate) && notification.isRead);
    await _saveNotifications();
  }

  // Dispose
  static void dispose() {
    _checkTimer?.cancel();
  }
}
