// lib/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

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
      _settings = NotificationService.getAllSettings();
      _isLoading = false;
    });
  }

  void _updateSetting(NotificationType type, bool value) async {
    await NotificationService.updateNotificationSetting(type, value);
    setState(() {
      _settings[type] = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'ເປີດການແຈ້ງເຕືອນ ${_getTypeLabel(type)}'
              : 'ປິດການແຈ້ງເຕືອນ ${_getTypeLabel(type)}',
        ),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
  }

  void _scheduleTestNotification(NotificationType type) async {
    final testTime = DateTime.now().add(const Duration(seconds: 5));

    await NotificationService.scheduleNotification(
      title: 'ທົດສອບການແຈ້ງເຕືອນ ${_getTypeLabel(type)}',
      body:
          'ນີ້ແມ່ນການທົດສອບການແຈ້ງເຕືອນ ຖ້າເຈົ້າເຫັນຂໍ້ຄວາມນີ້ ແມ່ນການແຈ້ງເຕືອນເຮັດວຽກປົກກະຕິ',
      type: type,
      scheduledTime: testTime,
      data: {'test': true},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ສົ່ງການທົດສອບແລ້ວ ລໍຖ້າ 5 ວິນາທີ...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showScheduleDialog(NotificationType type) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        type: type,
        onScheduled: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ກຳນົດການແຈ້ງເຕືອນ ${_getTypeLabel(type)} ສຳເລັດ'),
              backgroundColor: Colors.green,
            ),
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
                        'ເປີດ/ປິດການແຈ້ງເຕືອນຕາມປະເພດ',
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
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _scheduleTestNotification(type),
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: const Text(
                                'ທົດສອບ',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _getTypeColor(type),
                                side: BorderSide(color: _getTypeColor(type)),
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
                              onPressed: () => _showScheduleDialog(type),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await NotificationService.cleanupOldNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ລຶບການແຈ້ງເຕືອນເກົ່າແລ້ວ'),
                              backgroundColor: Colors.orange,
                            ),
                          );
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
                          await NotificationService.scheduleWeeklyReports();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ກຳນົດລາຍງານປະຈຳອາທິດແລ້ວ'),
                              backgroundColor: Colors.green,
                            ),
                          );
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Schedule Dialog for different notification types
class _ScheduleDialog extends StatefulWidget {
  final NotificationType type;
  final VoidCallback onScheduled;

  const _ScheduleDialog({
    required this.type,
    required this.onScheduled,
  });

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<TimeOfDay> _medicationTimes = [];
  final List<int> _selectedWeekdays = [];
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ກຳນົດ${_getTypeLabel(widget.type)}'),
      content: _buildContent(),
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
        const Text('ເພີ່ມເວລາກິນຢາ:'),
        const SizedBox(height: 16),

        // Time picker
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
            }
          },
        ),

        ElevatedButton(
          onPressed: () {
            if (!_medicationTimes.any((t) =>
                t.hour == _selectedTime.hour &&
                t.minute == _selectedTime.minute)) {
              setState(() {
                _medicationTimes.add(_selectedTime);
              });
            }
          },
          child: const Text('ເພີ່ມເວລາ'),
        ),

        const SizedBox(height: 16),

        // Selected times
        if (_medicationTimes.isNotEmpty) ...[
          const Text('ເວລາທີ່ເລືອກ:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _medicationTimes.map((time) {
              return Chip(
                label: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
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
        const Text('ຕັ້ງເວລານອນ ແລະ ຕື່ນ:'),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.bedtime),
          title: const Text('ເວລານອນ'),
          subtitle: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildExerciseContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ເລືອກວັນແລະເວລາອອກກຳລັງກາຍ:'),
        const SizedBox(height: 16),

        // Time picker
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Weekday selection
        const Text('ເລືອກວັນ:'),
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
        const Text('ຄາດການວັນປະຈຳເດືອນຄັ້ງຕໍ່ໄປ:'),
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
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
            }
          },
        ),
      ],
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
            await NotificationService.scheduleMedicationReminders(
              medicationName: 'ຢາປົກກະຕິ',
              times: _medicationTimes,
              durationDays: 30,
            );
          }
          break;

        case NotificationType.sleep:
          final wakeupTime = TimeOfDay(
            hour: (_selectedTime.hour + 8) % 24,
            minute: _selectedTime.minute,
          );
          await NotificationService.scheduleSleepReminders(
            bedtime: _selectedTime,
            wakeupTime: wakeupTime,
          );
          break;

        case NotificationType.exercise:
          if (_selectedWeekdays.isNotEmpty) {
            await NotificationService.scheduleExerciseReminders(
              weekdays: _selectedWeekdays,
              time: _selectedTime,
            );
          }
          break;

        case NotificationType.period:
          await NotificationService.schedulePeriodPrediction(
            predictedDate: _selectedDate,
            cycleDays: 28,
          );
          break;

        default:
          // For other types, schedule a simple reminder
          await NotificationService.scheduleNotification(
            title: 'ການແຈ້ງເຕືອນ ${_getTypeLabel(widget.type)}',
            body: 'ນີ້ແມ່ນການແຈ້ງເຕືອນທີ່ເຈົ້າຕັ້ງໄວ້',
            type: widget.type,
            scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
          );
          break;
      }

      widget.onScheduled();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ເກີດຂໍ້ຜິດພາດ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
