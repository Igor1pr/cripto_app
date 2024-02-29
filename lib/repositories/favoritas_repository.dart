import 'dart:collection';

import 'package:cripto_app/adapters/moeda_hive_adapter.dart';
import 'package:cripto_app/models/moeda.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// O ChangeNotifier é reponsável por notificar o Flutter para redesenhar a tela
class FavoritasRepository extends ChangeNotifier {
  // Lista de moedas
  List<Moeda> _lista = [];

  // Adição do Hive; tipo LazyBox pois ele não é carregado de forma síncrona
  late LazyBox box;

  // Método construtor
  FavoritasRepository() {
    _startRepository();
  }

  // Método responsável por inicializar o box do Hive
  _startRepository() async {
    await _openBox();
    await _readFavoritas();
  }

  // Método para abrir o box
  _openBox() async {
    // O adapter serve para salvar dados mais complexos, pois o Hive trabalha com tipos primitivos (string, int, list, etc)
    // O adapter é uma classe criada dentro da pasta lib/adapters
    Hive.registerAdapter(MoedaHiveAdapter());
    box = await Hive.openLazyBox<Moeda>('moedas_favoritas');
  }

  // Método para ler as favoritas que estão salvas
  _readFavoritas() {
    box.keys.forEach((moeda) async {
      Moeda m = await box.get(moeda);
      _lista.add(m);
      notifyListeners();
    });
  }

  // Método get para a lista
  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  // Método para salvar as moedas na lista de favoritas
  saveAll(List<Moeda> moedas) {
    moedas.forEach((moeda) {
      // objetos (moeda) estão sendo salvos, e quando são inicializados, são diferentes por mais que tenham os mesmos dados, por isso é necesário comparar identificadores únicos, que nesse caso é a sigla
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        box.put(moeda.sigla, moeda);
      }
    });

    // Notifica o Flutter para redesenhar a tela; método da classe ChangeNotifier. Notifica a todos que estão consumindo as mudanças no Provider
    notifyListeners();
  }

  // Método para remover moedas da lista de favoritas
  remove(Moeda moeda) {
    _lista.remove(moeda);
    box.delete(moeda.sigla);
    notifyListeners();
  }
}
