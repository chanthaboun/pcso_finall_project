// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../widgets/lao_text_field.dart';

// // LanguageSwitcher widget (ຕ້ອງເພີ່ມເຂົ້າໄປ)
// class LanguageSwitcher extends StatelessWidget {
//   final String currentLanguage;
//   final Function(String) onLanguageChanged;

//   const LanguageSwitcher({
//     super.key,
//     required this.currentLanguage,
//     required this.onLanguageChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.language, color: Colors.black87),
//       onSelected: onLanguageChanged,
//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: 'ລາວ',
//           child: Text('ລາວ'),
//         ),
//         const PopupMenuItem(
//           value: 'English',
//           child: Text('English'),
//         ),
//       ],
//     );
//   }
// }

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
//     'ອາຫານວ່າງ'
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
//         _nutritionRecords =
//             List<Map<String, dynamic>>.from(jsonDecode(nutritionData));
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
//           content: Text('ບັນທຶກອາຫານສຳເລັດ! 🍽️'),
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
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       appBar: AppBar(
//         title: const Text(
//           '🍽️ ການກິນ',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           LanguageSwitcher(
//             currentLanguage: 'ລາວ',
//             onLanguageChanged: (language) {
//               // TODO: Implement language switching
//               print('Language changed to: $language');
//             },
//           ),
//         ],
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
//                   color: theme.cardColor,
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
//                         items: _mealTypes.map((type) {
//                           return DropdownMenuItem(
//                             value: type,
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   _getMealIcon(type),
//                                   color: _getMealColor(type),
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(type),
//                               ],
//                             ),
//                           );
//                         }).toList(),
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

//                     // Meal name with Lao support
//                     const Text(
//                       'ຊື່ອາຫານ:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     LaoTextField(
//                       controller: _mealController,
//                       hintText: 'ປ້ອນຊື່ອາຫານ... (ໃຊ້ພາສາລາວໄດ້)',
//                       prefixIcon: const Icon(
//                         Icons.restaurant,
//                         color: Color(0xFFE91E63),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'ກະລຸນາປ້ອນຊື່ອາຫານ';
//                         }
//                         return null;
//                       },
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
//                           onPressed: _portionSize > 1
//                               ? () {
//                                   setState(() {
//                                     _portionSize--;
//                                   });
//                                 }
//                               : null,
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
//                           onPressed: _portionSize < 10
//                               ? () {
//                                   setState(() {
//                                     _portionSize++;
//                                   });
//                                 }
//                               : null,
//                           icon: const Icon(Icons.add_circle_outline),
//                           color: const Color(0xFFE91E63),
//                         ),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'ສ່ວນ',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
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
//               Row(
//                 children: [
//                   const Text(
//                     'ປະຫວັດການກິນມື້ນີ້',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const Spacer(),
//                   if (_nutritionRecords.isNotEmpty)
//                     Text(
//                       '${_nutritionRecords.length} ລາຍການ',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               Expanded(
//                 child: _nutritionRecords.isEmpty
//                     ? const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.restaurant_outlined,
//                               size: 60,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 12),
//                             Text(
//                               'ຍັງບໍ່ມີຂໍ້ມູນການກິນ',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               'ເພີ່ມອາຫານທຳອິດຂອງເຈົ້າເລີຍ!',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: _nutritionRecords.length,
//                         itemBuilder: (context, index) {
//                           final record = _nutritionRecords[index];
//                           final date = DateTime.parse(record['date']);

//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: theme.cardColor,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 5,
//                                   offset: const Offset(0, 1),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 50,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: _getMealColor(record['mealType'])
//                                         .withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(25),
//                                   ),
//                                   child: Icon(
//                                     _getMealIcon(record['mealType']),
//                                     color: _getMealColor(record['mealType']),
//                                     size: 24,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         record['mealName'],
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         '${record['mealType']} • ${record['portionSize']} ສ່ວນ',
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       Text(
//                                         '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _nutritionRecords.removeAt(index);
//                                     });
//                                     SharedPreferences.getInstance()
//                                         .then((prefs) {
//                                       prefs.setString('nutrition_records',
//                                           jsonEncode(_nutritionRecords));
//                                     });

//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text('ລຶບອາຫານແລ້ວ'),
//                                         backgroundColor: Colors.orange,
//                                       ),
//                                     );
//                                   },
//                                   icon: const Icon(
//                                     Icons.delete_outline,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
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
import 'dart:math';

// LanguageSwitcher widget
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

// LaoTextField widget (simple implementation)
class LaoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const LaoTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with TickerProviderStateMixin {
  final _mealController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMealType = 'ອາຫານເຊົ້າ';
  int _portionSize = 1;
  List<Map<String, dynamic>> _nutritionRecords = [];

  // Nutrition tracking
  int _dailyCalorieGoal = 2000;
  double _waterIntake = 0; // in glasses
  List<String> _selectedNutritionTags = [];

  late TabController _tabController;

  final List<String> _mealTypes = [
    'ອາຫານເຊົ້າ',
    'ອາຫານທ່ຽງ',
    'ອາຫານແລງ',
    'ອາຫານວ່າງ'
  ];

  // Nutrition tags
  final List<String> _nutritionTags = [
    '🥬 ຜັກໃສ',
    '🍎 ໝາກໄມ້',
    '🥩 ເນື້ອສັດ',
    '🐟 ປາ',
    '🥛 ນົມ',
    '🍚 ເຂົ້າ',
    '🍞 ເຂົ້າຈີ່',
    '🥜 ໝາກຖົ່ວ',
    '🧄 ເຄື່ອງເທດ',
    '🍰 ຂອງຫວານ',
    '🍟 ອາຫານທອດ',
    '🥤 ເຄື່ອງດື່ມ'
  ];

  // Quick add meals
  final List<Map<String, dynamic>> _quickMeals = [
    {'name': 'ເຂົ້າຈີ່ + ໄຂ່', 'calories': 300, 'type': 'ອາຫານເຊົ້າ'},
    {'name': 'ຕຳໝາກຮຸ່ງ', 'calories': 150, 'type': 'ອາຫານວ່າງ'},
    {'name': 'ເຂົ້າຜັດ', 'calories': 450, 'type': 'ອາຫານທ່ຽງ'},
    {'name': 'ລາບ', 'calories': 350, 'type': 'ອາຫານແລງ'},
    {'name': 'ເຂົ້າປຽກ', 'calories': 400, 'type': 'ອາຫານເຊົ້າ'},
    {'name': 'ໝີ່ຊົ່ວ', 'calories': 380, 'type': 'ອາຫານທ່ຽງ'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNutritionData();
  }

  @override
  void dispose() {
    _mealController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNutritionData() async {
    final prefs = await SharedPreferences.getInstance();
    final nutritionData = prefs.getString('nutrition_records');
    final calorieGoal = prefs.getInt('daily_calorie_goal');
    final waterData = prefs.getDouble('water_intake');

    if (nutritionData != null) {
      setState(() {
        _nutritionRecords =
            List<Map<String, dynamic>>.from(jsonDecode(nutritionData));
      });
    }

    if (calorieGoal != null) {
      setState(() {
        _dailyCalorieGoal = calorieGoal;
      });
    }

    if (waterData != null) {
      setState(() {
        _waterIntake = waterData;
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

    final calories = int.tryParse(_caloriesController.text) ?? 0;

    final record = {
      'date': DateTime.now().toIso8601String(),
      'mealType': _selectedMealType,
      'mealName': _mealController.text.trim(),
      'portionSize': _portionSize,
      'calories': calories,
      'nutritionTags': List.from(_selectedNutritionTags),
      'notes': _notesController.text.trim(),
    };

    setState(() {
      _nutritionRecords.insert(0, record);
      _selectedNutritionTags.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutrition_records', jsonEncode(_nutritionRecords));

    _mealController.clear();
    _caloriesController.clear();
    _notesController.clear();
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

  Future<void> _addQuickMeal(Map<String, dynamic> meal) async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'mealType': meal['type'],
      'mealName': meal['name'],
      'portionSize': 1,
      'calories': meal['calories'],
      'nutritionTags': <String>[],
      'notes': 'ເພີ່ມດ່ວນ',
    };

    setState(() {
      _nutritionRecords.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutrition_records', jsonEncode(_nutritionRecords));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ເພີ່ມ ${meal['name']} ແລ້ວ! 🍽️'),
        backgroundColor: Colors.green,
      ),
    );
  }

  int _getTodayCalories() {
    final today = DateTime.now();
    return _nutritionRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day;
    }).fold<int>(0, (sum, record) => sum + (record['calories'] as int? ?? 0));
  }

  int _getTodayMeals() {
    final today = DateTime.now();
    return _nutritionRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day;
    }).length;
  }

  Map<String, int> _getMealTypeCount() {
    final today = DateTime.now();
    final todayRecords = _nutritionRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day;
    });

    final counts = <String, int>{};
    for (final type in _mealTypes) {
      counts[type] = todayRecords.where((r) => r['mealType'] == type).length;
    }
    return counts;
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

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick stats overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'ມື້ນີ້',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_getTodayCalories()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Calories',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white30),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_getTodayMeals()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'ມື້ອາຫານ',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white30),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_waterIntake.toInt()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'ແກ້ວນ້ຳ',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Quick meal buttons
          Container(
            padding: EdgeInsets.all(16),
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
                Text(
                  'ເພີ່ມດ່ວນ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                  children: _quickMeals.map((meal) {
                    return GestureDetector(
                      onTap: () => _addQuickMeal(meal),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getMealColor(meal['type']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getMealColor(meal['type']).withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            meal['name'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getMealColor(meal['type']),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Water intake tracker
          Container(
            padding: EdgeInsets.all(16),
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
                Row(
                  children: [
                    Icon(Icons.local_drink, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'ການດື່ມນ້ຳ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${_waterIntake.toInt()}/8 ແກ້ວ',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: min(_waterIntake / 8, 1.0),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _waterIntake += 0.5;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('water_intake', _waterIntake);
                      },
                      icon: Icon(Icons.add, size: 16),
                      label: Text('+0.5'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _waterIntake += 1;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('water_intake', _waterIntake);
                      },
                      icon: Icon(Icons.add, size: 16),
                      label: Text('+1'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                    Spacer(),
                    if (_waterIntake > 0)
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            _waterIntake = 0;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setDouble('water_intake', 0);
                        },
                        child: Text('Reset'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Add meal form
          Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  'ເພີ່ມອາຫານແບບລະອຽດ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                SizedBox(height: 16),

                // Meal type and name in row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ປະເພດ:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedMealType,
                              isExpanded: true,
                              underline: SizedBox(),
                              items: _mealTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(_getMealIcon(type),
                                          color: _getMealColor(type), size: 16),
                                      SizedBox(width: 6),
                                      Text(type,
                                          style: TextStyle(fontSize: 14)),
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
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ສ່ວນ:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _portionSize > 1
                                    ? () => setState(() => _portionSize--)
                                    : null,
                                icon:
                                    Icon(Icons.remove_circle_outline, size: 20),
                                padding: EdgeInsets.zero,
                                constraints:
                                    BoxConstraints(minWidth: 30, minHeight: 30),
                              ),
                              Container(
                                width: 35,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE91E63).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    _portionSize.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _portionSize < 10
                                    ? () => setState(() => _portionSize++)
                                    : null,
                                icon: Icon(Icons.add_circle_outline, size: 20),
                                padding: EdgeInsets.zero,
                                constraints:
                                    BoxConstraints(minWidth: 30, minHeight: 30),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Meal name and calories in row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ຊື່ອາຫານ:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          LaoTextField(
                            controller: _mealController,
                            hintText: 'ປ້ອນຊື່ອາຫານ...',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Calories:',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          LaoTextField(
                            controller: _caloriesController,
                            hintText: '0',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Nutrition tags
                Text('ປະເພດອາຫານ:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _nutritionTags.map((tag) {
                    final isSelected = _selectedNutritionTags.contains(tag);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedNutritionTags.remove(tag);
                          } else {
                            _selectedNutritionTags.add(tag);
                          }
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFFE91E63).withOpacity(0.2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Color(0xFFE91E63))
                              : null,
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Color(0xFFE91E63)
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 12),

                // Notes
                Text('ໝາຍເຫດ:', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                LaoTextField(
                  controller: _notesController,
                  hintText: 'ເພີ່ມໝາຍເຫດ...',
                ),

                SizedBox(height: 16),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _saveMealRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ເພີ່ມອາຫານ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final todayCalories = _getTodayCalories();
    final mealCounts = _getMealTypeCount();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calorie goal progress
          Container(
            padding: EdgeInsets.all(16),
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
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'ເປົ້າໝາຍ Calories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: min(todayCalories / _dailyCalorieGoal, 1.0),
                        strokeWidth: 8,
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$todayCalories',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              '/ $_dailyCalorieGoal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Slider(
                  value: _dailyCalorieGoal.toDouble(),
                  min: 1200,
                  max: 3000,
                  divisions: 36,
                  label: '$_dailyCalorieGoal Cal',
                  onChanged: (value) async {
                    setState(() {
                      _dailyCalorieGoal = value.toInt();
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('daily_calorie_goal', _dailyCalorieGoal);
                  },
                ),
                Text(
                  'ກຳນົດເປົ້າໝາຍ Calories ຕໍ່ວັນ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Meal distribution
          Container(
            padding: EdgeInsets.all(16),
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
                Text(
                  'ການແຈກຢາຍມື້ອາຫານມື້ນີ້',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ...mealCounts.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          _getMealIcon(entry.key),
                          color: _getMealColor(entry.key),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getMealColor(entry.key).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getMealColor(entry.key),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Weekly summary
          Container(
            padding: EdgeInsets.all(16),
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
                Text(
                  'ສະຖິຕິ 7 ວັນຜ່ານມາ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'ຈຳນວນມື້',
                        '${_getWeeklyMeals()}',
                        Icons.restaurant,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Calories ເຉລີ່ຍ',
                        '${_getAverageCalories()}',
                        Icons.local_fire_department,
                        Colors.orange,
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

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getWeeklyMeals() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return _nutritionRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekAgo) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    }).length;
  }

  int _getAverageCalories() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final weeklyRecords = _nutritionRecords.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(weekAgo) &&
          recordDate.isBefore(now.add(Duration(days: 1)));
    }).toList();

    if (weeklyRecords.isEmpty) return 0;

    final totalCalories = weeklyRecords.fold<int>(
        0, (sum, record) => sum + (record['calories'] as int? ?? 0));
    return totalCalories ~/ 7;
  }

  Widget _buildHistoryTab() {
    return _nutritionRecords.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'ຍັງບໍ່ມີຂໍ້ມູນການກິນ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ເພີ່ມອາຫານທຳອິດຂອງເຈົ້າເລີຍ!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _nutritionRecords.length,
            itemBuilder: (context, index) {
              final record = _nutritionRecords[index];
              final date = DateTime.parse(record['date']);
              final nutritionTags =
                  record['nutritionTags'] as List<dynamic>? ?? [];
              final notes = record['notes'] as String? ?? '';

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
                  children: [
                    Row(
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
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      record['mealName'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (record['calories'] != null &&
                                      record['calories'] > 0)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${record['calories']} Cal',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${record['mealType']} • ${record['portionSize']} ສ່ວນ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
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
                            SharedPreferences.getInstance().then((prefs) {
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
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    if (nutritionTags.isNotEmpty || notes.isNotEmpty) ...[
                      SizedBox(height: 12),
                      if (nutritionTags.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: nutritionTags.map<Widget>((tag) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      if (notes.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notes,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
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
              print('Language changed to: $language');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFE91E63),
          tabs: [
            Tab(icon: Icon(Icons.add), text: 'ເພີ່ມ'),
            Tab(icon: Icon(Icons.analytics), text: 'ສະຖິຕິ'),
            Tab(icon: Icon(Icons.history), text: 'ປະຫວັດ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrackingTab(),
          _buildStatsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }
}
