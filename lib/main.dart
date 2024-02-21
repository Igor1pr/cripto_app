import 'package:cripto_app/my_app.dart';
import 'package:cripto_app/repositories/favoritas_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // A lista de favoritas vai ser compartilhada entre várias telas, é indicado que ela seja colocada na raiz do projeto
    // O ChangeNotifier fica como uma espécie de fornecedor desse repositório de favoritas para o child que será o aplicativo
    // Se houvessem mais de um provider, seria utilizado um multi provider com um array com esses providers
    // Agora qualquer widget filho do MyApp pode acessar o repositório de favoritas
    ChangeNotifierProvider(create: (context) => FavoritasRepository(),
    child: const MyApp(),
    )
  );
}
