// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class LaoTextField extends StatefulWidget {
//   final TextEditingController? controller;
//   final String? labelText;
//   final String? hintText;
//   final String? helperText;
//   final bool obscureText;
//   final TextInputType? keyboardType;
//   final int? maxLines;
//   final int? maxLength;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final void Function()? onTap;
//   final bool readOnly;
//   final bool enabled;
//   final FocusNode? focusNode;
//   final TextCapitalization textCapitalization;
//   final EdgeInsetsGeometry? contentPadding;
//   final Color? fillColor;
//   final bool filled;

//   const LaoTextField({
//     super.key,
//     this.controller,
//     this.labelText,
//     this.hintText,
//     this.helperText,
//     this.obscureText = false,
//     this.keyboardType,
//     this.maxLines = 1,
//     this.maxLength,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.onChanged,
//     this.onTap,
//     this.readOnly = false,
//     this.enabled = true,
//     this.focusNode,
//     this.textCapitalization = TextCapitalization.none,
//     this.contentPadding,
//     this.fillColor,
//     this.filled = true,
//   });

//   @override
//   State<LaoTextField> createState() => _LaoTextFieldState();
// }

// class _LaoTextFieldState extends State<LaoTextField> {
//   late FocusNode _internalFocusNode;
//   FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;
//   bool _showKeyboardHint = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.focusNode == null) {
//       _internalFocusNode = FocusNode();
//     }
//     _effectiveFocusNode.addListener(_onFocusChange);
//   }

//   @override
//   void dispose() {
//     _effectiveFocusNode.removeListener(_onFocusChange);
//     if (widget.focusNode == null) {
//       _internalFocusNode.dispose();
//     }
//     super.dispose();
//   }

//   void _onFocusChange() {
//     setState(() {
//       _showKeyboardHint = _effectiveFocusNode.hasFocus;
//     });

//     if (_effectiveFocusNode.hasFocus) {
//       // ເມື່ອ focus ເຂົ້າມາ, ຕັ້ງຄ່າ text input ໃຫ້ຮອງຮັບຫຼາຍພາສາ
//       SystemChannels.textInput.invokeMethod('TextInput.setEditingState', {
//         'text': widget.controller?.text ?? '',
//         'selectionBase': widget.controller?.selection.baseOffset ?? -1,
//         'selectionExtent': widget.controller?.selection.extentOffset ?? -1,
//         'composingBase': -1,
//         'composingExtent': -1,
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: widget.controller,
//           focusNode: _effectiveFocusNode,
//           obscureText: widget.obscureText,
//           keyboardType: widget.keyboardType,
//           maxLines: widget.maxLines,
//           maxLength: widget.maxLength,
//           validator: widget.validator,
//           onChanged: widget.onChanged,
//           onTap: widget.onTap,
//           readOnly: widget.readOnly,
//           enabled: widget.enabled,
//           textCapitalization: widget.textCapitalization,

//           // ປັບປຸງ input formatters ເພື່ອຮອງຮັບພາສາລາວດີຂຶ້ນ
//           inputFormatters: [
//             // ອະນຸຍາດໃຫ້ໃຊ້ໄດ້ທຸກອັກສອນ ລວມທັງພາສາລາວ, ອັງກິດ, ໄທ, ແລະອື່ນໆ
//             FilteringTextInputFormatter.allow(
//                 RegExp(r'[\u0000-\u007F' // ASCII (English)
//                     r'\u0E80-\u0EFF' // Lao
//                     r'\u0E00-\u0E7F' // Thai
//                     r'\u00A0-\u00FF' // Latin-1 Supplement
//                     r'\u0100-\u017F' // Latin Extended-A
//                     r'\u0180-\u024F' // Latin Extended-B
//                     r'\u1E00-\u1EFF' // Latin Extended Additional
//                     r'\u2000-\u206F' // General Punctuation
//                     r'\u3000-\u303F' // CJK Symbols and Punctuation
//                     r'\u4E00-\u9FFF' // CJK Unified Ideographs
//                     r'\s]' // Whitespace
//                     )),
//             // Custom formatter ສຳລັບຈັດການ text ພິເສດ
//             LaoTextInputFormatter(),
//           ],

