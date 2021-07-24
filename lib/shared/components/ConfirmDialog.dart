import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final Function cancel;
  final Function confirm;
  ConfirmDialog(
      {@required this.title,
      @required this.cancel,
      @required this.content,
      @required this.confirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text("Cancelar"),
          onPressed: () => cancel(),
        ),
        TextButton(
          child: Text("Confirmar"),
          onPressed: () => confirm(),
        ),
      ],
    );
  }
}
