# Plafin

**Plafin** (Planejamento Financeiro) é um app Flutter para organizar suas finanças em **ciclos**
(normalmente, a data em que você recebe o salário). Em cada ciclo você registra receitas e despesas,
marca o que já foi realizado e acompanha o saldo.

## Funcionalidades

- Ciclos com nome opcional e data; lista ordenada pela data real
- Receitas e despesas por ciclo: criar, editar, excluir (também por deslize), marcar como realizado
- Resumo do ciclo: saldo, receitas, despesas, recebido / pago / a pagar e progresso
- Copiar um ciclo para uma nova data (itens voltam como não realizados) e editar data/nome
- **Desfazer** exclusões de itens e ciclos
- **Backup**: exportar e importar todos os dados em um arquivo JSON (substituir ou mesclar),
  para trocar de aparelho
- Tema claro/escuro/sistema, idiomas pt-BR e inglês, moeda configurável (BRL, USD, EUR, GBP)
- Plataformas: Android, iOS, Web, macOS, Windows e Linux

## Requisitos

- Flutter 3.41.4 (Dart 3.11.1)
- Android: JDK 17 (o projeto fixa o JVM do daemon do Gradle em `android/gradle/gradle-daemon-jvm.properties`,
  pois o Gradle 8.14 não reconhece o JDK 25)

## Como rodar

```bash
flutter pub get
flutter run -d <dispositivo>        # flutter devices lista os disponíveis
flutter test                         # testes unitários e de widget
flutter analyze
flutter build apk --release --split-per-abi
```

## Estrutura

```
lib/
  app.dart, main.dart       # MaterialApp, rotas, aviso global de "Desfazer"
  core/                     # tema (Material 3, claro/escuro) e formatação de moeda/datas
  cubits/                   # CyclesCubit (dados) e SettingsCubit (tema, idioma, moeda)
  data/                     # modelos (valores em centavos, ids estáveis), repositório, codec de backup
  screens/, widgets/        # telas e componentes
  services/backup_service.dart  # exportar/importar arquivo
  l10n/                     # ARB (pt, en) e código gerado (flutter gen-l10n)
tool/generate_icons.py      # gera a marca (PNGs e SVG) a partir de uma única geometria
```

## Dados e backup

Os dados ficam em `SharedPreferences` como JSON (`plafin.data.v2`). O formato do backup tem
`schemaVersion`; o app também lê o formato legado da versão 1 (chave `CYCLES_KEY`) e o migra
automaticamente, mantendo a chave antiga intacta.

```json
{ "app": "plafin", "schemaVersion": 2, "currency": "BRL",
  "cycles": [ { "id": "…", "name": null, "date": "2026-11-05",
                "items": [ { "id": "…", "name": "Salário", "amountCents": 500000, "income": true, "done": false } ] } ] }
```

## Identidade visual

O logo (seta de ciclo em volta de uma moeda serrilhada com um "P") é gerado por
`python3 tool/generate_icons.py` (requer Pillow). Para aplicar nas plataformas:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Publicação

O build `release` do Android ainda usa a chave de debug. Antes de publicar, configure uma chave de upload
(`key.properties` + `signingConfigs` em `android/app/build.gradle.kts`). Package id: `com.plafin.app`.
