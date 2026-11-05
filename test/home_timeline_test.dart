import 'package:flutter_test/flutter_test.dart';
import 'package:plafin/cubits/cycles_cubit.dart';
import 'package:plafin/data/cycle.dart';
import 'package:plafin/data/item.dart';
import 'package:plafin/widgets/timeline.dart';

void main() {
  Cycle c(String id, DateTime d, {List<Item> items = const []}) =>
      Cycle(id: id, date: d, items: items);

  group('currentCycle', () {
    final today = DateTime(2026, 11, 5);

    test('is the latest cycle that already started', () {
      final s = CyclesState(
        status: CyclesStatus.ready,
        cycles: [
          c('a', DateTime(2026, 9, 5)),
          c('b', DateTime(2026, 11, 5)),
          c('f', DateTime(2026, 12, 5)),
        ],
      );
      expect(s.currentCycle(today)!.id, 'b');
    });

    test('falls back to the nearest future cycle', () {
      final s = CyclesState(
        status: CyclesStatus.ready,
        cycles: [c('x', DateTime(2027, 2, 1)), c('y', DateTime(2027, 1, 1))],
      );
      expect(s.currentCycle(today)!.id, 'y');
    });

    test('null when empty', () {
      expect(const CyclesState().currentCycle(today), isNull);
    });
  });

  group('buildTimeline', () {
    test('starts with the new-cycle card and groups by year', () {
      final sorted = [
        c('a', DateTime(2026, 11, 20)),
        c('b', DateTime(2026, 11, 5)),
        c('d', DateTime(2025, 12, 5)),
      ];
      final entries = buildTimeline(sorted, sorted[1]);
      expect(entries.map((e) => e.runtimeType.toString()), [
        'NewCycleEntry',
        'YearEntry',
        'CycleEntry',
        'CycleEntry',
        'YearEntry',
        'CycleEntry',
      ]);
      expect((entries[1] as YearEntry).year, 2026);
      expect((entries[4] as YearEntry).year, 2025);
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
