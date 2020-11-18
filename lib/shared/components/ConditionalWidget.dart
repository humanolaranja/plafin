import 'package:flutter/material.dart';

class ConditionalWidget extends StatelessWidget {
  final bool render;
  final Widget child;

  ConditionalWidget(this.render, {Key key, @required this.child}) : super(key: key);

  Widget build(BuildContext context) {
    if (this.render) {
      return child;
    }

    return Container();
  }
}
