import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/features/onboarding/birth_date_input_formatter.dart';

void main() {
  const formatter = BirthDateInputFormatter();

  test('inserts date separators from digits and keeps cursor after typed part',
      () {
    final formatted = formatter.formatEditUpdate(
      const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0)),
      const TextEditingValue(
        text: '12051995',
        selection: TextSelection.collapsed(offset: 8),
      ),
    );
    expect(formatted.text, '12.05.1995');
    expect(formatted.selection.baseOffset, formatted.text.length);
  });

  test('limits input to eight digits and preserves a middle cursor', () {
    final formatted = formatter.formatEditUpdate(
      const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0)),
      const TextEditingValue(
        text: '12051995123',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    expect(formatted.text, '12.05.1995');
    expect(formatted.selection.baseOffset, 6);
  });
}
