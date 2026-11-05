// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Plafin';

  @override
  String get appTagline => 'Financial planning';

  @override
  String get cyclesTitle => 'Cycles';

  @override
  String get newCycle => 'New cycle';

  @override
  String get cyclesEmptyTitle => 'No cycles yet';

  @override
  String get cyclesEmptyBody =>
      'Create a cycle starting on the day you get paid and track your income and expenses.';

  @override
  String get cycleCreateAction => 'Create cycle';

  @override
  String get cycleEditTitle => 'Edit cycle';

  @override
  String get cycleCopyTitle => 'Copy cycle';

  @override
  String get cycleCopyBody => 'Items will be copied as not done.';

  @override
  String get cycleDeleteTitle => 'Delete this cycle?';

  @override
  String get cycleDeleteBody =>
      'The cycle and all of its items will be removed.';

  @override
  String get cycleDeleted => 'Cycle deleted';

  @override
  String get cycleName => 'Name (optional)';

  @override
  String get cycleNameHint => 'E.g. November salary';

  @override
  String get cycleDate => 'Cycle date';

  @override
  String get initialBalance => 'Initial balance';

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get undo => 'Undo';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get copy => 'Copy';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Try again';

  @override
  String get loadError => 'We couldn\'t load your data.';

  @override
  String get addItem => 'Add item';

  @override
  String get newItemTitle => 'New item';

  @override
  String get editItemTitle => 'Edit item';

  @override
  String get itemName => 'Name';

  @override
  String get itemAmount => 'Amount';

  @override
  String get itemExpense => 'Expense';

  @override
  String get itemIncome => 'Income';

  @override
  String get requiredField => 'Required field';

  @override
  String get amountMustBePositive => 'Enter an amount greater than zero';

  @override
  String get summaryBalance => 'Cycle balance';

  @override
  String get summaryIncome => 'Income';

  @override
  String get summaryExpenses => 'Expenses';

  @override
  String get summaryReceived => 'Received';

  @override
  String get summaryPaid => 'Paid';

  @override
  String get summaryPending => 'To pay';

  @override
  String progressDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get itemsEmptyTitle => 'No items in this cycle';

  @override
  String get itemsEmptyBody =>
      'Add your income and expenses to keep track of your balance.';

  @override
  String get markDone => 'Mark as done';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get currency => 'Currency';

  @override
  String get dataSection => 'Data';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupSubtitle => 'Saves all your cycles to a JSON file.';

  @override
  String get shareBackup => 'Share backup';

  @override
  String get importBackup => 'Import backup';

  @override
  String get importBackupSubtitle => 'Restores cycles from a backup file.';

  @override
  String get exportSuccess => 'Backup saved.';

  @override
  String get exportFailed => 'Couldn\'t save the backup.';

  @override
  String get importPreviewTitle => 'Import backup';

  @override
  String importPreviewBody(int cycles, int items) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: '$cycles cycles',
      one: '1 cycle',
    );
    String _temp1 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items items',
      one: '1 item',
    );
    return 'The file contains $_temp0 and $_temp1.';
  }

  @override
  String get importReplace => 'Replace everything';

  @override
  String get importReplaceHelp =>
      'Deletes current data and uses the file\'s data.';

  @override
  String get importMerge => 'Merge';

  @override
  String get importMergeHelp =>
      'Keeps current data and adds the file\'s data. Cycles with the same identifier are replaced.';

  @override
  String get importDone => 'Backup imported.';

  @override
  String get importInvalidFile => 'Invalid file. Choose a Plafin backup.';

  @override
  String get importNewerVersion =>
      'This backup was created by a newer version of Plafin.';

  @override
  String get aboutSection => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get homeCurrentCycle => 'Current cycle';

  @override
  String get homeWelcomeTitle => 'Plan your next cycle';

  @override
  String get homeWelcomeBody =>
      'Organize income and expenses starting from the day you get paid.';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String cyclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cycles',
      one: '1 cycle',
      zero: 'No cycles',
    );
    return '$_temp0';
  }

  @override
  String get newCycleHint => 'Start from payday';

  @override
  String get homeLastCycle => 'Last cycle';

  @override
  String get sortItems => 'Sort items';

  @override
  String get sortIncomeFirst => 'Income on top';

  @override
  String get sortPendingFirst => 'Pending before done';

  @override
  String get sortAmountDesc => 'Highest to lowest amount';

  @override
  String get itemsSorted => 'Items sorted';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get sortExpensesFirst => 'Expenses on top';

  @override
  String get sortAmountAsc => 'Lowest to highest amount';
}
