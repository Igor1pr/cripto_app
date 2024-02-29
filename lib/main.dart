import 'package:cripto_app/configs/app_settings.dart';
import 'package:cripto_app/configs/hive_config.dart';
import 'package:cripto_app/my_app.dart';
import 'package:cripto_app/repositories/favoritas_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Garante que as widgets sejam inicializadas antes que as operações sejam feitas. Sem essa instrução, o Flutter tenta compilar e rodar o app e dará erro, pois existe código antes do runApp. Essa instrução evita o erro
  WidgetsFlutterBinding.ensureInitialized();

  // A inicialização do Hive é feita na main para evitar erros no app, pois existe uma latência até o Dart ler e inicializar o sistema de arquivos.
  // Como o Hive vai ser usado em muitas partes do app, é interessante ser criada uma única inicialização para o sistema de BD para que não seja necessário fazer a inicialização em vários momentos
  await HiveConfig.start();

  runApp(
    // A lista de favoritas vai ser compartilhada entre várias telas, é indicado que ela seja colocada na raiz do projeto
    // Agora o AppSetting também ficará na raiz do projeto, pois serve como um configurador global (uso de SharedPreferences)
    // O ChangeNotifierProvider fica como uma espécie de fornecedor para o child, que é o aplicativo
    // Como há mais de um provider, é utilizado o MultirProvider com um array com esses providers
    // Qualquer widget filho do MyApp pode acessar os providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(create: (context) => FavoritasRepository())
      ],
      child: const MyApp(),
    ),
  );
}
