import 'package:flutter/material.dart';

import '../core/format/format_context.dart';
import '../core/theme/app_theme.dart';
import '../data/cycle.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

/// Cabeçalho da home: gradiente da marca, logo, configurações e o ciclo atual.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.current,
    this.currentIsPast = false,
    required this.onSettings,
    required this.onOpenCurrent,
  });

  /// `null` quando ainda não há ciclos (mostra as boas-vindas).
  final Cycle? current;

  /// O ciclo mostrado já começou (todos estão no passado): rótulo "Último ciclo".
  final bool currentIsPast;
  final VoidCallback onSettings;
  final VoidCallback onOpenCurrent;

  static const _radius = 36.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.heroStart, AppTheme.heroEnd],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(_radius)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(_radius),
        ),
        child: Stack(
          children: [
            // Marca d'água: o anel-seta do logo, cortado no canto.
            Positioned(
              right: -90,
              top: 56,
              width: 300,
              height: 300,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.09,
                  child: Image.asset(
                    'assets/branding/icon_foreground.png',
                    excludeFromSemantics: true,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, top + 12, 0, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(onSettings: onSettings),
                        const SizedBox(height: 28),
                        if (current == null)
                          _Welcome(
                            title: l10n.homeWelcomeTitle,
                            body: l10n.homeWelcomeBody,
                            textTheme: textTheme,
                          )
                        else
                          _CurrentCycle(
                            cycle: current!,
                            isPast: currentIsPast,
                            onTap: onOpenCurrent,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const PlafinLogo(size: 40),
          const SizedBox(width: 12),
          Text(
            l10n.appName,
            style: textTheme.titleLarge?.copyWith(
              color: AppTheme.heroInk,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          Material(
            color: AppTheme.heroInk.withValues(alpha: 0.12),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: l10n.settings,
              onPressed: onSettings,
              iconSize: 24,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              color: AppTheme.heroInk,
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({
    required this.title,
    required this.body,
    required this.textTheme,
  });

  final String title;
  final String body;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(
            color: AppTheme.heroInk,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: textTheme.bodyLarge?.copyWith(color: AppTheme.heroInk),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CurrentCycle extends StatelessWidget {
  const _CurrentCycle({
    required this.cycle,
    required this.isPast,
    required this.onTap,
  });

  final Cycle cycle;
  final bool isPast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final money = context.money;
    const ink = AppTheme.heroInk;
    final dateText = context.formatDate(cycle.date);

    Widget stat(String label, int cents, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ink.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: ink),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(color: ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        money.format(cents),
                        style: textTheme.titleSmall?.copyWith(color: ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppTheme.heroStart,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPast ? l10n.homeLastCycle : l10n.homeCurrentCycle,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppTheme.heroStart,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_outward_rounded, color: ink),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              cycle.name ?? dateText,
              style: textTheme.titleLarge?.copyWith(color: ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (cycle.name != null)
              Text(dateText, style: textTheme.bodyMedium?.copyWith(color: ink)),
            const SizedBox(height: 6),
            _CountUpMoney(
              cents: cycle.balanceCents,
              style: textTheme.displaySmall?.copyWith(
                color: ink,
                fontSize: 44,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                stat(
                  l10n.summaryIncome,
                  cycle.incomeCents,
                  Icons.arrow_downward_rounded,
                ),
                const SizedBox(width: 12),
                stat(
                  l10n.summaryExpenses,
                  cycle.expenseCents,
                  Icons.arrow_upward_rounded,
                ),
              ],
            ),
            if (cycle.items.isNotEmpty) ...[
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: cycle.progress,
                  color: ink,
                  backgroundColor: ink.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.progressDone(cycle.doneCount, cycle.items.length),
                style: textTheme.labelMedium?.copyWith(color: ink),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Valor que "conta" até o saldo na primeira exibição e a cada mudança.
class _CountUpMoney extends StatelessWidget {
  const _CountUpMoney({required this.cents, required this.style});

  final int cents;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final money = context.money;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: cents.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(money.format(value.round()), style: style),
      ),
    );
  }
}
