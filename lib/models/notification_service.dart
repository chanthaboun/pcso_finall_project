import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool medicationReminders;
  final bool sleepReminders;
  final bool exerciseReminders;
  final bool periodPredictions;
  final bool weeklyReports;
  final String sleepReminderTime; // "22:00"
  final String exerciseReminderTime; // "18:00"

  NotificationSettings({
    this.medicationReminders = true,
    this.sleepReminders = true,
    this.exerciseReminders = true,
    this.periodPredictions = true,
    this.weeklyReports = true,
    this.sleepReminderTime = "22:00",
    this.exerciseReminderTime = "18:00",
  });

  Map<String, dynamic> toJson() {
    return {
      'medicationReminders': medicationReminders,
      'sleepReminders': sleepReminders,
      'exerciseReminders': exerciseReminders,
      'periodPredictions': periodPredictions,
      'weeklyReports': weeklyReports,
      'sleepReminderTime': sleepReminderTime,
      'exerciseReminderTime': exerciseReminderTime,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      medicationReminders: json['medicationReminders'] ?? true,
      sleepReminders: json['sleepReminders'] ?? true,
      exerciseReminders: json['exerciseReminders'] ?? true,
      periodPredictions: json['periodPredictions'] ?? true,
      weeklyReports: json['weeklyReports'] ?? true,
      sleepReminderTime: json['sleepReminderTime'] ?? "22:00",
      exerciseReminderTime: json['exerciseReminderTime'] ?? "18:00",
    );
  }

  NotificationSettings copyWith({
    bool? medicationReminders,
    bool? sleepReminders,
    bool? exerciseReminders,
    bool? periodPredictions,
    bool? weeklyReports,
    String? sleepReminderTime,
    String? exerciseReminderTime,
  }) {
    return NotificationSettings(
      medicationReminders: medicationReminders ?? this.medicationReminders,
      sleepReminders: sleepReminders ?? this.sleepReminders,
      exerciseReminders: exerciseReminders ?? this.exerciseReminders,
      periodPredictions: periodPredictions ?? this.periodPredictions,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      sleepReminderTime: sleepReminderTime ?? this.sleepReminderTime,
      exerciseReminderTime: exerciseReminderTime ?? this.exerciseReminderTime,
    );
  }
}

class NotificationService {
  static const String _settingsKey = 'notification_settings';
  static NotificationSettings? _cachedSettings;

  // Get notification settings
  static Future<NotificationSettings> getSettings() async {
    if (_cachedSettings != null) return _cachedSettings!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        _cachedSettings =
            NotificationSettings.fromJson(jsonDecode(settingsJson));
      } else {
        _cachedSettings = NotificationSettings();
      }

