import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plafin/app.dart';
import 'package:plafin/cubits/cycles_cubit.dart';
import 'package:plafin/data/cycle.dart';
import 'package:plafin/data/cycles_repository.dart';
import 'package:plafin/data/item.dart';
import 'package:plafin/data/item_sort.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRepo extends Mock implements CyclesRepository {}

Item it(
  String id,
  String name,
  int cents, {
  bool income = false,
  bool done = false,
}) =>
    Item(id: id, name: name, amountCents: cents, isIncome: income, done: done);

void main() {
  final items = [
    it('1', 'Aluguel', 150000),
    it('2', 'Salário', 850000, income: true, done: true),
    it('3', 'mercado', 90000, done: true),
    it('4', 'Bônus', 50000, income: true),
    it('5', 'Água', 8000),
  ];
  List<String> ids(List<Item> l) => [for (final i in l) i.id];

  group('ItemSort (stable)', () {
    test('income first keeps relative order inside each group', () {
      expect(ids(ItemSort.incomeFirst.apply(items)), ['2', '4', '1', '3', '5']);
    });
    test('pending first', () {
      expect(ids(ItemSort.pendingFirst.apply(items)), [
        '1',
        '4',
        '5',
        '2',
        '3',
      ]);
    });
    test('amount desc', () {
      expect(ids(ItemSort.amountDesc.apply(items)), ['2', '1', '3', '4', '5']);
    });
    test('expenses first keeps relative order inside each group', () {
      expect(ids(ItemSort.expensesFirst.apply(items)), [
        '1',
        '3',
        '5',
        '2',
        '4',
      ]);
    });
    test('amount asc', () {
      expect(ids(ItemSort.amountAsc.apply(items)), ['5', '4', '3', '1', '2']);
    });
    test('equal amounts keep their order', () {
      final eq = [it('a', 'x', 100), it('b', 'y', 100), it('c', 'z', 100)];
      expect(ids(ItemSort.amountDesc.apply(eq)), ['a', 'b', 'c']);
      expect(ids(ItemSort.amountAsc.apply(eq)), ['a', 'b', 'c']);
    });
  });

  group('cubit', () {
    late _MockRepo repo;
    final cycle = Cycle(id: 'c', date: DateTime(2026, 11, 5), items: items);
    CyclesState seed() =>
        CyclesState(status: CyclesStatus.ready, cycles: [cycle]);

    setUpAll(() => registerFallbackValue(<Cycle>[]));
    setUp(() {
      repo = _MockRepo();
      when(() => repo.save(any())).thenAnswer((_) async {});
    });

    List<String> order(CyclesCubit c) => ids(c.state.cycleById('c')!.items);

    blocTest<CyclesCubit, CyclesState>(
      'reorderItems moves down (Flutter newIndex semantics) and persists',
      build: () => CyclesCubit(repo),
      seed: seed,
      act: (c) =>
          c.reorderItems('c', 0, 3), // item 0 vai para depois do índice 2
      verify: (c) {
        expect(order(c), ['2', '3', '1', '4', '5']);
        verify(() => repo.save(any())).called(1);
      },
    );

    blocTest<CyclesCubit, CyclesState>(
      'reorderItems moves up and to the very end',
      build: () => CyclesCubit(repo),
      seed: seed,
      act: (c) async {
        await c.reorderItems('c', 3, 1);
        await c.reorderItems('c', 0, 5);
      },
      verify: (c) => expect(order(c), ['4', '2', '3', '5', '1']),
    );

    blocTest<CyclesCubit, CyclesState>(
      'reorderItems ignores no-ops and invalid indexes',
      build: () => CyclesCubit(repo),
      seed: seed,
      act: (c) async {
        await c.reorderItems('c', 2, 2);
        await c.reorderItems('c', 2, 3); // mesma posição após ajuste
        await c.reorderItems('c', 9, 0);
        await c.reorderItems('x', 0, 1);
      },
      verify: (c) {
        expect(order(c), ['1', '2', '3', '4', '5']);
        verifyNever(() => repo.save(any()));
      },
    );

    blocTest<CyclesCubit, CyclesState>(
      'sortItems is undoable and restores the manual order',
      build: () => CyclesCubit(repo),
      seed: seed,
      act: (c) async {
        await c.reorderItems('c', 4, 0); // ordem manual: 5 1 2 3 4
        await c.sortItems('c', ItemSort.incomeFirst);
        expect(order(c), ['2', '4', '5', '1', '3']);
        expect(c.state.removal, isA<ItemsOrderChange>());
        await c.undoRemoval();
      },
      verify: (c) {
        expect(order(c), ['5', '1', '2', '3', '4']);
        expect(c.state.removal, isNull);
      },
    );

    blocTest<CyclesCubit, CyclesState>(
      'undo keeps items created after the sort (appended at the end)',
      build: () => CyclesCubit(repo),
      seed: seed,
      act: (c) async {
        await c.sortItems('c', ItemSort.amountAsc);
        await c.saveItem('c', it('6', 'Novo', 1000));
        await c.undoRemoval();
      },
      verify: (c) => expect(order(c), ['1', '2', '3', '4', '5', '6']),
    );

    blocTest<CyclesCubit, CyclesState>(
      'sort that changes nothing does not emit an undo entry',
      build: () => CyclesCubit(repo),
      seed: seed,
      act: (c) async {
        await c.sortItems('c', ItemSort.incomeFirst);
        await c.sortItems('c', ItemSort.incomeFirst); // já ordenado
      },
      verify: (c) => verify(() => repo.save(any())).called(1),
    );
  });

  testWidgets('drag handle reorders items on screen and persists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final json =
        '''{"schemaVersion":2,"cycles":[{"id":"c","name":"Teste","date":"2026-11-05","items":[
      {"id":"1","name":"Primeiro","amountCents":1000,"income":false,"done":false},
      {"id":"2","name":"Segundo","amountCents":2000,"income":false,"done":false},
      {"id":"3","name":"Terceiro","amountCents":3000,"income":false,"done":false}]}]}''';
    SharedPreferences.setMockInitialValues({
      'plafin.data.v2': json,
      'plafin.settings.locale': 'pt',
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(PlafinApp(prefs: prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Teste').last);
    await tester.pumpAndSettle();

    double y(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(
      y('Primeiro') < y('Segundo') && y('Segundo') < y('Terceiro'),
      isTrue,
    );

    // arrasta o puxador do primeiro item para baixo do terceiro
    final handle = find.byIcon(Icons.drag_indicator_rounded).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(0, 22));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      y('Segundo') < y('Terceiro') && y('Terceiro') < y('Primeiro'),
      isTrue,
    );
    expect(prefs.getString('plafin.data.v2'), contains('"Segundo"'));
    final saved = prefs.getString('plafin.data.v2')!;
    expect(saved.indexOf('Segundo') < saved.indexOf('Terceiro'), isTrue);
    expect(saved.indexOf('Terceiro') < saved.indexOf('Primeiro'), isTrue);

    // atalho de ordenação: Maior para menor valor, e desfazer
    await tester.tap(find.byIcon(Icons.sort_rounded));
    await tester.pumpAndSettle();
    // menu: 5 opções, na ordem pedida, sem "Nome (A–Z)"
    final labels = [
      'Receitas no topo',
      'Despesas no topo',
      'Maior para menor valor',
      'Menor para maior valor',
      'Pendentes antes dos realizados',
    ];
    final ys = [for (final l in labels) tester.getTopLeft(find.text(l)).dy];
    expect(ys, orderedEquals([...ys]..sort()));
    expect(find.text('Nome (A–Z)'), findsNothing);
    await tester.tap(find.text('Maior para menor valor'));
    await tester.pumpAndSettle();
    expect(
      y('Terceiro') < y('Segundo') && y('Segundo') < y('Primeiro'),
      isTrue,
    );
    expect(find.text('Itens ordenados'), findsOneWidget);
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(
      y('Segundo') < y('Terceiro') && y('Terceiro') < y('Primeiro'),
      isTrue,
    );
  });
}
