// // lib/screens/welcome_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../providers/theme_provider.dart';
// import '../services/simple_storage_service.dart';
// import 'auth/login_screen.dart';
// import 'home_screen.dart';

// class WelcomeScreen extends StatefulWidget {
//   final ThemeProvider themeProvider;
//   final Function(Locale) onLanguageChanged;
//   final Locale currentLocale;

//   const WelcomeScreen({
//     super.key,
//     required this.themeProvider,
//     required this.onLanguageChanged,
//     required this.currentLocale,
//   });

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   bool _isChecking = true;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _checkAuthStatus();
//   }

//   void _setupAnimations() {
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeIn,
//     ));

//     _scaleAnimation = Tween<double>(
//       begin: 0.5,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     ));

//     _controller.forward();
//   }

//   Future<void> _checkAuthStatus() async {
//     await Future.delayed(const Duration(seconds: 3));

//     if (mounted) {
//       final isLoggedIn = await SimpleStorageService.isLoggedIn();

//       setState(() {
//         _isChecking = false;
//       });

//       if (isLoggedIn) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) =>
//                 HomeScreen(themeProvider: widget.themeProvider),
//           ),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: widget.themeProvider.isDarkMode
//                 ? [
//                     const Color(0xFF2D2D2D),
//                     const Color(0xFF1E1E1E),
//                   ]
//                 : [
//                     const Color(0xFFFCE4EC),
//                     const Color(0xFFE8F5E8),
//                   ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Settings buttons
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Language selector
//                     PopupMenuButton<Locale>(
//                       icon: Icon(
//                         Icons.language,
//                         color: widget.themeProvider.isDarkMode
//                             ? Colors.white
//                             : const Color(0xFFE91E63),
//                       ),
//                       onSelected: widget.onLanguageChanged,
//                       itemBuilder: (context) => [
//                         const PopupMenuItem(
//                           value: Locale('en', 'US'),
//                           child: Text('English'),
//                         ),
//                         const PopupMenuItem(
//                           value: Locale('lo', 'LA'),
//                           child: Text('ລາວ'),
//                         ),
//                         const PopupMenuItem(
//                           value: Locale('th', 'TH'),
//                           child: Text('ไทย'),
//                         ),
//                       ],
//                     ),
//                     // Theme toggle
//                     IconButton(
//                       onPressed: () {
//                         HapticFeedback.lightImpact();
//                         widget.themeProvider.toggleTheme();
//                       },
//                       icon: Icon(
//                         widget.themeProvider.isDarkMode
//                             ? Icons.light_mode
//                             : Icons.dark_mode,
//                         color: widget.themeProvider.isDarkMode
//                             ? Colors.white
//                             : const Color(0xFFE91E63),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Main content
//               Expanded(
//                 child: Center(
//                   child: AnimatedBuilder(
//                     animation: _controller,
//                     builder: (context, child) {
//                       return FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: ScaleTransition(
//                           scale: _scaleAnimation,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 width: 120,
//                                 height: 120,
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFE91E63),
//                                   borderRadius: BorderRadius.circular(30),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: const Color(0xFFE91E63)
//                                           .withOpacity(0.3),
//                                       blurRadius: 20,
//                                       offset: const Offset(0, 10),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.favorite,
//                                   color: Colors.white,
//                                   size: 60,
//                                 ),
//                               ),
//                               const SizedBox(height: 30),
//                               Text(
//                                 'PCOS Care',
//                                 style: TextStyle(
//                                   fontSize: 36,
//                                   fontWeight: FontWeight.bold,
//                                   color: widget.themeProvider.isDarkMode
//                                       ? Colors.white
//                                       : const Color(0xFFE91E63),
//                                   letterSpacing: 1.2,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 _getWelcomeText(),
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: widget.themeProvider.isDarkMode
//                                       ? Colors.white70
//                                       : Colors.black54,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(height: 50),
//                               if (_isChecking)
//                                 const CircularProgressIndicator(
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Color(0xFFE91E63),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _getWelcomeText() {
//     switch (widget.currentLocale.languageCode) {
//       case 'en':
//         return 'Take care of your health with love';
//       case 'th':
//         return 'ดูแลสุขภาพของคุณด้วยความรัก';
//       case 'lo':
//       default:
//         return 'ດູແລສຸຂະພາບຂອງທ່ານດ້ວຍຄວາມຮັກ';
//     }
//   }
// }




// lib/screens/welcome_screen.dart - Fixed
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
        // ✅ Fixed: Remove themeProvider parameter since HomeScreen doesn't accept it
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
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
