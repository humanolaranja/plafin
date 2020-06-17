import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:plafin/routes.dart';
import 'package:plafin/screens/cycles/cycles_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = await HydratedBlocDelegate.build();

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
      ),
    ),
  );
}