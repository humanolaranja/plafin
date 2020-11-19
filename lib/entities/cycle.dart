import 'package:plafin/entities/spent.dart';

class Cycle {
  String date;
  double amount;
  List<Spent> spendings = <Spent>[];

  Cycle({this.date, this.amount, this.spendings});

  static Cycle fromJson(Map<dynamic, dynamic> json) {
    Cycle cycle = Cycle();
    cycle.date = json['date'].toString();
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
      'amount': amount,
      'spendings': spendings,
    };
  }
}
