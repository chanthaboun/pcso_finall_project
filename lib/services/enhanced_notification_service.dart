// // lib/services/enhanced_notification_service.dart - Fixed to prevent duplicates
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:async';
// import 'dart:io';

// enum NotificationType {
//   medication,
//   sleep,
//   exercise,
//   period,
//   report,
//   goal,
// }

// class NotificationData {
//   final String id;
//   final String title;
//   final String body;
//   final NotificationType type;
//   final DateTime scheduledTime;
//   final Map<String, dynamic>? data;
//   final bool isRead;
//   final bool isActive;
//   final bool
//       isTriggered; // Add this to track if notification was already triggered

//   NotificationData({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.type,
//     required this.scheduledTime,
//     this.data,
//     this.isRead = false,
//     this.isActive = true,
//     this.isTriggered = false,
//   });

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'body': body,
//         'type': type.index,
//         'scheduledTime': scheduledTime.toIso8601String(),
//         'data': data,
//         'isRead': isRead,
//         'isActive': isActive,
//         'isTriggered': isTriggered,
//       };

//   factory NotificationData.fromJson(Map<String, dynamic> json) =>
//       NotificationData(
//         id: json['id'],
//         title: json['title'],
//         body: json['body'],
//         type: NotificationType.values[json['type']],
//         scheduledTime: DateTime.parse(json['scheduledTime']),
//         data: json['data'],
//         isRead: json['isRead'] ?? false,
//         isActive: json['isActive'] ?? true,
//         isTriggered: json['isTriggered'] ?? false,
//       );

//   NotificationData copyWith({
//     String? id,
//     String? title,
//     String? body,
//     NotificationType? type,
//     DateTime? scheduledTime,
//     Map<String, dynamic>? data,
//     bool? isRead,
//     bool? isActive,
//     bool? isTriggered,
//   }) =>
//       NotificationData(
//         id: id ?? this.id,
//         title: title ?? this.title,
//         body: body ?? this.body,
//         type: type ?? this.type,
//         scheduledTime: scheduledTime ?? this.scheduledTime,
//         data: data ?? this.data,
//         isRead: isRead ?? this.isRead,
//         isActive: isActive ?? this.isActive,
//         isTriggered: isTriggered ?? this.isTriggered,
//       );
// }

// class EnhancedNotificationService {
//   static const String _notificationsKey = 'app_notifications';
//   static const String _settingsKey = 'notification_settings';

//   static final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();

//   static List<NotificationData> _notifications = [];
//   static Map<NotificationType, bool> _settings = {
//     NotificationType.medication: true,
//     NotificationType.sleep: true,
//     NotificationType.exercise: true,
//     NotificationType.period: true,
//     NotificationType.report: true,
//     NotificationType.goal: true,
//   };

//   static Timer? _realtimeTimer;
//   static Function(NotificationData)? _onNotificationCallback;
//   static String _currentTimezone = 'Asia/Vientiane';
//   static Set<String> _triggeredNotifications =
//       <String>{}; // Track triggered notifications

//   // Initialize notification service with real-time support
//   static Future<void> initialize() async {
//     try {
//       // Initialize timezone data
//       tz.initializeTimeZones();
//       await _setupLocalNotifications();
//       await _loadNotifications();
//       await _loadSettings();
//       await _detectTimezone();
//       _startRealtimeCheck();
//       print('Enhanced notification service initialized successfully');
//     } catch (e) {
//       print('Error initializing enhanced notification service: $e');
//       rethrow;
//     }
//   }

//   // Setup native local notifications
//   static Future<void> _setupLocalNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );

//     await _localNotifications.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     // Request permissions
//     if (Platform.isAndroid) {
//       await _localNotifications
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestNotificationsPermission();
//     } else if (Platform.isIOS) {
//       await _localNotifications
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//     }
//   }

//   // Handle notification tap
//   static void _onNotificationTapped(NotificationResponse response) {
//     if (response.payload != null) {
//       final notificationId = response.payload!;
//       final notification = _notifications.firstWhere(
//         (n) => n.id == notificationId,
//         orElse: () => _notifications.isNotEmpty
//             ? _notifications.first
//             : _createDummyNotification(),
//       );
//       _onNotificationCallback?.call(notification);
//     }
//   }

//   // Create dummy notification for error cases
//   static NotificationData _createDummyNotification() {
//     return NotificationData(
//       id: 'dummy',
//       title: 'แจ้งเตือน',
//       body: 'คุณมีการแจ้งเตือนใหม่',
//       type: NotificationType.goal,
//       scheduledTime: DateTime.now(),
//     );
//   }

