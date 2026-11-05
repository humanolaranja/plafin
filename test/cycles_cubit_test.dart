import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plafin/cubits/cycles_cubit.dart';
import 'package:plafin/data/cycle.dart';
import 'package:plafin/data/cycles_repository.dart';
import 'package:plafin/data/item.dart';

class _MockRepo extends Mock implements CyclesRepository {}

void main() {
  late _MockRepo repo;
  const salary = Item(
    id: 'i1',
    name: 'Salário',
    amountCents: 500000,
    isIncome: true,
  );
  const rent = Item(
    id: 'i2',
    name: 'Aluguel',
    amountCents: 150000,
    isIncome: false,
    done: true,
  );
  final base = Cycle(
    id: 'c1',
    date: DateTime(2026, 11, 5),
    items: const [salary, rent],
  );
  CyclesState ready([List<Cycle>? cycles]) =>
      CyclesState(status: CyclesStatus.ready, cycles: cycles ?? [base]);

  setUpAll(() => registerFallbackValue(<Cycle>[]));

  setUp(() {
    repo = _MockRepo();
    when(() => repo.load()).thenAnswer((_) async => [base]);
    when(() => repo.save(any())).thenAnswer((_) async {});
  });

  CyclesCubit build() => CyclesCubit(repo);

  blocTest<CyclesCubit, CyclesState>(
    'loads cycles',
    build: build,
    act: (c) => c.load(),
    expect: () => [const CyclesState(status: CyclesStatus.loading), ready()],
  );

  blocTest<CyclesCubit, CyclesState>(
    'load failure -> failure status (no endless spinner)',
    setUp: () => when(() => repo.load()).thenThrow(const FormatException('x')),
    build: build,
    act: (c) => c.load(),
    errors: () => [isA<FormatException>()],
    expect: () => [
      const CyclesState(status: CyclesStatus.loading),
      const CyclesState(status: CyclesStatus.failure),
    ],
  );

  blocTest<CyclesCubit, CyclesState>(
    'creates cycle with initial balance item and persists',
    build: build,
    seed: () => const CyclesState(status: CyclesStatus.ready),
    act: (c) => c.createCycle(
      id: 'n1',
      date: DateTime(2026, 12, 1),
      name: '  Dez ',
      initialBalanceCents: 12345,
      initialBalanceLabel: 'Saldo inicial',
    ),
    verify: (c) {
      final cycle = c.state.cycles.single;
      expect(cycle.name, 'Dez');
      expect(cycle.balanceCents, 12345);
      expect(cycle.items.single.isIncome, isTrue);
      verify(() => repo.save(any())).called(1);
    },
  );

  blocTest<CyclesCubit, CyclesState>(
    'no initial item when balance is zero',
    build: build,
    act: (c) => c.createCycle(id: 'n1', date: DateTime(2026, 12, 1)),
    verify: (c) => expect(c.state.cycles.single.items, isEmpty),
  );

  blocTest<CyclesCubit, CyclesState>(
    'copy resets done and assigns fresh ids',
    build: build,
    seed: ready,
    act: (c) =>
        c.copyCycle(sourceId: 'c1', newId: 'c2', date: DateTime(2026, 12, 5)),
    verify: (c) {
      final copy = c.state.cycleById('c2')!;
      expect(copy.items.every((i) => !i.done), isTrue);
      expect(copy.balanceCents, base.balanceCents);
      expect(copy.items.map((i) => i.id), isNot(contains('i1')));
      expect(
        c.state.cycleById('c1')!.items[1].done,
        isTrue,
      ); // original intacto
    },
  );

  blocTest<CyclesCubit, CyclesState>(
    'saveItem adds, then updates; toggleItem marks done',
    build: build,
    seed: ready,
    act: (c) async {
      const luz = Item(
        id: 'i3',
        name: 'Luz',
        amountCents: 9000,
        isIncome: false,
      );
      await c.saveItem('c1', luz);
      await c.saveItem('c1', luz.copyWith(amountCents: 10000));
      await c.toggleItem('c1', 'i3', true);
    },
    verify: (c) {
      final items = c.state.cycleById('c1')!.items;
      expect(items, hasLength(3));
      expect(items.last.amountCents, 10000);
      expect(items.last.done, isTrue);
    },
  );

  blocTest<CyclesCubit, CyclesState>(
    'updateCycle changes date/name and clears empty name',
    build: build,
    seed: () => ready([base.copyWith(name: 'Velho')]),
    act: (c) =>
        c.updateCycle(id: 'c1', date: DateTime(2026, 11, 20), name: ' '),
    verify: (c) {
      expect(c.state.cycles.single.name, isNull);
      expect(c.state.cycles.single.date, DateTime(2026, 11, 20));
    },
  );

  group('delete + undo', () {
    blocTest<CyclesCubit, CyclesState>(
      'item delete is undone at the original position',
      build: build,
      seed: ready,
      act: (c) async {
        await c.deleteItem('c1', 'i1');
        expect(c.state.cycleById('c1')!.items, [rent]);
        expect(c.state.removal, isA<ItemRemoval>());
        await c.undoRemoval();
      },
      verify: (c) {
        expect(c.state.cycleById('c1')!.items, [salary, rent]);
        expect(c.state.removal, isNull);
      },
    );

    blocTest<CyclesCubit, CyclesState>(
      'cycle delete is undone at the original position',
      build: build,
      seed: () => ready([base, Cycle(id: 'c2', date: DateTime(2026, 12, 1))]),
      act: (c) async {
        await c.deleteCycle('c1');
        expect(c.state.cycles.map((x) => x.id), ['c2']);
        await c.undoRemoval();
      },
      verify: (c) => expect(c.state.cycles.map((x) => x.id), ['c1', 'c2']),
    );

    test('consecutive identical removals get different tokens', () async {
      final c = build()..emit(ready());
      await c.deleteItem('c1', 'i1');
      final first = c.state.removal;
      await c.undoRemoval();
      await c.deleteItem('c1', 'i1');
      expect(c.state.removal, isNot(first));
      await c.close();
    });

    test('unknown ids are ignored', () async {
      final c = build()..emit(ready());
      await c.deleteItem('nope', 'i1');
      await c.deleteItem('c1', 'nope');
      await c.deleteCycle('nope');
      await c.undoRemoval();
      expect(c.state, ready());
      verifyNever(() => repo.save(any()));
      await c.close();
    });
  });

  group('import', () {
    final other = Cycle(
      id: 'c1',
      date: DateTime(2020, 1, 1),
      name: 'Do arquivo',
    );
    final extra = Cycle(id: 'c9', date: DateTime(2020, 2, 1));

    blocTest<CyclesCubit, CyclesState>(
      'replace discards current data',
      build: build,
      seed: ready,
      act: (c) => c.importBackup([extra], mode: ImportMode.replace),
      verify: (c) => expect(c.state.cycles, [extra]),
    );

    blocTest<CyclesCubit, CyclesState>(
      'merge keeps existing, overrides same id, appends new',
      build: build,
      seed: ready,
      act: (c) => c.importBackup([other, extra], mode: ImportMode.merge),
      verify: (c) => expect(c.state.cycles, [other, extra]),
    );
  });

  test('sortedCycles orders by real date, newest first', () {
    final s = ready([
      Cycle(id: 'a', date: DateTime(2026, 3, 1)),
      Cycle(id: 'b', date: DateTime(2026, 5, 1)),
      Cycle(id: 'c', date: DateTime(2026, 5, 1)),
      Cycle(id: 'd', date: DateTime(2026, 1, 1)),
    ]);
    expect(s.sortedCycles.map((c) => c.id), ['c', 'b', 'a', 'd']);
  });
}
