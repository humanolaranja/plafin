import 'item.dart';

/// Ordenações automáticas dos itens de um ciclo, na ordem em que aparecem no
/// menu. Todas são estáveis: itens "iguais" mantêm a ordem relativa atual (a
/// ordem manual dentro de cada grupo é preservada).
enum ItemSort {
  /// Receitas no topo, despesas abaixo.
  incomeFirst,

  /// Despesas no topo, receitas abaixo.
  expensesFirst,

  /// Maior valor para o menor.
  amountDesc,

  /// Menor valor para o maior.
  amountAsc,

  /// Itens não realizados no topo, realizados abaixo.
  pendingFirst;

  List<Item> apply(List<Item> items) {
    final indexed = [for (var i = 0; i < items.length; i++) (i, items[i])];
    indexed.sort((a, b) {
      final x = a.$2;
      final y = b.$2;
      final result = switch (this) {
        ItemSort.incomeFirst => (x.isIncome ? 0 : 1).compareTo(
          y.isIncome ? 0 : 1,
        ),
        ItemSort.expensesFirst => (x.isIncome ? 1 : 0).compareTo(
          y.isIncome ? 1 : 0,
        ),
        ItemSort.amountDesc => y.amountCents.compareTo(x.amountCents),
        ItemSort.amountAsc => x.amountCents.compareTo(y.amountCents),
        ItemSort.pendingFirst => (x.done ? 1 : 0).compareTo(y.done ? 1 : 0),
      };
      return result != 0 ? result : a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }
}
