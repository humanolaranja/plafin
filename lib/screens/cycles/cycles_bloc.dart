import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:plafin/entities/cycle.dart';

class CyclesBloc extends HydratedBloc<CyclesEvent, CyclesState> {
  CyclesBloc() : super(CyclesState(cycles: []));

  @override
  CyclesState fromJson(Map<dynamic, dynamic> json) {
    try {
      CyclesState cyclesState = CyclesState();
      if (json.containsKey('cycles')) {
        var items = json['cycles'] as List;
        cyclesState.cycles = items.map((e) => Cycle.fromJson(e)).toList();
      }

      return cyclesState;
    } catch (_) {
      print(_);
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson(CyclesState state) {
    try {
      List<Map> cycles = state.cycles != null ? state.cycles.map((i) => i.toJson()).toList() : [];
      return {'cycles': cycles};
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<CyclesState> mapEventToState(CyclesEvent event) {
    if (event is AddCycleEvent) {
      return _handleAddCycleEvent(this.state, event);
    }
    return Stream.value(this.state);
  }
}

Stream<CyclesState> _handleAddCycleEvent(CyclesState currentState, AddCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();

  cycles.add(Cycle(date: event.date, initialMoney: event.initialMoney, spendings: []));
  newState.cycles = cycles;

  yield newState;
}

abstract class CyclesEvent {}

class AddCycleEvent extends CyclesEvent {
  String date;
  double initialMoney;
  AddCycleEvent({@required this.date, @required this.initialMoney});
}

class CyclesState {
  List<Cycle> cycles;

  CyclesState({
    this.cycles,
  });

  T cloneAs<T extends CyclesState>(T instance) {
    instance.cycles = this.cycles;

    return instance;
  }
}
