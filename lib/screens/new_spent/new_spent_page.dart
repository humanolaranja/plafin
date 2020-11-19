import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';

class NewSpentPage extends StatefulWidget {
  final int index;
  const NewSpentPage(this.index, {Key key}) : super(key: key);

  @override
  _NewSpentPageState createState() => _NewSpentPageState();
}

class _NewSpentPageState extends State<NewSpentPage> {
  final _formKey = GlobalKey<FormState>();
  final String prefixValue = 'R\$ ';
  String name = '';
  double value = 0.0;
  bool income = false;

  _requiredField(String text) {
    if (text.isEmpty || text == '0.0') {
      return 'Preenchimento obrigatório';
    }
    return null;
  }

  _createNewSpent(BuildContext context) {
    if (_formKey.currentState.validate()) {
      print('name: $name, value: $value, income: $income');
      BlocProvider.of<CyclesBloc>(context).add(
        AddSpentToCycleEvent(index: widget.index, name: name, value: value, income: income),
      );
      Navigator.of(context).pop();
    }
  }

  _parseValue(String value) {
    return double.tryParse(value.replaceAll('.', '').replaceAll(',', '.').replaceAll(prefixValue, '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          padding: MediaQuery.of(context).viewInsets,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Nome',
                    ),
                    onChanged: (newName) {
                      setState(() {
                        name = newName;
                      });
                    },
                    validator: (name) {
                      return _requiredField(name);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
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
                        value = _parseValue(newValue);
                      });
                    },
                    validator: (value) {
                      print(_parseValue(value).toString());
                      return _requiredField(_parseValue(value).toString());
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
                    onPressed: () => _createNewSpent(context),
                    child: Text("Criar"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