//   // Detect user's timezone
//   static Future<void> _detectTimezone() async {
//     try {
//       final location = tz.getLocation(_currentTimezone);
//       tz.setLocalLocation(location);
//       print('Timezone set to: $_currentTimezone');
//     } catch (e) {
//       print('Error setting timezone: $e');
//       tz.setLocalLocation(tz.UTC);
//     }
//   }

//   // Start real-time checking every 10 seconds
//   static void _startRealtimeCheck() {
//     _realtimeTimer?.cancel();
//     _realtimeTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       _checkDueNotifications();
//     });
//   }

//   // Check for due notifications with precise timing and duplicate prevention
//   static void _checkDueNotifications() {
//     final now = DateTime.now();

//     final dueNotifications = _notifications.where((notification) {
//       // Skip if already triggered, not active, read, or setting disabled
//       if (_triggeredNotifications.contains(notification.id) ||
//           !notification.isActive ||
//           notification.isRead ||
//           !(_settings[notification.type] ?? false)) {
//         return false;
//       }

//       // Check if notification time has passed (within 1 minute tolerance)
//       final timeDiff = now.difference(notification.scheduledTime).inSeconds;
//       return timeDiff >= 0 && timeDiff <= 60;
//     }).toList();

//     for (var notification in dueNotifications) {
//       // Mark as triggered to prevent duplicates
//       _triggeredNotifications.add(notification.id);

//       // Mark notification as triggered in storage
//       _markAsTriggered(notification.id);

//       // Show notifications
//       _showNativeNotification(notification);
//       _onNotificationCallback?.call(notification);

//       print(
//           'Triggered notification: ${notification.title} at ${DateTime.now()}');
//     }
//   }

//   // Mark notification as triggered
//   static Future<void> _markAsTriggered(String id) async {
//     final index =
//         _notifications.indexWhere((notification) => notification.id == id);
//     if (index != -1) {
//       _notifications[index] = _notifications[index].copyWith(isTriggered: true);
//       await _saveNotifications();
//     }
//   }

//   // Show native notification
//   static Future<void> _showNativeNotification(
//       NotificationData notification) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'pcos_care_channel',
//       'PCOS Care Notifications',
//       channelDescription: 'Notifications for PCOS Care app',
//       importance: Importance.high,
//       priority: Priority.high,
//       showWhen: true,
//       enableVibration: true,
//       playSound: true,
//     );

//     const DarwinNotificationDetails iosPlatformChannelSpecifics =
//         DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iosPlatformChannelSpecifics,
//     );

//     try {
//       await _localNotifications.show(
//         notification.id.hashCode,
//         notification.title,
//         notification.body,
//         platformChannelSpecifics,
//         payload: notification.id,
//       );
//     } catch (e) {
//       print('Error showing native notification: $e');
//     }
//   }

//   // Set callback for notification events
//   static void setNotificationCallback(Function(NotificationData) callback) {
//     _onNotificationCallback = callback;
//   }

//   // Schedule notification with timezone support and duplicate prevention
//   static Future<String> scheduleNotification({
//     required String title,
//     required String body,
//     required NotificationType type,
//     required DateTime scheduledTime,
//     Map<String, dynamic>? data,
//   }) async {
//     // Generate unique ID based on content and time to prevent exact duplicates
//     final contentHash =
//         '${type.toString()}_${scheduledTime.millisecondsSinceEpoch}_${title.hashCode}';
//     final id = contentHash;

//     // Check for existing notification with same content and time
//     final existingNotification = _notifications.firstWhere(
//       (n) => n.id == id,
//       orElse: () => NotificationData(
//         id: 'not_found',
//         title: '',
//         body: '',
//         type: type,
//         scheduledTime: DateTime.now(),
//       ),
//     );

//     if (existingNotification.id != 'not_found') {
//       print('Duplicate notification prevented: $title');
//       return existingNotification.id;
//     }

//     // Convert to local timezone
//     final localScheduledTime = _convertToLocalTime(scheduledTime);

//     final notification = NotificationData(
//       id: id,
//       title: title,
//       body: body,
//       type: type,
//       scheduledTime: localScheduledTime,
//       data: data,
//     );

//     _notifications.add(notification);
//     await _saveNotifications();

//     // Schedule native notification
//     await _scheduleNativeNotification(notification);

//     print('Scheduled notification: $title for ${localScheduledTime}');
//     return id;
//   }

