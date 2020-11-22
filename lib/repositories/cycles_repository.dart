import 'dart:convert';
import 'package:plafin/entities/cycle.dart';
import 'package:plafin/repositories/base_repository.dart';

class CyclesRepository extends BaseRepository {
  static final CYCLES_KEY = 'CYCLES_KEY';

  Future<bool> saveCycles(List<Cycle> cyclesToBeSaved) async {
    List<Map> cycles = cyclesToBeSaved != null ? cyclesToBeSaved.map((i) => i.toJson()).toList() : <Cycle>[];
    String cyclesJson = json.encode({'cycles': cycles});
    var localSource = await this.getLocalSource();
    return localSource.setString(CYCLES_KEY, cyclesJson);
  }

  Future<List<Cycle>> getCycles() async {
    List<Cycle> cyclesToBeReturned = <Cycle>[];
    var localSource = await this.getLocalSource();

    if (localSource.containsKey(CYCLES_KEY)) {
      String cyclesJson = await localSource.getString(CYCLES_KEY);
      Map<dynamic, dynamic> cycles = jsonDecode(cyclesJson);
      if (cycles.containsKey('cycles')) {
        var items = cycles['cycles'] as List;
        cyclesToBeReturned = items.map((e) => Cycle.fromJson(e)).toList();
      }
    }
    return cyclesToBeReturned;
  }
}
