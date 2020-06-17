class Cycle {
  String date;
  double initialMoney;
  List<dynamic> spendings = const [];

  Cycle({this.date, this.initialMoney, this.spendings});

  static Cycle fromJson(Map<dynamic, dynamic> json) {
    Cycle cycle = Cycle();
    cycle.date = json['date'].toString();
    cycle.initialMoney = json['initialMoney'];
    if (json.containsKey('spendings')) {
      var items = json['spendings'] as List;
      cycle.spendings = items.map((e) => e).toList();
    }

    return cycle;
  }

  Map toJson() {
    return {
      'date': date,
      'initialMoney': initialMoney,
      'spendings': spendings,
    };
  }
}