//   // Convert time to local timezone
//   static DateTime _convertToLocalTime(DateTime utcTime) {
//     try {
//       final location = tz.getLocation(_currentTimezone);
//       final tzDateTime = tz.TZDateTime.from(utcTime, location);
//       return tzDateTime;
//     } catch (e) {
//       print('Error converting timezone: $e');
//       return utcTime;
//     }
//   }

//   // Schedule native notification
//   static Future<void> _scheduleNativeNotification(
//       NotificationData notification) async {
//     if (notification.scheduledTime.isBefore(DateTime.now())) return;

//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'pcos_care_channel',
//       'PCOS Care Notifications',
//       channelDescription: 'Notifications for PCOS Care app',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const DarwinNotificationDetails iosPlatformChannelSpecifics =
//         DarwinNotificationDetails();

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iosPlatformChannelSpecifics,
//     );

//     try {
//       final location = tz.getLocation(_currentTimezone);
//       final scheduledDate =
//           tz.TZDateTime.from(notification.scheduledTime, location);

//       await _localNotifications.zonedSchedule(
//         notification.id.hashCode,
//         notification.title,
//         notification.body,
//         scheduledDate,
//         platformChannelSpecifics,
//         payload: notification.id,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );
//     } catch (e) {
//       print('Error scheduling notification: $e');
//     }
//   }

//   // Load notifications from storage
//   static Future<void> _loadNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final notificationsJson = prefs.getString(_notificationsKey);

//       if (notificationsJson != null) {
//         final List<dynamic> notificationsList = jsonDecode(notificationsJson);
//         _notifications = notificationsList
//             .map((json) => NotificationData.fromJson(json))
//             .toList();

//         // Rebuild triggered notifications set
//         _triggeredNotifications =
//             _notifications.where((n) => n.isTriggered).map((n) => n.id).toSet();
//       }
//     } catch (e) {
//       print('Error loading notifications: $e');
//     }
//   }

//   // Save notifications to storage
//   static Future<void> _saveNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final notificationsJson = jsonEncode(
//         _notifications.map((notification) => notification.toJson()).toList(),
//       );
//       await prefs.setString(_notificationsKey, notificationsJson);
//     } catch (e) {
//       print('Error saving notifications: $e');
//     }
//   }

//   // Load notification settings
//   static Future<void> _loadSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final settingsJson = prefs.getString(_settingsKey);

//       if (settingsJson != null) {
//         final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
//         for (var type in NotificationType.values) {
//           _settings[type] = settingsMap[type.toString()] ?? true;
//         }
//       }
//     } catch (e) {
//       print('Error loading notification settings: $e');
//     }
//   }

//   // Save notification settings
//   static Future<void> _saveSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final settingsMap = <String, bool>{};
//       for (var entry in _settings.entries) {
//         settingsMap[entry.key.toString()] = entry.value;
//       }
//       await prefs.setString(_settingsKey, jsonEncode(settingsMap));
//     } catch (e) {
//       print('Error saving notification settings: $e');
//     }
//   }

//   // Mark notification as read
//   static Future<void> markAsRead(String id) async {
//     final index =
//         _notifications.indexWhere((notification) => notification.id == id);
//     if (index != -1) {
//       _notifications[index] = _notifications[index].copyWith(isRead: true);
//       await _saveNotifications();
//     }
//   }

//   // Mark ALL notifications as read
//   static Future<void> markAllAsRead() async {
//     for (int i = 0; i < _notifications.length; i++) {
//       if (!_notifications[i].isRead) {
//         _notifications[i] = _notifications[i].copyWith(isRead: true);
//       }
//     }
//     await _saveNotifications();
//   }

//   // Cancel notification
//   static Future<void> cancelNotification(String id) async {
//     // Cancel native notification
//     await _localNotifications.cancel(id.hashCode);

//     // Remove from triggered set
//     _triggeredNotifications.remove(id);

//     // Remove from list
//     _notifications.removeWhere((notification) => notification.id == id);
//     await _saveNotifications();
//   }

//   // Get all notifications
//   static List<NotificationData> getAllNotifications() {
//     return List.from(_notifications);
//   }

//   // Get unread notifications
//   static List<NotificationData> getUnreadNotifications() {
//     return _notifications
//         .where((notification) => !notification.isRead)
//         .toList();
//   }

//   // Get notifications by type
//   static List<NotificationData> getNotificationsByType(NotificationType type) {
//     return _notifications
//         .where((notification) => notification.type == type)
//         .toList();
//   }

//   // Update notification settings
//   static Future<void> updateNotificationSetting(
//       NotificationType type, bool enabled) async {
//     _settings[type] = enabled;
//     await _saveSettings();
//   }

