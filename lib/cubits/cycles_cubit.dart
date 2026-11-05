import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/cycle.dart';
import '../data/cycles_repository.dart';
import '../data/item.dart';

part 'cycles_state.dart';

/// Estado dos ciclos. Cada método altera o estado em memória (síncrono, para
/// a UI reagir na hora) e em seguida persiste o resultado.
class CyclesCubit extends Cubit<CyclesState> {
  CyclesCubit(this._repository) : super(const CyclesState());

  final CyclesRepository _repository;
  int _removalToken = 0;

  Future<void> load() async {
    emit(state.copyWith(status: CyclesStatus.loading));
    try {
      final cycles = await _repository.load();
      emit(state.copyWith(status: CyclesStatus.ready, cycles: cycles));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: CyclesStatus.failure));
    }
  }

  // --- ciclos --------------------------------------------------------------

  Future<void> createCycle({
    required String id,
    required DateTime date,
    String? name,
    int initialBalanceCents = 0,
    String initialBalanceLabel = '',
  }) {
    return _commit([
      ...state.cycles,
      Cycle(
        id: id,
        date: date,
        name: _cleanName(name),
        items: [
          if (initialBalanceCents > 0)
            Item(
              id: '$id-initial',
              name: initialBalanceLabel,
              amountCents: initialBalanceCents,
              isIncome: true,
            ),
        ],
      ),
    ]);
  }

  Future<void> updateCycle({
    required String id,
    required DateTime date,
    String? name,
  }) {
    final clean = _cleanName(name);
    return _commit(
      _mapCycle(
        id,
        (c) => c.copyWith(date: date, name: clean, clearName: clean == null),
      ),
    );
  }

  Future<void> deleteCycle(String id) {
    final index = state.cycles.indexWhere((c) => c.id == id);
    if (index < 0) return Future.value();
    return _commit(
      [...state.cycles]..removeAt(index),
      removal: CycleRemoval(
        ++_removalToken,
        cycle: state.cycles[index],
        index: index,
      ),
    );
  }

  /// Copia um ciclo para uma nova data, com todos os itens como não
  /// realizados.
  Future<void> copyCycle({
    required String sourceId,
    required String newId,
    required DateTime date,
    String? name,
  }) {
    final source = state.cycleById(sourceId);
    if (source == null) return Future.value();
    return _commit([
      ...state.cycles,
      Cycle(
        id: newId,
        date: date,
        name: _cleanName(name),
        items: [
          for (var i = 0; i < source.items.length; i++)
            source.items[i].copyWith(id: '$newId-$i', done: false),
        ],
      ),
    ]);
  }

  // --- itens ---------------------------------------------------------------

  /// Cria o item (se o id ainda não existe no ciclo) ou o atualiza.
  Future<void> saveItem(String cycleId, Item item) {
    return _commit(
      _mapCycle(cycleId, (c) {
        final exists = c.items.any((i) => i.id == item.id);
        return c.copyWith(
          items: exists
              ? [for (final i in c.items) i.id == item.id ? item : i]
              : [...c.items, item],
        );
      }),
    );
  }

  Future<void> deleteItem(String cycleId, String itemId) {
    final cycle = state.cycleById(cycleId);
    final index = cycle?.items.indexWhere((i) => i.id == itemId) ?? -1;
    if (cycle == null || index < 0) return Future.value();
    return _commit(
      _mapCycle(
        cycleId,
        (c) => c.copyWith(items: [...c.items]..removeAt(index)),
      ),
      removal: ItemRemoval(
        ++_removalToken,
        cycleId: cycleId,
        item: cycle.items[index],
        index: index,
      ),
    );
  }

  Future<void> toggleItem(String cycleId, String itemId, bool done) {
    return _commit(
      _mapCycle(
        cycleId,
        (c) => c.copyWith(
          items: [
            for (final i in c.items)
              i.id == itemId ? i.copyWith(done: done) : i,
          ],
        ),
      ),
    );
  }

  // --- desfazer / importar ---------------------------------------------------

  Future<void> undoRemoval() {
    final removal = state.removal;
    if (removal == null) return Future.value();
    switch (removal) {
      case CycleRemoval(:final cycle, :final index):
        return _commit(
          [...state.cycles]..insert(index.clamp(0, state.cycles.length), cycle),
          clearRemoval: true,
        );
      case ItemRemoval(:final cycleId, :final item, :final index):
        return _commit(
          _mapCycle(cycleId, (c) {
            final items = [...c.items]
              ..insert(index.clamp(0, c.items.length), item);
            return c.copyWith(items: items);
          }),
          clearRemoval: true,
        );
    }
  }

  /// [ImportMode.merge]: ciclos com o mesmo id são substituídos pelos do
  /// arquivo e os novos são acrescentados.
  Future<void> importBackup(List<Cycle> imported, {required ImportMode mode}) {
    switch (mode) {
      case ImportMode.replace:
        return _commit(imported, clearRemoval: true);
      case ImportMode.merge:
        final incoming = {for (final c in imported) c.id: c};
        return _commit([
          for (final c in state.cycles) incoming.remove(c.id) ?? c,
          ...incoming.values,
        ], clearRemoval: true);
    }
  }

  // --- internos ------------------------------------------------------------

  /// Emite o novo estado e persiste. Se salvar falhar o erro é reportado via
  /// [addError] (o estado em memória continua válido).
  Future<void> _commit(
    List<Cycle> cycles, {
    Removal? removal,
    bool clearRemoval = false,
  }) async {
    emit(
      state.copyWith(
        cycles: cycles,
        removal: removal,
        clearRemoval: clearRemoval,
      ),
    );
    try {
      await _repository.save(cycles);
    } catch (e, st) {
      addError(e, st);
    }
  }

  List<Cycle> _mapCycle(String id, Cycle Function(Cycle) update) => [
    for (final c in state.cycles) c.id == id ? update(c) : c,
  ];

  static String? _cleanName(String? name) {
    final trimmed = name?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
