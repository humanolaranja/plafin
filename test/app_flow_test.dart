import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plafin/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'plafin.settings.locale': 'pt'});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(PlafinApp(prefs: prefs));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty state -> create cycle -> add item -> delete -> undo', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Nenhum ciclo ainda'), findsOneWidget);
    await tester.tap(find.text('Criar ciclo'));
    await tester.pumpAndSettle();

    // formulário de ciclo: nome + saldo inicial R$ 100,00
    await tester.enterText(
      find.widgetWithText(TextField, 'Nome (opcional)'),
      'Novembro',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Saldo inicial'),
      '10000',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Criar'));
    await tester.pumpAndSettle();

    // abriu a página do ciclo com o item de saldo inicial
    expect(find.text('Novembro'), findsOneWidget);
    expect(find.textContaining('+R\$'), findsOneWidget);
    expect(find.text('0 de 1 realizados'), findsOneWidget);

    // novo item (despesa) de R$ 30,00
    await tester.tap(find.text('Adicionar item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Luz');
    await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), '3000');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Luz'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'R\$[\s\u00a0]70,00')),
      findsWidgets,
    ); // saldo 100 - 30

    // marcar como realizado
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    expect(find.text('1 de 2 realizados'), findsOneWidget);

    // valor zero é rejeitado
    await tester.tap(find.text('Adicionar item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Zero');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um valor maior que zero'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // fecha o sheet
    await tester.pumpAndSettle();

    // editar o item e excluir pelo sheet; desfazer pelo SnackBar
    await tester.tap(find.text('Luz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Luz'), findsNothing);
    expect(find.text('Item excluído'), findsOneWidget);
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text('Luz'), findsOneWidget);

    // voltar: o ciclo aparece na lista com progresso
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('Novembro'), findsOneWidget);
    expect(find.text('1 de 2 realizados'), findsOneWidget);
  });
}
