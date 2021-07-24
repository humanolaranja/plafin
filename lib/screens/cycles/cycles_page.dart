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
    return BlocBuilder<CyclesBloc, CyclesState>(
        builder: (context, cyclesState) {
      BlocProvider.of<CyclesBloc>(context).add(GetCyclesSavedEvent());
      return Scaffold(
        appBar: CommonAppBar(title: "Ciclos"),
        floatingActionButton: CyclesFloatingActionButton(),
        body: SafeArea(
          child: cyclesState.loading
              ? Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: cyclesState?.cycles?.length ?? 0,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    int invertedIndex = cyclesState.cycles.length - 1 - index;
                    Cycle item = cyclesState?.cycles[invertedIndex];
                    return InkWell(
                      onLongPress: () => showBottomSheet(
                          context: context,
                          builder: (context) => NewCyclePage()),
                      onTap: () => Routes().navigateToCyclePage(
                          context, CyclePageArguments(id: invertedIndex)),
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
