// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Plafin';

  @override
  String get appTagline => 'Planejamento Financeiro';

  @override
  String get cyclesTitle => 'Ciclos';

  @override
  String get newCycle => 'Novo ciclo';

  @override
  String get cyclesEmptyTitle => 'Nenhum ciclo ainda';

  @override
  String get cyclesEmptyBody =>
      'Crie um ciclo a partir do dia em que você recebe seu salário e registre suas receitas e despesas.';

  @override
  String get cycleCreateAction => 'Criar ciclo';

  @override
  String get cycleEditTitle => 'Editar ciclo';

  @override
  String get cycleCopyTitle => 'Copiar ciclo';

  @override
  String get cycleCopyBody => 'Os itens serão copiados como não realizados.';

  @override
  String get cycleDeleteTitle => 'Excluir este ciclo?';

  @override
  String get cycleDeleteBody =>
      'O ciclo e todos os seus itens serão removidos.';

  @override
  String get cycleDeleted => 'Ciclo excluído';

  @override
  String get cycleName => 'Nome (opcional)';

  @override
  String get cycleNameHint => 'Ex.: Salário de novembro';

  @override
  String get cycleDate => 'Data do ciclo';

  @override
  String get initialBalance => 'Saldo inicial';

  @override
  String get itemDeleted => 'Item excluído';

  @override
  String get undo => 'Desfazer';

  @override
  String get save => 'Salvar';

  @override
  String get create => 'Criar';

  @override
  String get copy => 'Copiar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Fechar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get loadError => 'Não foi possível carregar seus dados.';

  @override
  String get addItem => 'Adicionar item';

  @override
  String get newItemTitle => 'Novo item';

  @override
  String get editItemTitle => 'Editar item';

  @override
  String get itemName => 'Nome';

  @override
  String get itemAmount => 'Valor';

  @override
  String get itemExpense => 'Despesa';

  @override
  String get itemIncome => 'Receita';

  @override
  String get requiredField => 'Preenchimento obrigatório';

  @override
  String get amountMustBePositive => 'Informe um valor maior que zero';

  @override
  String get summaryBalance => 'Saldo do ciclo';

  @override
  String get summaryIncome => 'Receitas';

  @override
  String get summaryExpenses => 'Despesas';

  @override
  String get summaryReceived => 'Recebido';

  @override
  String get summaryPaid => 'Pago';

  @override
  String get summaryPending => 'A pagar';

  @override
  String progressDone(int done, int total) {
    return '$done de $total realizados';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Sem itens',
    );
    return '$_temp0';
  }

  @override
  String get itemsEmptyTitle => 'Sem itens neste ciclo';

  @override
  String get itemsEmptyBody =>
      'Adicione suas receitas e despesas para acompanhar o saldo.';

  @override
  String get markDone => 'Marcar como realizado';

  @override
  String get settings => 'Configurações';

  @override
  String get appearance => 'Aparência';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get currency => 'Moeda';

  @override
  String get dataSection => 'Dados';

  @override
  String get exportBackup => 'Exportar backup';

  @override
  String get exportBackupSubtitle =>
      'Salva todos os seus ciclos em um arquivo JSON.';

  @override
  String get shareBackup => 'Compartilhar backup';

  @override
  String get importBackup => 'Importar backup';

  @override
  String get importBackupSubtitle =>
      'Restaura ciclos a partir de um arquivo de backup.';

  @override
  String get exportSuccess => 'Backup salvo.';

  @override
  String get exportFailed => 'Não foi possível salvar o backup.';

  @override
  String get importPreviewTitle => 'Importar backup';

  @override
  String importPreviewBody(int cycles, int items) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: '$cycles ciclos',
      one: '1 ciclo',
      zero: '0 ciclos',
    );
    String _temp1 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items itens',
      one: '1 item',
      zero: '0 itens',
    );
    return 'O arquivo contém $_temp0 e $_temp1.';
  }

  @override
  String get importReplace => 'Substituir tudo';

  @override
  String get importReplaceHelp => 'Apaga os dados atuais e usa os do arquivo.';

  @override
  String get importMerge => 'Mesclar';

  @override
  String get importMergeHelp =>
      'Mantém os dados atuais e adiciona os do arquivo. Ciclos com o mesmo identificador são substituídos.';

  @override
  String get importDone => 'Backup importado.';

  @override
  String get importInvalidFile =>
      'Arquivo inválido. Escolha um backup do Plafin.';

  @override
  String get importNewerVersion =>
      'Esse backup foi criado por uma versão mais nova do Plafin.';

  @override
  String get aboutSection => 'Sobre';

  @override
  String versionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get homeCurrentCycle => 'Ciclo atual';

  @override
  String get homeWelcomeTitle => 'Planeje o seu próximo ciclo';

  @override
  String get homeWelcomeBody =>
      'Organize receitas e despesas a partir do dia em que você recebe.';

  @override
  String get timelineTitle => 'Linha do tempo';

  @override
  String cyclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ciclos',
      one: '1 ciclo',
      zero: 'Nenhum ciclo',
    );
    return '$_temp0';
  }

  @override
  String get newCycleHint => 'Comece a partir do dia do pagamento';

  @override
  String get homeLastCycle => 'Último ciclo';

  @override
  String get sortItems => 'Ordenar itens';

  @override
  String get sortIncomeFirst => 'Receitas no topo';

  @override
  String get sortPendingFirst => 'Pendentes antes dos realizados';

  @override
  String get sortAmountDesc => 'Maior para menor valor';

  @override
  String get itemsSorted => 'Itens ordenados';

  @override
  String get dragToReorder => 'Arrastar para reordenar';

  @override
  String get sortExpensesFirst => 'Despesas no topo';

  @override
  String get sortAmountAsc => 'Menor para maior valor';
}
