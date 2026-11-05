import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Moedas disponíveis nas configurações.
const supportedCurrencies = ['BRL', 'USD', 'EUR', 'GBP'];

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.currency = 'BRL',
  });

  final ThemeMode themeMode;

  /// `null` = seguir o idioma do sistema.
  final Locale? locale;
  final String currency;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    String? currency,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, currency];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs) : super(_read(_prefs));

  static const _themeKey = 'plafin.settings.theme';
  static const _localeKey = 'plafin.settings.locale';
  static const _currencyKey = 'plafin.settings.currency';

  final SharedPreferences _prefs;

  static SettingsState _read(SharedPreferences p) {
    final theme = ThemeMode.values.asNameMap()[p.getString(_themeKey)];
    final lang = p.getString(_localeKey);
    final currency = p.getString(_currencyKey);
    return SettingsState(
      themeMode: theme ?? ThemeMode.system,
      locale: lang == null ? null : Locale(lang),
      currency: supportedCurrencies.contains(currency) ? currency! : 'BRL',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    emit(state.copyWith(locale: locale, clearLocale: locale == null));
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }

  Future<void> setCurrency(String code) async {
    if (!supportedCurrencies.contains(code)) return;
    emit(state.copyWith(currency: code));
    await _prefs.setString(_currencyKey, code);
  }
}
