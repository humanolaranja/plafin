import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  CommonAppBar({Key key, @required this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
