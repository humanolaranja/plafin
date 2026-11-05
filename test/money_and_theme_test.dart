import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plafin/core/format/money.dart';
import 'package:plafin/core/theme/app_theme.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final l1 = _lum(a), l2 = _lum(b);
  final hi = math.max(l1, l2), lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt');
    await initializeDateFormatting('en');
  });

  group('MoneyFormatter', () {
    test('pt/BRL formats thousands and negatives correctly', () {
      final m = MoneyFormatter(currency: 'BRL', locale: 'pt');
      expect(m.format(0).replaceAll(' ', ' '), 'R\$ 0,00');
      expect(m.format(123456).replaceAll(' ', ' '), 'R\$ 1.234,56');
      expect(m.format(100000000).replaceAll(' ', ' '), 'R\$ 1.000.000,00');
      expect(m.format(-1000).replaceAll(' ', ' '), '-R\$ 10,00');
      expect(m.formatSigned(1000).replaceAll(' ', ' '), '+R\$ 10,00');
      expect(m.formatSigned(-1000).replaceAll(' ', ' '), '−R\$ 10,00');
    });

    test('en/USD', () {
      final m = MoneyFormatter(currency: 'USD', locale: 'en');
      expect(m.format(123456), '\$1,234.56');
    });
  });

  group('MoneyInputFormatter', () {
    final f = MoneyInputFormatter(
      MoneyFormatter(currency: 'BRL', locale: 'pt'),
    );
    String type(String digits) {
      var value = TextEditingValue.empty;
      for (final ch in digits.split('')) {
        value = f.formatEditUpdate(
          value,
          TextEditingValue(text: value.text + ch),
        );
      }
      return value.text.replaceAll(' ', ' ');
    }

    test('typing digits fills cents from the right', () {
      expect(type('1'), 'R\$ 0,01');
      expect(type('12'), 'R\$ 0,12');
      expect(type('123'), 'R\$ 1,23');
      expect(type('123456'), 'R\$ 1.234,56');
    });

    test('parseCents ignores symbols and separators', () {
      expect(MoneyInputFormatter.parseCents('R\$ 1.234,56'), 123456);
      expect(MoneyInputFormatter.parseCents(''), 0);
    });
  });

  group('theme contrast (WCAG AA)', () {
    for (final (name, scheme, colors) in [
      ('light', AppTheme.lightScheme, PlafinColors.light),
      ('dark', AppTheme.darkScheme, PlafinColors.dark),
    ]) {
      test('$name text pairs >= 4.5', () {
        final pairs = {
          'onSurface/surface': (scheme.onSurface, scheme.surface),
          'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
          'onPrimary/primary': (scheme.onPrimary, scheme.primary),
          'onPrimaryContainer/primaryContainer': (
            scheme.onPrimaryContainer,
            scheme.primaryContainer,
          ),
          'onSecondaryContainer/secondaryContainer': (
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
          ),
          'primary/surface': (scheme.primary, scheme.surface),
          'primary/card': (scheme.primary, scheme.surfaceContainerLow),
          'income/surface': (colors.income, scheme.surface),
          'income/card': (colors.income, scheme.surfaceContainerLow),
          'expense/surface': (colors.expense, scheme.surface),
          'expense/card': (colors.expense, scheme.surfaceContainerLow),
          'onError/error': (scheme.onError, scheme.error),
          'onInverseSurface/inverseSurface': (
            scheme.onInverseSurface,
            scheme.inverseSurface,
          ),
          'onSurfaceVariant/card': (
            scheme.onSurfaceVariant,
            scheme.surfaceContainerLow,
          ),
        };
        for (final e in pairs.entries) {
          expect(
            contrast(e.value.$1, e.value.$2),
            greaterThanOrEqualTo(4.5),
            reason: '$name ${e.key}',
          );
        }
      });

      test('$name non-text >= 3 (outline/border, checkbox, progress)', () {
        expect(
          contrast(scheme.outline, scheme.surface),
          greaterThanOrEqualTo(3),
        );
        expect(
          contrast(scheme.primary, scheme.surface),
          greaterThanOrEqualTo(3),
        );
      });
    }
  });
}
