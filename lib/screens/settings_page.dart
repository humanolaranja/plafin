import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../cubits/cycles_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../data/backup_codec.dart';
import '../l10n/app_localizations.dart';
import '../services/backup_service.dart';
import '../widgets/common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.backup = const BackupService()});

  final BackupService backup;

  BackupData _currentData(BuildContext context) => BackupData(
    cycles: context.read<CyclesCubit>().state.cycles,
    currency: context.read<SettingsCubit>().state.currency,
  );

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _export(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final data = _currentData(context);
    try {
      final saved = await backup.saveToFile(data);
      if (saved && context.mounted) _toast(context, l10n.exportSuccess);
    } catch (e) {
      debugPrint('Plafin: export failed: $e');
      if (context.mounted) _toast(context, l10n.exportFailed);
    }
  }

  Future<void> _share(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      await backup.share(_currentData(context), origin: origin);
    } catch (e) {
      debugPrint('Plafin: share failed: $e');
      if (context.mounted) _toast(context, l10n.exportFailed);
    }
  }

  Future<void> _import(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final BackupData? data;
    try {
      data = await backup.pickAndParse();
    } on BackupFormatException catch (e) {
      if (context.mounted) {
        _toast(
          context,
          e.code == 'newer-version'
              ? l10n.importNewerVersion
              : l10n.importInvalidFile,
        );
      }
      return;
    } catch (e) {
      debugPrint('Plafin: import failed: $e');
      if (context.mounted) _toast(context, l10n.importInvalidFile);
      return;
    }
    if (data == null || !context.mounted) return;

    final mode = await showDialog<ImportMode>(
      context: context,
      builder: (_) => _ImportDialog(data: data!),
    );
    if (mode == null || !context.mounted) return;

    context.read<CyclesCubit>().importBackup(data.cycles, mode: mode);
    if (mode == ImportMode.replace && data.currency != null) {
      await context.read<SettingsCubit>().setCurrency(data.currency!);
    }
    if (context.mounted) _toast(context, l10n.importDone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>();
    final state = settings.state;

    Widget section(String title, List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );

    Widget labeled(String label, Widget child) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(l10n.settings)),
          ContentSliver(
            bottom: 32,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                section(l10n.appearance, [
                  labeled(
                    l10n.theme,
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(l10n.themeSystem),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(l10n.themeLight),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(l10n.themeDark),
                          ),
                        ],
                        selected: {state.themeMode},
                        onSelectionChanged: (s) =>
                            settings.setThemeMode(s.first),
                      ),
                    ),
                  ),
                  const Divider(),
                  labeled(
                    l10n.language,
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: '',
                            label: Text(l10n.languageSystem),
                          ),
                          const ButtonSegment(
                            value: 'pt',
                            label: Text('Português'),
                          ),
                          const ButtonSegment(
                            value: 'en',
                            label: Text('English'),
                          ),
                        ],
                        selected: {state.locale?.languageCode ?? ''},
                        onSelectionChanged: (s) => settings.setLocale(
                          s.first.isEmpty ? null : Locale(s.first),
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  labeled(
                    l10n.currency,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final code in supportedCurrencies)
                          ChoiceChip(
                            label: Text(code),
                            selected: state.currency == code,
                            onSelected: (_) => settings.setCurrency(code),
                          ),
                      ],
                    ),
                  ),
                ]),
                section(l10n.dataSection, [
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined),
                    title: Text(l10n.exportBackup),
                    subtitle: Text(l10n.exportBackupSubtitle),
                    onTap: () => _export(context),
                  ),
                  if (BackupService.canShare)
                    Builder(
                      builder: (context) => ListTile(
                        leading: const Icon(Icons.ios_share_rounded),
                        title: Text(l10n.shareBackup),
                        onTap: () => _share(context),
                      ),
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.file_upload_outlined),
                    title: Text(l10n.importBackup),
                    subtitle: Text(l10n.importBackupSubtitle),
                    onTap: () => _import(context),
                  ),
                ]),
                section(l10n.aboutSection, [const _AboutTile()]),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        return ListTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: Text('${l10n.appName} · ${l10n.appTagline}'),
          subtitle: version.isEmpty ? null : Text(l10n.versionLabel(version)),
        );
      },
    );
  }
}

class _ImportDialog extends StatelessWidget {
  const _ImportDialog({required this.data});

  final BackupData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget option(
      String title,
      String help,
      ImportMode mode, {
      bool primary = false,
    }) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            primary
                ? FilledButton(
                    onPressed: () => Navigator.of(context).pop(mode),
                    child: Text(title),
                  )
                : OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(mode),
                    child: Text(title),
                  ),
            const SizedBox(height: 4),
            Text(
              help,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Text(l10n.importPreviewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importPreviewBody(data.cycles.length, data.itemCount)),
            option(
              l10n.importMerge,
              l10n.importMergeHelp,
              ImportMode.merge,
              primary: true,
            ),
            option(
              l10n.importReplace,
              l10n.importReplaceHelp,
              ImportMode.replace,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
