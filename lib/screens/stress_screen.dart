import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> {
  int _stressLevel = 3;
  String _selectedCause = 'ວຽກງານ';
  final _noteController = TextEditingController();
  List<Map<String, dynamic>> _stressRecords = [];
  
  final List<String> _stressCauses = [
    'ວຽກງານ',
    'ຄອບຄົວ',
    'ເງິນ',
    'ສຸຂະພາບ',
    'ຄວາມສຳພັນ',
    'ການຮຽນ',
    'ອື່ນໆ'
  ];

  @override
  void initState() {
    super.initState();
    _loadStressData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadStressData() async {
    final prefs = await SharedPreferences.getInstance();
    final stressData = prefs.getString('stress_records');
    if (stressData != null) {
      setState(() {
        _stressRecords = List<Map<String, dynamic>>.from(jsonDecode(stressData));
      });
    }
  }

  Future<void> _saveStressRecord() async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'stressLevel': _stressLevel,
      'cause': _selectedCause,
      'note': _noteController.text.trim(),
    };

    setState(() {
      _stressRecords.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stress_records', jsonEncode(_stressRecords));

    _noteController.clear();
    setState(() {
      _stressLevel = 3;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ບັນທຶກຄວາມຄຽດສຳເລັດ!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getStressLevelText(int level) {
    switch (level) {
      case 1: return 'ຜ່ອນຄາຍ';
      case 2: return 'ເບົາໆ';
      case 3: return 'ປົກກະຕິ';
      case 4: return 'ຄຽດ';
      case 5: return 'ຄຽດຫຼາຍ';
      default: return 'ປົກກະຕິ';
    }
  }

  Color _getStressLevelColor(int level) {
    switch (level) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.yellow[700]!;
      case 4: return Colors.orange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getCauseIcon(String cause) {
    switch (cause) {
      case 'ວຽກງານ':
        return Icons.work;
      case 'ຄອບຄົວ':
        return Icons.family_restroom;
      case 'ເງິນ':
        return Icons.monetization_on;
      case 'ສຸຂະພາບ':
        return Icons.health_and_safety;
      case 'ຄວາມສຳພັນ':
        return Icons.favorite;
      case 'ການຮຽນ':
        return Icons.school;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'ຄວາມຄຽດ',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stress input section
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ບັນທຶກຄວາມຄຽດມື້ນີ້',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Stress level
                    const Text(
                      'ລະດັບຄວາມຄຽດ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final level = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _stressLevel = level;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _stressLevel == level
                                      ? _getStressLevelColor(level)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    level.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _stressLevel == level
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getStressLevelText(level),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _stressLevel == level
                                      ? _getStressLevelColor(level)
                                      : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    
                    // Stress cause
                    const Text(
                      'ສາເຫດຂອງຄວາມຄຽດ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCause,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        items: _stressCauses.map((cause) {
                          return DropdownMenuItem(
                            value: cause,
                            child: Row(
                              children: [
                                Icon(
                                  _getCauseIcon(cause),
                                  color: const Color(0xFFE91E63),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(cause),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCause = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Note
                    const Text(
                      'ບັນທຶກເພີ່ມເຕີມ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'ເຂີຍນຄວາມຮູ້ສຶກ ຫຼື ອາກອນທີ່ເກີດຂື່ນ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _saveStressRecord,
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
              
              // Stress history
              const Text(
                'ປະຫວັດຄວາມຄຽດ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: _stressRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'ຍັງບໍ່ມີຂໍ້ມູນຄວາມຄຽດ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _stressRecords.length,
                        itemBuilder: (context, index) {
                          final record = _stressRecords[index];
                          final date = DateTime.parse(record['date']);
                          
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
                                        color: _getStressLevelColor(record['stressLevel']),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                _getCauseIcon(record['cause']),
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                record['cause'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'ລະດັບ ${record['stressLevel']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE91E63),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStressLevelColor(record['stressLevel']).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _getStressLevelText(record['stressLevel']),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _getStressLevelColor(record['stressLevel']),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (record['note'].isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      record['note'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
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