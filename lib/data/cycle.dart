import 'package:equatable/equatable.dart';

import 'item.dart';

/// Um ciclo financeiro (normalmente começa no dia em que o salário cai).
///
/// O saldo e os totais são sempre derivados dos [items]; nada é guardado
/// de forma redundante.
class Cycle extends Equatable {
  const Cycle({
    required this.id,
    required this.date,
    this.name,
    this.items = const [],
  });

  final String id;

  /// Apenas a data (sem hora).
  final DateTime date;

  /// Nome opcional; quando ausente a UI exibe a data.
  final String? name;
  final List<Item> items;

  int get incomeCents =>
      items.where((i) => i.isIncome).fold(0, (s, i) => s + i.amountCents);

  int get expenseCents =>
      items.where((i) => !i.isIncome).fold(0, (s, i) => s + i.amountCents);

  int get balanceCents => incomeCents - expenseCents;

  int get receivedCents => items
      .where((i) => i.isIncome && i.done)
      .fold(0, (s, i) => s + i.amountCents);

  int get paidCents => items
      .where((i) => !i.isIncome && i.done)
      .fold(0, (s, i) => s + i.amountCents);

  int get pendingExpenseCents => expenseCents - paidCents;

  int get doneCount => items.where((i) => i.done).length;

  /// Fração de itens realizados (0..1).
  double get progress => items.isEmpty ? 0 : doneCount / items.length;

  Cycle copyWith({
    String? id,
    DateTime? date,
    String? name,
    bool clearName = false,
    List<Item>? items,
  }) {
    return Cycle(
      id: id ?? this.id,
      date: date ?? this.date,
      name: clearName ? null : (name ?? this.name),
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': formatIsoDate(date),
    'items': items.map((i) => i.toJson()).toList(),
  };

  factory Cycle.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim();
    return Cycle(
      id: json['id'] as String,
      name: (name == null || name.isEmpty) ? null : name,
      date: parseIsoDate(json['date'] as String),
      items: [
        for (final i in (json['items'] as List? ?? const []))
          Item.fromJson(Map<String, dynamic>.from(i as Map)),
      ],
    );
  }

  @override
  List<Object?> get props => [id, date, name, items];
}

/// `yyyy-MM-dd`
String formatIsoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime parseIsoDate(String s) {
  final d = DateTime.parse(s);
  return DateTime(d.year, d.month, d.day);
}
