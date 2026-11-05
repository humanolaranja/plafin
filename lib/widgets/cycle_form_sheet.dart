import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../cubits/cycles_cubit.dart';
import '../core/format/format_context.dart';
import '../core/format/money.dart';
import '../data/cycle.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

enum CycleFormMode { create, edit, copy }

/// Abre o formulário de ciclo. Retorna o id do ciclo criado/copiado/editado,
/// ou `null` se o usuário cancelou.
Future<String?> showCycleForm(
  BuildContext context, {
  required CycleFormMode mode,
  Cycle? cycle,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: context.read<CyclesCubit>(),
      child: _CycleFormSheet(mode: mode, cycle: cycle),
    ),
  );
}

class _CycleFormSheet extends StatefulWidget {
  const _CycleFormSheet({required this.mode, this.cycle});

  final CycleFormMode mode;
  final Cycle? cycle;

  @override
  State<_CycleFormSheet> createState() => _CycleFormSheetState();
}

class _CycleFormSheetState extends State<_CycleFormSheet> {
  late final TextEditingController _name;
  TextEditingController? _balance;
  late DateTime _date;
  MoneyInputFormatter? _formatter;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.cycle?.name ?? '');
    final today = DateUtils.dateOnly(DateTime.now());
    _date = widget.mode == CycleFormMode.edit ? widget.cycle!.date : today;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.mode == CycleFormMode.create && _balance == null) {
      final money = context.moneyOf(listen: false);
      _formatter = MoneyInputFormatter(money);
      _balance = TextEditingController(text: money.format(0));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _balance?.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = DateUtils.dateOnly(picked));
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CyclesCubit>();
    final name = _name.text;
    final String id;
    switch (widget.mode) {
      case CycleFormMode.create:
        id = const Uuid().v4();
        cubit.createCycle(
          id: id,
          date: _date,
          name: name,
          initialBalanceCents: MoneyInputFormatter.parseCents(_balance!.text),
          initialBalanceLabel: l10n.initialBalance,
        );
      case CycleFormMode.edit:
        id = widget.cycle!.id;
        cubit.updateCycle(id: id, date: _date, name: name);
      case CycleFormMode.copy:
        id = const Uuid().v4();
        cubit.copyCycle(
          sourceId: widget.cycle!.id,
          newId: id,
          date: _date,
          name: name,
        );
    }
    Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final title = switch (widget.mode) {
      CycleFormMode.create => l10n.newCycle,
      CycleFormMode.edit => l10n.cycleEditTitle,
      CycleFormMode.copy => l10n.cycleCopyTitle,
    };
    final action = switch (widget.mode) {
      CycleFormMode.create => l10n.create,
      CycleFormMode.edit => l10n.save,
      CycleFormMode.copy => l10n.copy,
    };

    return FormSheet(
      title: title,
      children: [
        if (widget.mode == CycleFormMode.copy) ...[
          Text(
            l10n.cycleCopyBody,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.cycleName,
            hintText: l10n.cycleNameHint,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _pickDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.cycleDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(context.formatDate(_date)),
          ),
        ),
        if (_balance != null) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _balance,
            keyboardType: TextInputType.number,
            inputFormatters: [_formatter!],
            decoration: InputDecoration(labelText: l10n.initialBalance),
          ),
        ],
        const SizedBox(height: 24),
        PrimaryButton(label: action, onPressed: _submit),
      ],
    );
  }
}
