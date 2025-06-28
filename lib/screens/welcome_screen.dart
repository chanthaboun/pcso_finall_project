// import 'package:flutter/material.dart';
// import 'auth/login_screen.dart';
// import 'debug_screen.dart';
// import '../widgets/lao_text_field.dart';
// import '../services/keyboard_helper.dart';
// import '../providers/theme_provider.dart';

// // LanguageSwitcher widget
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
//       icon: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE91E63).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: const Color(0xFFE91E63),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               currentLanguage,
//               style: const TextStyle(
//                 color: Color(0xFFE91E63),
//                 fontWeight: FontWeight.w500,
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(width: 4),
//             const Icon(
//               Icons.keyboard_arrow_down,
//               color: Color(0xFFE91E63),
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//       onSelected: onLanguageChanged,
//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: 'ລາວ',
//           child: Text('🇱🇦 ລາວ'),
//         ),
//         const PopupMenuItem(
//           value: 'EN',
//           child: Text('🇺🇸 English'),
//         ),
//         const PopupMenuItem(
//           value: 'ไทย',
//           child: Text('🇹🇭 ไทย'),
//         ),
//       ],
//     );
//   }
// }

// class WelcomeScreen extends StatefulWidget {
//   final ThemeProvider? themeProvider;
//   final Function(Locale)? onLanguageChanged;
//   final Locale? currentLocale;

//   const WelcomeScreen({
//     super.key,
//     this.themeProvider,
//     this.onLanguageChanged,
//     this.currentLocale,
//   });

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   String _currentLanguage = 'ລາວ';

//   @override
//   void initState() {
//     super.initState();
//     KeyboardHelper.setupLaoKeyboard();

//     // ກຳນົດພາສາເລີ່ມຕົ້ນ
//     if (widget.currentLocale?.languageCode == 'en') {
//       _currentLanguage = 'EN';
//     } else if (widget.currentLocale?.languageCode == 'th') {
//       _currentLanguage = 'ไทย';
//     } else {
//       _currentLanguage = 'ລາວ';
//     }
//   }

//   void _changeLanguage(String language) {
//     setState(() {
//       _currentLanguage = language;
//     });

//     Locale newLocale;
//     switch (language) {
//       case 'EN':
//         newLocale = const Locale('en', 'US');
//         break;
//       case 'ไทย':
//         newLocale = const Locale('th', 'TH');
//         break;
//       default:
//         newLocale = const Locale('lo', 'LA');
//     }

//     widget.onLanguageChanged?.call(newLocale);
//   }

//   String _getText(String laoText, String englishText, String thaiText) {
//     switch (_currentLanguage) {
//       case 'EN':
//         return englishText;
//       case 'ไทย':
//         return thaiText;
//       default:
//         return laoText;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = widget.themeProvider?.isDarkMode ?? false;

//     return Scaffold(
//       backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Top bar with theme toggle and language switcher
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Theme toggle
//                   IconButton(
//                     onPressed: () {
//                       widget.themeProvider?.toggleTheme();
//                     },
//                     icon: Icon(
//                       isDarkMode ? Icons.light_mode : Icons.dark_mode,
//                       color: const Color(0xFFE91E63),
//                     ),
//                   ),

//                   // Language switcher
//                   LanguageSwitcher(
//                     currentLanguage: _currentLanguage,
//                     onLanguageChanged: _changeLanguage,
//                   ),
//                 ],
//               ),

//               const Spacer(),

//               // Logo
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE91E63),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFFE91E63).withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.favorite,
//                   color: Colors.white,
//                   size: 60,
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // App Name
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     const TextSpan(
//                       text: 'PCOS ',
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFFE91E63),
//                       ),
//                     ),
//                     TextSpan(
//                       text: 'care.',
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.normal,
//                         color: isDarkMode ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Tagline
//               Text(
//                 _getText(
//                   '"ສຸຂະພາບດີ ເລີ່ມຕົ້ນຈາກເຮົາ" 🌸',
//                   '"Good health starts with us" 🌸',
//                   '"สุขภาพดีเริ่มต้นจากเรา" 🌸',
//                 ),
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: isDarkMode ? Colors.grey[300] : Colors.grey,
//                   fontStyle: FontStyle.italic,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _getText(
//                   'PCOS Care ພ້ອມເປັນເພື່ອນຮ່ວມທາງ',
//                   'PCOS Care is ready to be your companion',
//                   'PCOS Care พร้อมเป็นเพื่อนร่วมทาง',
//                 ),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isDarkMode ? Colors.grey[400] : Colors.grey,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 _getText(
//                   '💪 ມາເລີ່ມຕົ້ນເປັນແມ່ສາວໃນທຸກວັນກັນເຮອ!',
//                   '💪 Let\'s start being a healthy woman every day!',
//                   '💪 มาเริ่มต้นเป็นผู้หญิงสุขภาพดีในทุกวันกันเถอะ!',
//                 ),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isDarkMode ? Colors.grey[400] : Colors.grey,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const Spacer(),

//               // Get Started Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pushReplacement(
//                       MaterialPageRoute(
//                         builder: (context) => const LoginScreen(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFE91E63),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     _getText(
//                       'ເລີ່ມຕົ້ນ',
//                       'Get Started',
//                       'เริ่มต้น',
//                     ),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Debug Button (ສຳລັບແກ້ບັນຫາ)
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const DebugScreen(),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   _getText('ແກ້ບັນຫາ', 'Debug', 'แก้ปัญหา'),
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.grey[500] : Colors.grey,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/theme_provider.dart';
import '../services/simple_storage_service.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final Function(Locale) onLanguageChanged;
  final Locale currentLocale;

  const WelcomeScreen({
    super.key,
    required this.themeProvider,
    required this.onLanguageChanged,
    required this.currentLocale,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final isLoggedIn = await SimpleStorageService.isLoggedIn();

      setState(() {
        _isChecking = false;
      });

      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(themeProvider: widget.themeProvider),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.themeProvider.isDarkMode
                ? [
                    const Color(0xFF2D2D2D),
                    const Color(0xFF1E1E1E),
                  ]
                : [
                    const Color(0xFFFCE4EC),
                    const Color(0xFFE8F5E8),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Settings buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Language selector
                    PopupMenuButton<Locale>(
                      icon: Icon(
                        Icons.language,
                        color: widget.themeProvider.isDarkMode
                            ? Colors.white
                            : const Color(0xFFE91E63),
                      ),
                      onSelected: widget.onLanguageChanged,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: Locale('en', 'US'),
                          child: Text('English'),
                        ),
                        const PopupMenuItem(
                          value: Locale('lo', 'LA'),
                          child: Text('ລາວ'),
                        ),
                        const PopupMenuItem(
                          value: Locale('th', 'TH'),
                          child: Text('ไทย'),
                        ),
                      ],
                    ),
                    // Theme toggle
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.themeProvider.toggleTheme();
                      },
                      icon: Icon(
                        widget.themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: widget.themeProvider.isDarkMode
                            ? Colors.white
                            : const Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE91E63)
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'PCOS Care',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: widget.themeProvider.isDarkMode
                                      ? Colors.white
                                      : const Color(0xFFE91E63),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getWelcomeText(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 50),
                              if (_isChecking)
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFE91E63),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWelcomeText() {
    switch (widget.currentLocale.languageCode) {
      case 'en':
        return 'Take care of your health with love';
      case 'th':
        return 'ดูแลสุขภาพของคุณด้วยความรัก';
      case 'lo':
      default:
        return 'ດູແລສຸຂະພາບຂອງທ່ານດ້ວຍຄວາມຮັກ';
    }
  }
}