      return _cachedSettings!;
    } catch (e) {
      print('Error loading notification settings: $e');
      return NotificationSettings();
    }
  }

  // Save notification settings
  static Future<void> saveSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
      _cachedSettings = settings;
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  // Check if it's time for sleep reminder
  static bool shouldShowSleepReminder() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    // Show sleep reminder between 21:00 - 23:59
    return hour >= 21 || hour <= 1;
  }

  // Check if user should exercise today
  static Future<bool> shouldRemindExercise() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exerciseData = prefs.getString('exercise_records');

      if (exerciseData != null) {
        final List<dynamic> records = jsonDecode(exerciseData);
        final today = DateTime.now();

        // Check if user exercised today
        final todayExercise = records.any((record) {
          final date = DateTime.parse(record['date']);
          return date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        });

        return !todayExercise;
      }

      return true; // No records, should remind
    } catch (e) {
      print('Error checking exercise records: $e');
      return true;
    }
  }

  // Predict next period
  static Future<DateTime?> predictNextPeriod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final periodData = prefs.getString('period_records');

      if (periodData != null) {
        final List<dynamic> records = jsonDecode(periodData);

        if (records.isNotEmpty) {
          // Sort by date, most recent first
          records.sort((a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

          final lastPeriod = DateTime.parse(records.first['date']);

          // Calculate average cycle length if we have multiple records
          if (records.length > 1) {
            int totalDays = 0;
            int cycles = 0;

            for (int i = 0; i < records.length - 1; i++) {
              final current = DateTime.parse(records[i]['date']);
              final previous = DateTime.parse(records[i + 1]['date']);
              final days = current.difference(previous).inDays;

              if (days > 15 && days < 45) {
                // Valid cycle length
                totalDays += days;
                cycles++;
              }
            }

            if (cycles > 0) {
              final averageCycle = totalDays / cycles;
              return lastPeriod.add(Duration(days: averageCycle.round()));
            }
          }

          // Default to 28-day cycle
          return lastPeriod.add(const Duration(days: 28));
        }
      }

      return null;
    } catch (e) {
      print('Error predicting next period: $e');
      return null;
    }
  }

  // Check if should remind about upcoming period
  static Future<bool> shouldRemindPeriod() async {
    final nextPeriod = await predictNextPeriod();
    if (nextPeriod == null) return false;

    final now = DateTime.now();
    final daysUntil = nextPeriod.difference(now).inDays;

    // Remind 3 days before and on the day
    return daysUntil <= 3 && daysUntil >= 0;
  }

  // Generate personalized recommendations
  static Future<List<String>> getPersonalizedRecommendations() async {
    final recommendations = <String>[];

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check sleep quality
      final sleepData = prefs.getString('sleep_records');
      if (sleepData != null) {
        final records = jsonDecode(sleepData) as List;
        if (records.isNotEmpty) {
          final recentSleep = records.take(7);
          final avgQuality =
              recentSleep.map((r) => r['quality']).reduce((a, b) => a + b) /
                  recentSleep.length;

          if (avgQuality < 3) {
            recommendations
                .add('ພະຍາຍາມປັບປຸງຄຸນນະພາບການນອນ - ຫຼີກເວັ້ນຄາເຟອີນກ່ອນນອນ');
          }
        }
      }

      // Check exercise frequency
      final exerciseData = prefs.getString('exercise_records');
      if (exerciseData != null) {
        final records = jsonDecode(exerciseData) as List;
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        final recentExercise = records
            .where((r) => DateTime.parse(r['date']).isAfter(weekAgo))
            .length;

        if (recentExercise < 3) {
          recommendations.add('ພະຍາຍາມອອກກຳລັງກາຍຢ່າງນ້ອຍ 3 ຄັ້ງຕໍ່ອາທິດ');
        }
      }

      // Check stress levels
      final stressData = prefs.getString('stress_records');
      if (stressData != null) {
        final records = jsonDecode(stressData) as List;
        if (records.isNotEmpty) {
          final recentStress = records.take(7);
          final avgStress = recentStress
                  .map((r) => r['stressLevel'])
                  .reduce((a, b) => a + b) /
              recentStress.length;

          if (avgStress > 3) {
            recommendations
                .add('ລອງເຕັກນິກການຜ່ອນຄາຍ ເຊັ່ນ: ການຫາຍໃຈເລິກ ຫຼື ສະມາທິ');
          }
        }
      }

      // Default recommendations
      if (recommendations.isEmpty) {
        recommendations.addAll([
          'ດື່ມນ້ຳໃຫ້ພຽງພໍ - ຢ່າງນ້ອຍ 8 ແກ້ວຕໍ່ວັນ',
          'ກິນອາຫານທີ່ມີໄຟເບີສູງ ແລະ ໂປຣຕີນ',
          'ພັກຜ່ອນໃຫ້ພຽງພໍ 7-9 ຊົ່ວໂມງຕໍ່ຄືນ',
        ]);
      }
    } catch (e) {
      print('Error generating recommendations: $e');
    }

    return recommendations;
  }

  // Mock notification display (ໃນ production ຈະໃຊ້ local_notifications package)
  static Future<void> showNotification(String title, String body) async {
    // This is a mock implementation
    // In real app, you would use flutter_local_notifications
    print('Notification: $title - $body');
  }

  // Schedule daily check for notifications
  static Future<void> scheduleDailyCheck() async {
    final settings = await getSettings();

    // Check sleep reminder
    if (settings.sleepReminders && shouldShowSleepReminder()) {
      await showNotification(
          '😴 ເວລານອນແລ້ວ!', 'ໃກ້ເວລານອນແລ້ວ ພັກຜ່ອນໃຫ້ພຽງພໍເພື່ອສຸຂະພາບທີ່ດີ');
    }

    // Check exercise reminder
    if (settings.exerciseReminders && await shouldRemindExercise()) {
      await showNotification('🏃‍♀️ ເວລາອອກກຳລັງກາຍ!',
          'ມື້ນີ້ຍັງບໍ່ໄດ້ອອກກຳລັງກາຍເທື່ອ ມາເຄື່ອນໄຫວຮ່າງກາຍກັນເດີ!');
    }

    // Check period reminder
    if (settings.periodPredictions && await shouldRemindPeriod()) {
      final nextPeriod = await predictNextPeriod();
      if (nextPeriod != null) {
        final daysUntil = nextPeriod.difference(DateTime.now()).inDays;
        await showNotification(
            '🩸 ແຈ້ງເຕືອນປະຈຳເດືອນ',
            daysUntil == 0
                ? 'ມື້ນີ້ອາດເປັນວັນເລີ່ມປະຈຳເດືອນ'
                : 'ອີກ $daysUntil ວັນຈະເຖິງປະຈຳເດືອນ');
      }
    }
  }

  // Generate weekly health report
  static Future<Map<String, dynamic>> generateWeeklyReport() async {
    final report = <String, dynamic>{};

    try {
      final prefs = await SharedPreferences.getInstance();
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      // Sleep summary
      final sleepData = prefs.getString('sleep_records');
      if (sleepData != null) {
        final records = jsonDecode(sleepData) as List;
        final weeklyRecords = records
            .where((r) => DateTime.parse(r['date']).isAfter(weekAgo))
            .toList();

        if (weeklyRecords.isNotEmpty) {
          final avgQuality =
              weeklyRecords.map((r) => r['quality']).reduce((a, b) => a + b) /
                  weeklyRecords.length;
          report['sleep'] = {
            'nights': weeklyRecords.length,
            'avgQuality': avgQuality.toStringAsFixed(1),
            'recommendation': avgQuality < 3
                ? 'ຄວນປັບປຸງຄຸນນະພາບການນອນ'
                : 'ການນອນດີ ສືບຕໍ່ຮັກສາ!'
          };
        }
      }

      // Exercise summary
      final exerciseData = prefs.getString('exercise_records');
      if (exerciseData != null) {
        final records = jsonDecode(exerciseData) as List;
        final weeklyRecords = records
            .where((r) => DateTime.parse(r['date']).isAfter(weekAgo))
            .toList();

        final totalMinutes = weeklyRecords.fold<int>(
            0, (sum, r) => sum + (r['duration'] as int));
        report['exercise'] = {
          'sessions': weeklyRecords.length,
          'totalMinutes': totalMinutes,
          'recommendation': weeklyRecords.length >= 3
              ? 'ດີຫຼາຍ! ສືບຕໍ່ຮັກສາ'
              : 'ຄວນເພີ່ມການອອກກຳລັງກາຍ'
        };
      }

      // Stress summary
      final stressData = prefs.getString('stress_records');
      if (stressData != null) {
        final records = jsonDecode(stressData) as List;
        final weeklyRecords = records
            .where((r) => DateTime.parse(r['date']).isAfter(weekAgo))
            .toList();

        if (weeklyRecords.isNotEmpty) {
          final avgStress = weeklyRecords
                  .map((r) => r['stressLevel'])
                  .reduce((a, b) => a + b) /
              weeklyRecords.length;
          report['stress'] = {
            'avgLevel': avgStress.toStringAsFixed(1),
            'entries': weeklyRecords.length,
            'recommendation':
                avgStress > 3 ? 'ຄວນຫາວິທີຄຸ້ມຄອງຄວາມຄຽດ' : 'ລະດັບຄວາມຄຽດດີ'
          };
        }
      }

      report['generatedAt'] = DateTime.now().toIso8601String();
      report['recommendations'] = await getPersonalizedRecommendations();
    } catch (e) {
      print('Error generating weekly report: $e');
    }

    return report;
  }
}
