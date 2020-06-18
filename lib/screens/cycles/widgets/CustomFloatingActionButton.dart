import 'package:flutter/material.dart';
import 'package:plafin/screens/new_cycle/new_cycle_page.dart';

class CustomFloatingActionButton extends StatelessWidget {
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
          builder: (context) => NewCyclePage(),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
