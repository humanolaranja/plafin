class FormatUtils {
  static doubleValueToMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}'.replaceAll('.', ',').replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}
