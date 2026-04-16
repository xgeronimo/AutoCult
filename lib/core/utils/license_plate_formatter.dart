import 'package:flutter/services.dart';

class LicensePlateFormatter extends TextInputFormatter {
  static const _latinToCyrillic = {
    'A': 'А', 'B': 'В', 'E': 'Е', 'K': 'К', 'M': 'М', 'H': 'Н',
    'O': 'О', 'P': 'Р', 'C': 'С', 'T': 'Т', 'Y': 'У', 'X': 'Х',
  };

  static const _allowedLetters = 'АВЕКМНОРСТУХ';

  static const _maxLength = 9;

  /// Position map: L=letter, D=digit
  /// Format: LDDDDLLDD(D) — e.g. А123БВ77 or А123БВ777
  static const _pattern = 'LDDDLLDDD';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase();

    final buffer = StringBuffer();
    var cursorOffset = newValue.selection.baseOffset;

    for (var i = 0; i < raw.length && buffer.length < _maxLength; i++) {
      final char = _mapChar(raw[i]);
      final pos = buffer.length;
      final expected = pos < _pattern.length ? _pattern[pos] : null;

      if (expected == null) break;

      if (expected == 'L') {
        if (_allowedLetters.contains(char)) {
          buffer.write(char);
        } else {
          if (i < cursorOffset) cursorOffset--;
        }
      } else if (expected == 'D') {
        if (_isDigit(char)) {
          buffer.write(char);
        } else {
          if (i < cursorOffset) cursorOffset--;
        }
      }
    }

    final text = buffer.toString();
    cursorOffset = cursorOffset.clamp(0, text.length);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  String _mapChar(String char) {
    return _latinToCyrillic[char] ?? char;
  }

  bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
}
