import 'package:flutter_test/flutter_test.dart';
import 'package:plafin/l10n/app_localizations_en.dart';
import 'package:plafin/l10n/app_localizations_pt.dart';

void main() {
  // Em português o ICU trata 0 como "um": sem um ramo =0 explícito, "0 ciclos"
  // apareceria como "1 ciclo".
  test('pt plurals handle zero explicitly', () {
    final l = AppLocalizationsPt();
    expect(l.cyclesCount(0), 'Nenhum ciclo');
    expect(l.cyclesCount(1), '1 ciclo');
    expect(l.cyclesCount(3), '3 ciclos');
    expect(l.itemsCount(0), 'Sem itens');
    expect(l.importPreviewBody(0, 0), contains('0 ciclos e 0 itens'));
    expect(l.importPreviewBody(1, 1), contains('1 ciclo e 1 item'));
  });

  test('en plurals', () {
    final l = AppLocalizationsEn();
    expect(l.cyclesCount(0), 'No cycles');
    expect(l.cyclesCount(2), '2 cycles');
    expect(l.importPreviewBody(0, 2), contains('0 cycles and 2 items'));
  });
}
