import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/entities/cycle.dart';
import 'package:plafin/routes.dart';
import 'package:plafin/screens/cycle/cycle_page.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/screens/cycles/widgets/CyclesFloatingActionButton.dart';
import 'package:plafin/screens/new_cycle/new_cycle_page.dart';
import 'package:plafin/shared/components/CommonAppBar.dart';

class CyclesPage extends StatelessWidget {
  const CyclesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CyclesBloc, CyclesState>(builder: (context, cyclesState) {
      return Scaffold(
        appBar: CommonAppBar(title: "Ciclos"),
        floatingActionButton: CyclesFloatingActionButton(),
        body: SafeArea(
          child: ListView.separated(
            reverse: true,
            shrinkWrap: true,
            itemCount: cyclesState?.cycles?.length ?? 0,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              Cycle item = cyclesState?.cycles[index];
              return InkWell(
                onLongPress: () => showBottomSheet(context: context, builder: (context) => NewCyclePage()),
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
