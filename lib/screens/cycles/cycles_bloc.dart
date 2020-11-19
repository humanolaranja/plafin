import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:plafin/entities/cycle.dart';
import 'package:plafin/entities/spent.dart';

class CyclesBloc extends HydratedBloc<CyclesEvent, CyclesState> {
  CyclesBloc() : super(CyclesState(cycles: <Cycle>[]));

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
      List<Map> cycles = state.cycles != null ? state.cycles.map((i) => i.toJson()).toList() : <Cycle>[];
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
    if (event is AddSpentToCycleEvent) {
      return _handleAddSpentToCycleEvent(this.state, event);
    }
    if (event is DeleteCycleEvent) {
      return _handleDeleteCycleEvent(this.state, event);
    }
    return Stream.value(this.state);
  }
}

Stream<CyclesState> _handleAddSpentToCycleEvent(CyclesState currentState, AddSpentToCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();
  double value = event.income ? event.value : event.value * -1;

  cycles[event.index].amount = cycles[event.index].amount + value;
  cycles[event.index].spendings.add(Spent(name: event.name, value: event.value, income: event.income));
  newState.cycles = cycles;

  yield newState;
}

Stream<CyclesState> _handleDeleteCycleEvent(CyclesState currentState, DeleteCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();

  cycles.removeAt(event.index);
  newState.cycles = cycles;

  yield newState;
}

Stream<CyclesState> _handleAddCycleEvent(CyclesState currentState, AddCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();
  List<Spent> spendings = <Spent>[];
  if (event.initialAmount > 0) {
    spendings.add(Spent(income: true, name: 'Valor Inicial', value: event.initialAmount));
  }

  cycles.add(Cycle(date: event.date, initialAmount: event.initialAmount, amount: event.amount, spendings: spendings));
  newState.cycles = cycles;

  yield newState;
}

abstract class CyclesEvent {}

class AddCycleEvent extends CyclesEvent {
  String date;
  double initialAmount;
  double amount;

  AddCycleEvent({@required this.date, @required this.initialAmount, @required this.amount});
}

class AddSpentToCycleEvent extends CyclesEvent {
  int index;
  String name;
  double value;
  bool income;

  AddSpentToCycleEvent({@required this.index, @required this.name, @required this.value, @required this.income});
}

class DeleteCycleEvent extends CyclesEvent {
  int index;

  DeleteCycleEvent({@required this.index});
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
