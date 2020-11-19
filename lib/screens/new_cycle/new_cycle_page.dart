import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';

class NewCyclePage extends StatefulWidget {
  const NewCyclePage({Key key}) : super(key: key);

  @override
  _NewCyclePageState createState() => _NewCyclePageState();
}

class _NewCyclePageState extends State<NewCyclePage> {
  final String prefixValue = 'R\$ ';
  DateTime selectedDate = DateTime.now();
  double initialAmount = 0.0;

  _parseValue(String value) {
    return double.tryParse(value.replaceAll('.', '').replaceAll(',', '.').replaceAll(prefixValue, '')) ?? 0;
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = formatDate(selectedDate, [dd, '/', mm, '/', yyyy]);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            padding: MediaQuery.of(context).viewInsets,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Saldo Inicial',
                    ),
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        decimalDigits: 2,
                        symbol: prefixValue,
                        locale: 'pt-BR',
                      )
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        initialAmount = _parseValue(value);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: FlatButton(
                    onPressed: () => _selectDate(context),
                    child: Text(date),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 48,
                  child: RaisedButton(
                    onPressed: () => {
                      BlocProvider.of<CyclesBloc>(context).add(
                        AddCycleEvent(amount: initialAmount ?? 0, date: date),
                      ),
                      Navigator.of(context).pop()
                    },
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
