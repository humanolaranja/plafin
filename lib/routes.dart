import 'package:flutter/material.dart';
import 'package:plafin/screens/cycle/cycle_page.dart';
import 'package:plafin/screens/new_cycle/new_cycle_page.dart';
import 'package:plafin/screens/cycles/cycles_page.dart';

class Routes {
  static final String homePagePath = '/';
  static final String cyclePagePath = '/cycle';
  static final String newCyclePagePath = '/cycle/new';

  getDefault() {
    return {
      homePagePath: (BuildContext context) => CyclesPage(),
      cyclePagePath: (BuildContext context) => CyclePage(),
      newCyclePagePath: (BuildContext context) => NewCyclePage(),
    };
  }

  navigateToCyclePage(BuildContext context, CyclePageArguments arguments) {
    Navigator.pushNamed(context, cyclePagePath, arguments: arguments);
  }

  navigateToNewCyclePage(BuildContext context) {
    Navigator.pushNamed(context, newCyclePagePath);
  }

  replaceToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, homePagePath);
  }
}
