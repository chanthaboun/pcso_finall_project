// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class NutritionScreen extends StatefulWidget {
//   const NutritionScreen({super.key});

//   @override
//   State<NutritionScreen> createState() => _NutritionScreenState();
// }

// class _NutritionScreenState extends State<NutritionScreen> {
//   final _mealController = TextEditingController();
//   String _selectedMealType = 'ອາຫານເຊົ້າ';
//   int _portionSize = 1;
//   List<Map<String, dynamic>> _nutritionRecords = [];

//   final List<String> _mealTypes = [
//     'ອາຫານເຊົ້າ',
//     'ອາຫານທ່ຽງ',
//     'ອາຫານແລງ',
//     'ອາຫານວ່າງ',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadNutritionData();
//   }

//   @override
//   void dispose() {
//     _mealController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadNutritionData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final nutritionData = prefs.getString('nutrition_records');
//     if (nutritionData != null) {
//       setState(() {
//         _nutritionRecords = List<Map<String, dynamic>>.from(
//           jsonDecode(nutritionData),
//         );
//       });
//     }
//   }

//   Future<void> _saveMealRecord() async {
//     if (_mealController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('ກະລຸນາປ້ອນຊື່ອາຫານ'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final record = {
//       'date': DateTime.now().toIso8601String(),
//       'mealType': _selectedMealType,
//       'mealName': _mealController.text.trim(),
//       'portionSize': _portionSize,
//     };

//     setState(() {
//       _nutritionRecords.insert(0, record);
//     });

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('nutrition_records', jsonEncode(_nutritionRecords));

//     _mealController.clear();
//     setState(() {
//       _portionSize = 1;
//     });

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('ບັນທຶກອາຫານສຳເລັດ!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   IconData _getMealIcon(String mealType) {
//     switch (mealType) {
//       case 'ອາຫານເຊົ້າ':
//         return Icons.wb_sunny;
//       case 'ອາຫານທ່ຽງ':
//         return Icons.wb_cloudy;
//       case 'ອາຫານແລງ':
//         return Icons.nights_stay;
//       case 'ອາຫານວ່າງ':
//         return Icons.local_cafe;
//       default:
//         return Icons.restaurant;
//     }
//   }

//   Color _getMealColor(String mealType) {
//     switch (mealType) {
//       case 'ອາຫານເຊົ້າ':
//         return Colors.orange;
//       case 'ອາຫານທ່ຽງ':
//         return Colors.blue;
//       case 'ອາຫານແລງ':
//         return Colors.purple;
//       case 'ອາຫານວ່າງ':
//         return Colors.green;
//       default:
//         return const Color(0xFFE91E63);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCE4EC),
//       appBar: AppBar(
//         title: const Text(
//           'ການກິນ',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Add meal section
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'ເພີ່ມອາຫານມື້ນີ້',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFFE91E63),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Meal type selection
//                     const Text(
//                       'ປະເພດອາຫານ:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: _selectedMealType,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16),
//                         ),
//                         items:
//                             _mealTypes.map((type) {
//                               return DropdownMenuItem(
//                                 value: type,
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       _getMealIcon(type),
//                                       color: _getMealColor(type),
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(type),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() {
//                               _selectedMealType = value;
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Meal name
//                     const Text(
//                       'ຊື່ອາຫານ:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _mealController,
//                       decoration: InputDecoration(
//                         hintText: 'ປ້ອນຊື່ອາຫານ...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         prefixIcon: const Icon(
//                           Icons.restaurant,
//                           color: Color(0xFFE91E63),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Portion size
//                     const Text(
//                       'ຈຳນວນ/ສ່ວນ:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         IconButton(
//                           onPressed:
//                               _portionSize > 1
//                                   ? () {
//                                     setState(() {
//                                       _portionSize--;
//                                     });
//                                   }
//                                   : null,
//                           icon: const Icon(Icons.remove_circle_outline),
//                           color: const Color(0xFFE91E63),
//                         ),
//                         Container(
//                           width: 60,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFE91E63).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Center(
//                             child: Text(
//                               _portionSize.toString(),
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFFE91E63),
//                               ),
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed:
//                               _portionSize < 10
//                                   ? () {
//                                     setState(() {
//                                       _portionSize++;
//                                     });
//                                   }
//                                   : null,
//                           icon: const Icon(Icons.add_circle_outline),
//                           color: const Color(0xFFE91E63),
//                         ),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'ສ່ວນ',
//                           style: TextStyle(fontSize: 16, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     // Add button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 45,
//                       child: ElevatedButton(
//                         onPressed: _saveMealRecord,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFE91E63),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'ເພີ່ມອາຫານ',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Nutrition history
//               const Text(
//                 'ປະຫວັດການກິນມື້ນີ້',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               Expanded(
//                 child:
//                     _nutritionRecords.isEmpty
//                         ? const Center(
//                           child: Text(
//                             'ຍັງບໍ່ມີຂໍ້ມູນການກິນ',
//                             style: TextStyle(fontSize: 16, color: Colors.grey),
//                           ),
//                         )
//                         : ListView.builder(
//                           itemCount: _nutritionRecords.length,
//                           itemBuilder: (context, index) {
//                             final record = _nutritionRecords[index];
//                             final date = DateTime.parse(record['date']);

