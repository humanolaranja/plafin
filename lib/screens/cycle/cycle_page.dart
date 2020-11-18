import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/entities/cycle.dart';
import 'package:plafin/screens/cycle/widgets/CycleFloatingActionButton.dart';
import 'package:plafin/screens/cycle/widgets/Empty.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/shared/components/CommonAppBar.dart';

class CyclePage extends StatelessWidget {
  const CyclePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CyclePageArguments args = ModalRoute.of(context).settings.arguments;

    return BlocBuilder<CyclesBloc, CyclesState>(builder: (context, cyclesState) {
      Cycle item = cyclesState.cycles[args.id];
      return Scaffold(
        appBar: CommonAppBar(title: '${item.date}'),
        floatingActionButton: CycleFloatingActionButton(),
        body: SafeArea(
          child: item.spendings.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: Empty(),
                )
              : ListView.separated(
                  itemCount: item.spendings.length,
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('item $index'),
                    );
                  },
                ),
        ),
      );
    });
  }
}

class CyclePageArguments {
  int id;

  CyclePageArguments({
    @required this.id,
  });
}
