import 'package:shared_preferences/shared_preferences.dart';

import 'backup_codec.dart';
import 'cycle.dart';

abstract interface class CyclesRepository {
  Future<List<Cycle>> load();
  Future<void> save(List<Cycle> cycles);
}

/// Persiste os ciclos como JSON em [SharedPreferences].
///
/// Na primeira leitura migra automaticamente o formato legado (chave
/// `CYCLES_KEY` do app antigo), mantendo a chave antiga intacta como backup.
class PrefsCyclesRepository implements CyclesRepository {
  PrefsCyclesRepository(this._prefs);

  static const dataKey = 'plafin.data.v2';
  static const legacyKey = 'CYCLES_KEY';

  final SharedPreferences _prefs;

  @override
  Future<List<Cycle>> load() async {
    final current = _prefs.getString(dataKey);
    if (current != null) return BackupCodec.decode(current).cycles;

    final legacy = _prefs.getString(legacyKey);
    if (legacy == null) return const [];

    final cycles = BackupCodec.decode(legacy).cycles;
    await save(cycles);
    return cycles;
  }

  @override
  Future<void> save(List<Cycle> cycles) async {
    final ok = await _prefs.setString(
      dataKey,
      BackupCodec.encode(BackupData(cycles: cycles)),
    );
    if (!ok) throw StateError('Failed to persist cycles');
  }
}
