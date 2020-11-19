import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/entities/cycle.dart';
import 'package:plafin/entities/spent.dart';
import 'package:plafin/screens/cycle/widgets/CycleFloatingActionButton.dart';
import 'package:plafin/screens/cycle/widgets/Empty.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/shared/components/CommonAppBar.dart';
import 'package:plafin/shared/utils/formatUtils.dart';

class CyclePage extends StatelessWidget {
  const CyclePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CyclePageArguments args = ModalRoute.of(context).settings.arguments;

    return BlocBuilder<CyclesBloc, CyclesState>(builder: (context, cyclesState) {
      int index = args.id;
      Cycle item;

      if (cyclesState.cycles.isEmpty || !cyclesState.cycles.asMap().containsKey(index)) {
        item = Cycle(amount: 0, date: '', initialAmount: 0, spendings: []);
      } else {
        item = cyclesState?.cycles[index];
      }
      return Scaffold(
        appBar: CommonAppBar(title: '${item.date}', actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              BlocProvider.of<CyclesBloc>(context).add(DeleteCycleEvent(index: index));
              Navigator.of(context).pop();
            },
            child: Icon(Icons.delete),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ]),
        floatingActionButton: CycleFloatingActionButton(index),
        body: SafeArea(
          child: item.spendings.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: Empty(),
                )
              : ListView.separated(
                  itemCount: item.spendings.length + 1,
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == item.spendings.length) {
                      return ListTile(
                        title: Container(
                          alignment: Alignment.centerRight,
                          child: Text(FormatUtils.doubleValueToMoney(item.amount)),
                        ),
                      );
                    } else {
                      Spent spent = item.spendings[index];
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(spent.name),
                            Text(
                              FormatUtils.doubleValueToMoney(spent.value),
                              style: TextStyle(color: spent.income ? Colors.green : Colors.deepOrangeAccent),
                            ),
                          ],
                        ),
                      );
                    }
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
