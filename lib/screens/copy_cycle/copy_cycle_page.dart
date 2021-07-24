import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/routes.dart';
import 'package:plafin/screens/cycle/cycle_page.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';

class CopyCyclePage extends StatefulWidget {
  final int baseIndex;

  const CopyCyclePage({@required this.baseIndex, Key key}) : super(key: key);

  @override
  _CopyCyclePageState createState() => _CopyCyclePageState();
}

class _CopyCyclePageState extends State<CopyCyclePage> {
  DateTime selectedDate = DateTime.now();

  _copyCycle(BuildContext context, int lastIndex) {
    String date = formatDate(selectedDate, [dd, '/', mm, '/', yyyy]);

    BlocProvider.of<CyclesBloc>(context).add(
      CopyCycleEvent(index: widget.baseIndex, date: date),
    );
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Routes().navigateToCyclePage(
      context,
      CyclePageArguments(id: lastIndex),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
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
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(date),
                  ),
                ),
                BlocBuilder<CyclesBloc, CyclesState>(
                    builder: (context, cyclesState) {
                  return Container(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () =>
                          _copyCycle(context, cyclesState.cycles.length),
                      child: Text("Criar"),
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
