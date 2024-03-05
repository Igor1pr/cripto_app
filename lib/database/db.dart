// Classe de helper para ajudar a conectar ao banco e fazer todas as configurações necessárias

// O motivo da criação da classe se deve ao fato de, por o sqlite ser um BD do tipo sql, é necessário fazer toda a configuração de abertura do banco, a configuração e criação das tabelas e da estrutura dessas tabelas, e a realização das operações iniciais necessárias

// Geralmente essas classes de helpers de BD são do formato Singleton (?), um padrão de projeto que possibilita que uma classe gerencie sua própria instânciação e que somente uma instãncia dessa classe possa ser criada. Isso é útil no contexto desse projeto pois dessa forma é possível gerenciar o número de conexões/abertura para leitura do BD e outras operações uma única vez, ao invés de abrir várias conexões para acesso ao dispositivo interno de armazanamento desses dados.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  // Construtor com acesso privado para que somente uma instância seja criada
  DB._();

  // Criar uma instância de DB
  static final DB instance = DB._();

  // Instância do SQLite
  static Database? _database;

  // Método que verifica se o db está vazio; se não estiver, ele é retornado pois já está instanciado e criado; caso contrário ele é inicializado
  // Essa é uma forma de retornar somente uma instãncia
  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  // Função de inicialização do BD
  _initDatabase() async {
    return await openDatabase(
      // pega o caminho do SO para salvar o BD
      join(await getDatabasesPath(), 'cripto.db'),
      // Versão do BD
      version: 1,
      // Função executada somente na primeira vez que o banco for criado
      onCreate: _onCreate,
    );
  }

  _onCreate(db, versao) async {
    // O usuário terá um saldo que será salvo na conta
    await db.execute(_conta);
    // Possui todas as posições de moedas que o usuário comprou
    await db.execute(_carteira);
    // Como o intuito é fazer compra e venda, é preciso ter o histórico de operações do usuário
    await db.execute(_historico);
    // Conta sendo inserida com saldo zerado
    await db.insert('conta', {'saldo': 0});
  }

  // ''': sting em bloco
  String get _conta => '''
    CREATE TABLE conta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      saldo REAL
    );
  ''';

  String get _carteira => '''
    CREATE TABLE carteira (
      sigla TEXT PRIMARY KEY,
      moeda TEXT,
      quantidade TEXT
    );
  ''';

  String get _historico => '''
    CREATE TABLE historico (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_operacao INT,
      tipo_operacao TEXT,
      moeda TEXT,
      sigla TEXT,
      valor REAL,
      quantidade TEXT
    );
  ''';
}
