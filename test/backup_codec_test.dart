import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:plafin/data/backup_codec.dart';
import 'package:plafin/data/cycle.dart';
import 'package:plafin/data/item.dart';

void main() {
  group('v2 round-trip', () {
    test('export -> import preserves everything', () {
      final cycles = [
        Cycle(
          id: 'c1',
          name: 'Novembro',
          date: DateTime(2026, 11, 5),
          items: const [
            Item(
              id: 'i1',
              name: 'Salário',
              amountCents: 500000,
              isIncome: true,
            ),
            Item(
              id: 'i2',
              name: 'Aluguel',
              amountCents: 150050,
              isIncome: false,
              done: true,
            ),
          ],
        ),
        Cycle(id: 'c2', date: DateTime(2026, 12, 5)),
      ];
      final json = BackupCodec.encode(
        BackupData(cycles: cycles, currency: 'BRL'),
      );
      final decoded = BackupCodec.decode(json);

      expect(decoded.cycles, cycles);
      expect(decoded.currency, 'BRL');
      expect(decoded.schemaVersion, kSchemaVersion);
      expect(decoded.itemCount, 2);
    });

    test('rejects newer versions and garbage', () {
      expect(
        () => BackupCodec.decode('{"schemaVersion": 99, "cycles": []}'),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.code,
            'code',
            'newer-version',
          ),
        ),
      );
      expect(
        () => BackupCodec.decode('not json'),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.code,
            'code',
            'invalid-json',
          ),
        ),
      );
      expect(
        () => BackupCodec.decode('[1,2]'),
        throwsA(isA<BackupFormatException>()),
      );
      expect(
        () => BackupCodec.decode('{"schemaVersion": 2, "cycles": [{"id": 1}]}'),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  group('legacy (v1) migration', () {
    final legacy = jsonEncode({
      'cycles': [
        {
          'date': '05/11/2020',
          'amount': 1234.5,
          'spendings': [
            {
              'name': 'Saldo Inicial',
              'value': 1000.0,
              'income': true,
              'done': false,
            },
            {'name': 'Aluguel', 'value': 0.1, 'income': false, 'done': true},
            {'name': 'Luz', 'value': 3, 'income': false, 'done': null},
            {'name': 'Quebrado', 'value': null, 'income': false, 'done': false},
          ],
        },
        {'date': '31/02/2020', 'amount': 0, 'spendings': []},
        {'date': '01/12/2020', 'amount': 0},
      ],
    });

    test('converts dates, cents and nulls; skips invalid entries', () {
      final data = BackupCodec.decode(legacy);
      expect(data.schemaVersion, 1);
      expect(data.cycles, hasLength(2)); // 31/02 descartado
      final c = data.cycles.first;
      expect(c.date, DateTime(2020, 11, 5));
      expect(c.items.map((i) => i.amountCents), [100000, 10, 300]);
      expect(c.items[0].isIncome, isTrue);
      expect(c.items[1].done, isTrue);
      expect(c.items[2].done, isFalse); // null -> false
      expect(c.balanceCents, 100000 - 10 - 300);
      expect(data.cycles.last.items, isEmpty);
    });

    test(
      'ids are deterministic so re-importing merges instead of duplicating',
      () {
        final a = BackupCodec.decode(legacy);
        final b = BackupCodec.decode(legacy);
        expect(a.cycles.map((c) => c.id), b.cycles.map((c) => c.id));
        expect(a.cycles.first.items.map((i) => i.id).toSet(), hasLength(3));
      },
    );
  });

  test('Cycle totals are derived from items', () {
    final c = Cycle(
      id: 'c',
      date: DateTime(2026, 1, 1),
      items: const [
        Item(id: '1', name: 'a', amountCents: 1000, isIncome: true, done: true),
        Item(id: '2', name: 'b', amountCents: 300, isIncome: false, done: true),
        Item(id: '3', name: 'c', amountCents: 200, isIncome: false),
      ],
    );
    expect(c.incomeCents, 1000);
    expect(c.expenseCents, 500);
    expect(c.balanceCents, 500);
    expect(c.receivedCents, 1000);
    expect(c.paidCents, 300);
    expect(c.pendingExpenseCents, 200);
    expect(c.doneCount, 2);
    expect(c.progress, closeTo(2 / 3, 1e-9));
  });
}
