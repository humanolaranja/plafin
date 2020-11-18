import 'package:flutter/material.dart';
import 'package:plafin/screens/cycle/cycle_page.dart';
import 'package:plafin/screens/cycles/cycles_page.dart';

class Routes {
  static final String homePagePath = '/';
  static final String cyclePagePath = '/cycle';

  getDefault() {
    return {
      homePagePath: (BuildContext context) => CyclesPage(),
      cyclePagePath: (BuildContext context) => CyclePage(),
    };
  }

  navigateToCyclePage(BuildContext context, CyclePageArguments arguments) {
    Navigator.pushNamed(context, cyclePagePath, arguments: arguments);
  }

  replaceToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, homePagePath);
  }
}
