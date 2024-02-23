import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  // Variável do tipo SharedPreferences que irá receber as preferências; instância para acessar o sistema interno de arquivos
  late SharedPreferences _prefs;

  // Localização default do aplicativo
  Map<String, String> locale = {
    'locale': 'pt_BR',
    'name': 'R\$',
  };

  // Construtor; dentro dele, será chamado um método privado, pois o construtor não pode ser assíncrono
  AppSettings() {
    _startSettings();
  }

  // Inicialização do SharedPreferences e ler, se já estiver salvo, o locale
  _startSettings() async {
    await _startPreferences();
    await _readLocale();
  }

  // Método onde será feita a inicialização das preferences; retorna um Future ("promessa") do tipo void
  // dessa forma é possível inicializar o sistema de arquivos por meio do SharedPreferences
  Future<void> _startPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Método que lê as informações que estão salvas no SharedPreferences
  _readLocale() {
    // O ?? (ou) serve para dizer que caso seja retornado um valor vazio ou null, será atribuído um padrão
    final local = _prefs.getString('local') ?? 'pt_BR';
    final name = _prefs.getString('local') ?? 'R\$';
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
    await _prefs.setString('local', local);
    await _prefs.setString('name', name);
    // Atualiza o locale caso haja mudança e notifica os listeners
    await _readLocale();
  }
}
