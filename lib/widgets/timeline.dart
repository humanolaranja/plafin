import 'dart:async';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/format/format_context.dart';
import '../core/theme/app_theme.dart';
import '../data/cycle.dart';
import '../l10n/app_localizations.dart';

/// Largura da trilha (linha + marcadores) à esquerda dos cards.
const double kRailWidth = 40;

/// Altura, a partir do topo da linha, onde fica o marcador de cada item.
const double _nodeY = 30;

enum NodeKind { add, group, current, done, open }

/// Uma linha da linha do tempo: trilha à esquerda + conteúdo à direita.
class TimelineRow extends StatelessWidget {
  const TimelineRow({
    super.key,
    required this.child,
    required this.kind,
    this.isFirst = false,
    this.isLast = false,
    this.bottomGap = 12,
  });

  final Widget child;
  final NodeKind kind;
  final bool isFirst;
  final bool isLast;
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: kRailWidth,
          child: CustomPaint(
            painter: _RailPainter(
              color: scheme.outlineVariant,
              fromY: isFirst ? _nodeY : 0,
              toY: isLast ? _nodeY : null,
              hideLine: kind == NodeKind.group && isLast,
            ),
          ),
        ),
        if (kind != NodeKind.group)
          Positioned(
            left: 0,
            top: _nodeY - 14,
            width: kRailWidth,
            height: 28,
            child: Center(child: _Node(kind: kind)),
          ),
        Padding(
          padding: EdgeInsets.only(left: kRailWidth, bottom: bottomGap),
          child: child,
        ),
      ],
    );
  }
}

class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.color,
    required this.fromY,
    required this.toY,
    required this.hideLine,
  });

  final Color color;
  final double fromY;
  final double? toY;
  final bool hideLine;

  @override
  void paint(Canvas canvas, Size size) {
    if (hideLine) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    canvas.drawLine(Offset(x, fromY), Offset(x, toY ?? size.height), paint);
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.color != color || old.fromY != fromY || old.toY != toY;
}

class _Node extends StatelessWidget {
  const _Node({required this.kind});

  final NodeKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (kind) {
      case NodeKind.add:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.primary, width: 2),
          ),
          child: Icon(Icons.add_rounded, size: 16, color: scheme.primary),
        );
      case NodeKind.current:
        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary.withValues(alpha: 0.22),
          ),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary,
              border: Border.all(color: scheme.surface, width: 3),
            ),
          ),
        );
      case NodeKind.done:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: context.plafin.income,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.surface, width: 3),
          ),
          child: Icon(Icons.check_rounded, size: 12, color: scheme.surface),
        );
      case NodeKind.open:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: scheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outline, width: 2.5),
          ),
        );
      case NodeKind.group:
        return const SizedBox.shrink();
    }
  }
}

/// Etiquetas do grupo: o ano (só quando muda) e o mês por extenso.
class GroupLabel extends StatelessWidget {
  const GroupLabel({super.key, required this.date, required this.showYear});

  final DateTime date;
  final bool showYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final month = toBeginningOfSentenceCase(
      DateFormat.MMMM(locale).format(date),
    );

    Widget pill(String text, {required bool strong}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: strong ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: strong ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: strong ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (showYear) pill('${date.year}', strong: false),
            pill(month, strong: true),
          ],
        ),
      ),
    );
  }
}

/// Card tracejado "+ Novo ciclo".
class NewCycleCard extends StatelessWidget {
  const NewCycleCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: scheme.primary.withValues(alpha: 0.7),
        radius: 16,
      ),
      child: Material(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.newCycle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.newCycleHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.75),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(rrect);
    for (final PathMetric m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 7), paint);
        d += 7 + 5;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Card de um ciclo (mesmas informações de antes).
class CycleCard extends StatelessWidget {
  const CycleCard({
    super.key,
    required this.cycle,
    required this.onTap,
    this.highlight = false,
  });

  final Cycle cycle;
  final VoidCallback onTap;
  final bool highlight;

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlight
              ? theme.colorScheme.primary.withValues(alpha: 0.7)
              : theme.colorScheme.outlineVariant,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
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

/// Entrada suave (fade + subida) com atraso escalonado.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 60 * widget.index.clamp(0, 8));
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Itens da linha do tempo da home.
sealed class TimelineEntry {
  const TimelineEntry();
}

class NewCycleEntry extends TimelineEntry {
  const NewCycleEntry();
}

/// Cabeçalho de um grupo (mês); mostra também o ano quando ele muda.
class GroupEntry extends TimelineEntry {
  const GroupEntry(this.date, {required this.showYear});
  final DateTime date;
  final bool showYear;
}

class CycleEntry extends TimelineEntry {
  const CycleEntry(this.cycle, {required this.isCurrent});
  final Cycle cycle;
  final bool isCurrent;
}

/// Monta a lista: "+ Novo ciclo", depois os ciclos agrupados por mês (com o
/// ano indicado quando muda).
List<TimelineEntry> buildTimeline(List<Cycle> sorted, Cycle? current) {
  final entries = <TimelineEntry>[const NewCycleEntry()];
  int? year;
  int? month;
  for (final c in sorted) {
    final newYear = c.date.year != year;
    if (newYear || c.date.month != month) {
      entries.add(GroupEntry(c.date, showYear: newYear));
      year = c.date.year;
      month = c.date.month;
    }
    entries.add(CycleEntry(c, isCurrent: c.id == current?.id));
  }
  return entries;
}

NodeKind nodeKindFor(Cycle c, {required bool isCurrent}) {
  if (isCurrent) return NodeKind.current;
  if (c.items.isNotEmpty && c.doneCount == c.items.length) return NodeKind.done;
  return NodeKind.open;
}
