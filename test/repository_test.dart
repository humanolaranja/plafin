import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:plafin/data/cycles_repository.dart';
import 'package:plafin/data/cycle.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'migrates legacy CYCLES_KEY on first load and keeps the old key',
    () async {
      final legacy = jsonEncode({
        'cycles': [
          {
            'date': '05/11/2020',
            'amount': 100.0,
            'spendings': [
              {
                'name': 'Saldo Inicial',
                'value': 100.0,
                'income': true,
                'done': false,
              },
            ],
          },
        ],
      });
      SharedPreferences.setMockInitialValues({
        PrefsCyclesRepository.legacyKey: legacy,
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsCyclesRepository(prefs);

      final cycles = await repo.load();
      expect(cycles.single.balanceCents, 10000);
      expect(prefs.getString(PrefsCyclesRepository.dataKey), isNotNull);
      expect(prefs.getString(PrefsCyclesRepository.legacyKey), legacy);

      // segunda carga lê o formato novo, com os mesmos ids
      expect((await repo.load()).single.id, cycles.single.id);
    },
  );

  test('does not re-migrate after the user emptied everything', () async {
    SharedPreferences.setMockInitialValues({
      PrefsCyclesRepository.legacyKey: jsonEncode({
        'cycles': [
          {'date': '05/11/2020', 'amount': 0, 'spendings': []},
        ],
      }),
    });
    final repo = PrefsCyclesRepository(await SharedPreferences.getInstance());
    expect(await repo.load(), hasLength(1));
    await repo.save(const <Cycle>[]);
    expect(await repo.load(), isEmpty);
  });

  test('fresh install loads empty', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = PrefsCyclesRepository(await SharedPreferences.getInstance());
    expect(await repo.load(), isEmpty);
  });
}
