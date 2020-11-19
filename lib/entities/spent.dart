class Spent {
  String name;
  double value;
  bool income;
  bool done;

  Spent({this.name, this.value, this.income, this.done});

  static Spent fromJson(Map<dynamic, dynamic> json) {
    Spent spent = Spent();
    spent.name = json['name'].toString();
    spent.value = json['value'];
    spent.income = json['income'];
    spent.done = json['done'];

    return spent;
  }

  Map toJson() {
    return {
      'name': name,
      'value': value,
      'income': income,
      'done': done,
    };
  }
}
