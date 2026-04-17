// ============================================================
// BANCO DE DADOS: DatabaseHelper
// Substitui o ConexaoFactory.java + JogoDAO.java
//
// DIFERENÇA PRINCIPAL:
//   Antes: MySQL rodando num servidor separado na sua máquina
//   Agora: SQLite embutido direto no celular, sem servidor!
//
// O SQLite cria um arquivo .db dentro do próprio app.
// Funciona offline, em qualquer celular, sem configuração.
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/palavra.dart';

class DatabaseHelper {
  // Singleton: garante que só existe UMA instância do banco
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Abre (ou cria) o banco de dados
  // Equivalente ao DriverManager.getConnection() do seu Java
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jogo_forca.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // getDatabasesPath() → encontra a pasta certa no celular
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _criarTabelas, // Chamado na primeira vez que o app abre
    );
  }

  // ============================================================
  // CRIAÇÃO DAS TABELAS
  // Equivalente ao seu script SQL no MySQL
  //
  // ESTRUTURA:
  //   tabela 'palavras' → texto, dica, categoria, dificuldade
  //
  // No seu projeto original havia duas tabelas (palavras + categorias)
  // ligadas por categoria_id. Aqui simplificamos: a categoria fica
  // como texto direto na tabela palavras. Mais simples para mobile!
  // ============================================================
  Future<void> _criarTabelas(Database db, int version) async {
    // Cria a tabela de palavras
    await db.execute('''
      CREATE TABLE palavras (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        texto       TEXT    NOT NULL,
        dica        TEXT    NOT NULL,
        categoria   TEXT    NOT NULL,
        dificuldade TEXT    NOT NULL DEFAULT 'medio'
      )
    ''');

    // Cria a tabela de pontuação para o modo 2 jogadores
    await db.execute('''
      CREATE TABLE pontuacao (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        jogador     TEXT    NOT NULL,
        vitorias    INTEGER NOT NULL DEFAULT 0,
        derrotas    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Popula com dados iniciais de exemplo
    // VOCÊ VAI ADICIONAR MAIS PALAVRAS AQUI! (veja o README)
    await _popularBancoDados(db);
  }

  // ============================================================
  // DADOS INICIAIS
  // Adicione suas palavras aqui!
  // Formato: (texto, dica, categoria, dificuldade)
  // dificuldade: 'facil' (até 5 letras), 'medio' (6-8), 'dificil' (9+)
  // ============================================================
  Future<void> _popularBancoDados(Database db) async {
    final palavras = [
      // --- FILMES E SÉRIES ---
      {'texto': 'AVATAR', 'dica': 'Filme de ficção científica com criaturas azuis', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'VINGADORES', 'dica': 'Grupo de super-heróis da Marvel', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'MATRIX', 'dica': 'Filme onde a realidade é uma simulação', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'INTERESTELAR', 'dica': 'Filme sobre viagem pelo espaço e buracos negros', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'BREAKING BAD', 'dica': 'Série sobre um professor de química que vira traficante', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'SIMPSONS', 'dica': 'Família amarela de Springfield', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},

      // --- ESPORTES ---
      {'texto': 'FUTEBOL', 'dica': 'Esporte mais popular do Brasil', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'BASQUETE', 'dica': 'Esporte com cesta e bola laranja', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'NATACAO', 'dica': 'Esporte praticado dentro da água', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'OLIMPIADAS', 'dica': 'Maior evento esportivo do mundo', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'TENIS', 'dica': 'Esporte com raquete e rede', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'VOLEIBOL', 'dica': 'Esporte onde não pode deixar a bola cair', 'categoria': 'Esportes', 'dificuldade': 'medio'},

      // --- TECNOLOGIA / PROGRAMAÇÃO ---
      {'texto': 'ALGORITMO', 'dica': 'Sequência de passos para resolver um problema', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'FLUTTER', 'dica': 'Framework Google para criar apps mobile', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'PYTHON', 'dica': 'Linguagem de programação com nome de cobra', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'JAVASCRIPT', 'dica': 'Linguagem de programação da web', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'GITHUB', 'dica': 'Plataforma para guardar e compartilhar código', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'INTELIGENCIA ARTIFICIAL', 'dica': 'Tecnologia que simula a inteligência humana', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},

      // --- COMIDAS E BEBIDAS ---
      {'texto': 'PIZZA', 'dica': 'Prato italiano redondo com queijo', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'BRIGADEIRO', 'dica': 'Docinho brasileiro de chocolate', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'SUSHI', 'dica': 'Prato japonês com arroz e peixe cru', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'LASANHA', 'dica': 'Massa italiana em camadas', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'CAIPIRINHA', 'dica': 'Bebida brasileira com limão e cachaça', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'HAMBURGUER', 'dica': 'Sanduíche com carne entre dois pães', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},

      // --- MÚSICA ---
      {'texto': 'GUITARRA', 'dica': 'Instrumento elétrico de cordas', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'BEETHOVEN', 'dica': 'Compositor clássico alemão que ficou surdo', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'SAMBA', 'dica': 'Ritmo musical típico do Brasil', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'MICROFONE', 'dica': 'Equipamento usado para captar a voz', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'FORRÓ', 'dica': 'Ritmo musical do Nordeste brasileiro', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'BATERIA', 'dica': 'Instrumento de percussão com vários tambores', 'categoria': 'Música', 'dificuldade': 'medio'},
    ];

    for (final p in palavras) {
      await db.insert('palavras', p);
    }

    // Cria os 2 jogadores padrão para o modo multiplayer
    await db.insert('pontuacao', {'jogador': 'Jogador 1', 'vitorias': 0, 'derrotas': 0});
    await db.insert('pontuacao', {'jogador': 'Jogador 2', 'vitorias': 0, 'derrotas': 0});
  }

  // ============================================================
  // BUSCAR PALAVRA ALEATÓRIA
  // Equivalente ao método sortearPalavra() do seu JogoDAO.java
  // ============================================================
  Future<Palavra?> sortearPalavra({String? categoria}) async {
    final db = await database;

    List<Map<String, dynamic>> resultado;

    if (categoria != null && categoria != 'Todas') {
      // SQL com filtro de categoria (equivalente ao seu SELECT com INNER JOIN)
      resultado = await db.rawQuery(
        'SELECT * FROM palavras WHERE categoria = ? ORDER BY RANDOM() LIMIT 1',
        [categoria],
      );
    } else {
      // SQL sem filtro (palavra totalmente aleatória)
      resultado = await db.rawQuery(
        'SELECT * FROM palavras ORDER BY RANDOM() LIMIT 1',
      );
    }

    if (resultado.isEmpty) return null;
    return Palavra.fromMap(resultado.first);
  }

  // ============================================================
  // BUSCAR CATEGORIAS DISPONÍVEIS
  // ============================================================
  Future<List<String>> buscarCategorias() async {
    final db = await database;
    final resultado = await db.rawQuery(
      'SELECT DISTINCT categoria FROM palavras ORDER BY categoria',
    );
    return resultado.map((r) => r['categoria'] as String).toList();
  }

  // ============================================================
  // PONTUAÇÃO (Modo 2 Jogadores)
  // ============================================================
  Future<List<Map<String, dynamic>>> buscarPontuacao() async {
    final db = await database;
    return await db.query('pontuacao', orderBy: 'jogador ASC');
  }

  Future<void> registrarVitoria(String jogador) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE pontuacao SET vitorias = vitorias + 1 WHERE jogador = ?',
      [jogador],
    );
  }

  Future<void> registrarDerrota(String jogador) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE pontuacao SET derrotas = derrotas + 1 WHERE jogador = ?',
      [jogador],
    );
  }

  Future<void> resetarPontuacao() async {
    final db = await database;
    await db.rawUpdate('UPDATE pontuacao SET vitorias = 0, derrotas = 0');
  }

  // ============================================================
  // ADICIONAR NOVA PALAVRA (para você popular o banco depois)
  // ============================================================
  Future<void> inserirPalavra(Palavra palavra) async {
    final db = await database;
    await db.insert('palavras', palavra.toMap());
  }

  // Fecha o banco (boa prática)
  Future<void> fechar() async {
    final db = await database;
    db.close();
  }
}
