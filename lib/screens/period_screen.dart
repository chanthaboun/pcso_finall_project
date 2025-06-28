import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PeriodScreen extends StatefulWidget {
  const PeriodScreen({super.key});

  @override
  State<PeriodScreen> createState() => _PeriodScreenState();
}

class _PeriodScreenState extends State<PeriodScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFlow = 'ປົກກະຕິ';
  List<String> _selectedSymptoms = [];
  List<Map<String, dynamic>> _periodRecords = [];

  final List<String> _flowLevels = ['ເບົາ', 'ປົກກະຕິ', 'ຫຼາຍ', 'ຫຼາຍຫຼາຍ'];

  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'ປວດທ້ອງ', 'icon': Icons.sick, 'color': Colors.red},
    {'name': 'ປວດຫົວ', 'icon': Icons.psychology, 'color': Colors.orange},
    {'name': 'ເມື່ອຍ', 'icon': Icons.battery_0_bar, 'color': Colors.blue},
    {
      'name': 'ອາລົມບໍ່ດີ',
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.purple,
    },
    {'name': 'ປວດຫຼັງ', 'icon': Icons.accessibility_new, 'color': Colors.brown},
    {'name': 'ບວມ', 'icon': Icons.water_drop, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _loadPeriodData();
  }

  Future<void> _loadPeriodData() async {
    final prefs = await SharedPreferences.getInstance();
    final periodData = prefs.getString('period_records');
    if (periodData != null) {
      setState(() {
        _periodRecords = List<Map<String, dynamic>>.from(
          jsonDecode(periodData),
        );
      });
    }
  }

  Future<void> _savePeriodRecord() async {
    final record = {
      'date': _selectedDate.toIso8601String(),
      'flow': _selectedFlow,
      'symptoms': _selectedSymptoms,
    };

    // Remove existing record for the same date
    _periodRecords.removeWhere((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.day == _selectedDate.day &&
          recordDate.month == _selectedDate.month &&
          recordDate.year == _selectedDate.year;
    });

    setState(() {
      _periodRecords.add(record);
      _periodRecords.sort(
        (a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
      );
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('period_records', jsonEncode(_periodRecords));

    setState(() {
      _selectedSymptoms.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ບັນທຶກປະຈຳເດືອນສຳເລັດ!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getFlowColor(String flow) {
    switch (flow) {
      case 'ເບົາ':
        return Colors.pink[200]!;
      case 'ປົກກະຕິ':
        return Colors.pink[400]!;
      case 'ຫຼາຍ':
        return Colors.pink[600]!;
      case 'ຫຼາຍຫຼາຍ':
        return Colors.pink[800]!;
      default:
        return Colors.grey;
    }
  }

  DateTime? _getLastPeriodDate() {
    if (_periodRecords.isEmpty) return null;
    return DateTime.parse(_periodRecords.first['date']);
  }

  DateTime? _getNextPredictedDate() {
    final lastDate = _getLastPeriodDate();
    if (lastDate == null) return null;
    return lastDate.add(const Duration(days: 28)); // Average cycle
  }

  int? _getDaysSinceLastPeriod() {
    final lastDate = _getLastPeriodDate();
    if (lastDate == null) return null;
    return DateTime.now().difference(lastDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'ປະຈຳເດືອນ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period overview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_getLastPeriodDate() != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'ຄັ້ງສຸດທ້າຍ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_getDaysSinceLastPeriod()} ວັນ',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          Column(
                            children: [
                              const Text(
                                'ຄາດການຄັ້ງຕໍ່ໄປ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getNextPredictedDate() != null
                                    ? '${_getNextPredictedDate()!.day}/${_getNextPredictedDate()!.month}'
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Date selection
                    const Text(
                      'ເລືອກວັນທີ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE91E63),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFFE91E63),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Flow level
                    const Text(
                      'ຄວາມແຮງ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          _flowLevels.map((flow) {
                            final isSelected = _selectedFlow == flow;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFlow = flow;
                                });
                              },
                              child: Container(
                                width: 60,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? _getFlowColor(flow)
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    flow,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Symptoms
                    const Text(
                      'ອາການ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _symptoms.map((symptom) {
                            final isSelected = _selectedSymptoms.contains(
                              symptom['name'],
                            );
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedSymptoms.remove(symptom['name']);
                                  } else {
                                    _selectedSymptoms.add(symptom['name']);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? symptom['color'].withOpacity(0.2)
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: symptom['color'],
                                            width: 1,
                                          )
                                          : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      symptom['icon'],
                                      color:
                                          isSelected
                                              ? symptom['color']
                                              : Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      symptom['name'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isSelected
                                                ? symptom['color']
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _savePeriodRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ບັນທຶກ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Period history
              const Text(
                'ປະຫວັດປະຈຳເດືອນ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child:
                    _periodRecords.isEmpty
                        ? const Center(
                          child: Text(
                            'ຍັງບໍ່ມີຂໍ້ມູນປະຈຳເດືອນ',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _periodRecords.length,
                          itemBuilder: (context, index) {
                            final record = _periodRecords[index];
                            final date = DateTime.parse(record['date']);
                            final symptoms = List<String>.from(
                              record['symptoms'],
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _getFlowColor(record['flow']),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${date.day}/${date.month}/${date.year}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ຄວາມແຮງ: ${record['flow']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (symptoms.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'ອາການ:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children:
                                          symptoms.map((symptom) {
                                            final symptomInfo = _symptoms
                                                .firstWhere(
                                                  (s) => s['name'] == symptom,
                                                  orElse:
                                                      () => {
                                                        'name': symptom,
                                                        'icon': Icons.circle,
                                                        'color': Colors.grey,
                                                      },
                                                );
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: symptomInfo['color']
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                symptom,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: symptomInfo['color'],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