//   // Get notification setting
//   static bool getNotificationSetting(NotificationType type) {
//     return _settings[type] ?? true;
//   }

//   // Get all settings
//   static Map<NotificationType, bool> getAllSettings() {
//     return Map.from(_settings);
//   }

//   // Schedule sleep reminders with exact time
//   static Future<void> scheduleSleepReminder({
//     required TimeOfDay bedtime,
//   }) async {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);

//     // Calculate bedtime for today
//     DateTime bedtimeToday = DateTime(
//       today.year,
//       today.month,
//       today.day,
//       bedtime.hour,
//       bedtime.minute,
//     );

//     // If bedtime has passed today, schedule for tomorrow
//     if (bedtimeToday.isBefore(now)) {
//       bedtimeToday = bedtimeToday.add(const Duration(days: 1));
//     }

//     await scheduleNotification(
//       title: '😴 ເວລານອນ',
//       body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
//       type: NotificationType.sleep,
//       scheduledTime: bedtimeToday,
//       data: {'type': 'bedtime'},
//     );
//   }

//   // Schedule medication with exact times (prevent duplicates)
//   static Future<void> scheduleMedicationReminders({
//     required String medicationName,
//     required List<TimeOfDay> times,
//     required int durationDays,
//   }) async {
//     final now = DateTime.now();

//     for (int day = 0; day < durationDays; day++) {
//       final date = now.add(Duration(days: day));

//       for (var time in times) {
//         final scheduledTime = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           time.hour,
//           time.minute,
//         );

//         if (scheduledTime.isAfter(now)) {
//           await scheduleNotification(
//             title: '💊 ເວລາກິນຢາ',
//             body: 'ຖືງເວລາກິນຢາ $medicationName ແລ້ວ',
//             type: NotificationType.medication,
//             scheduledTime: scheduledTime,
//             data: {
//               'medicationName': medicationName,
//               'time':
//                   '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
//             },
//           );
//         }
//       }
//     }
//   }

//   // Cleanup old notifications
//   static Future<void> cleanupOldNotifications() async {
//     final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
//     _notifications.removeWhere((notification) =>
//         notification.scheduledTime.isBefore(cutoffDate) && notification.isRead);

//     // Clean triggered set
//     final activeIds = _notifications.map((n) => n.id).toSet();
//     _triggeredNotifications.removeWhere((id) => !activeIds.contains(id));

//     await _saveNotifications();
//   }

//   // Reset all notifications (for testing)
//   static Future<void> resetAllNotifications() async {
//     _notifications.clear();
//     _triggeredNotifications.clear();
//     await _saveNotifications();
//     await _localNotifications.cancelAll();
//   }

//   // Dispose
//   static void dispose() {
//     _realtimeTimer?.cancel();
//   }
// }




// // lib/services/enhanced_notification_service.dart - Fixed Real-time Version
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:async';

// enum NotificationType {
//   medication,
//   sleep,
//   exercise,
//   period,
//   report,
//   goal,
// }

// class NotificationData {
//   final String id;
//   final String title;
//   final String body;
//   final NotificationType type;
//   final DateTime scheduledTime;
//   final Map<String, dynamic>? data;
//   final bool isRead;
//   final bool isActive;
//   final bool isTriggered;

//   NotificationData({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.type,
//     required this.scheduledTime,
//     this.data,
//     this.isRead = false,
//     this.isActive = true,
//     this.isTriggered = false,
//   });

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'body': body,
//         'type': type.index,
//         'scheduledTime': scheduledTime.toIso8601String(),
//         'data': data,
//         'isRead': isRead,
//         'isActive': isActive,
//         'isTriggered': isTriggered,
//       };

//   factory NotificationData.fromJson(Map<String, dynamic> json) =>
//       NotificationData(
//         id: json['id'],
//         title: json['title'],
//         body: json['body'],
//         type: NotificationType.values[json['type']],
//         scheduledTime: DateTime.parse(json['scheduledTime']),
//         data: json['data'],
//         isRead: json['isRead'] ?? false,
//         isActive: json['isActive'] ?? true,
//         isTriggered: json['isTriggered'] ?? false,
//       );

//   NotificationData copyWith({
//     String? id,
//     String? title,
//     String? body,
//     NotificationType? type,
//     DateTime? scheduledTime,
//     Map<String, dynamic>? data,
//     bool? isRead,
//     bool? isActive,
//     bool? isTriggered,
//   }) =>
//       NotificationData(
//         id: id ?? this.id,
//         title: title ?? this.title,
//         body: body ?? this.body,
//         type: type ?? this.type,
//         scheduledTime: scheduledTime ?? this.scheduledTime,
//         data: data ?? this.data,
//         isRead: isRead ?? this.isRead,
//         isActive: isActive ?? this.isActive,
//         isTriggered: isTriggered ?? this.isTriggered,
//       );
// }

