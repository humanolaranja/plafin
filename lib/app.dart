import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cubits/cycles_cubit.dart';
import 'cubits/settings_cubit.dart';
import 'core/theme/app_theme.dart';
import 'data/cycles_repository.dart';
import 'l10n/app_localizations.dart';
import 'screens/cycle_page.dart';
import 'screens/cycles_page.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class Routes {
  static const home = '/';
  static const cycle = '/cycle';
}

class PlafinApp extends StatelessWidget {
  const PlafinApp({super.key, required this.prefs, this.repository});

  final SharedPreferences prefs;

  /// Permite injetar um repositório (testes).
  final CyclesRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(prefs)),
        BlocProvider(
          create: (_) =>
              CyclesCubit(repository ?? PrefsCyclesRepository(prefs))..load(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: Routes.home,
            onGenerateRoute: _onGenerateRoute,
            builder: (context, child) => _RemovalSnackBars(child: child!),
          );
        },
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CyclesPage(),
        );
      case Routes.cycle:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CyclePage(cycleId: id),
        );
    }
    return null;
  }
}

/// Mostra "excluído · Desfazer" para qualquer remoção, em qualquer tela.
class _RemovalSnackBars extends StatelessWidget {
  const _RemovalSnackBars({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CyclesCubit, CyclesState>(
      listenWhen: (prev, curr) =>
          curr.removal != null && curr.removal != prev.removal,
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        final message = switch (state.removal!) {
          CycleRemoval() => l10n.cycleDeleted,
          ItemRemoval() => l10n.itemDeleted,
          ItemsOrderChange() => l10n.itemsSorted,
        };
        scaffoldMessengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 6),
              showCloseIcon: true,
              action: SnackBarAction(
                label: l10n.undo,
                onPressed: () => context.read<CyclesCubit>().undoRemoval(),
              ),
            ),
          );
      },
      child: child,
    );
  }
}
