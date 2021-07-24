import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        localizationsDelegates: [GlobalMaterialLocalizations.delegate],
        supportedLocales: [Locale('pt', 'BR')],
        initialRoute: Routes.homePagePath,
        routes: Routes().getDefault(),
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
          visualDensity: VisualDensity.standard,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.dark(
            primary: Colors.deepOrange,
            onPrimary: Colors.white,
          ),
          buttonColor: Colors.deepOrange,
          toggleableActiveColor: Colors.deepOrange,
          unselectedWidgetColor: Colors.deepOrange,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: Colors.deepOrange),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Colors.deepOrange,
              textStyle: TextStyle(color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.deepOrange),
            ),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.deepOrange,
            selectionColor: Colors.deepOrange,
            selectionHandleColor: Colors.deepOrange,
          ),
        ),
      ),
    ),
  );
}
