import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup_codec.dart';

/// Exporta e importa backups (arquivo JSON) em todas as plataformas.
class BackupService {
  const BackupService();

  static const mimeType = 'application/json';

  /// Compartilhar arquivos não é suportado no Linux e na Web é irregular.
  static bool get canShare =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  static String fileNameFor(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'plafin-backup-${now.year}${two(now.month)}${two(now.day)}.json';
  }

  static Uint8List encodeBytes(BackupData data) =>
      Uint8List.fromList(utf8.encode(BackupCodec.encode(data)));

  /// Salva o backup em um arquivo escolhido pelo usuário (na Web dispara o
  /// download). Retorna `false` se o usuário cancelou.
  Future<bool> saveToFile(BackupData data) async {
    final uri = await FilePicker.saveFile(
      fileName: fileNameFor(DateTime.now()),
      bytes: encodeBytes(data),
      mimeType: mimeType,
    );
    return kIsWeb || uri != null;
  }

  /// Abre a folha de compartilhamento do sistema com o arquivo de backup.
  Future<void> share(BackupData data, {Rect? origin}) async {
    final name = fileNameFor(DateTime.now());
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(encodeBytes(data), mimeType: mimeType, name: name),
        ],
        fileNameOverrides: [name],
        subject: name,
        sharePositionOrigin: origin,
      ),
    );
  }

  /// Pede um arquivo ao usuário e o interpreta. Retorna `null` se cancelou;
  /// lança [BackupFormatException] se o arquivo não for um backup válido.
  Future<BackupData?> pickAndParse() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      throw const BackupFormatException('invalid-json');
    }
    return BackupCodec.decode(text);
  }
}
