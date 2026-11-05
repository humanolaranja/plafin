import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app.dart';
import '../cubits/cycles_cubit.dart';
import '../core/format/format_context.dart';
import '../core/format/money.dart';
import '../core/theme/app_theme.dart';
import '../data/cycle.dart';
import '../data/item.dart';
import '../data/item_sort.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common.dart';
import '../widgets/cycle_form_sheet.dart';
import '../widgets/item_form_sheet.dart';

enum _CycleAction { edit, copy, delete }

class CyclePage extends StatelessWidget {
  const CyclePage({super.key, required this.cycleId});

  final String cycleId;

  Future<void> _onAction(
    BuildContext context,
    Cycle cycle,
    _CycleAction action,
  ) async {
    switch (action) {
      case _CycleAction.edit:
        await showCycleForm(context, mode: CycleFormMode.edit, cycle: cycle);
      case _CycleAction.copy:
        final id = await showCycleForm(
          context,
          mode: CycleFormMode.copy,
          cycle: cycle,
        );
        if (id != null && context.mounted) {
          Navigator.of(
            context,
          ).pushReplacementNamed(Routes.cycle, arguments: id);
        }
      case _CycleAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(l10n.cycleDeleteTitle),
              content: Text(l10n.cycleDeleteBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.delete),
                ),
              ],
            );
          },
        );
        if (confirmed == true && context.mounted) {
          context.read<CyclesCubit>().deleteCycle(cycle.id);
          Navigator.of(context).pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cycle = context.select((CyclesCubit b) => b.state.cycleById(cycleId));

    // Ciclo removido: a rota já está sendo fechada.
    if (cycle == null) return const Scaffold();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showItemForm(context, cycleId: cycle.id),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addItem),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              cycle.name ?? context.formatDate(cycle.date),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (cycle.items.length > 1)
                PopupMenuButton<ItemSort>(
                  tooltip: l10n.sortItems,
                  icon: const Icon(Icons.sort_rounded),
                  onSelected: (sort) =>
                      context.read<CyclesCubit>().sortItems(cycle.id, sort),
                  itemBuilder: (context) => [
                    for (final (sort, label, icon) in [
                      (
                        ItemSort.incomeFirst,
                        l10n.sortIncomeFirst,
                        Icons.arrow_downward_rounded,
                      ),
                      (
                        ItemSort.expensesFirst,
                        l10n.sortExpensesFirst,
                        Icons.arrow_upward_rounded,
                      ),
                      (
                        ItemSort.amountDesc,
                        l10n.sortAmountDesc,
                        Icons.trending_down_rounded,
                      ),
                      (
                        ItemSort.amountAsc,
                        l10n.sortAmountAsc,
                        Icons.trending_up_rounded,
                      ),
                      (
                        ItemSort.pendingFirst,
                        l10n.sortPendingFirst,
                        Icons.radio_button_unchecked_rounded,
                      ),
                    ])
                      PopupMenuItem(
                        value: sort,
                        child: ListTile(
                          leading: Icon(icon),
                          title: Text(label),
                        ),
                      ),
                  ],
                ),
              PopupMenuButton<_CycleAction>(
                onSelected: (a) => _onAction(context, cycle, a),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _CycleAction.edit,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.edit),
                    ),
                  ),
                  PopupMenuItem(
                    value: _CycleAction.copy,
                    child: ListTile(
                      leading: const Icon(Icons.content_copy_rounded),
                      title: Text(l10n.copy),
                    ),
                  ),
                  PopupMenuItem(
                    value: _CycleAction.delete,
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(l10n.delete),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          ContentSliver(
            top: 8,
            sliver: SliverToBoxAdapter(child: _SummaryCard(cycle: cycle)),
          ),
          if (cycle.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: l10n.itemsEmptyTitle,
                message: l10n.itemsEmptyBody,
              ),
            )
          else
            ContentSliver(
              top: 16,
              bottom: 96,
              sliver: SliverReorderableList(
                itemCount: cycle.items.length,
                onReorder: (o, n) =>
                    context.read<CyclesCubit>().reorderItems(cycle.id, o, n),
                proxyDecorator: (child, index, animation) => AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Material(
                    type: MaterialType.transparency,
                    elevation: 0,
                    child: Transform.scale(
                      scale:
                          1 + 0.02 * Curves.easeOut.transform(animation.value),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    ),
                  ),
                  child: child,
                ),
                itemBuilder: (context, i) => _ItemTile(
                  key: ValueKey(cycle.items[i].id),
                  index: i,
                  cycleId: cycle.id,
                  item: cycle.items[i],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cycle});

  final Cycle cycle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final money = context.money;
    final onPrimary = scheme.onPrimary;

    Widget stat(String label, String value, String detail, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: onPrimary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: onPrimary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(color: onPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.summaryBalance,
            style: theme.textTheme.labelLarge?.copyWith(color: onPrimary),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              money.format(cycle.balanceCents),
              style: theme.textTheme.headlineLarge?.copyWith(color: onPrimary),
            ),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                stat(
                  l10n.summaryIncome,
                  money.format(cycle.incomeCents),
                  '${l10n.summaryReceived}: ${money.format(cycle.receivedCents)}',
                  Icons.arrow_downward_rounded,
                ),
                const SizedBox(width: 12),
                stat(
                  l10n.summaryExpenses,
                  money.format(cycle.expenseCents),
                  '${l10n.summaryPaid}: ${money.format(cycle.paidCents)}\n'
                  '${l10n.summaryPending}: ${money.format(cycle.pendingExpenseCents)}',
                  Icons.arrow_upward_rounded,
                ),
              ],
            ),
          ),
          if (cycle.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: cycle.progress,
                color: onPrimary,
                backgroundColor: onPrimary.withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.progressDone(cycle.doneCount, cycle.items.length),
              style: theme.textTheme.labelMedium?.copyWith(color: onPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.index,
    required this.cycleId,
    required this.item,
  });

  final int index;
  final String cycleId;
  final Item item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.plafin;
    final money = context.money;
    final color = item.isIncome ? colors.income : colors.expense;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _dismissible(context, l10n, theme, money, color),
    );
  }

  Widget _dismissible(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    MoneyFormatter money,
    Color color,
  ) {
    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          context.read<CyclesCubit>().deleteItem(cycleId, item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showItemForm(context, cycleId: cycleId, item: item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Checkbox(
                  value: item.done,
                  semanticLabel: l10n.markDone,
                  onChanged: (v) => context.read<CyclesCubit>().toggleItem(
                    cycleId,
                    item.id,
                    v ?? false,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: item.done ? TextDecoration.lineThrough : null,
                      color: item.done
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  money.formatSigned(item.signedCents),
                  style: theme.textTheme.titleSmall?.copyWith(color: color),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        semanticLabel: l10n.dragToReorder,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
