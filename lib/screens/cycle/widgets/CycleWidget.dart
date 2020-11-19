import 'package:flutter/material.dart';
import 'package:plafin/entities/spent.dart';
import 'package:plafin/screens/cycle/widgets/CycleOptions.dart';
import 'package:plafin/shared/utils/formatUtils.dart';

class CycleWidget extends StatelessWidget {
  final Spent spent;
  final int index;
  CycleWidget(this.spent, this.index);

  _onTapCycle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      isScrollControlled: true,
      builder: (context) => CycleOptions(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onTapCycle(context),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                spent.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              FormatUtils.doubleValueToMoney(spent.value),
              style: TextStyle(color: spent.income ? Colors.green : Colors.deepOrangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}
