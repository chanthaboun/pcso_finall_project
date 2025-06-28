// lib/generated/l10n.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', 'US'),
    Locale('lo', 'LA'),
    Locale('th', 'TH')
  ];

  // ເພີ່ມ static method load ທີ່ຂາດຢູ່
  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = intl.Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      intl.Intl.defaultLocale = localeName;
      final instance = lookupS(locale);
      S._current = instance;
      return instance;
    });
  }

  /// The title of the application
  String get appTitle;

  /// Welcome message
  String get welcome;

  /// Get started button text
  String get getStarted;

  /// Login button text
  String get login;

  /// Register button text
  String get register;

  /// Email field label
  String get email;

  /// Password field label
  String get password;

  /// Username field label
  String get username;

  /// Confirm password field label
  String get confirmPassword;

  /// Email field hint
  String get enterEmail;

  /// Password field hint
  String get enterPassword;

  /// Username field hint
  String get enterUsername;

  /// Confirm password field hint
  String get enterConfirmPassword;

  /// App tagline
  String get tagline;

  /// App subtitle
  String get subtitle;

  /// Motivational text
  String get motivation;

  /// Debug button text
  String get debug;

  /// Nutrition screen title
  String get nutrition;

  /// Email validation message
  String get pleaseEnterEmail;

  /// Password validation message
  String get pleaseEnterPassword;

  /// Username validation message
  String get pleaseEnterUsername;

  /// Confirm password validation message
  String get pleaseConfirmPassword;

  /// Invalid email validation message
  String get invalidEmail;

  /// Password length validation message
  String get passwordTooShort;

  /// Password mismatch validation message
  String get passwordsDoNotMatch;

  /// Username length validation message
  String get usernameTooShort;
}

Future<bool> initializeMessages(String localeName) async {
  // This is a mock implementation
  return true;
}

S lookupS(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'lo':
      return SLo();
    case 'th':
      return STh();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

/// The localization delegate for S.
class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'lo'),
      Locale.fromSubtags(languageCode: 'th'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PCOS Care';

  @override
  String get welcome => 'Welcome';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get enterUsername => 'Enter your name';

  @override
  String get enterConfirmPassword => 'Enter confirm password';

  @override
  String get tagline => '"Good health starts with us" 🌸';

  @override
  String get subtitle => 'PCOS Care is ready to be your companion';

  @override
  String get motivation => '💪 Let\'s start being a healthy woman every day!';

  @override
  String get debug => 'Debug';

  @override
  String get nutrition => '🍽️ Nutrition';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get usernameTooShort => 'Username must be at least 2 characters';
}

/// The translations for Lao (`lo`).
class SLo extends S {
  SLo([String locale = 'lo']) : super(locale);

  @override
  String get appTitle => 'PCOS Care';

  @override
  String get welcome => 'ຍິນດີຕ້ອນຮັບ';

  @override
  String get getStarted => 'ເລີ່ມຕົ້ນ';

  @override
  String get login => 'ເຂົ້າສູ່ລະບົບ';

  @override
  String get register => 'ລົງທະບຽນ';

  @override
  String get email => 'ອີເມວ';

  @override
  String get password => 'ລະຫັດຜ່ານ';

  @override
  String get username => 'ຊື່ຜູ້ໃຊ້';

  @override
  String get confirmPassword => 'ຢືນຢັນລະຫັດຜ່ານ';

  @override
  String get enterEmail => 'ປ້ອນອີເມວຂອງເຈົ້າ';

  @override
  String get enterPassword => 'ປ້ອນລະຫັດຜ່ານ';

  @override
  String get enterUsername => 'ປ້ອນຊື່ຂອງເຈົ້າ';

  @override
  String get enterConfirmPassword => 'ປ້ອນຢືນຢັນລະຫັດຜ່ານ';

  @override
  String get tagline => '"ສຸຂະພາບດີ ເລີ່ມຕົ້ນຈາກເຮົາ" 🌸';

  @override
  String get subtitle => 'PCOS Care ພ້ອມເປັນເພື່ອນຮ່ວມທາງ';

  @override
  String get motivation => '💪 ມາເລີ່ມຕົ້ນເປັນແມ່ສາວໃນທຸກວັນກັນເຮອ!';

  @override
  String get debug => 'ແກ້ບັນຫາ';

  @override
  String get nutrition => '🍽️ ການກິນ';

  @override
  String get pleaseEnterEmail => 'ກະລຸນາປ້ອນອີເມວ';

  @override
  String get pleaseEnterPassword => 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';

  @override
  String get pleaseEnterUsername => 'ກະລຸນາປ້ອນຊື່ຜູ້ໃຊ້';

  @override
  String get pleaseConfirmPassword => 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານ';

  @override
  String get invalidEmail => 'ອີເມວບໍ່ຖືກຕ້ອງ';

  @override
  String get passwordTooShort => 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງນ້ອຍ 6 ຕົວອັກສອນ';

  @override
  String get passwordsDoNotMatch => 'ລະຫັດຜ່ານບໍ່ຕົງກັນ';

  @override
  String get usernameTooShort => 'ຊື່ຜູ້ໃຊ້ຕ້ອງມີຢ່າງນ້ອຍ 2 ຕົວອັກສອນ';
}

/// The translations for Thai (`th`).
class STh extends S {
  STh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'PCOS Care';

  @override
  String get welcome => 'ยินดีต้อนรับ';

  @override
  String get getStarted => 'เริ่มต้น';

  @override
  String get login => 'เข้าสู่ระบบ';

  @override
  String get register => 'สมัครสมาชิก';

  @override
  String get email => 'อีเมล';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get username => 'ชื่อผู้ใช้';

  @override
  String get confirmPassword => 'ยืนยันรหัสผ่าน';

  @override
  String get enterEmail => 'ใส่อีเมลของคุณ';

  @override
  String get enterPassword => 'ใส่รหัสผ่าน';

  @override
  String get enterUsername => 'ใส่ชื่อของคุณ';

  @override
  String get enterConfirmPassword => 'ใส่ยืนยันรหัสผ่าน';

  @override
  String get tagline => '"สุขภาพดีเริ่มต้นจากเรา" 🌸';

  @override
  String get subtitle => 'PCOS Care พร้อมเป็นเพื่อนร่วมทาง';

  @override
  String get motivation => '💪 มาเริ่มต้นเป็นผู้หญิงสุขภาพดีในทุกวันกันเถอะ!';

  @override
  String get debug => 'แก้ปัญหา';

  @override
  String get nutrition => '🍽️ โภชนาการ';

  @override
  String get pleaseEnterEmail => 'กรุณาใส่อีเมล';

  @override
  String get pleaseEnterPassword => 'กรุณาใส่รหัสผ่าน';

  @override
  String get pleaseEnterUsername => 'กรุณาใส่ชื่อผู้ใช้';

  @override
  String get pleaseConfirmPassword => 'กรุณายืนยันรหัสผ่าน';

  @override
  String get invalidEmail => 'รูปแบบอีเมลไม่ถูกต้อง';

  @override
  String get passwordTooShort => 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';

  @override
  String get passwordsDoNotMatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get usernameTooShort => 'ชื่อผู้ใช้ต้องมีอย่างน้อย 2 ตัวอักษร';
}
