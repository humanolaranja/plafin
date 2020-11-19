import 'package:flutter/material.dart';
import 'package:plafin/screens/new_edit_spent/new_edit_spent_page.dart';

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
          builder: (context) => NewEditSpentPage(cycleIndex: index),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
