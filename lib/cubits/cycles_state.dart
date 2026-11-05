part of 'cycles_cubit.dart';

enum CyclesStatus { loading, ready, failure }

enum ImportMode { replace, merge }

/// Algo que o usuário removeu e que pode ser desfeito.
sealed class Removal extends Equatable {
  const Removal(this.token);

  /// Distingue remoções consecutivas idênticas (para a UI reexibir o aviso).
  final int token;
}

class CycleRemoval extends Removal {
  const CycleRemoval(super.token, {required this.cycle, required this.index});

  final Cycle cycle;
  final int index;

  @override
  List<Object?> get props => [token, cycle, index];
}

class ItemRemoval extends Removal {
  const ItemRemoval(
    super.token, {
    required this.cycleId,
    required this.item,
    required this.index,
  });

  final String cycleId;
  final Item item;
  final int index;

  @override
  List<Object?> get props => [token, cycleId, item, index];
}

class CyclesState extends Equatable {
  const CyclesState({
    this.status = CyclesStatus.loading,
    this.cycles = const [],
    this.removal,
  });

  final CyclesStatus status;

  /// Em ordem de inserção; use [sortedCycles] para exibir.
  final List<Cycle> cycles;
  final Removal? removal;

  /// Ordenados por data (mais recente primeiro). Empates mantêm a ordem de
  /// criação (mais novo primeiro).
  List<Cycle> get sortedCycles {
    final indexed = [for (var i = 0; i < cycles.length; i++) (i, cycles[i])];
    indexed.sort((a, b) {
      final byDate = b.$2.date.compareTo(a.$2.date);
      return byDate != 0 ? byDate : b.$1.compareTo(a.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  /// Ciclo em andamento: o mais recente com data até [today]; se todos forem
  /// futuros, o mais próximo.
  Cycle? currentCycle(DateTime today) {
    final sorted = sortedCycles;
    if (sorted.isEmpty) return null;
    final day = DateTime(today.year, today.month, today.day);
    for (final c in sorted) {
      if (!c.date.isAfter(day)) return c;
    }
    return sorted.last;
  }

  Cycle? cycleById(String id) {
    for (final c in cycles) {
      if (c.id == id) return c;
    }
    return null;
  }

  CyclesState copyWith({
    CyclesStatus? status,
    List<Cycle>? cycles,
    Removal? removal,
    bool clearRemoval = false,
  }) {
    return CyclesState(
      status: status ?? this.status,
      cycles: cycles ?? this.cycles,
      removal: clearRemoval ? null : (removal ?? this.removal),
    );
  }

  @override
  List<Object?> get props => [status, cycles, removal];
}
