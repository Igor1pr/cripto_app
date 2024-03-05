import 'package:cripto_app/database/db.dart';
import 'package:cripto_app/models/historico.dart';
import 'package:cripto_app/models/moeda.dart';
import 'package:cripto_app/models/posicao.dart';
import 'package:cripto_app/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ContaRepository extends ChangeNotifier {
  late Database db;
  // Possui todas as operações/posições que o usuário tem na carteira
  List<Posicao> _carteira = [];
  List<Historico> _historico = [];
  double _saldo = 0;

  get saldo => _saldo;
  List<Posicao> get carteira => _carteira;
  List<Historico> get historico => _historico;

  // Método construtor
  // O _initRepository serve para permitir o trabalho com dados do tipo assíncrono que não podem ser feitos dentro do construtor
  ContaRepository() {
    _initRepository();
  }

  _initRepository() async {
    await _getSaldo();
    await _getCarteira();
    await _getHistorico();
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

  comprar(Moeda moeda, double valor) async {
    db = await DB.instance.database;
    
    // A transação permite que várias operações ocorram de forma "simultânea" e se uma dessas operações apresentar um erro, toda a transação é anulada. Dessa forma, é garantida a consistência dos dados
    await db.transaction((txn) async {
      // Verificar se a moeda já foi comprada
      final posicaoMoeda = await txn.query(
        'carteira',
        where: 'sigla = ?',
        whereArgs: [moeda.sigla],
      );

      // Se não tiver a moeda em carteira
      if (posicaoMoeda.isEmpty) {
        await txn.insert('carteira', {
          'sigla': moeda.sigla,
          'moeda': moeda.nome,
          'quantidade': (valor / moeda.preco).toString()
        });
      }

      // Se já tiver a moeda em carteira
      else {
        final atual = double.parse(posicaoMoeda.first['quantidade'].toString());
        await txn.update('carteira',
            {'quantidade': (atual + (valor / moeda.preco)).toString()},
            where: 'sigla = ?', whereArgs: [moeda.sigla]);
      }

      // Inserir a compra no histórico
      await txn.insert('historico', {
        'sigla': moeda.sigla,
        'moeda': moeda.nome,
        'quantidade': (valor / moeda.preco).toString(),
        'valor': valor,
        'tipo_operacao': 'compra',
        'data_operacao': DateTime.now().millisecondsSinceEpoch
      });

      // Atualizar o saldo
      await txn.update('conta', {'saldo': saldo - valor});
    });

    // Atualizar o repositório e atualiza as telas que dependem dos dados do repositório
    await _initRepository();
    notifyListeners();
  }

  _getCarteira() async {
    _carteira = [];

    List posicoes = await db.query('carteira');

    posicoes.forEach((posicao) {
      Moeda moeda = MoedaRepository.tabela.firstWhere(
        (m) => m.sigla == posicao['sigla'],
      );

      _carteira.add(Posicao(
          moeda: moeda, quantidade: double.parse(posicao['quantidade'])));
    });

    notifyListeners();
  }

  _getHistorico() async {
    _historico = [];

    List operacoes = await db.query('historico');

    operacoes.forEach((operacao) {
      Moeda moeda = MoedaRepository.tabela.firstWhere(
        (m) => m.sigla == operacao['sigla'],
      );

      _historico.add(Historico(
        dataOperacao:
            DateTime.fromMillisecondsSinceEpoch(operacao['data_operacao']),
        tipoOperacao: operacao['tipo_operacao'],
        moeda: moeda,
        valor: operacao['valor'],
        quantidade: double.parse(operacao['quantidade']),
      ));
    });

    notifyListeners();
  }
}
