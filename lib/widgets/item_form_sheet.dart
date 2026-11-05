import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../cubits/cycles_cubit.dart';
import '../core/format/format_context.dart';
import '../core/format/money.dart';
import '../data/item.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

/// Formulário de novo item (ou edição quando [item] é informado).
Future<void> showItemForm(
  BuildContext context, {
  required String cycleId,
  Item? item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: context.read<CyclesCubit>(),
      child: _ItemFormSheet(cycleId: cycleId, item: item),
    ),
  );
}

class _ItemFormSheet extends StatefulWidget {
  const _ItemFormSheet({required this.cycleId, this.item});

  final String cycleId;
  final Item? item;

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  TextEditingController? _amount;
  late MoneyInputFormatter _formatter;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _isIncome = widget.item?.isIncome ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amount == null) {
      final money = context.moneyOf(listen: false);
      _formatter = MoneyInputFormatter(money);
      _amount = TextEditingController(
        text: money.format(widget.item?.amountCents ?? 0),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount?.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final item = Item(
      id: widget.item?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      amountCents: MoneyInputFormatter.parseCents(_amount!.text),
      isIncome: _isIncome,
      done: widget.item?.done ?? false,
    );
    context.read<CyclesCubit>().saveItem(widget.cycleId, item);
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<CyclesCubit>().deleteItem(widget.cycleId, widget.item!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final editing = widget.item != null;

    return FormSheet(
      title: editing ? l10n.editItemTitle : l10n.newItemTitle,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    label: Text(l10n.itemExpense),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.arrow_downward_rounded),
                    label: Text(l10n.itemIncome),
                  ),
                ],
                selected: {_isIncome},
                onSelectionChanged: (s) => setState(() => _isIncome = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                autofocus: !editing,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.itemName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [_formatter],
                decoration: InputDecoration(labelText: l10n.itemAmount),
                onFieldSubmitted: (_) => _submit(),
                validator: (v) => MoneyInputFormatter.parseCents(v ?? '') > 0
                    ? null
                    : l10n.amountMustBePositive,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: l10n.save, onPressed: _submit),
        if (editing) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.delete),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
          ),
        ],
      ],
    );
  }
}
