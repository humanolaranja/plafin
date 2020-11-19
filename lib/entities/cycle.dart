import 'package:plafin/entities/spent.dart';

class Cycle {
  String date;
  double initialAmount;
  double amount;
  List<Spent> spendings = <Spent>[];

  Cycle({this.date, this.initialAmount, this.amount, this.spendings});

  static Cycle fromJson(Map<dynamic, dynamic> json) {
    Cycle cycle = Cycle();
    cycle.date = json['date'].toString();
    cycle.initialAmount = json['initialAmount'];
    cycle.amount = json['amount'];
    if (json.containsKey('spendings')) {
      var items = json['spendings'] as List;
      cycle.spendings = items.map((e) => Spent.fromJson(e)).toList();
    }

    return cycle;
  }

  Map toJson() {
    return {
      'date': date,
      'initialAmount': initialAmount,
      'amount': amount,
      'spendings': spendings,
    };
  }
}
