import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plafin/routes.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';

void main() async {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CyclesBloc>(
          create: (BuildContext context) => CyclesBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'PlaFin',
        initialRoute: Routes.homePagePath,
        routes: Routes().getDefault(),
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
          visualDensity: VisualDensity.standard,
          floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.deepOrange),
          buttonColor: Colors.deepOrange,
          toggleableActiveColor: Colors.deepOrange,
          unselectedWidgetColor: Colors.deepOrange,
        ),
      ),
    ),
  );
}
