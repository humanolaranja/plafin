import 'item.dart';

/// Ordenações automáticas dos itens de um ciclo. Todas são estáveis: itens
/// "iguais" mantêm a ordem relativa atual (a ordem manual dentro de cada grupo
/// é preservada).
enum ItemSort {
  /// Receitas no topo, despesas abaixo.
  incomeFirst,

  /// Itens não realizados no topo, realizados abaixo.
  pendingFirst,

  /// Maior valor primeiro.
  amountDesc,

  /// Nome de A a Z (sem diferenciar maiúsculas nem acentos: "Água" vem como "A").
  nameAsc;

  List<Item> apply(List<Item> items) {
    final indexed = [for (var i = 0; i < items.length; i++) (i, items[i])];
    indexed.sort((a, b) {
      final x = a.$2;
      final y = b.$2;
      final result = switch (this) {
        ItemSort.incomeFirst => (x.isIncome ? 0 : 1).compareTo(
          y.isIncome ? 0 : 1,
        ),
        ItemSort.pendingFirst => (x.done ? 1 : 0).compareTo(y.done ? 1 : 0),
        ItemSort.amountDesc => y.amountCents.compareTo(x.amountCents),
        ItemSort.nameAsc => _fold(x.name).compareTo(_fold(y.name)),
      };
      return result != 0 ? result : a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }
}

const _accents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

/// Minúsculas e sem acentos, só para comparar nomes.
String _fold(String text) {
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    out.write(_accents[ch] ?? ch);
  }
  return out.toString();
}
