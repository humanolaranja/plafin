import 'package:flutter/material.dart';
import 'package:plafin/shared/components/CommonAppBar.dart';

class CyclePage extends StatelessWidget {
  const CyclePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CyclePageArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: CommonAppBar(title: '${args.id}'),
      body: SafeArea(
        child: ListView.separated(
          itemCount: 2,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text('item $index'),
            );
          },
        ),
      ),
    );
  }
}

class CyclePageArguments {
  int id;

  CyclePageArguments({
    @required this.id,
  });
}
