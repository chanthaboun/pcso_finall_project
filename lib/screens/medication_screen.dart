import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<Medication> _medications = [];
  List<MedicationLog> _medicationLogs = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsData = prefs.getString('medications');
      final logsData = prefs.getString('medication_logs');

      if (medicationsData != null) {
        final List<dynamic> decoded = jsonDecode(medicationsData);
        _medications =
            decoded.map((item) => Medication.fromJson(item)).toList();
      }

      if (logsData != null) {
        final List<dynamic> decoded = jsonDecode(logsData);
        _medicationLogs =
            decoded.map((item) => MedicationLog.fromJson(item)).toList();
      }

      setState(() {});
    } catch (e) {
      print('Error loading medications: $e');
    }
  }

  Future<void> _saveMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_medications.map((med) => med.toJson()).toList());
      await prefs.setString('medications', encoded);
    } catch (e) {
      print('Error saving medications: $e');
    }
  }

  Future<void> _saveMedicationLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_medicationLogs.map((log) => log.toJson()).toList());
      await prefs.setString('medication_logs', encoded);
    } catch (e) {
      print('Error saving medication logs: $e');
    }
  }

  void _addMedication() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMedicationModal(
        onAdd: (medication) {
          setState(() {
            _medications.add(medication);
          });
          _saveMedications();
        },
      ),
    );
  }

  Future<void> _logMedication(Medication medication, bool taken,
      [String? reason]) async {
    final log = MedicationLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medication.id,
      takenAt: DateTime.now(),
      wasTaken: taken,
      missedReason: reason,
    );

    setState(() {
      _medicationLogs.add(log);
    });

    await _saveMedicationLogs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(taken ? 'ບັນທຶກການກິນຢາແລ້ວ ✅' : 'ບັນທຶກການບໍ່ກິນຢາ ⚠️'),
          backgroundColor: taken ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  List<MedicationLog> _getTodayLogs(String medicationId) {
    final today = DateTime.now();
    return _medicationLogs.where((log) {
      return log.medicationId == medicationId &&
          log.takenAt.year == today.year &&
          log.takenAt.month == today.month &&
          log.takenAt.day == today.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('💊 ການກິນຢາ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addMedication,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _medications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ຍັງບໍ່ມີຢາທີ່ຕ້ອງກິນ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ກົດ + ເພື່ອເພີ່ມຢາ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final medication = _medications[index];
                final todayLogs = _getTodayLogs(medication.id);
                final hasBeenTaken = todayLogs.any((log) => log.wasTaken);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: hasBeenTaken
                                    ? Colors.green.withOpacity(0.1)
                                    : theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                _getMedicationIcon(medication.type),
                                color: hasBeenTaken
                                    ? Colors.green
                                    : theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medication.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${medication.dosage} • ${_getFrequencyText(medication.frequency)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (medication.times.isNotEmpty)
                                    Text(
                                      'ເວລາ: ${medication.times.join(", ")}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (hasBeenTaken)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '✅ ກິນແລ້ວ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (medication.notes != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              medication.notes!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: hasBeenTaken
                                    ? null
                                    : () => _logMedication(medication, true),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('ກິນແລ້ວ'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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
                                onPressed: hasBeenTaken
                                    ? null
                                    : () => _showMissedDialog(medication),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('ບໍ່ກິນ'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
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
                  ),
                );
              },
            ),
    );
  }

  void _showMissedDialog(Medication medication) {
    final reasons = [
      'ລືມ',
      'ບໍ່ມີຢາ',
      'ຮູ້ສຶກບໍ່ສະບາຍ',
      'ອື່ນໆ',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ເຫດຜົນທີ່ບໍ່ກິນຢາ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map((reason) => ListTile(
                    title: Text(reason),
                    onTap: () {
                      Navigator.pop(context);
                      _logMedication(medication, false, reason);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  IconData _getMedicationIcon(String type) {
    switch (type) {
      case 'pill':
        return Icons.medication;
      case 'liquid':
        return Icons.local_drink;
      case 'injection':
        return Icons.colorize;
      default:
        return Icons.medication;
    }
  }

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'ທຸກວັນ';
      case 'weekly':
        return 'ທຸກອາທິດ';
      case 'as_needed':
        return 'ເມື່ອຕ້ອງການ';
      default:
        return frequency;
    }
  }
}

class _AddMedicationModal extends StatefulWidget {
  final Function(Medication) onAdd;

  const _AddMedicationModal({required this.onAdd});

  @override
  State<_AddMedicationModal> createState() => _AddMedicationModalState();
}

class _AddMedicationModalState extends State<_AddMedicationModal> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  String _frequency = 'daily';
  String _type = 'pill';
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            const Text(
              'ເພີ່ມຢາໃໝ່',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'ຊື່ຢາ',
                        hintText: 'ເຊັ່ນ: Metformin',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'ຂະໜາດ',
                        hintText: 'ເຊັ່ນ: 500mg',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _frequency,
                      decoration: const InputDecoration(labelText: 'ຄວາມຖີ່'),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('ທຸກວັນ')),
                        DropdownMenuItem(
                            value: 'weekly', child: Text('ທຸກອາທິດ')),
                        DropdownMenuItem(
                            value: 'as_needed', child: Text('ເມື່ອຕ້ອງການ')),
                      ],
                      onChanged: (value) => setState(() => _frequency = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'ປະເພດຢາ'),
                      items: const [
                        DropdownMenuItem(value: 'pill', child: Text('ເມັດ')),
                        DropdownMenuItem(value: 'liquid', child: Text('ນ້ຳ')),
                        DropdownMenuItem(
                            value: 'injection', child: Text('ເຂັມ')),
                      ],
                      onChanged: (value) => setState(() => _type = value!),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ໝາຍເຫດ (ເສີມ)',
                        hintText: 'ບັນທຶກເພີ່ມເຕີມ...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty &&
                      _dosageController.text.isNotEmpty) {
                    final medication = Medication(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      frequency: _frequency,
                      times: _times
                          .map((time) =>
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
                          .toList(),
                      notes: _notesController.text.isEmpty
                          ? null
                          : _notesController.text,
                      startDate: DateTime.now(),
                      type: _type,
                    );

                    widget.onAdd(medication);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                ),
                child: const Text('ເພີ່ມຢາ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
