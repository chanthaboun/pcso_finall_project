import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // Light Theme - Legacy Material 2
  static final lightTheme = ThemeData(
    useMaterial3: false, // Force Material 2
    brightness: Brightness.light,
    primarySwatch: Colors.pink,
    primaryColor: const Color(0xFFE91E63),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFF8BBD9),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Color(0xFFE91E63),
      onSurface: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    // ລຶບ cardTheme ອອກ ແລະໃຊ້ Card widget ໂດຍຕົງ
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  // Dark Theme - Legacy Material 2
  static final darkTheme = ThemeData(
    useMaterial3: false, // Force Material 2
    brightness: Brightness.dark,
    primarySwatch: Colors.pink,
    primaryColor: const Color(0xFFE91E63),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE91E63),
      secondary: Color(0xFF7C3F47),
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    // ລຶບ cardTheme ອອກ ແລະໃຊ້ Card widget ໂດຍຕົງ
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  // Initialize theme from storage
  Future<void> initTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  // Set theme
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_themeKey, _isDarkMode);
      } catch (e) {
        print('Error saving theme: $e');
      }
    }
  }
}






// // lib/providers/theme_provider.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   static const String _themeKey = 'theme_mode';
//   bool _isDarkMode = false;

//   bool get isDarkMode => _isDarkMode;

//   ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

//   static ThemeData get lightTheme => ThemeData(
//         primarySwatch: Colors.pink,
//         primaryColor: const Color(0xFFE91E63),
//         brightness: Brightness.light,
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFFE91E63),
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFE91E63),
//             foregroundColor: Colors.white,
//           ),
//         ),
//         fontFamily: 'Roboto',
//       );

//   static ThemeData get darkTheme => ThemeData(
//         primarySwatch: Colors.pink,
//         primaryColor: const Color(0xFFE91E63),
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: const Color(0xFF1E1E1E),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF2D2D2D),
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFE91E63),
//             foregroundColor: Colors.white,
//           ),
//         ),
//         fontFamily: 'Roboto',
//       );

//   Future<void> initTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkMode = prefs.getBool(_themeKey) ?? false;
//     notifyListeners();
//   }

//   Future<void> toggleTheme() async {
//     _isDarkMode = !_isDarkMode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_themeKey, _isDarkMode);
//     notifyListeners();
//   }
// }









