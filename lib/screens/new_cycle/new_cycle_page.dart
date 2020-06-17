import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/routes.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/shared/components.dart';

class NewCyclePage extends StatelessWidget {
  const NewCyclePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "New Cycle"),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Routes().navigateToNewCyclePage(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            RaisedButton(
              onPressed: () => {
                BlocProvider.of<CyclesBloc>(context).add(
                  AddCycleEvent(initialMoney: 100, date: "30/06/2020"),
                ),
                Navigator.of(context).pop()
              },
              child: Text("Create"),
            )
          ],
        ),
      ),
    );
  }
}
