import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formata valores em centavos conforme a moeda e o idioma.
class MoneyFormatter {
  MoneyFormatter({required this.currency, required String locale})
    : _format = NumberFormat.simpleCurrency(locale: locale, name: currency);

  final String currency;
  final NumberFormat _format;

  int get decimalDigits => _format.decimalDigits ?? 2;

  String format(int cents) => _format.format(cents / 100);

  /// Com sinal explícito (`+`/`−`) para listar receitas e despesas.
  String formatSigned(int cents) {
    final abs = format(cents.abs());
    if (cents == 0) return abs;
    return cents > 0 ? '+$abs' : '−$abs';
  }

  /// Texto "cru" (sem símbolo) usado para preencher o campo de valor.
  String formatForInput(int cents) => _format.format(cents / 100);
}

/// Campo de valor monetário: o usuário digita apenas dígitos e o texto é
/// sempre exibido já formatado (ex.: `1`, `2`, `3` → `R$ 0,01`, `0,12`, `1,23`).
class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter(this.formatter);

  final MoneyFormatter formatter;

  /// Valor em centavos representado por [text] (só dígitos são considerados).
  static int parseCents(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    // Limita a 12 dígitos para não estourar.
    return int.parse(digits.length > 12 ? digits.substring(0, 12) : digits);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cents = parseCents(newValue.text);
    final text = formatter.format(cents);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
