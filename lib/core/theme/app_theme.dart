import 'package:flutter/material.dart';

/// Cores semânticas do Plafin (receita / despesa), por tema.
@immutable
class PlafinColors extends ThemeExtension<PlafinColors> {
  const PlafinColors({
    required this.income,
    required this.expense,
    required this.incomeContainer,
    required this.expenseContainer,
  });

  final Color income;
  final Color expense;
  final Color incomeContainer;
  final Color expenseContainer;

  static const light = PlafinColors(
    income: Color(0xFF15803D),
    expense: Color(0xFFB93C0A),
    incomeContainer: Color(0xFFDCFCE7),
    expenseContainer: Color(0xFFFFE4D6),
  );

  static const dark = PlafinColors(
    income: Color(0xFF4ADE80),
    expense: Color(0xFFFF9466),
    incomeContainer: Color(0xFF12301E),
    expenseContainer: Color(0xFF3D1E10),
  );

  @override
  PlafinColors copyWith({
    Color? income,
    Color? expense,
    Color? incomeContainer,
    Color? expenseContainer,
  }) {
    return PlafinColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      incomeContainer: incomeContainer ?? this.incomeContainer,
      expenseContainer: expenseContainer ?? this.expenseContainer,
    );
  }

  @override
  PlafinColors lerp(ThemeExtension<PlafinColors>? other, double t) {
    if (other is! PlafinColors) return this;
    return PlafinColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      expenseContainer: Color.lerp(
        expenseContainer,
        other.expenseContainer,
        t,
      )!,
    );
  }
}

extension PlafinThemeX on BuildContext {
  PlafinColors get plafin => Theme.of(this).extension<PlafinColors>()!;
}

/// Identidade visual do Plafin: laranja vibrante sobre superfícies quentes.
abstract final class AppTheme {
  /// Laranja da marca (logo, splash). Na UI usamos tons ajustados para
  /// garantir contraste mínimo WCAG AA.
  static const brandOrange = Color(0xFFFF5A1F);

  /// Gradiente do cabeçalho da home (mais claro que o do ícone para garantir
  /// contraste >= 4.5:1 com [heroInk]) e a tinta escura usada sobre ele.
  static const heroStart = Color(0xFFFF8E54);
  static const heroEnd = Color(0xFFF46426);
  static const heroInk = Color(0xFF1C130E);

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFC2410C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFDCCB),
    onPrimaryContainer: Color(0xFF3B1100),
    secondary: Color(0xFF7A4A36),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFE9DF),
    onSecondaryContainer: Color(0xFF2E170C),
    tertiary: Color(0xFF15803D),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFBF8),
    onSurface: Color(0xFF211A16),
    onSurfaceVariant: Color(0xFF5B4B43),
    outline: Color(0xFF8C7A70),
    outlineVariant: Color(0xFFE4D5CC),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFF4EE),
    surfaceContainer: Color(0xFFFCEDE5),
    surfaceContainerHigh: Color(0xFFF7E6DC),
    surfaceContainerHighest: Color(0xFFF1DFD4),
    inverseSurface: Color(0xFF372F2B),
    onInverseSurface: Color(0xFFFDEEE6),
    inversePrimary: Color(0xFFFF9466),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFF9466),
    onPrimary: Color(0xFF3B1100),
    primaryContainer: Color(0xFF8A2D08),
    onPrimaryContainer: Color(0xFFFFDCCB),
    secondary: Color(0xFFE6BEAB),
    onSecondary: Color(0xFF3F2518),
    secondaryContainer: Color(0xFF59392A),
    onSecondaryContainer: Color(0xFFFFE9DF),
    tertiary: Color(0xFF4ADE80),
    onTertiary: Color(0xFF00391A),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF17120F),
    onSurface: Color(0xFFEFE0D8),
    onSurfaceVariant: Color(0xFFD3C3BA),
    outline: Color(0xFF9C8C83),
    outlineVariant: Color(0xFF4F423B),
    surfaceContainerLowest: Color(0xFF110D0A),
    surfaceContainerLow: Color(0xFF1F1915),
    surfaceContainer: Color(0xFF241D19),
    surfaceContainerHigh: Color(0xFF2F2722),
    surfaceContainerHighest: Color(0xFF3A312C),
    inverseSurface: Color(0xFFEFE0D8),
    onInverseSurface: Color(0xFF372F2B),
    inversePrimary: Color(0xFFC2410C),
  );

  static ThemeData light() => _build(lightScheme, PlafinColors.light);
  static ThemeData dark() => _build(darkScheme, PlafinColors.dark);

  static const _fontFamily = 'PlusJakartaSans';

  static TextTheme _textTheme(TextTheme base) {
    TextStyle? s(TextStyle? style, double weight) => style?.copyWith(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
      fontVariations: [FontVariation('wght', weight)],
    );
    return base.copyWith(
      displayLarge: s(base.displayLarge, 700),
      displayMedium: s(base.displayMedium, 700),
      displaySmall: s(base.displaySmall, 700),
      headlineLarge: s(base.headlineLarge, 700),
      headlineMedium: s(base.headlineMedium, 700),
      headlineSmall: s(base.headlineSmall, 700),
      titleLarge: s(base.titleLarge, 700),
      titleMedium: s(base.titleMedium, 600),
      titleSmall: s(base.titleSmall, 600),
      bodyLarge: s(base.bodyLarge, 500),
      bodyMedium: s(base.bodyMedium, 500),
      bodySmall: s(base.bodySmall, 500),
      labelLarge: s(base.labelLarge, 700),
      labelMedium: s(base.labelMedium, 600),
      labelSmall: s(base.labelSmall, 600),
    );
  }

  static ThemeData _build(ColorScheme scheme, PlafinColors colors) {
    final base = ThemeData(brightness: scheme.brightness, useMaterial3: true);
    final text = _textTheme(
      base.textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final radius = BorderRadius.circular(16);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      extensions: [colors],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: scheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : null,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        linearMinHeight: 8,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
