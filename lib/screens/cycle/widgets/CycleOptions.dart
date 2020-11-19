import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/shared/components/ConfirmDialog.dart';

class CycleOptions extends StatelessWidget {
  final int cycleIndex;
  final int index;
  CycleOptions({@required this.cycleIndex, @required this.index});

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: double.infinity,
                height: 48,
                child: InkWell(
                  onTap: () => print('edit $index in cycle $cycleIndex'),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.edit),
                        Text("Editar"),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 48,
                child: InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmDialog(
                        title: 'Deseja deletar esse ciclo?',
                        content: 'Essa ação não pode ser desfeita',
                        cancel: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                        },
                        confirm: () => {
                          BlocProvider.of<CyclesBloc>(context).add(
                            DeleteSpentInCycleEvent(index: index, cycleIndex: cycleIndex),
                          ),
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                        },
                      );
                    },
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.delete),
                        Text("Deletar"),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