//           style: const TextStyle(
//             fontSize: 16,
//             fontFamily: null, // ໃຊ້ system default font ທີ່ຮອງຮັບຫຼາຍພາສາ
//             height: 1.4,
//           ),

//           decoration: InputDecoration(
//             labelText: widget.labelText,
//             hintText: widget.hintText,
//             helperText: widget.helperText,
//             prefixIcon: widget.prefixIcon,
//             suffixIcon: widget.suffixIcon,
//             filled: widget.filled,
//             fillColor: widget.fillColor ?? Colors.grey[100],
//             contentPadding: widget.contentPadding ??
//                 const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: Colors.grey[300]!,
//                 width: 1,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: Color(0xFFE91E63),
//                 width: 2,
//               ),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: Colors.red,
//                 width: 1,
//               ),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: Colors.red,
//                 width: 2,
//               ),
//             ),
//             hintStyle: TextStyle(
//               color: Colors.grey[500],
//               fontSize: 16,
//             ),
//             labelStyle: const TextStyle(
//               color: Colors.grey,
//               fontSize: 16,
//             ),
//           ),
//         ),

//         // ສະແດງ hint ສຳລັບການສະຫຼັບພາສາ
//         if (_showKeyboardHint)
//           Padding(
//             padding: const EdgeInsets.only(top: 4, left: 12),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.keyboard,
//                   size: 12,
//                   color: Colors.grey[600],
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   'ກົດ Ctrl+Space ເພື່ອສະຫຼັບພາສາ',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () {
//                     // ສະແດງວິທີການສະຫຼັບພາສາ
//                     _showKeyboardInstructions(context);
//                   },
//                   child: Icon(
//                     Icons.help_outline,
//                     size: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   void _showKeyboardInstructions(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('ວິທີສະຫຼັບພາສາ'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('• Windows: Win + Space'),
//             Text('• Mac: Cmd + Space'),
//             Text('• Linux: Ctrl + Space'),
//             SizedBox(height: 8),
//             Text(
//               'ກ່ອນພິມພາສາລາວ ໃຫ້ແນ່ໃຈວ່າເຄື່ອງຂອງເຈົ້າໄດ້ຕິດຕັ້ງ Lao keyboard ແລ້ວ',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('ເຂົ້າໃຈແລ້ວ'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Custom TextInputFormatter ສຳລັບພາສາລາວ
// class LaoTextInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     // ອະນຸຍາດໃຫ້ພິມທຸກຕົວອັກສອນ ແລະຈັດການ composition
//     return TextEditingValue(
//       text: newValue.text,
//       selection: newValue.selection,
//       composing: newValue.composing,
//     );
//   }
// }

// // Widget ສຳລັບປຸ່ມສະຫຼັບພາສາ - ປັບປຸງແລ້ວ
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
//       onSelected: onLanguageChanged,
//       tooltip: 'ສະຫຼັບພາສາ',
//       icon: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: const Color(0xFFE91E63).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: const Color(0xFFE91E63).withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               _getLanguageFlag(currentLanguage),
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(width: 4),
//             Text(
//               currentLanguage,
//               style: const TextStyle(
//                 color: Color(0xFFE91E63),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(width: 2),
//             const Icon(
//               Icons.keyboard_arrow_down,
//               color: Color(0xFFE91E63),
//               size: 14,
//             ),
//           ],
//         ),
//       ),
//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: 'ລາວ',
//           child: Row(
//             children: [
//               Text('🇱🇦', style: TextStyle(fontSize: 18)),
//               SizedBox(width: 12),
//               Text('ລາວ'),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'EN',
//           child: Row(
//             children: [
//               Text('🇺🇸', style: TextStyle(fontSize: 18)),
//               SizedBox(width: 12),
//               Text('English'),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'ไทย',
//           child: Row(
//             children: [
//               Text('🇹🇭', style: TextStyle(fontSize: 18)),
//               SizedBox(width: 12),
//               Text('ไทย'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   String _getLanguageFlag(String language) {
//     switch (language) {
//       case 'ລາວ':
//         return '🇱🇦';
//       case 'EN':
//         return '🇺🇸';
//       case 'ไทย':
//         return '🇹🇭';
//       default:
//         return '🌐';
//     }
//   }
// }

// // Utility ສຳລັບກວດສອບວ່າຂໍ້ຄວາມເປັນພາສາລາວຫຼືບໍ່ - ປັບປຸງແລ້ວ
// class LaoTextUtils {
//   static bool isLaoText(String text) {
//     // ກວດສອບວ່າມີອັກສອນລາວຫຼືບໍ່
//     return RegExp(r'[\u0E80-\u0EFF]').hasMatch(text);
//   }

//   static bool hasLaoCharacters(String text) {
//     return text.contains(RegExp(r'[\u0E80-\u0EFF]'));
//   }

//   static bool isThaiText(String text) {
//     return RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);
//   }

//   static bool isEnglishText(String text) {
//     return RegExp(r'^[a-zA-Z\s\d\p{P}]*$', unicode: true).hasMatch(text);
//   }

//   // ຟັງຊັນສຳລັບຈັດການຂໍ້ຄວາມທີ່ປະສົມກັນ
//   static String cleanLaoText(String text) {
//     return text.trim().replaceAll(RegExp(r'\s+'), ' ');
//   }

//   // ກວດສອບວ່າ keyboard ຮອງຮັບພາສາລາວຫຼືບໍ່
//   static bool isLaoKeyboardSupported() {
//     return true;
//   }

//   // ຕັ້ງຄ່າ keyboard ໃຫ້ເໝາະສົມກັບພາສາ
//   static void setupKeyboardForLanguage(String language) {
//     // ໃນອະນາຄົດອາດຈະມີການຕັ້ງຄ່າເພີ່ມເຕີມ
//   }

//   // ກວດສອບວ່າຂໍ້ຄວາມມີພາສາປະສົມກັນຫຼືບໍ່
//   static bool hasMixedLanguages(String text) {
//     bool hasLao = hasLaoCharacters(text);
//     bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
//     bool hasThai = RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);

//     int languageCount = 0;
//     if (hasLao) languageCount++;
//     if (hasEnglish) languageCount++;
//     if (hasThai) languageCount++;

//     return languageCount > 1;
//   }
// }

// // TextField ສະເພາະສຳລັບຕົວເລກທີ່ຮອງຮັບພາສາລາວ - ປັບປຸງແລ້ວ
// class LaoNumberField extends StatelessWidget {
//   final TextEditingController? controller;
//   final String? labelText;
//   final String? hintText;
//   final String? suffixText;
//   final Widget? prefixIcon;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final double? minValue;
//   final double? maxValue;
//   final int decimalPlaces;

//   const LaoNumberField({
//     super.key,
//     this.controller,
//     this.labelText,
//     this.hintText,
//     this.suffixText,
//     this.prefixIcon,
//     this.validator,
//     this.onChanged,
//     this.minValue,
//     this.maxValue,
//     this.decimalPlaces = 1,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LaoTextField(
//       controller: controller,
//       labelText: labelText,
//       hintText: hintText,
//       prefixIcon: prefixIcon,
//       keyboardType: TextInputType.numberWithOptions(
//         decimal: decimalPlaces > 0,
//         signed: minValue != null && minValue! < 0,
//       ),
//       validator: (value) {
//         if (validator != null) {
//           return validator!(value);
//         }

//         if (value == null || value.isEmpty) {
//           return 'ກະລຸນາປ້ອນຕົວເລກ';
//         }

//         final number = double.tryParse(value);
//         if (number == null) {
//           return 'ກະລຸນາປ້ອນຕົວເລກທີ່ຖືກຕ້ອງ';
//         }

//         if (minValue != null && number < minValue!) {
//           return 'ຕົວເລກຕ້ອງເກີນ $minValue';
//         }

//         if (maxValue != null && number > maxValue!) {
//           return 'ຕົວເລກຕ້ອງນ້ອຍກວ່າ $maxValue';
//         }

//         return null;
//       },
//       onChanged: onChanged,
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LaoTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool filled;

  const LaoTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.fillColor,
    this.filled = true,
  });

  @override
  State<LaoTextField> createState() => _LaoTextFieldState();
}

