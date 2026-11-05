import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'cycle.dart';
import 'item.dart';

/// Versão atual do formato de dados / backup.
const int kSchemaVersion = 2;

/// Conteúdo completo de um backup do Plafin.
class BackupData {
  const BackupData({
    required this.cycles,
    this.currency,
    this.exportedAt,
    this.schemaVersion = kSchemaVersion,
  });

  final List<Cycle> cycles;

  /// Código ISO 4217 (ex.: `BRL`). `null` para dados legados (v1).
  final String? currency;
  final DateTime? exportedAt;
  final int schemaVersion;

  int get itemCount => cycles.fold(0, (s, c) => s + c.items.length);
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.code);

  /// `invalid-json`, `invalid-structure` ou `newer-version`.
  final String code;

  @override
  String toString() => 'BackupFormatException: $code';
}

/// Converte entre [BackupData] e JSON (v2), e lê o formato legado (v1) do
/// app antigo (`{"cycles":[{"date":"dd/MM/yyyy","amount":..,"spendings":[..]}]}`).
class BackupCodec {
  const BackupCodec._();

  static const _uuid = Uuid();

  static String encode(BackupData data) {
    final map = {
      'app': 'plafin',
      'schemaVersion': kSchemaVersion,
      'exportedAt': (data.exportedAt ?? DateTime.now())
          .toUtc()
          .toIso8601String(),
      if (data.currency != null) 'currency': data.currency,
      'cycles': data.cycles.map((c) => c.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static BackupData decode(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const BackupFormatException('invalid-json');
    }
    if (root is! Map) throw const BackupFormatException('invalid-structure');
    final map = Map<String, dynamic>.from(root);

    final version = map['schemaVersion'];
    try {
      if (version == null) return _decodeLegacy(map);
      if (version is! int || version < 2) {
        throw const BackupFormatException('invalid-structure');
      }
      if (version > kSchemaVersion) {
        throw const BackupFormatException('newer-version');
      }
      return _decodeV2(map);
    } on BackupFormatException {
      rethrow;
    } catch (_) {
      throw const BackupFormatException('invalid-structure');
    }
  }

  static BackupData _decodeV2(Map<String, dynamic> map) {
    final cycles = <Cycle>[
      for (final c in (map['cycles'] as List))
        Cycle.fromJson(Map<String, dynamic>.from(c as Map)),
    ];
    final exported = map['exportedAt'] as String?;
    return BackupData(
      cycles: cycles,
      currency: map['currency'] as String?,
      exportedAt: exported == null ? null : DateTime.tryParse(exported),
    );
  }

  // --- legado (v1) ---------------------------------------------------------

  static BackupData _decodeLegacy(Map<String, dynamic> map) {
    final raw = map['cycles'];
    if (raw is! List) throw const BackupFormatException('invalid-structure');

    final cycles = <Cycle>[];
    for (var ci = 0; ci < raw.length; ci++) {
      final c = raw[ci];
      if (c is! Map) continue;
      final date = _parseLegacyDate(c['date']);
      if (date == null) {
        debugPrint('Plafin: ciclo legado $ci ignorado (data inválida)');
        continue;
      }
      final items = <Item>[];
      final spendings = c['spendings'];
      if (spendings is List) {
        for (var ii = 0; ii < spendings.length; ii++) {
          final s = spendings[ii];
          if (s is! Map || s['value'] is! num) continue;
          final name = (s['name'] ?? '').toString();
          items.add(
            Item(
              // Ids determinísticos: reimportar o mesmo arquivo legado mescla
              // em vez de duplicar.
              id: _uuid.v5(Namespace.url.value, 'plafin-legacy:$ci:$ii:$name'),
              name: name,
              amountCents: ((s['value'] as num) * 100).round().abs(),
              isIncome: s['income'] == true,
              done: s['done'] == true,
            ),
          );
        }
      }
      cycles.add(
        Cycle(
          id: _uuid.v5(Namespace.url.value, 'plafin-legacy:$ci:${c['date']}'),
          date: date,
          items: items,
        ),
      );
    }
    return BackupData(cycles: cycles, schemaVersion: 1);
  }

  static DateTime? _parseLegacyDate(Object? value) {
    final parts = value.toString().split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    final date = DateTime(y, m, d);
    // Rejeita datas "roladas" (ex.: 31/02).
    if (date.year != y || date.month != m || date.day != d) return null;
    return date;
  }
}
