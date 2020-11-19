import 'package:flutter/material.dart';
import 'package:plafin/screens/new_spent/new_spent_page.dart';

class CycleFloatingActionButton extends StatelessWidget {
  final int index;

  CycleFloatingActionButton(this.index);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          isScrollControlled: true,
          builder: (context) => NewSpentPage(index),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