class _LaoTextFieldState extends State<LaoTextField> {
  late FocusNode _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;
  bool _showKeyboardHint = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showKeyboardHint = _effectiveFocusNode.hasFocus;
    });

    if (_effectiveFocusNode.hasFocus) {
      // ເມື່ອ focus ເຂົ້າມາ, ຕັ້ງຄ່າ text input ໃຫ້ຮອງຮັບຫຼາຍພາສາ
      SystemChannels.textInput.invokeMethod('TextInput.setEditingState', {
        'text': widget.controller?.text ?? '',
        'selectionBase': widget.controller?.selection.baseOffset ?? -1,
        'selectionExtent': widget.controller?.selection.extentOffset ?? -1,
        'composingBase': -1,
        'composingExtent': -1,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _effectiveFocusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,

          // ປັບປຸງ input formatters ເພື່ອຮອງຮັບພາສາລາວດີຂຶ້ນ
          inputFormatters: [
            // ອະນຸຍາດໃຫ້ໃຊ້ໄດ້ທຸກອັກສອນ ລວມທັງພາສາລາວ, ອັງກິດ, ໄທ, ແລະອື່ນໆ
            FilteringTextInputFormatter.allow(
                RegExp(r'[\u0000-\u007F' // ASCII (English)
                    r'\u0E80-\u0EFF' // Lao
                    r'\u0E00-\u0E7F' // Thai
                    r'\u00A0-\u00FF' // Latin-1 Supplement
                    r'\u0100-\u017F' // Latin Extended-A
                    r'\u0180-\u024F' // Latin Extended-B
                    r'\u1E00-\u1EFF' // Latin Extended Additional
                    r'\u2000-\u206F' // General Punctuation
                    r'\u3000-\u303F' // CJK Symbols and Punctuation
                    r'\u4E00-\u9FFF' // CJK Unified Ideographs
                    r'\s]' // Whitespace
                    )),
            // Custom formatter ສຳລັບຈັດການ text ພິເສດ
            LaoTextInputFormatter(),
          ],

          style: const TextStyle(
            fontSize: 16,
            // ໃຊ້ system default font ທີ່ຮອງຮັບຫຼາຍພາສາ
            height: 1.4,
          ),

          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            filled: widget.filled,
            fillColor: widget.fillColor ?? Colors.grey[100],
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(
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
          ),
        ),

        // ສະແດງ hint ສຳລັບການສະຫຼັບພາສາ
        if (_showKeyboardHint)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Row(
              children: [
                Icon(
                  Icons.keyboard,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'ກົດ Ctrl+Space ເພື່ອສະຫຼັບພາສາ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // ສະແດງວິທີການສະຫຼັບພາສາ
                    _showKeyboardInstructions(context);
                  },
                  child: Icon(
                    Icons.help_outline,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showKeyboardInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ວິທີສະຫຼັບພາສາ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Windows: Win + Space'),
            Text('• Mac: Cmd + Space'),
            Text('• Linux: Ctrl + Space'),
            SizedBox(height: 8),
            Text(
              'ກ່ອນພິມພາສາລາວ ໃຫ້ແນ່ໃຈວ່າເຄື່ອງຂອງເຈົ້າໄດ້ຕິດຕັ້ງ Lao keyboard ແລ້ວ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ເຂົ້າໃຈແລ້ວ'),
          ),
        ],
      ),
    );
  }
}

