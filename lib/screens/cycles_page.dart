import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app.dart';
import '../cubits/cycles_cubit.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common.dart';
import '../widgets/cycle_form_sheet.dart';
import '../widgets/home_hero.dart';
import '../widgets/timeline.dart';
import 'settings_page.dart';

class CyclesPage extends StatefulWidget {
  const CyclesPage({super.key});

  @override
  State<CyclesPage> createState() => _CyclesPageState();
}

class _CyclesPageState extends State<CyclesPage> {
  /// Enquanto o hero laranja está sob a barra de status, os ícones ficam
  /// escuros; depois que ele sai da tela, seguem o tema.
  bool _heroUnderStatusBar = true;

  final _heroKey = GlobalKey();

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    final heroHeight = _heroKey.currentContext?.size?.height ?? 300;
    final statusBar = MediaQuery.paddingOf(context).top;
    final under = n.metrics.pixels < heroHeight - statusBar;
    if (under != _heroUnderStatusBar) {
      setState(() => _heroUnderStatusBar = under);
    }
    return false;
  }

  Future<void> _createCycle() async {
    final id = await showCycleForm(context, mode: CycleFormMode.create);
    if (id != null && mounted) {
      Navigator.of(context).pushNamed(Routes.cycle, arguments: id);
    }
  }

  void _openCycle(String id) =>
      Navigator.of(context).pushNamed(Routes.cycle, arguments: id);

  void _openSettings() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = context.watch<CyclesCubit>().state;
    final sorted = state.sortedCycles;
    final today = DateTime.now();
    final current = state.currentCycle(today);
    final ready = state.status == CyclesStatus.ready;
    final List<TimelineEntry> entries = ready
        ? buildTimeline(sorted, current)
        : const [];

    final darkIcons =
        _heroUnderStatusBar || theme.brightness == Brightness.light;
    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
      statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeHero(
                  key: _heroKey,
                  current: ready ? current : null,
                  currentIsPast:
                      ready &&
                      current != null &&
                      CyclesState.isPast(current, today),
                  onSettings: _openSettings,
                  onOpenCurrent: () => _openCycle(current!.id),
                ),
              ),
              switch (state.status) {
                CyclesStatus.loading => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                CyclesStatus.failure => SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.loadError,
                    message: '',
                    action: FilledButton(
                      onPressed: () => context.read<CyclesCubit>().load(),
                      child: Text(l10n.retry),
                    ),
                  ),
                ),
                CyclesStatus.ready => _Timeline(
                  entries: entries,
                  total: sorted.length,
                  onCreate: _createCycle,
                  onOpen: _openCycle,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.entries,
    required this.total,
    required this.onCreate,
    required this.onOpen,
  });

  final List<TimelineEntry> entries;
  final int total;
  final VoidCallback onCreate;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bottom = 32 + MediaQuery.paddingOf(context).bottom;

    return ContentSliver(
      top: 28,
      bottom: bottom,
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.timelineTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Text(
                  l10n.cyclesCount(total),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < entries.length; i++)
            Reveal(
              index: i,
              child: _row(context, entries[i], isLast: i == entries.length - 1),
            ),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, TimelineEntry e, {required bool isLast}) {
    return switch (e) {
      NewCycleEntry() => TimelineRow(
        kind: NodeKind.add,
        isFirst: true,
        isLast: isLast,
        child: NewCycleCard(onTap: onCreate),
      ),
      GroupEntry(:final date) => TimelineRow(
        kind: NodeKind.group,
        isLast: isLast,
        bottomGap: 8,
        child: GroupLabel(date: date),
      ),
      CycleEntry(:final cycle, :final isCurrent) => TimelineRow(
        kind: nodeKindFor(cycle, isCurrent: isCurrent),
        isLast: isLast,
        child: CycleCard(
          cycle: cycle,
          highlight: isCurrent,
          onTap: () => onOpen(cycle.id),
        ),
      ),
    };
  }
}
