import 'package:flutter_test/flutter_test.dart';
import 'package:plafin/cubits/cycles_cubit.dart';
import 'package:plafin/data/cycle.dart';
import 'package:plafin/data/item.dart';
import 'package:plafin/widgets/timeline.dart';

void main() {
  Cycle c(String id, DateTime d, {List<Item> items = const []}) =>
      Cycle(id: id, date: d, items: items);

  group('currentCycle (nearest cycle that is not in the past)', () {
    final nov5 = c('nov5', DateTime(2026, 11, 5));
    final nov20 = c('nov20', DateTime(2026, 11, 20));
    CyclesState state(List<Cycle> cycles) =>
        CyclesState(status: CyclesStatus.ready, cycles: cycles);

    test('day after the 5th -> the 20th', () {
      final s = state([nov5, nov20]);
      expect(s.currentCycle(DateTime(2026, 11, 6))!.id, 'nov20');
    });

    test('today counts as not past', () {
      final s = state([nov5, nov20]);
      expect(s.currentCycle(DateTime(2026, 11, 5, 18, 30))!.id, 'nov5');
      expect(s.currentCycle(DateTime(2026, 11, 20))!.id, 'nov20');
    });

    test('picks the nearest future one regardless of list order', () {
      final s = state([
        c('dec', DateTime(2026, 12, 5)),
        nov20,
        c('jan', DateTime(2027, 1, 5)),
        nov5,
      ]);
      expect(s.currentCycle(DateTime(2026, 11, 6))!.id, 'nov20');
      expect(s.currentCycle(DateTime(2026, 11, 21))!.id, 'dec');
    });

    test('all in the past -> most recent one, flagged as past', () {
      final s = state([nov5, nov20]);
      final today = DateTime(2026, 11, 21);
      final cur = s.currentCycle(today)!;
      expect(cur.id, 'nov20');
      expect(CyclesState.isPast(cur, today), isTrue);
      expect(CyclesState.isPast(nov20, DateTime(2026, 11, 20)), isFalse);
    });

    test('null when empty', () {
      expect(const CyclesState().currentCycle(DateTime(2026, 11, 6)), isNull);
    });
  });

  group('buildTimeline', () {
    test('new-cycle card first, then one group per month/year', () {
      final sorted = [
        c('a', DateTime(2026, 11, 20)),
        c('b', DateTime(2026, 11, 5)),
        c('x', DateTime(2026, 10, 5)),
        c('y', DateTime(2025, 10, 5)), // mesmo mês, outro ano => novo grupo
      ];
      final entries = buildTimeline(sorted, sorted[1]);
      expect(entries.map((e) => e.runtimeType.toString()), [
        'NewCycleEntry',
        'GroupEntry',
        'CycleEntry',
        'CycleEntry',
        'GroupEntry',
        'CycleEntry',
        'GroupEntry',
        'CycleEntry',
      ]);
      expect(
        entries.whereType<GroupEntry>().map((g) => (g.date.year, g.date.month)),
        [(2026, 11), (2026, 10), (2025, 10)],
      );
      expect((entries[3] as CycleEntry).isCurrent, isTrue);
      expect((entries[2] as CycleEntry).isCurrent, isFalse);
    });

    test('only the new-cycle card when there are no cycles', () {
      expect(buildTimeline(const [], null), hasLength(1));
    });
  });

  test('node kinds', () {
    const done = Item(
      id: '1',
      name: 'a',
      amountCents: 1,
      isIncome: true,
      done: true,
    );
    const open = Item(id: '2', name: 'b', amountCents: 1, isIncome: false);
    final d = DateTime(2026, 1, 1);
    expect(
      nodeKindFor(c('1', d, items: [done]), isCurrent: false),
      NodeKind.done,
    );
    expect(
      nodeKindFor(c('2', d, items: [done, open]), isCurrent: false),
      NodeKind.open,
    );
    expect(nodeKindFor(c('3', d), isCurrent: false), NodeKind.open);
    expect(
      nodeKindFor(c('4', d, items: [done]), isCurrent: true),
      NodeKind.current,
    );
  });
}
