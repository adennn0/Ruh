import 'package:flutter/services.dart';

/// Formats digit input as dd.MM.yyyy while keeping the cursor next to the
/// digits the user just edited.
class BirthDateInputFormatter extends TextInputFormatter {
  const BirthDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = rawDigits.length > 8 ? rawDigits.substring(0, 8) : rawDigits;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('.');
      buffer.write(digits[i]);
    }
    final inputCursor = newValue.selection.isValid
        ? newValue.selection.baseOffset.clamp(0, newValue.text.length)
        : newValue.text.length;
    final digitsBeforeCursor = newValue.text
        .substring(0, inputCursor)
        .replaceAll(RegExp(r'\D'), '')
        .length
        .clamp(0, digits.length);
    final cursorOffset = digitsBeforeCursor < 2
        ? digitsBeforeCursor
        : digitsBeforeCursor == 2
            ? 3
            : digitsBeforeCursor < 4
                ? digitsBeforeCursor + 1
                : digitsBeforeCursor + 2;
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection:
          TextSelection.collapsed(offset: cursorOffset.clamp(0, text.length)),
    );
  }
}
