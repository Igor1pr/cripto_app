import 'package:cripto_app/database/db.dart';
import 'package:cripto_app/models/posicao.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ContaRepository extends ChangeNotifier {
  late Database db;
  // Possui todas as operações/posições que o usuário tem na carteira
  final List<Posicao> _carteira = [];
  double _saldo = 0;

  get saldo => _saldo;
  List<Posicao> get carteira => _carteira;

  // Método construtor
  // O _initRepository serve para permitir o trabalho com dados do tipo assíncrono que não podem ser feitos dentro do construtor
  ContaRepository() {
    _initRepository();
  }

  _initRepository() async {
    await _getSaldo();
  }

  _getSaldo() async {
    // Recupera a instância do BD
    db = await DB.instance.database;
    // List para fazer uma consulta (query) no BD
    // O limit está sendo passado como 1 considerando somente 1 usuário (dev tester) para otimizar essa consulta
    List conta = await db.query('conta', limit: 1);
    // Acessando o saldo; como 'conta' retorna um list, o .first é para pegar o primeiro item da list e é acessada a chave saldo
    _saldo = conta.first['saldo'];
    notifyListeners();
  }

  // Método público para que o usuário possa setar o saldo dele
  setSaldo(double valor) async {
    db = await DB.instance.database;
    // update na tabela conta passando o mapa, nesse mapa o saldo será o valor que o usuário informar na tela da conta
    db.update('conta', {
      'saldo': valor,
    });
    // O saldo recebe o valor informado pelo usuário
    _saldo = valor;
    notifyListeners();
  }
}
