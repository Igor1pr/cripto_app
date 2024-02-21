import 'dart:collection';

import 'package:cripto_app/models/moeda.dart';
import 'package:flutter/material.dart';

// O ChangeNotifyer é reponsável por notificar o Flutter para redesenhar a tela
class FavoritasRepository extends ChangeNotifier {
  // Lista de moedas
  List<Moeda> _lista = [];

  // Método get para a lista
  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  // Método para salvar as moedas na lista de favoritas
  saveAll(List<Moeda> moedas) {
    moedas.forEach((moeda) {
      if (!_lista.contains(moeda)) _lista.add(moeda);
    });

    // Notifica o Flutter para redesenhar a tela; método da classe ChangeNotifier. Notifica a todos que estão consumindo as mudanças no Provider
    notifyListeners();
  }

  // Método para remover moedas da lista de favoritas
  remove(Moeda moeda) {
    _lista.remove(moeda);
    notifyListeners();
  }
}