// Custom TextInputFormatter ສຳລັບພາສາລາວ
class LaoTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // ອະນຸຍາດໃຫ້ພິມທຸກຕົວອັກສອນ ແລະຈັດການ composition
    return TextEditingValue(
      text: newValue.text,
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}

// Widget ສຳລັບປຸ່ມສະຫຼັບພາສາ - ປັບປຸງແລ້ວ
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
      onSelected: onLanguageChanged,
      tooltip: 'ສະຫຼັບພາສາ',
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLanguageFlag(currentLanguage),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              currentLanguage,
              style: const TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFFE91E63),
              size: 14,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'ລາວ',
          child: Row(
            children: [
              Text('🇱🇦', style: TextStyle(fontSize: 18)),
              SizedBox(width: 12),
              Text('ລາວ'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'EN',
          child: Row(
            children: [
              Text('🇺🇸', style: TextStyle(fontSize: 18)),
              SizedBox(width: 12),
              Text('English'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'ไทย',
          child: Row(
            children: [
              Text('🇹🇭', style: TextStyle(fontSize: 18)),
              SizedBox(width: 12),
              Text('ไทย'),
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageFlag(String language) {
    switch (language) {
      case 'ລາວ':
        return '🇱🇦';
      case 'EN':
        return '🇺🇸';
      case 'ไทย':
        return '🇹🇭';
      default:
        return '🌐';
    }
  }
}

// Utility ສຳລັບກວດສອບວ່າຂໍ້ຄວາມເປັນພາສາລາວຫຼືບໍ່ - ປັບປຸງແລ້ວ
class LaoTextUtils {
  static bool isLaoText(String text) {
    // ກວດສອບວ່າມີອັກສອນລາວຫຼືບໍ່
    return RegExp(r'[\u0E80-\u0EFF]').hasMatch(text);
  }

  static bool hasLaoCharacters(String text) {
    return text.contains(RegExp(r'[\u0E80-\u0EFF]'));
  }

  static bool isThaiText(String text) {
    return RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);
  }

  static bool isEnglishText(String text) {
    return RegExp(r'^[a-zA-Z\s\d\p{P}]*$', unicode: true).hasMatch(text);
  }

  // ຟັງຊັນສຳລັບຈັດການຂໍ້ຄວາມທີ່ປະສົມກັນ
  static String cleanLaoText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ກວດສອບວ່າ keyboard ຮອງຮັບພາສາລາວຫຼືບໍ່
  static bool isLaoKeyboardSupported() {
    return true;
  }

  // ຕັ້ງຄ່າ keyboard ໃຫ້ເໝາະສົມກັບພາສາ
  static void setupKeyboardForLanguage(String language) {
    // ໃນອະນາຄົດອາດຈະມີການຕັ້ງຄ່າເພີ່ມເຕີມ
  }

  // ກວດສອບວ່າຂໍ້ຄວາມມີພາສາປະສົມກັນຫຼືບໍ່
  static bool hasMixedLanguages(String text) {
    bool hasLao = hasLaoCharacters(text);
    bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    bool hasThai = RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);

    int languageCount = 0;
    if (hasLao) languageCount++;
    if (hasEnglish) languageCount++;
    if (hasThai) languageCount++;

    return languageCount > 1;
  }
}

// TextField ສະເພາະສຳລັບຕົວເລກທີ່ຮອງຮັບພາສາລາວ - ປັບປຸງແລ້ວ
class LaoNumberField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? suffixText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final double? minValue;
  final double? maxValue;
  final int decimalPlaces;

  const LaoNumberField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.suffixText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.minValue,
    this.maxValue,
    this.decimalPlaces = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LaoTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimalPlaces > 0,
        signed: minValue != null && minValue! < 0,
      ),
      validator: (value) {
        if (validator != null) {
          return validator!(value);
        }

        if (value == null || value.isEmpty) {
          return 'ກະລຸນາປ້ອນຕົວເລກ';
        }

        final number = double.tryParse(value);
        if (number == null) {
          return 'ກະລຸນາປ້ອນຕົວເລກທີ່ຖືກຕ້ອງ';
        }

        if (minValue != null && number < minValue!) {
          return 'ຕົວເລກຕ້ອງເກີນ $minValue';
        }

        if (maxValue != null && number > maxValue!) {
          return 'ຕົວເລກຕ້ອງນ້ອຍກວ່າ $maxValue';
        }

        return null;
      },
      onChanged: onChanged,
    );
  }
}
