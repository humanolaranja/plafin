import 'package:flutter/material.dart';
import 'package:plafin/shared/components/ConfirmDialog.dart';

class CycleOptions extends StatelessWidget {
  final int index;
  CycleOptions(this.index);

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
                  onTap: () => print('edit $index'),
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
                          print('delete'),
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