//                             return Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 1),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 50,
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       color: _getMealColor(
//                                         record['mealType'],
//                                       ).withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(25),
//                                     ),
//                                     child: Icon(
//                                       _getMealIcon(record['mealType']),
//                                       color: _getMealColor(record['mealType']),
//                                       size: 24,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           record['mealName'],
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           '${record['mealType']} • ${record['portionSize']} ສ່ວນ',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                         Text(
//                                           '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         _nutritionRecords.removeAt(index);
//                                       });
//                                       SharedPreferences.getInstance().then((
//                                         prefs,
//                                       ) {
//                                         prefs.setString(
//                                           'nutrition_records',
//                                           jsonEncode(_nutritionRecords),
//                                         );
//                                       });
//                                     },
//                                     icon: const Icon(
//                                       Icons.delete_outline,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/lao_text_field.dart';

// LanguageSwitcher widget (ຕ້ອງເພີ່ມເຂົ້າໄປ)
class LanguageSwitcher extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSwitcher({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.black87),
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'ລາວ',
          child: Text('ລາວ'),
        ),
        const PopupMenuItem(
          value: 'English',
          child: Text('English'),
        ),
      ],
    );
  }
}

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _mealController = TextEditingController();
  String _selectedMealType = 'ອາຫານເຊົ້າ';
  int _portionSize = 1;
  List<Map<String, dynamic>> _nutritionRecords = [];

  final List<String> _mealTypes = [
    'ອາຫານເຊົ້າ',
    'ອາຫານທ່ຽງ',
    'ອາຫານແລງ',
    'ອາຫານວ່າງ'
  ];

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  @override
  void dispose() {
    _mealController.dispose();
    super.dispose();
  }

  Future<void> _loadNutritionData() async {
    final prefs = await SharedPreferences.getInstance();
    final nutritionData = prefs.getString('nutrition_records');
    if (nutritionData != null) {
      setState(() {
        _nutritionRecords =
            List<Map<String, dynamic>>.from(jsonDecode(nutritionData));
      });
    }
  }

  Future<void> _saveMealRecord() async {
    if (_mealController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ກະລຸນາປ້ອນຊື່ອາຫານ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final record = {
      'date': DateTime.now().toIso8601String(),
      'mealType': _selectedMealType,
      'mealName': _mealController.text.trim(),
      'portionSize': _portionSize,
    };

    setState(() {
      _nutritionRecords.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutrition_records', jsonEncode(_nutritionRecords));

    _mealController.clear();
    setState(() {
      _portionSize = 1;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ບັນທຶກອາຫານສຳເລັດ! 🍽️'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'ອາຫານເຊົ້າ':
        return Icons.wb_sunny;
      case 'ອາຫານທ່ຽງ':
        return Icons.wb_cloudy;
      case 'ອາຫານແລງ':
        return Icons.nights_stay;
      case 'ອາຫານວ່າງ':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'ອາຫານເຊົ້າ':
        return Colors.orange;
      case 'ອາຫານທ່ຽງ':
        return Colors.blue;
      case 'ອາຫານແລງ':
        return Colors.purple;
      case 'ອາຫານວ່າງ':
        return Colors.green;
      default:
        return const Color(0xFFE91E63);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text(
          '🍽️ ການກິນ',
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
        actions: [
          LanguageSwitcher(
            currentLanguage: 'ລາວ',
            onLanguageChanged: (language) {
              // TODO: Implement language switching
              print('Language changed to: $language');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add meal section
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ເພີ່ມອາຫານມື້ນີ້',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Meal type selection
                    const Text(
                      'ປະເພດອາຫານ:',
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
                        value: _selectedMealType,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        items: _mealTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  _getMealIcon(type),
                                  color: _getMealColor(type),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(type),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMealType = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meal name with Lao support
                    const Text(
                      'ຊື່ອາຫານ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LaoTextField(
                      controller: _mealController,
                      hintText: 'ປ້ອນຊື່ອາຫານ... (ໃຊ້ພາສາລາວໄດ້)',
                      prefixIcon: const Icon(
                        Icons.restaurant,
                        color: Color(0xFFE91E63),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'ກະລຸນາປ້ອນຊື່ອາຫານ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Portion size
                    const Text(
                      'ຈຳນວນ/ສ່ວນ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _portionSize > 1
                              ? () {
                                  setState(() {
                                    _portionSize--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFFE91E63),
                        ),
                        Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _portionSize.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _portionSize < 10
                              ? () {
                                  setState(() {
                                    _portionSize++;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFFE91E63),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ສ່ວນ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _saveMealRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ເພີ່ມອາຫານ',
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

              // Nutrition history
              Row(
                children: [
                  const Text(
                    'ປະຫວັດການກິນມື້ນີ້',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (_nutritionRecords.isNotEmpty)
                    Text(
                      '${_nutritionRecords.length} ລາຍການ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _nutritionRecords.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'ຍັງບໍ່ມີຂໍ້ມູນການກິນ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ເພີ່ມອາຫານທຳອິດຂອງເຈົ້າເລີຍ!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _nutritionRecords.length,
                        itemBuilder: (context, index) {
                          final record = _nutritionRecords[index];
                          final date = DateTime.parse(record['date']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
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
                                    color: _getMealColor(record['mealType'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    _getMealIcon(record['mealType']),
                                    color: _getMealColor(record['mealType']),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record['mealName'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${record['mealType']} • ${record['portionSize']} ສ່ວນ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _nutritionRecords.removeAt(index);
                                    });
                                    SharedPreferences.getInstance()
                                        .then((prefs) {
                                      prefs.setString('nutrition_records',
                                          jsonEncode(_nutritionRecords));
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('ລຶບອາຫານແລ້ວ'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
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
