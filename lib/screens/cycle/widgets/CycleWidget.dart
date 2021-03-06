import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/entities/spent.dart';
import 'package:plafin/screens/cycle/widgets/CycleOptions.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';
import 'package:plafin/shared/utils/formatUtils.dart';

class CycleWidget extends StatelessWidget {
  final Spent spent;
  final int index;
  final int cycleIndex;

  CycleWidget({@required this.spent, @required this.cycleIndex, @required this.index});

  _onTapCycle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      isScrollControlled: true,
      builder: (context) => CycleOptions(
        spent: spent,
        cycleIndex: cycleIndex,
        index: index,
      ),
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
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: spent.done,
                      onChanged: (isDone) {
                        print(isDone);
                        BlocProvider.of<CyclesBloc>(context).add(DoneSpentInCycleEvent(cycleIndex: cycleIndex, index: index, done: isDone));
                      },
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        spent.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              FormatUtils.doubleValueToMoney(spent.value),
              style: TextStyle(
                color: spent.income ? Colors.green : Colors.deepOrangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
