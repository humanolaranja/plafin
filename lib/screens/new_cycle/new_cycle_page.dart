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
  DateTime selectedDate = DateTime.now();
  double initialAmount = 0;

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
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                      AddCycleEvent(initialAmount: initialAmount, amount: initialAmount, date: date),
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
    );
  }
}
