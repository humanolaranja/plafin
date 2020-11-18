import 'package:flutter/material.dart';

class NewSpentPage extends StatefulWidget {
  const NewSpentPage({Key key}) : super(key: key);

  @override
  _NewSpentPageState createState() => _NewSpentPageState();
}

class _NewSpentPageState extends State<NewSpentPage> {
  String name = '';
  double value = 0;
  bool income = false;

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
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextField(
                    onChanged: (newName) {
                      name = newName;
                    },
                  )),
              Container(
                width: double.infinity,
                height: 48,
                child: RaisedButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  child: Text("Create"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
