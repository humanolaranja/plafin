import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Plafin'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In pt, this message translates to:
  /// **'Planejamento financeiro'**
  String get appTagline;

  /// No description provided for @cyclesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ciclos'**
  String get cyclesTitle;

  /// No description provided for @newCycle.
  ///
  /// In pt, this message translates to:
  /// **'Novo ciclo'**
  String get newCycle;

  /// No description provided for @cyclesEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ciclo ainda'**
  String get cyclesEmptyTitle;

  /// No description provided for @cyclesEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Crie um ciclo a partir do dia em que você recebe seu salário e registre suas receitas e despesas.'**
  String get cyclesEmptyBody;

  /// No description provided for @cycleCreateAction.
  ///
  /// In pt, this message translates to:
  /// **'Criar ciclo'**
  String get cycleCreateAction;

  /// No description provided for @cycleEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar ciclo'**
  String get cycleEditTitle;

  /// No description provided for @cycleCopyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Copiar ciclo'**
  String get cycleCopyTitle;

  /// No description provided for @cycleCopyBody.
  ///
  /// In pt, this message translates to:
  /// **'Os itens serão copiados como não realizados.'**
  String get cycleCopyBody;

  /// No description provided for @cycleDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir este ciclo?'**
  String get cycleDeleteTitle;

  /// No description provided for @cycleDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'O ciclo e todos os seus itens serão removidos.'**
  String get cycleDeleteBody;

  /// No description provided for @cycleDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Ciclo excluído'**
  String get cycleDeleted;

  /// No description provided for @cycleName.
  ///
  /// In pt, this message translates to:
  /// **'Nome (opcional)'**
  String get cycleName;

  /// No description provided for @cycleNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Salário de novembro'**
  String get cycleNameHint;

  /// No description provided for @cycleDate.
  ///
  /// In pt, this message translates to:
  /// **'Data do ciclo'**
  String get cycleDate;

  /// No description provided for @initialBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo inicial'**
  String get initialBalance;

  /// No description provided for @itemDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Item excluído'**
  String get itemDeleted;

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @create.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get create;

  /// No description provided for @copy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @loadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seus dados.'**
  String get loadError;

  /// No description provided for @addItem.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item'**
  String get addItem;

  /// No description provided for @newItemTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo item'**
  String get newItemTitle;

  /// No description provided for @editItemTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar item'**
  String get editItemTitle;

  /// No description provided for @itemName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get itemName;

  /// No description provided for @itemAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get itemAmount;

  /// No description provided for @itemExpense.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get itemExpense;

  /// No description provided for @itemIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get itemIncome;

  /// No description provided for @requiredField.
  ///
  /// In pt, this message translates to:
  /// **'Preenchimento obrigatório'**
  String get requiredField;

  /// No description provided for @amountMustBePositive.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor maior que zero'**
  String get amountMustBePositive;

  /// No description provided for @summaryBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo do ciclo'**
  String get summaryBalance;

  /// No description provided for @summaryIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receitas'**
  String get summaryIncome;

  /// No description provided for @summaryExpenses.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get summaryExpenses;

  /// No description provided for @summaryReceived.
  ///
  /// In pt, this message translates to:
  /// **'Recebido'**
  String get summaryReceived;

  /// No description provided for @summaryPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pago'**
  String get summaryPaid;

  /// No description provided for @summaryPending.
  ///
  /// In pt, this message translates to:
  /// **'A pagar'**
  String get summaryPending;

  /// No description provided for @progressDone.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} realizados'**
  String progressDone(int done, int total);

  /// No description provided for @itemsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Sem itens} =1{1 item} other{{count} itens}}'**
  String itemsCount(int count);

  /// No description provided for @itemsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem itens neste ciclo'**
  String get itemsEmptyTitle;

  /// No description provided for @itemsEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Adicione suas receitas e despesas para acompanhar o saldo.'**
  String get itemsEmptyBody;

  /// No description provided for @markDone.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como realizado'**
  String get markDone;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @currency.
  ///
  /// In pt, this message translates to:
  /// **'Moeda'**
  String get currency;

  /// No description provided for @dataSection.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get dataSection;

  /// No description provided for @exportBackup.
  ///
  /// In pt, this message translates to:
  /// **'Exportar backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Salva todos os seus ciclos em um arquivo JSON.'**
  String get exportBackupSubtitle;

  /// No description provided for @shareBackup.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar backup'**
  String get shareBackup;

  /// No description provided for @importBackup.
  ///
  /// In pt, this message translates to:
  /// **'Importar backup'**
  String get importBackup;

  /// No description provided for @importBackupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Restaura ciclos a partir de um arquivo de backup.'**
  String get importBackupSubtitle;

  /// No description provided for @exportSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Backup salvo.'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o backup.'**
  String get exportFailed;

  /// No description provided for @importPreviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Importar backup'**
  String get importPreviewTitle;

  /// No description provided for @importPreviewBody.
  ///
  /// In pt, this message translates to:
  /// **'O arquivo contém {cycles, plural, =1{1 ciclo} other{{cycles} ciclos}} e {items, plural, =1{1 item} other{{items} itens}}.'**
  String importPreviewBody(int cycles, int items);

  /// No description provided for @importReplace.
  ///
  /// In pt, this message translates to:
  /// **'Substituir tudo'**
  String get importReplace;

  /// No description provided for @importReplaceHelp.
  ///
  /// In pt, this message translates to:
  /// **'Apaga os dados atuais e usa os do arquivo.'**
  String get importReplaceHelp;

  /// No description provided for @importMerge.
  ///
  /// In pt, this message translates to:
  /// **'Mesclar'**
  String get importMerge;

  /// No description provided for @importMergeHelp.
  ///
  /// In pt, this message translates to:
  /// **'Mantém os dados atuais e adiciona os do arquivo. Ciclos com o mesmo identificador são substituídos.'**
  String get importMergeHelp;

  /// No description provided for @importDone.
  ///
  /// In pt, this message translates to:
  /// **'Backup importado.'**
  String get importDone;

  /// No description provided for @importInvalidFile.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo inválido. Escolha um backup do Plafin.'**
  String get importInvalidFile;

  /// No description provided for @importNewerVersion.
  ///
  /// In pt, this message translates to:
  /// **'Esse backup foi criado por uma versão mais nova do Plafin.'**
  String get importNewerVersion;

  /// No description provided for @aboutSection.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get aboutSection;

  /// No description provided for @versionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Versão {version}'**
  String versionLabel(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
