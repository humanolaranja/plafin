import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/entities/cycle.dart';
import 'package:plafin/routes.dart';
import 'package:plafin/screens/cycle/cycle_page.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/shared/components.dart';

class CyclesPage extends StatelessWidget {
  const CyclesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CyclesBloc, CyclesState>(builder: (context, cyclesState) {
      return Scaffold(
        appBar: CommonAppBar(title: "Cycles"),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Routes().navigateToNewCyclePage(context),
          child: Icon(Icons.add),
          backgroundColor: Colors.deepOrangeAccent,
        ),
        body: SafeArea(
          child: ListView.separated(
            itemCount: cyclesState.cycles.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              Cycle item = cyclesState.cycles[index];
              return GestureDetector(
                onTap: () => Routes().navigateToCyclePage(context, CyclePageArguments(id: index)),
                child: ListTile(
                  title: Text(item.date),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
