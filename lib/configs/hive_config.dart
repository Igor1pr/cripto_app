import 'dart:io';

import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

class HiveConfig {
  static start() async {
    // Acesso ao diretório onde os documentos do aplicativo ficarão localizados por meio da classe Directory
    Directory dir = await getApplicationDocumentsDirectory();

    // Inicialização do Hive e localização de onde os arquivos serão salvos
    await Hive.initFlutter(dir.path);
  }
}