// class EnhancedNotificationService {
//   static const String _notificationsKey = 'app_notifications';
//   static const String _settingsKey = 'notification_settings';

//   static List<NotificationData> _notifications = [];
//   static Map<NotificationType, bool> _settings = {
//     NotificationType.medication: true,
//     NotificationType.sleep: true,
//     NotificationType.exercise: true,
//     NotificationType.period: true,
//     NotificationType.report: true,
//     NotificationType.goal: true,
//   };

//   static Timer? _realtimeTimer;
//   static Function(NotificationData)? _onNotificationCallback;
//   static Set<String> _triggeredNotifications = <String>{};
//   static bool _isInitialized = false;

//   // Initialize with aggressive real-time checking
//   static Future<void> initialize() async {
//     if (_isInitialized) return;

//     try {
//       await _loadNotifications();
//       await _loadSettings();
//       _startAggressiveRealtimeCheck();
//       _isInitialized = true;
//       print('✅ Enhanced notification service initialized successfully');
//     } catch (e) {
//       print('❌ Error initializing enhanced notification service: $e');
//       rethrow;
//     }
//   }

//   // Start aggressive real-time checking every 5 seconds
//   static void _startAggressiveRealtimeCheck() {
//     _realtimeTimer?.cancel();
//     _realtimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       _checkDueNotifications();
//     });
//     print(
//         '🔄 Started aggressive real-time notification check (every 5 seconds)');
//   }

//   // Enhanced due notification checking with precise timing
//   static void _checkDueNotifications() {
//     final now = DateTime.now();

//     final dueNotifications = _notifications.where((notification) {
//       // Skip if already triggered, not active, read, or setting disabled
//       if (_triggeredNotifications.contains(notification.id) ||
//           !notification.isActive ||
//           notification.isRead ||
//           !(_settings[notification.type] ?? false)) {
//         return false;
//       }

//       // Check if notification time has passed (within 2 minute tolerance for safety)
//       final timeDiff = now.difference(notification.scheduledTime).inSeconds;
//       final isTimeToTrigger =
//           timeDiff >= 0 && timeDiff <= 120; // 2 minutes tolerance

//       if (isTimeToTrigger) {
//         print(
//             '⏰ Notification ready to trigger: ${notification.title} scheduled at ${notification.scheduledTime}, current time: $now, diff: ${timeDiff}s');
//       }

//       return isTimeToTrigger;
//     }).toList();

//     for (var notification in dueNotifications) {
//       // Mark as triggered to prevent duplicates
//       _triggeredNotifications.add(notification.id);

//       // Mark notification as triggered in storage
//       _markAsTriggered(notification.id);

//       // Trigger callback immediately
//       _onNotificationCallback?.call(notification);

//       print(
//           '🔔 Triggered notification: ${notification.title} at ${DateTime.now()}');
//     }
//   }

//   // Mark notification as triggered
//   static Future<void> _markAsTriggered(String id) async {
//     final index =
//         _notifications.indexWhere((notification) => notification.id == id);
//     if (index != -1) {
//       _notifications[index] = _notifications[index].copyWith(isTriggered: true);
//       await _saveNotifications();
//     }
//   }

//   // Set callback for notification events
//   static void setNotificationCallback(Function(NotificationData) callback) {
//     _onNotificationCallback = callback;
//     print('✅ Notification callback set');
//   }

//   // Schedule notification with enhanced duplicate prevention
//   static Future<String> scheduleNotification({
//     required String title,
//     required String body,
//     required NotificationType type,
//     required DateTime scheduledTime,
//     Map<String, dynamic>? data,
//   }) async {
//     // Generate unique ID
//     final id =
//         '${type.toString()}_${scheduledTime.millisecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch}';

//     final notification = NotificationData(
//       id: id,
//       title: title,
//       body: body,
//       type: type,
//       scheduledTime: scheduledTime,
//       data: data,
//     );

//     _notifications.add(notification);
//     await _saveNotifications();

//     print('📅 Scheduled notification: $title for ${scheduledTime}');
//     return id;
//   }

//   // Load notifications from storage
//   static Future<void> _loadNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final notificationsJson = prefs.getString(_notificationsKey);

