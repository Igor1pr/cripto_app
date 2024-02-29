import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings extends ChangeNotifier {
  // Formato que o Hive trabalha onde serão colocadas as informações de chave e valor
  late Box box;

  // Localização default do aplicativo
  Map<String, String> locale = {
    'locale': 'pt-BR',
    'name': 'R\$',
  };

  // Construtor; dentro dele, será chamado um método privado, pois o construtor não pode ser assíncrono
  AppSettings() {
    _startSettings();
  }

  // Inicialização e leitura, se já estiver salvo, do locale
  _startSettings() async {
    await _startPreferences();
    await _readLocale();
  }

  // Método onde será feita a inicialização das preferences; retorna um Future ("promessa") do tipo void
  Future<void> _startPreferences() async {

    // Inicialização do box
    box = await Hive.openBox('preferencias');
  }

  // Método que lê as informações que estão salvas no Hive
  _readLocale() {
    // O ?? (ou) serve para dizer que caso seja retornado um valor vazio ou null, será atribuído um padrão
    final local = box.get('local') ?? 'pt-BR';
    final name = box.get('name') ?? 'R\$';
    // set do Map
    locale = {
      'locale': local,
      'name': name,
    };
    // Notificar todas as classes que estão usando esse Provider
    notifyListeners();
  }

  // Método público para que qualquer classe possa alterar o locale conforme preferência do usuário
  setLocale(String local, String name) async {
    await box.put('local', local);
    await box.put('name', name);
    // Atualiza o locale caso haja mudança e notifica os listeners
    await _readLocale();
  }
}
