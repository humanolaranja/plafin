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
    if (event is DeleteSpentInCycleEvent) {
      return _handleDeleteSpentInCycleEvent(this.state, event);
    }
    if (event is EditSpentInCycleEvent) {
      return _handleEditSpentInCycleEvent(this.state, event);
    }
    if (event is DoneSpentInCycleEvent) {
      return _handleDoneSpentInCycleEvent(this.state, event);
    }
    return Stream.value(this.state);
  }
}

Stream<CyclesState> _handleAddSpentToCycleEvent(CyclesState currentState, AddSpentToCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();
  double value = event.income ? event.value : event.value * -1;

  cycles[event.index].amount = cycles[event.index].amount + value;
  cycles[event.index].spendings.add(Spent(name: event.name, value: event.value, income: event.income, done: false));
  newState.cycles = cycles;

  yield newState;
}

Stream<CyclesState> _handleDeleteSpentInCycleEvent(CyclesState currentState, DeleteSpentInCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();
  Spent spent = cycles[event.cycleIndex].spendings[event.index];
  double value = spent.income ? spent.value : spent.value * -1;

  cycles[event.cycleIndex].amount = cycles[event.cycleIndex].amount - value;
  cycles[event.cycleIndex].spendings.removeAt(event.index);

  if (cycles[event.cycleIndex].spendings.isEmpty) {
    cycles[event.cycleIndex].amount = 0;
  }

  newState.cycles = cycles;

  yield newState;
}

Stream<CyclesState> _handleEditSpentInCycleEvent(CyclesState currentState, EditSpentInCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();
  Spent spent = cycles[event.cycleIndex].spendings[event.index];
  double oldValue = spent.income ? spent.value : spent.value * -1;
  double newValue = event.income ? event.value : event.value * -1;

  cycles[event.cycleIndex].amount = cycles[event.cycleIndex].amount - oldValue;
  cycles[event.cycleIndex].amount = cycles[event.cycleIndex].amount + newValue;
  cycles[event.cycleIndex].spendings[event.index].income = event.income;
  cycles[event.cycleIndex].spendings[event.index].name = event.name;
  cycles[event.cycleIndex].spendings[event.index].value = event.value;
  newState.cycles = cycles;

  yield newState;
}

Stream<CyclesState> _handleDoneSpentInCycleEvent(CyclesState currentState, DoneSpentInCycleEvent event) async* {
  CyclesState newState = currentState.cloneAs(CyclesState());
  List<Cycle> cycles = newState.cycles.toList();

  cycles[event.cycleIndex].spendings[event.index].done = event.done;
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
  if (event.amount > 0) {
    spendings.add(Spent(income: true, name: 'Saldo Inicial', value: event.amount, done: false));
  }

  cycles.add(Cycle(date: event.date, amount: event.amount, spendings: spendings));
  newState.cycles = cycles;

  yield newState;
}

abstract class CyclesEvent {}

class AddCycleEvent extends CyclesEvent {
  String date;
  double amount;

  AddCycleEvent({@required this.date, @required this.amount});
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

class DeleteSpentInCycleEvent extends CyclesEvent {
  int cycleIndex;
  int index;

  DeleteSpentInCycleEvent({@required this.cycleIndex, @required this.index});
}

class EditSpentInCycleEvent extends CyclesEvent {
  int cycleIndex;
  int index;
  String name;
  double value;
  bool income;

  EditSpentInCycleEvent({@required this.cycleIndex, @required this.index, @required this.name, @required this.value, @required this.income});
}

class DoneSpentInCycleEvent extends CyclesEvent {
  int cycleIndex;
  int index;
  bool done;

  DoneSpentInCycleEvent({@required this.cycleIndex, @required this.index, @required this.done});
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