//       if (notificationsJson != null) {
//         final List<dynamic> notificationsList = jsonDecode(notificationsJson);
//         _notifications = notificationsList
//             .map((json) => NotificationData.fromJson(json))
//             .toList();

//         // Rebuild triggered notifications set
//         _triggeredNotifications =
//             _notifications.where((n) => n.isTriggered).map((n) => n.id).toSet();

//         print('📱 Loaded ${_notifications.length} notifications from storage');
//       }
//     } catch (e) {
//       print('❌ Error loading notifications: $e');
//     }
//   }

//   // Save notifications to storage
//   static Future<void> _saveNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final notificationsJson = jsonEncode(
//         _notifications.map((notification) => notification.toJson()).toList(),
//       );
//       await prefs.setString(_notificationsKey, notificationsJson);
//     } catch (e) {
//       print('❌ Error saving notifications: $e');
//     }
//   }

//   // Load notification settings
//   static Future<void> _loadSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final settingsJson = prefs.getString(_settingsKey);

//       if (settingsJson != null) {
//         final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
//         for (var type in NotificationType.values) {
//           _settings[type] = settingsMap[type.toString()] ?? true;
//         }
//       }
//     } catch (e) {
//       print('❌ Error loading notification settings: $e');
//     }
//   }

//   // Save notification settings
//   static Future<void> _saveSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final settingsMap = <String, bool>{};
//       for (var entry in _settings.entries) {
//         settingsMap[entry.key.toString()] = entry.value;
//       }
//       await prefs.setString(_settingsKey, jsonEncode(settingsMap));
//     } catch (e) {
//       print('❌ Error saving notification settings: $e');
//     }
//   }

//   // Mark notification as read
//   static Future<void> markAsRead(String id) async {
//     final index =
//         _notifications.indexWhere((notification) => notification.id == id);
//     if (index != -1) {
//       _notifications[index] = _notifications[index].copyWith(isRead: true);
//       await _saveNotifications();
//     }
//   }

//   // Mark ALL notifications as read
//   static Future<void> markAllAsRead() async {
//     for (int i = 0; i < _notifications.length; i++) {
//       if (!_notifications[i].isRead) {
//         _notifications[i] = _notifications[i].copyWith(isRead: true);
//       }
//     }
//     await _saveNotifications();
//   }

//   // Cancel notification
//   static Future<void> cancelNotification(String id) async {
//     // Remove from triggered set
//     _triggeredNotifications.remove(id);

//     // Remove from list
//     _notifications.removeWhere((notification) => notification.id == id);
//     await _saveNotifications();
//   }

//   // Get all notifications
//   static List<NotificationData> getAllNotifications() {
//     return List.from(_notifications);
//   }

//   // Get unread notifications
//   static List<NotificationData> getUnreadNotifications() {
//     return _notifications
//         .where((notification) => !notification.isRead)
//         .toList();
//   }

//   // Get notifications by type
//   static List<NotificationData> getNotificationsByType(NotificationType type) {
//     return _notifications
//         .where((notification) => notification.type == type)
//         .toList();
//   }

//   // Update notification settings
//   static Future<void> updateNotificationSetting(
//       NotificationType type, bool enabled) async {
//     _settings[type] = enabled;
//     await _saveSettings();
//   }

//   // Get notification setting
//   static bool getNotificationSetting(NotificationType type) {
//     return _settings[type] ?? true;
//   }

//   // Get all settings
//   static Map<NotificationType, bool> getAllSettings() {
//     return Map.from(_settings);
//   }

//   // Quick test methods for immediate testing
//   static Future<void> scheduleQuickTest({
//     required String title,
//     required String body,
//     required NotificationType type,
//     required int seconds,
//   }) async {
//     final futureTime = DateTime.now().add(Duration(seconds: seconds));
//     await scheduleNotification(
//       title: title,
//       body: body,
//       type: type,
//       scheduledTime: futureTime,
//       data: {'test': true, 'seconds': seconds},
//     );
//     print('🚀 Quick test scheduled for $seconds seconds from now');
//   }

//   // Schedule exact time test
//   static Future<void> scheduleExactTimeTest() async {
//     final now = DateTime.now();
//     final testTime = DateTime(now.year, now.month, now.day, 23, 45);

//     // If 23:45 has passed today, schedule for tomorrow
//     final actualTime = testTime.isBefore(now)
//         ? testTime.add(const Duration(days: 1))
//         : testTime;

//     await scheduleNotification(
//       title: '🌙 ເວລານອນ 23:45',
//       body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
//       type: NotificationType.sleep,
//       scheduledTime: actualTime,
//       data: {'exact_time': '23:45', 'test': true},
//     );
//   }

