import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class KeyboardHelper {
  // ຕັ້ງຄ່າ keyboard ໃຫ້ຮອງຮັບພາສາລາວ
  static void setupLaoKeyboard() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // ປິດ keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // ເປີດ keyboard
  static void showKeyboard(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  // ກວດສອບວ່າ keyboard ເປີດຢູ່ຫຼືບໍ່
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
}

// Custom Input Decoration ສຳລັບພາສາລາວ
class LaoInputDecoration {
  static InputDecoration getDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    bool filled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: fillColor ?? Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE91E63),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 16,
      ),
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    );
  }
}

// Validator functions ສຳລັບພາສາລາວ
class LaoValidators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນ${fieldName ?? 'ຂໍ້ມູນ'}';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນອີເມວ';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'ອີເມວບໍ່ຖືກຕ້ອງ';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
    }

    if (value.length < 6) {
      return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງນ້ອຍ 6 ຕົວອັກສອນ';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານ';
    }

    if (value != password) {
      return 'ລະຫັດຜ່ານບໍ່ຕົງກັນ';
    }

    return null;
  }

  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນຕົວເລກ';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'ກະລຸນາປ້ອນຕົວເລກທີ່ຖືກຕ້ອງ';
    }

    if (min != null && number < min) {
      return 'ຕົວເລກຕ້ອງເກີນ $min';
    }

    if (max != null && number > max) {
      return 'ຕົວເລກຕ້ອງນ້ອຍກວ່າ $max';
    }

    return null;
  }

  static String? validateAge(String? value) {
    return validateNumber(value, min: 10, max: 100);
  }

  static String? validateWeight(String? value) {
    return validateNumber(value, min: 30, max: 200);
  }

  static String? validateHeight(String? value) {
    return validateNumber(value, min: 100, max: 250);
  }
}

// Text Style ສຳລັບພາສາລາວ
class LaoTextStyles {
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: Colors.black87,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    height: 1.5,
    color: Colors.black87,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: Colors.black54,
  );

  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle error = TextStyle(
    fontSize: 12,
    color: Colors.red,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static const TextStyle label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}

// ຟັງຊັນຊ່ວຍເຫຼືອສຳລັບການຈັດການຂໍ້ຄວາມ
class LaoTextHelper {
  // ແປງຂໍ້ຄວາມໃຫ້ເໝາະສົມ
  static String formatLaoText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ກວດສອບວ່າມີອັກສອນພິເສດຫຼືບໍ່
  static bool hasSpecialCharacters(String text) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(text);
  }

  // ລຶບອັກສອນພິເສດອອກ
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), '');
  }

  // ຕົວພິມໃຫຍ່ອັກສອນທຳອິດ
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // ຈຳກັດຄວາມຍາວຂອງຂໍ້ຄວາມ
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
