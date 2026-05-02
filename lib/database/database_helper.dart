// ============================================================
// BANCO DE DADOS: DatabaseHelper
// Substitui o ConexaoFactory.java + JogoDAO.java
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/palavra.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // LISTA MÁGICA: Guarda os IDs das palavras que já saíram!
  List<int> _palavrasJogadasId = [];

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jogo_forca.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // MUDANÇA 1: Aumentamos a versão para 2!
      onCreate: _criarTabelas,
      onUpgrade: (db, oldVersion, newVersion) async {
        // MUDANÇA 2: Se a versão aumentar, apaga o banco velho e cria o novo com as palavras atualizadas
        await db.execute('DROP TABLE IF EXISTS palavras');
        await db.execute('DROP TABLE IF EXISTS pontuacao');
        await _criarTabelas(db, newVersion);
      },
    );
  }

  Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE palavras (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        texto       TEXT    NOT NULL,
        dica        TEXT    NOT NULL,
        categoria   TEXT    NOT NULL,
        dificuldade TEXT    NOT NULL DEFAULT 'medio'
      )
    ''');

    await db.execute('''
      CREATE TABLE pontuacao (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        jogador     TEXT    NOT NULL,
        vitorias    INTEGER NOT NULL DEFAULT 0,
        derrotas    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _popularBancoDados(db);
  }

  Future<void> _popularBancoDados(Database db) async {
    final palavras = [
      // --- FILMES E SÉRIES ---
      {'texto': 'AVATAR', 'dica': 'Filme de ficção científica com criaturas azuis', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'VINGADORES', 'dica': 'Grupo de super-heróis da Marvel', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'MATRIX', 'dica': 'Filme onde a realidade é uma simulação', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'INTERESTELAR', 'dica': 'Filme sobre viagem pelo espaço e buracos negros', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'BREAKING BAD', 'dica': 'Série sobre um professor de química que vira traficante', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'SIMPSONS', 'dica': 'Família amarela de Springfield', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'HARRY POTTER', 'dica': 'Bruxo famoso com uma cicatriz na testa', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'GAME OF THRONES', 'dica': 'Série com dragões e disputa por tronos', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'STRANGER THINGS', 'dica': 'Série com mundo invertido e poderes', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'TITANIC', 'dica': 'Filme sobre um navio que afundou', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'VELOZES E FURIOSOS', 'dica': 'Filme sobre corridas e carros tunados', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'THE OFFICE', 'dica': 'Série de comédia em ambiente de escritório', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'HOMEM ARANHA', 'dica': 'Herói que solta teias', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'BATMAN', 'dica': 'Herói sombrio de Gotham', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'CORINGA', 'dica': 'Vilão com sorriso assustador', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'THE FLASH', 'dica': 'Herói mais rápido do mundo', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},

      // --- ESPORTES ---
      {'texto': 'FUTEBOL', 'dica': 'Esporte mais popular do Brasil', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'BASQUETE', 'dica': 'Esporte com cesta e bola laranja', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'NATACAO', 'dica': 'Esporte praticado dentro da água', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'OLIMPIADAS', 'dica': 'Maior evento esportivo do mundo', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'TENIS', 'dica': 'Esporte com raquete e rede', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'VOLEIBOL', 'dica': 'Esporte onde não pode deixar a bola cair', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'HANDEBOL', 'dica': 'Esporte jogado com as mãos e gol', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'SURF', 'dica': 'Esporte praticado nas ondas do mar', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'SKATE', 'dica': 'Esporte radical com prancha e rodas', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'ATLETISMO', 'dica': 'Conjunto de esportes como corrida e salto', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'BOXE', 'dica': 'Luta com uso de luvas', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'FUTSAL', 'dica': 'Versão do futebol jogada em quadra', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'CICLISMO', 'dica': 'Esporte praticado com bicicleta', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'JUDO', 'dica': 'Arte marcial de origem japonesa', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'KARATE', 'dica': 'Luta com golpes de mãos e pés', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'ESCALADA', 'dica': 'Subir paredes ou montanhas', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'GINASTICA', 'dica': 'Esporte com movimentos acrobáticos', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'MARATONA', 'dica': 'Corrida de longa distância', 'categoria': 'Esportes', 'dificuldade': 'medio'},

      // --- TECNOLOGIA / PROGRAMAÇÃO ---
      {'texto': 'ALGORITMO', 'dica': 'Sequência de passos para resolver um problema', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'FLUTTER', 'dica': 'Framework Google para criar apps mobile', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'PYTHON', 'dica': 'Linguagem de programação com nome de cobra', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'JAVASCRIPT', 'dica': 'Linguagem de programação da web', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'GITHUB', 'dica': 'Plataforma para guardar e compartilhar código', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'INTELIGENCIA ARTIFICIAL', 'dica': 'Tecnologia que simula a inteligência humana', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'HTML', 'dica': 'Linguagem de marcação usada na web', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'CSS', 'dica': 'Usado para estilizar páginas web', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'JAVA', 'dica': 'Linguagem de programação muito usada em sistemas', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'REACT', 'dica': 'Biblioteca JavaScript para interfaces', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'BANCO DE DADOS', 'dica': 'Sistema para armazenar informações', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'API', 'dica': 'Forma de comunicação entre sistemas', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'NODEJS', 'dica': 'JavaScript rodando no servidor', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'TYPESCRIPT', 'dica': 'Superset do JavaScript com tipagem', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'FIREBASE', 'dica': 'Plataforma do Google para backend', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'LINUX', 'dica': 'Sistema operacional de código aberto', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'WINDOWS', 'dica': 'Sistema operacional da Microsoft', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'ANDROID', 'dica': 'Sistema operacional mobile do Google', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},

      // --- COMIDAS E BEBIDAS ---
      {'texto': 'PIZZA', 'dica': 'Prato italiano redondo com queijo', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'BRIGADEIRO', 'dica': 'Docinho brasileiro de chocolate', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'SUSHI', 'dica': 'Prato japonês com arroz e peixe cru', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'LASANHA', 'dica': 'Massa italiana em camadas', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'CAIPIRINHA', 'dica': 'Bebida brasileira com limão e cachaça', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'HAMBURGUER', 'dica': 'Sanduíche com carne entre dois pães', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'COXINHA', 'dica': 'Salgado brasileiro em formato de gota', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'PASTEL', 'dica': 'Salgado frito muito comum em feiras', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'CHURRASCO', 'dica': 'Carne assada na brasa', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'SORVETE', 'dica': 'Sobremesa gelada e doce', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'FEIJOADA', 'dica': 'Prato brasileiro com feijão preto e carne', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'REFRIGERANTE', 'dica': 'Bebida gaseificada e doce', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'MACARRAO', 'dica': 'Massa muito consumida no mundo', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'BOLO', 'dica': 'Doce comum em aniversários', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'PUDIM', 'dica': 'Sobremesa com calda de caramelo', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'CAFÉ', 'dica': 'Bebida estimulante muito consumida', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'SUCO', 'dica': 'Bebida feita de frutas', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'ACHOCOLATADO', 'dica': 'Bebida doce com leite e chocolate', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},

      // --- MÚSICA ---
      {'texto': 'GUITARRA', 'dica': 'Instrumento elétrico de cordas', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'BEETHOVEN', 'dica': 'Compositor clássico alemão que ficou surdo', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'SAMBA', 'dica': 'Ritmo musical típico do Brasil', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'MICROFONE', 'dica': 'Equipamento usado para captar a voz', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'FORRO', 'dica': 'Ritmo musical do Nordeste brasileiro', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'BATERIA', 'dica': 'Instrumento de percussão com vários tambores', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'VIOLAO', 'dica': 'Instrumento acústico de cordas', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'PIANO', 'dica': 'Instrumento com teclas', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'ROCK', 'dica': 'Gênero musical com guitarra e bateria', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'FUNK', 'dica': 'Gênero musical popular nas comunidades', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'SERTANEJO', 'dica': 'Gênero musical muito popular no Brasil', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'REGGAE', 'dica': 'Gênero musical associado à Jamaica', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'RAP', 'dica': 'Estilo musical com rimas e batida', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'POP', 'dica': 'Música popular internacional', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'BLUES', 'dica': 'Gênero musical com origem afro-americana', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'VIOLINO', 'dica': 'Instrumento de cordas tocado com arco', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'TECLADO', 'dica': 'Instrumento eletrônico com teclas', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'MICHAEL JACKSON', 'dica': 'Rei do pop famoso pelo moonwalk', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'ELVIS PRESLEY', 'dica': 'Ícone do rock conhecido como rei do rock', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'BEYONCE', 'dica': 'Cantora pop e R&B muito premiada', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'RIHANNA', 'dica': 'Cantora de Barbados com vários hits', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'DRAKE', 'dica': 'Rapper canadense muito popular', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'TAYLOR SWIFT', 'dica': 'Cantora famosa por músicas sobre relacionamentos', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'JUSTIN BIEBER', 'dica': 'Cantor canadense que ficou famoso jovem', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'EMINEM', 'dica': 'Rapper conhecido por suas rimas rápidas', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ANITTA', 'dica': 'Cantora brasileira de funk e pop internacional', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'GUSTTAVO LIMA', 'dica': 'Cantor sertanejo do hit "Apelido Carinhoso"', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'MARILIA MENDONCA', 'dica': 'Rainha da sofrência', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ZE NETO', 'dica': 'Faz dupla com Cristiano', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'LUAN SANTANA', 'dica': 'Cantor sertanejo muito popular entre jovens', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'IVETE SANGALO', 'dica': 'Cantora baiana famosa pelo axé', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'THIAGUINHO', 'dica': 'Cantor de pagode ex-Exaltasamba', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
    ];

    for (final p in palavras) {
      await db.insert('palavras', p);
    }

    await db.insert('pontuacao', {'jogador': 'Jogador 1', 'vitorias': 0, 'derrotas': 0});
    await db.insert('pontuacao', {'jogador': 'Jogador 2', 'vitorias': 0, 'derrotas': 0});
  }

  // ============================================================
  // BUSCAR PALAVRA ALEATÓRIA (COM MEMÓRIA!)
  // ============================================================
  Future<Palavra?> sortearPalavra({String? categoria}) async {
    final db = await database;
    List<Map<String, dynamic>> resultado;

    // Transforma a lista de IDs em um formato que o SQL entenda (ex: "1, 4, 10")
    String idsIgnorados = _palavrasJogadasId.isEmpty ? "0" : _palavrasJogadasId.join(',');

    if (categoria != null && categoria != 'Todas') {
      // MUDANÇA 3: Adicionamos o "AND id NOT IN" para filtrar as que já foram
      resultado = await db.rawQuery(
        'SELECT * FROM palavras WHERE categoria = ? AND id NOT IN ($idsIgnorados) ORDER BY RANDOM() LIMIT 1',
        [categoria],
      );
    } else {
      resultado = await db.rawQuery(
        'SELECT * FROM palavras WHERE id NOT IN ($idsIgnorados) ORDER BY RANDOM() LIMIT 1',
      );
    }

    // MUDANÇA 4: Se o resultado voltar vazio, o jogador já completou a categoria inteira!
    // Então limpamos a memória e chamamos a função de novo para recomeçar as palavras.
    if (resultado.isEmpty) {
      _palavrasJogadasId.clear();
      return await sortearPalavra(categoria: categoria);
    }

    // Converte o banco para o nosso Objeto
    final palavraSorteada = Palavra.fromMap(resultado.first);

    // MUDANÇA 5: Salva o ID dessa palavra para ela não ser chamada de novo neste ciclo
    _palavrasJogadasId.add(palavraSorteada.id!);

    return palavraSorteada;
  }

  // Método opcional para você poder resetar a memória do jogo quando quiser (ex: ao ir pro Menu Inicial)
  void resetarMemoriaDePalavras() {
    _palavrasJogadasId.clear();
  }

  Future<List<String>> buscarCategorias() async {
    final db = await database;
    final resultado = await db.rawQuery(
      'SELECT DISTINCT categoria FROM palavras ORDER BY categoria',
    );
    return resultado.map((r) => r['categoria'] as String).toList();
  }

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

  Future<void> inserirPalavra(Palavra palavra) async {
    final db = await database;
    await db.insert('palavras', palavra.toMap());
  }

  Future<void> fechar() async {
    final db = await database;
    db.close();
  }
}
