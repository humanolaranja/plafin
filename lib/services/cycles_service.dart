import 'package:plafin/entities/cycle.dart';
import 'package:plafin/repositories/cycles_repository.dart';

class CyclesService {
  CyclesRepository _cyclesRepository;

  CyclesService({CyclesRepository cyclesRepository}) {
    this._cyclesRepository = cyclesRepository ?? CyclesRepository();
  }

  Future<bool> saveCycles(List<Cycle> cycles) {
    return this._cyclesRepository.saveCycles(cycles);
  }

  Future<List<Cycle>> getCycles() {
    return this._cyclesRepository.getCycles();
  }
}