//   // Reset all notifications (for testing)
//   static Future<void> resetAllNotifications() async {
//     _notifications.clear();
//     _triggeredNotifications.clear();
//     await _saveNotifications();
//     print('🔄 All notifications reset');
//   }

//   // Force check notifications (for manual testing)
//   static void forceCheckNotifications() {
//     print('🔍 Force checking notifications...');
//     _checkDueNotifications();
//   }

//   // Get debug info
//   static Map<String, dynamic> getDebugInfo() {
//     final now = DateTime.now();
//     return {
//       'current_time': now.toString(),
//       'total_notifications': _notifications.length,
//       'active_notifications': _notifications.where((n) => n.isActive).length,
//       'triggered_notifications': _triggeredNotifications.length,
//       'unread_notifications': getUnreadNotifications().length,
//       'next_notification': _notifications
//               .where((n) =>
//                   n.isActive && !n.isTriggered && n.scheduledTime.isAfter(now))
//               .isNotEmpty
//           ? _notifications
//               .where((n) =>
//                   n.isActive && !n.isTriggered && n.scheduledTime.isAfter(now))
//               .reduce(
//                   (a, b) => a.scheduledTime.isBefore(b.scheduledTime) ? a : b)
//               .scheduledTime
//               .toString()
//           : 'None',
//       'timer_active': _realtimeTimer?.isActive ?? false,
//     };
//   }

//   // Dispose
//   static void dispose() {
//     _realtimeTimer?.cancel();
//     _isInitialized = false;
//     print('🛑 Enhanced notification service disposed');
//   }
// }




// lib/services/enhanced_notification_service.dart - Fixed with cleanupOldNotifications method
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
  final bool isTriggered;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.data,
    this.isRead = false,
    this.isActive = true,
    this.isTriggered = false,
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
        'isTriggered': isTriggered,
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
        isTriggered: json['isTriggered'] ?? false,
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
    bool? isTriggered,
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
        isTriggered: isTriggered ?? this.isTriggered,
      );
}

class EnhancedNotificationService {
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

  static Timer? _realtimeTimer;
  static Function(NotificationData)? _onNotificationCallback;
  static Set<String> _triggeredNotifications = <String>{};
  static bool _isInitialized = false;

