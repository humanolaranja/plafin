import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';

class NewSpentPage extends StatefulWidget {
  const NewSpentPage({Key key}) : super(key: key);

  @override
  _NewSpentPageState createState() => _NewSpentPageState();
}

class _NewSpentPageState extends State<NewSpentPage> {
  String name = '';
  double value = 0;
  bool income = false;

  @override
  Widget build(BuildContext context) {
    String prefixValue = 'R\$ ';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          padding: MediaQuery.of(context).viewInsets,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Nome',
                  ),
                  onChanged: (newName) {
                    setState(() {
                      name = newName;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Valor',
                  ),
                  inputFormatters: [
                    CurrencyTextInputFormatter(
                      decimalDigits: 2,
                      symbol: prefixValue,
                      locale: 'pt-BR',
                    )
                  ],
                  keyboardType: TextInputType.number,
                  onChanged: (newValue) {
                    setState(() {
                      value = double.tryParse(newValue.replaceAll('.', '').replaceAll(',', '.').replaceAll(prefixValue, '')) ?? 0;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CheckboxListTile(
                  title: Text('Receita'),
                  value: income,
                  onChanged: (isIncome) {
                    setState(() {
                      income = isIncome;
                    });
                  },
                ),
              ),
              Container(
                width: double.infinity,
                height: 48,
                child: RaisedButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  child: Text("Criar"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
