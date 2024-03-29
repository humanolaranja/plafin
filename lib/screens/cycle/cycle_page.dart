import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/entities/cycle.dart';
import 'package:plafin/screens/copy_cycle/copy_cycle_page.dart';
import 'package:plafin/screens/cycle/widgets/CycleFloatingActionButton.dart';
import 'package:plafin/screens/cycle/widgets/CycleWidget.dart';
import 'package:plafin/screens/cycle/widgets/Empty.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/shared/components/CommonAppBar.dart';
import 'package:plafin/shared/components/ConfirmDialog.dart';
import 'package:plafin/shared/utils/formatUtils.dart';

class CyclePage extends StatelessWidget {
  const CyclePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CyclePageArguments args = ModalRoute.of(context).settings.arguments;

    return BlocBuilder<CyclesBloc, CyclesState>(
        builder: (context, cyclesState) {
      int index = args.id;
      Cycle item;

      if (cyclesState.cycles.isEmpty ||
          !cyclesState.cycles.asMap().containsKey(index)) {
        item = Cycle(amount: 0, date: '', spendings: []);
      } else {
        item = cyclesState?.cycles[index];
      }

      return Scaffold(
        appBar: CommonAppBar(title: '${item.date}', actions: <Widget>[
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialog(
                    title: 'Copiar esse ciclo para um novo mês?',
                    content:
                        'Os valores serão mantidos, mas poderão ser editados',
                    cancel: () => Navigator.of(context).pop(),
                    confirm: () => {
                      Navigator.of(context).pop(),
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        isScrollControlled: true,
                        builder: (context) => CopyCyclePage(baseIndex: index),
                      )
                    },
                  );
                },
              );
            },
            child: Icon(
              Icons.content_copy,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialog(
                    title: 'Deseja deletar esse ciclo?',
                    content: 'Essa ação não pode ser desfeita',
                    cancel: () => Navigator.of(context).pop(),
                    confirm: () => {
                      BlocProvider.of<CyclesBloc>(context)
                          .add(DeleteCycleEvent(index: index)),
                      Navigator.of(context).pop(),
                      Navigator.of(context).pop(),
                    },
                  );
                },
              );
            },
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
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
                  separatorBuilder: (BuildContext context, int spentIndex) =>
                      Divider(),
                  itemBuilder: (BuildContext context, int spentIndex) {
                    if (spentIndex == item.spendings.length) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 80),
                        child: ListTile(
                          title: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                                FormatUtils.doubleValueToMoney(item.amount)),
                          ),
                        ),
                      );
                    } else {
                      return CycleWidget(
                        spent: item.spendings[spentIndex],
                        cycleIndex: index,
                        index: spentIndex,
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
