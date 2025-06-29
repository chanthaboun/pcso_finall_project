import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/theme_provider.dart';
import 'screens/welcome_screen.dart';
import 'generated/l10n.dart';
import 'services/enhanced_notification_service.dart'; // ເພີ່ມ import ໃໝ່

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ຕັ້ງຄ່າ system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // ຕັ້ງຄ່າ keyboard ໃຫ້ຮອງຮັບພາສາຫຼາກຫຼາຍ
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize notification service only
  try {
    await EnhancedNotificationService.initialize();
    print('Enhanced notification service initialized successfully');
  } catch (e) {
    print('Error initializing notification service: $e');
  }

  runApp(const PCOSCareApp());
}

class PCOSCareApp extends StatefulWidget {
  const PCOSCareApp({super.key});

  @override
  State<PCOSCareApp> createState() => _PCOSCareAppState();
}

class _PCOSCareAppState extends State<PCOSCareApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  Locale _locale = const Locale('lo', 'LA'); // Default to Lao

  @override
  void initState() {
    super.initState();
    _themeProvider.initTheme();
    _themeProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    // Cleanup notification service
    EnhancedNotificationService.dispose();
    super.dispose();
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCOS Care',
      debugShowCheckedModeBanner: false,

      // Localization support
      locale: _locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('lo', 'LA'), // Lao
        Locale('th', 'TH'), // Thai
      ],

      theme: _themeProvider.currentTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: _themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: WelcomeScreen(
        themeProvider: _themeProvider,
        onLanguageChanged: _changeLanguage,
        currentLocale: _locale,
      ),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // ປ້ອງກັນການ scale ຜິດປົກກະຕິ
          ),
          child: Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              // ເພີ່ມ shortcuts ສຳລັບ keyboard ຫຼາກຫຼາຍພາສາ
              LogicalKeySet(
                      LogicalKeyboardKey.control, LogicalKeyboardKey.space):
                  const ActivateIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (ActivateIntent intent) {
                    // Switch input method
                    return null;
                  },
                ),
              },
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
