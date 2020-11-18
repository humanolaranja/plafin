class Spent {
  String name;
  double value;
  bool income;

  Spent({this.name, this.value, this.income});

  static Spent fromJson(Map<dynamic, dynamic> json) {
    Spent spent = Spent();
    spent.name = json['name'].toString();
    spent.value = json['value'];
    spent.income = json['income'];

    return spent;
  }

  Map toJson() {
    return {
      'name': name,
      'value': value,
      'income': income,
    };
  }
}