  // Initialize with aggressive real-time checking
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadNotifications();
      await _loadSettings();
      _startAggressiveRealtimeCheck();
      _isInitialized = true;
      print('✅ Enhanced notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing enhanced notification service: $e');
      rethrow;
    }
  }

  // Start aggressive real-time checking every 5 seconds
  static void _startAggressiveRealtimeCheck() {
    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkDueNotifications();
    });
    print(
        '🔄 Started aggressive real-time notification check (every 5 seconds)');
  }

  // Enhanced due notification checking with precise timing
  static void _checkDueNotifications() {
    final now = DateTime.now();

    final dueNotifications = _notifications.where((notification) {
      // Skip if already triggered, not active, read, or setting disabled
      if (_triggeredNotifications.contains(notification.id) ||
          !notification.isActive ||
          notification.isRead ||
          !(_settings[notification.type] ?? false)) {
        return false;
      }

      // Check if notification time has passed (within 2 minute tolerance for safety)
      final timeDiff = now.difference(notification.scheduledTime).inSeconds;
      final isTimeToTrigger =
          timeDiff >= 0 && timeDiff <= 120; // 2 minutes tolerance

      if (isTimeToTrigger) {
        print(
            '⏰ Notification ready to trigger: ${notification.title} scheduled at ${notification.scheduledTime}, current time: $now, diff: ${timeDiff}s');
      }

      return isTimeToTrigger;
    }).toList();

    for (var notification in dueNotifications) {
      // Mark as triggered to prevent duplicates
      _triggeredNotifications.add(notification.id);

      // Mark notification as triggered in storage
      _markAsTriggered(notification.id);

      // Trigger callback immediately
      _onNotificationCallback?.call(notification);

      print(
          '🔔 Triggered notification: ${notification.title} at ${DateTime.now()}');
    }
  }

  // Mark notification as triggered
  static Future<void> _markAsTriggered(String id) async {
    final index =
        _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isTriggered: true);
      await _saveNotifications();
    }
  }

  // Set callback for notification events
  static void setNotificationCallback(Function(NotificationData) callback) {
    _onNotificationCallback = callback;
    print('✅ Notification callback set');
  }

  // Schedule notification with enhanced duplicate prevention
  static Future<String> scheduleNotification({
    required String title,
    required String body,
    required NotificationType type,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    // Generate unique ID
    final id =
        '${type.toString()}_${scheduledTime.millisecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch}';

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

    print('📅 Scheduled notification: $title for ${scheduledTime}');
    return id;
  }

  // ✅ Added missing cleanupOldNotifications method
  static Future<void> cleanupOldNotifications() async {
    final now = DateTime.now();
    final cutoffDate = now.subtract(
        const Duration(days: 7)); // Remove notifications older than 7 days

    final oldNotificationsCount = _notifications.length;

    // Remove old notifications that are:
    // - Older than 7 days
    // - Already triggered
    // - Read
    _notifications.removeWhere((notification) {
      final isOld = notification.scheduledTime.isBefore(cutoffDate);
      final isCompleted = notification.isTriggered && notification.isRead;
      return isOld || isCompleted;
    });

    // Also clean up triggered notifications set
    _triggeredNotifications.removeWhere((id) {
      return !_notifications.any((notification) => notification.id == id);
    });

    await _saveNotifications();

    final removedCount = oldNotificationsCount - _notifications.length;
    print('🧹 Cleaned up $removedCount old notifications');
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

        // Rebuild triggered notifications set
        _triggeredNotifications =
            _notifications.where((n) => n.isTriggered).map((n) => n.id).toSet();

        print('📱 Loaded ${_notifications.length} notifications from storage');
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
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
      print('❌ Error saving notifications: $e');
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
      print('❌ Error loading notification settings: $e');
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
      print('❌ Error saving notification settings: $e');
    }
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

  // Mark ALL notifications as read
  static Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _saveNotifications();
  }

  // Cancel notification
  static Future<void> cancelNotification(String id) async {
    // Remove from triggered set
    _triggeredNotifications.remove(id);

    // Remove from list
    _notifications.removeWhere((notification) => notification.id == id);
    await _saveNotifications();
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

  // Quick test methods for immediate testing
  static Future<void> scheduleQuickTest({
    required String title,
    required String body,
    required NotificationType type,
    required int seconds,
  }) async {
    final futureTime = DateTime.now().add(Duration(seconds: seconds));
    await scheduleNotification(
      title: title,
      body: body,
      type: type,
      scheduledTime: futureTime,
      data: {'test': true, 'seconds': seconds},
    );
    print('🚀 Quick test scheduled for $seconds seconds from now');
  }

  // Schedule exact time test
  static Future<void> scheduleExactTimeTest() async {
    final now = DateTime.now();
    final testTime = DateTime(now.year, now.month, now.day, 23, 45);

    // If 23:45 has passed today, schedule for tomorrow
    final actualTime = testTime.isBefore(now)
        ? testTime.add(const Duration(days: 1))
        : testTime;

    await scheduleNotification(
      title: '🌙 ເວລານອນ 23:45',
      body: 'ຖືງເວລານອນແລ້ວ! ພັກຜ່ອນໃຫ້ເພຽງພໍ',
      type: NotificationType.sleep,
      scheduledTime: actualTime,
      data: {'exact_time': '23:45', 'test': true},
    );
  }

  // Reset all notifications (for testing)
  static Future<void> resetAllNotifications() async {
    _notifications.clear();
    _triggeredNotifications.clear();
    await _saveNotifications();
    print('🔄 All notifications reset');
  }

  // Force check notifications (for manual testing)
  static void forceCheckNotifications() {
    print('🔍 Force checking notifications...');
    _checkDueNotifications();
  }

  // Get debug info
  static Map<String, dynamic> getDebugInfo() {
    final now = DateTime.now();
    return {
      'current_time': now.toString(),
      'total_notifications': _notifications.length,
      'active_notifications': _notifications.where((n) => n.isActive).length,
      'triggered_notifications': _triggeredNotifications.length,
      'unread_notifications': getUnreadNotifications().length,
      'next_notification': _notifications
              .where((n) =>
                  n.isActive && !n.isTriggered && n.scheduledTime.isAfter(now))
              .isNotEmpty
          ? _notifications
              .where((n) =>
                  n.isActive && !n.isTriggered && n.scheduledTime.isAfter(now))
              .reduce(
                  (a, b) => a.scheduledTime.isBefore(b.scheduledTime) ? a : b)
              .scheduledTime
              .toString()
          : 'None',
      'timer_active': _realtimeTimer?.isActive ?? false,
    };
  }

  // Dispose
  static void dispose() {
    _realtimeTimer?.cancel();
    _isInitialized = false;
    print('🛑 Enhanced notification service disposed');
  }
}
