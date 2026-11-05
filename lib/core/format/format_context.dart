import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubits/settings_cubit.dart';
import 'money.dart';

final _moneyCache = <String, MoneyFormatter>{};

extension FormatContext on BuildContext {
  /// Formatador de moeda conforme a moeda escolhida e o idioma atual.
  ///
  /// Por padrão reconstrói o widget quando a moeda muda (use só dentro do
  /// `build`). Fora do `build` (ex.: `initState`/`didChangeDependencies`) use
  /// `moneyOf(listen: false)`.
  MoneyFormatter get money => moneyOf();

  MoneyFormatter moneyOf({bool listen = true}) {
    final currency = listen
        ? select((SettingsCubit c) => c.state.currency)
        : read<SettingsCubit>().state.currency;
    final locale = Localizations.localeOf(this).toString();
    return _moneyCache.putIfAbsent(
      '$locale|$currency',
      () => MoneyFormatter(currency: currency, locale: locale),
    );
  }

  /// Data longa no idioma atual (ex.: `5 de novembro de 2026`).
  String formatDate(DateTime date) =>
      DateFormat.yMMMMd(Localizations.localeOf(this).toString()).format(date);
}
