import 'package:equatable/equatable.dart';

/// Um lançamento dentro de um ciclo (receita ou despesa).
///
/// Valores são guardados em centavos (`int`) para evitar erros de ponto
/// flutuante. [amountCents] é sempre positivo; o sinal vem de [isIncome].
class Item extends Equatable {
  const Item({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.isIncome,
    this.done = false,
  });

  final String id;
  final String name;
  final int amountCents;
  final bool isIncome;
  final bool done;

  /// Valor com sinal: receitas positivas, despesas negativas.
  int get signedCents => isIncome ? amountCents : -amountCents;

  Item copyWith({
    String? id,
    String? name,
    int? amountCents,
    bool? isIncome,
    bool? done,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      isIncome: isIncome ?? this.isIncome,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amountCents': amountCents,
    'income': isIncome,
    'done': done,
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: (json['name'] ?? '').toString(),
      amountCents: (json['amountCents'] as num).round().abs(),
      isIncome: json['income'] == true,
      done: json['done'] == true,
    );
  }

  @override
  List<Object?> get props => [id, name, amountCents, isIncome, done];
}
