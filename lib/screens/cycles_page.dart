import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app.dart';
import '../cubits/cycles_cubit.dart';
import '../core/format/format_context.dart';
import '../core/theme/app_theme.dart';
import '../data/cycle.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common.dart';
import '../widgets/cycle_form_sheet.dart';
import 'settings_page.dart';

class CyclesPage extends StatelessWidget {
  const CyclesPage({super.key});

  Future<void> _createCycle(BuildContext context) async {
    final id = await showCycleForm(context, mode: CycleFormMode.create);
    if (id != null && context.mounted) {
      Navigator.of(context).pushNamed(Routes.cycle, arguments: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<CyclesCubit>().state;
    final cycles = state.sortedCycles;
    final showFab = state.status == CyclesStatus.ready && cycles.isNotEmpty;

    return Scaffold(
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => _createCycle(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.newCycle),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(l10n.cyclesTitle),
            actions: [
              IconButton(
                tooltip: l10n.settings,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
                ),
              ),
              const SizedBox(width: 4),
            ],
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
            CyclesStatus.ready when cycles.isEmpty => SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.event_repeat_rounded,
                title: l10n.cyclesEmptyTitle,
                message: l10n.cyclesEmptyBody,
                action: FilledButton.icon(
                  onPressed: () => _createCycle(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.cycleCreateAction),
                ),
              ),
            ),
            CyclesStatus.ready => ContentSliver(
              bottom: 96,
              sliver: SliverList.separated(
                itemCount: cycles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _CycleCard(cycle: cycles[i]),
              ),
            ),
          },
        ],
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard({required this.cycle});

  final Cycle cycle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.plafin;
    final money = context.money;
    final balance = cycle.balanceCents;
    final dateText = context.formatDate(cycle.date);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Navigator.of(context).pushNamed(Routes.cycle, arguments: cycle.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cycle.name ?? dateText,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cycle.name != null
                              ? dateText
                              : l10n.itemsCount(cycle.items.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    money.format(balance),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: balance < 0 ? colors.expense : colors.income,
                    ),
                  ),
                ],
              ),
              if (cycle.items.isNotEmpty) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: cycle.progress),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.progressDone(cycle.doneCount, cycle.items.length),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
