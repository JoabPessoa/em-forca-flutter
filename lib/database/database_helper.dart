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

  //Guarda os IDs das palavras que já saíram!
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
      version: 5,
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
      // 30 palavras
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
      {'texto': 'SUPERMAN', 'dica': 'Herói conhecido por usar capa vermelha e voar', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'WANDINHA', 'dica': 'Série sobre uma jovem sombria da Família Addams', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'LUCIFER', 'dica': 'Série sobre o diabo vivendo em Los Angeles', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'FRIENDS', 'dica': 'Série de comédia sobre seis amigos em Nova York', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'LA CASA DE PAPEL', 'dica': 'Série espanhola sobre um grande assalto', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'PEAKY BLINDERS', 'dica': 'Série sobre uma gangue britânica liderada por Thomas Shelby', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'ROUND SIX', 'dica': 'Série coreana com jogos mortais por dinheiro', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'BARBIE', 'dica': 'Filme sobre a boneca mais famosa do mundo', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'OPPENHEIMER', 'dica': 'Filme sobre o criador da bomba atômica', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'JURASSIC PARK', 'dica': 'Filme com um parque cheio de dinossauros', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'STAR WARS', 'dica': 'Saga espacial com Jedi, Sith e sabres de luz', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'SENHOR DOS ANEIS', 'dica': 'Saga de fantasia sobre um anel poderoso', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'THE LAST OF US', 'dica': 'Série baseada em jogo com infectados e sobreviventes', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'CHAVES', 'dica': 'Série mexicana com personagens de uma vila', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},

      // --- ESPORTES ---
      // 30 palavras
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
      {'texto': 'AUTOMOBILISMO', 'dica': 'Esporte de corrida com carros em alta velocidade', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'FORMULA UM', 'dica': 'Categoria famosa de corrida automobilística', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'BADMINTON', 'dica': 'Esporte com raquete e peteca', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'RUGBY', 'dica': 'Esporte coletivo com bola oval', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'BEISEBOL', 'dica': 'Esporte com taco, bola e bases', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'GOLFE', 'dica': 'Esporte em que se tenta acertar a bola em buracos no campo', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'PING PONG', 'dica': 'Esporte de mesa jogado com pequenas raquetes', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'ARCO E FLECHA', 'dica': 'Esporte de precisão usando arco', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'ESGRIMA', 'dica': 'Esporte de combate com espada', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'HIPISMO', 'dica': 'Esporte praticado com cavalos', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'MUSCULACAO', 'dica': 'Atividade física com pesos e aparelhos', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'TAEKWONDO', 'dica': 'Arte marcial coreana com muitos chutes', 'categoria': 'Esportes', 'dificuldade': 'dificil'},

      // --- TECNOLOGIA / PROGRAMAÇÃO ---
      // 30 palavras
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
      {'texto': 'COMPUTADOR', 'dica': 'Máquina usada para processar informações', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'NOTEBOOK', 'dica': 'Computador portátil muito usado para estudar e trabalhar', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'PROCESSADOR', 'dica': 'Peça responsável por executar instruções no computador', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'MEMORIA RAM', 'dica': 'Memória temporária usada pelo computador', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'PLACA MAE', 'dica': 'Componente onde outras peças do computador são conectadas', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'ROTEADOR', 'dica': 'Aparelho usado para distribuir internet', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'WI FI', 'dica': 'Tecnologia de conexão sem fio à internet', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'BLUETOOTH', 'dica': 'Tecnologia sem fio usada para conectar dispositivos próximos', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'CIBERSEGURANCA', 'dica': 'Área que protege sistemas contra ataques digitais', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'CRIPTOGRAFIA', 'dica': 'Técnica usada para proteger informações', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'SERVIDOR', 'dica': 'Computador ou sistema que fornece serviços em rede', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'CLOUD COMPUTING', 'dica': 'Uso de serviços e armazenamento pela internet', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},

      // --- COMIDAS E BEBIDAS ---
      // 30 palavras
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
      {'texto': 'CAFE', 'dica': 'Bebida estimulante muito consumida', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'SUCO', 'dica': 'Bebida feita de frutas', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'ACHOCOLATADO', 'dica': 'Bebida doce com leite e chocolate', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'TAPIOCA', 'dica': 'Comida feita com goma de mandioca, comum no Nordeste', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'ACARAJE', 'dica': 'Comida baiana feita com massa de feijão-fradinho', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'CUSCUZ', 'dica': 'Comida feita de milho, muito comum no café da manhã nordestino', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'MOQUECA', 'dica': 'Prato brasileiro feito com peixe e temperos', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'PAMONHA', 'dica': 'Comida feita de milho verde, doce ou salgada', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'CANJICA', 'dica': 'Doce típico de festas juninas feito com milho', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'HOT DOG', 'dica': 'Lanche feito com pão e salsicha', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'BATATA FRITA', 'dica': 'Acompanhamento crocante muito comum em lanchonetes', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'PANQUECA', 'dica': 'Massa fina recheada, doce ou salgada', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'TACOS', 'dica': 'Comida mexicana feita com tortilha e recheio', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'YAKISOBA', 'dica': 'Prato oriental com macarrão, legumes e molho', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'MILK SHAKE', 'dica': 'Bebida gelada feita com leite e sorvete', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},

      // --- MÚSICA ---
      // 30 palavras
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
      {'texto': 'SAXOFONE', 'dica': 'Instrumento de sopro muito usado no jazz', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'TROMPETE', 'dica': 'Instrumento de sopro com som forte e marcante', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'FLAUTA', 'dica': 'Instrumento de sopro pequeno e leve', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'PERCUSSAO', 'dica': 'Conjunto de instrumentos tocados por batidas', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'ORQUESTRA', 'dica': 'Grupo grande de músicos tocando juntos', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'REGENTE', 'dica': 'Pessoa que conduz uma orquestra ou coral', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'MELODIA', 'dica': 'Sequência de notas que forma uma música', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'HARMONIA', 'dica': 'Combinação de sons tocados ao mesmo tempo', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'RITMO', 'dica': 'Marcação do tempo e movimento da música', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'REFRAO', 'dica': 'Parte da música que costuma se repetir', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'PARTITURA', 'dica': 'Registro escrito das notas musicais', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'CORAL', 'dica': 'Grupo de pessoas cantando juntas', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'MPB', 'dica': 'Sigla para Música Popular Brasileira', 'categoria': 'Música', 'dificuldade': 'facil'},
      
      // --- MÚSICA - CANTORES ---
      // 25 palavras
      {'texto': 'MICHAEL JACKSON', 'dica': 'Artista conhecido como uma das maiores figuras do pop mundial', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'ELVIS PRESLEY', 'dica': 'Artista histórico muito associado ao rock and roll', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'BEYONCE', 'dica': 'Artista internacional conhecida por grandes apresentações e voz potente', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'RIHANNA', 'dica': 'Artista caribenha que fez grande sucesso no pop e no R&B', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'DRAKE', 'dica': 'Artista canadense bastante ligado ao rap e ao pop', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'TAYLOR SWIFT', 'dica': 'Artista internacional conhecida por letras sobre experiências pessoais', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'JUSTIN BIEBER', 'dica': 'Artista canadense que ficou famoso ainda na adolescência', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'EMINEM', 'dica': 'Artista do rap conhecido por versos rápidos e letras intensas', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ANITTA', 'dica': 'Artista brasileira que levou o funk e o pop para o cenário internacional', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'GUSTTAVO LIMA', 'dica': 'Artista brasileiro muito associado ao sertanejo universitário', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'MARILIA MENDONCA', 'dica': 'Artista brasileira marcada por músicas de sofrência no sertanejo', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'ZE NETO', 'dica': 'Artista brasileiro conhecido por fazer parte de uma dupla sertaneja', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'LUAN SANTANA', 'dica': 'Artista brasileiro ligado ao sertanejo pop e romântico', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'IVETE SANGALO', 'dica': 'Artista brasileira muito associada ao axé e ao carnaval', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'THIAGUINHO', 'dica': 'Artista de pagode ex-Exaltasamba', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'BRUNO MARS', 'dica': 'Artista internacional que mistura pop, funk e R&B em suas músicas', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ADELE', 'dica': 'Artista britânica conhecida por baladas emocionais e voz marcante', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'SHAKIRA', 'dica': 'Artista latina de carreira internacional e músicas dançantes', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'LADY GAGA', 'dica': 'Artista pop conhecida por visual marcante e performances teatrais', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ARIANA GRANDE', 'dica': 'Artista pop conhecida por grande alcance vocal', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'POST MALONE', 'dica': 'Artista internacional que mistura rap, pop e rock', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'ED SHEERAN', 'dica': 'Artista britânico associado a canções românticas e violão', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ALOK', 'dica': 'Artista brasileiro ligado à música eletrônica', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'LUDMILLA', 'dica': 'Artista brasileira que transita entre funk, pop e pagode', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'CAETANO VELOSO', 'dica': 'Artista brasileiro ligado à MPB e ao tropicalismo', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},

      // --- ANIMAIS ---
      // 30 palavras
      {'texto': 'CACHORRO', 'dica': 'Animal doméstico conhecido por sua lealdade', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'GATO', 'dica': 'Animal doméstico conhecido por ser independente', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'ELEFANTE', 'dica': 'Animal grande conhecido por sua tromba', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'LEAO', 'dica': 'Felino conhecido como rei da selva', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'TIGRE', 'dica': 'Felino listrado encontrado principalmente na Ásia', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'MACACO', 'dica': 'Animal ágil que vive em árvores', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'CAVALO', 'dica': 'Animal usado historicamente para transporte', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'COELHO', 'dica': 'Animal pequeno conhecido por suas orelhas grandes', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'GIRAFA', 'dica': 'Animal conhecido por seu pescoço comprido', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'TUBARAO', 'dica': 'Animal marinho conhecido por seus dentes afiados', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'JACARE', 'dica': 'Réptil encontrado em rios e áreas alagadas', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'CANGURU', 'dica': 'Animal que se locomove saltando', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'PINGUIM', 'dica': 'Ave que não voa e vive em regiões frias', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'CORUJA', 'dica': 'Ave associada à noite e à visão aguçada', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'GOLFINHO', 'dica': 'Animal marinho conhecido por sua inteligência', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'BALEIA', 'dica': 'Grande animal marinho mamífero', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'RAPOSA', 'dica': 'Animal conhecido por sua esperteza', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'CAMELO', 'dica': 'Animal adaptado a regiões desérticas', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'PAVAO', 'dica': 'Ave conhecida por sua cauda colorida', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'ARARA', 'dica': 'Ave colorida comum em regiões tropicais', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'ORNITORRINCO', 'dica': 'Animal incomum que bota ovos e é mamífero', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'CAMALEAO', 'dica': 'Réptil conhecido por mudar de cor', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'TATU BOLA', 'dica': 'Animal que pode se enrolar para se proteger', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'LOBO GUARÁ', 'dica': 'Canídeo típico do cerrado brasileiro', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'CAPIVARA', 'dica': 'Maior roedor do mundo, comum no Brasil', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'AXOLOTE', 'dica': 'Animal aquático conhecido por sua capacidade de regeneração', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'SURICATO', 'dica': 'Pequeno mamífero que costuma viver em grupos', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'QUATI', 'dica': 'Mamífero de focinho alongado encontrado nas Américas', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'BICHO PREGUICA', 'dica': 'Animal conhecido por se mover lentamente', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'TAMANDUA', 'dica': 'Animal que se alimenta principalmente de formigas', 'categoria': 'Animais', 'dificuldade': 'dificil'},

      // -- Mitologia
      // -- 28 Palavras
        {'texto': 'THOR', 'dica': 'Deus nórdico do trovão que empunha o martelo Mjolnir', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'ZEUS', 'dica': 'O deus supremo do Olimpo e senhor dos raios na Grécia Antiga', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'MEDUSA', 'dica': 'Criatura com serpentes na cabeça que transformava quem olhasse para ela em pedra', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'POSEIDON', 'dica': 'Deus grego dos mares e dos oceanos que carrega um tridente', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'ANUBIS', 'dica': 'Deus egípcio dos mortos com cabeça de chacal', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'HERCULES', 'dica': 'Semideus conhecido por sua força incomum e pelos seus doze trabalhos', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'CUPIDO', 'dica': 'Deus romano do amor armado com arco e flecha', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'MINOTAURO', 'dica': 'Criatura metade homem e metade touro que habitava o labirinto de Creta', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'PEGASO', 'dica': 'Cavalo alado símbolo da imortalidade na mitologia grega', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'ODIN', 'dica': 'O Pai de Todos e governante de Asgard na mitologia nórdica', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'FENRIR', 'dica': 'Lobo monstruoso filho de Loki destinado a lutar no Ragnarok', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'AFRODITE', 'dica': 'Deusa grega do amor, da beleza e da sedução', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'CENTAURO', 'dica': 'Criatura mitológica com corpo de cavalo e tronco e cabeça de homem', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'VALQUIRIA', 'dica': 'Guerreira nórdica que escolhia os caídos em combate para ir a Valhala', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'LOKI', 'dica': 'Deus da trapaça e da travessura na mitologia nórdica', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'HADES', 'dica': 'Deus grego do submundo e do reino dos mortos', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'QUIMERA', 'dica': 'Monstro terrível que cuspia fogo com corpo de leão, cabra e cobra', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'CRONOS', 'dica': 'O titã do tempo que devorava os próprios filhos para manter o poder', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
        {'texto': 'CERBERO', 'dica': 'Cão de três cabeças que guardava a entrada do submundo grego', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
        {'texto': 'ACHILLES', 'dica': 'Herói da Guerra de Troia que tinha o calcanhar como único ponto vulnerável', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'OSIRIS', 'dica': 'Deus egípcio do renascimento que foi assassinado por seu irmão Seth', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'ICARO', 'dica': 'Jovem que voou com asas de cera e penas, mas caiu quando o sol as derreteu', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'PROMETEU', 'dica': 'Titã que roubou o fogo dos deuses para entregá-lo à humanidade', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'VALHALA', 'dica': 'O grande salão dos mortos governado por Odin para onde iam os guerreiros dignos', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'RAGNAROK', 'dica': 'O apocalipse e batalha final na mitologia nórdica', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'ESFINGE', 'dica': 'Criatura que desafiava os viajantes com enigmas antes de devorá-los', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'PERSEU', 'dica': 'Herói grego lendário que decapitou a Medusa', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
        {'texto': 'ATENA', 'dica': 'Deusa grega da sabedoria, das artes e da estratégia militar', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},

        // -- Contos de fada
        {'texto': 'CINDERELA', 'dica': 'Gata borralheira que perde seu sapatinho de cristal ao soar da meia-noite', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'PINOQUIO', 'dica': 'Boneco de madeira articulado que sonhava em se tornar um menino de verdade', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'RAPUNZEL', 'dica': 'Princesa de cabelos longos aprisionada em uma torre muito alta por uma bruxa', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'CHAPEUZINHO VERMELHO', 'dica': 'Menina que cruza a floresta para levar doces e encontra o Lobo Mau', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'ALADIM', 'dica': 'Jovem humilde que encontra um genio capaz de realizar desejos dentro de uma lampada', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'BRANCA DE NEVE', 'dica': 'Princesa de pele muito clara que foge da madrasta e vai morar com sete anoes', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'LOBO MAU', 'dica': 'O grande e clássico antagonista que persegue porquinhos e chapeuzinhos na floresta', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'BELA ADORMECIDA', 'dica': 'Princesa que cai em um sono profundo de cem anos após espetar o dedo em uma roca', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'PETER PAN', 'dica': 'O menino que se recusava a crescer e enfrentava o Capitao Gancho', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'MADRASTA', 'dica': 'Figura arquetipica crue e invejosa que atormenta Branca de Neve e Cinderela', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'FADA MADRINHA', 'dica': 'Entidade magica com varinha de condão que realiza os desejos das protagonistas', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'JOAO E MARIA', 'dica': 'Irmãos que se perdem na floresta e encontram uma tentadora casa feita de doces', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'CARRUAGEM', 'dica': 'Meio de transporte real que volta a ser uma abobora comum após a meia-noite', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'RUMPELSTILTSKIN', 'dica': 'Duende misterioso que consegue transformar palha em fios de ouro puro', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'ESPELHO MAGICO', 'dica': 'Objeto sincero de uma rainha má que sempre responde quem é a mais bela de todas', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'O PATINHO FEIO', 'dica': 'Criatura rejeitada por sua feiura que acaba crescendo e virando um lindo cisne', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'QUEBRA NOZES', 'dica': 'Boneco soldado que ganha vida na noite de Natal para enfrentar o Rei dos Ratos', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
        {'texto': 'PELE DE ASNO', 'dica': 'Princesa que se disfarça com uma capa de bicho para fugir de seu proprio reino', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
        {'texto': 'FLAUTISTA DE HAMELIN', 'dica': 'Musico misterioso que hipnotiza e leva embora todos os ratos de uma cidade', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
        {'texto': 'BARBA AZUL', 'dica': 'Nobre sinistro e misterioso que proibia suas esposas de entrarem em um quarto secreto', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
        {'texto': 'SININHO', 'dica': 'A pequenina e ciumenta fada artesã que acompanha Peter Pan espalhando po magico', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
        {'texto': 'JOAO E O PE DE FEIJAO', 'dica': 'Garoto que troca uma vaca por sementes magicas que crescem ate o ceu dos gigantes', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'SOLDADINHO DE CHUMBO', 'dica': 'Brinquedo de uma perna só que se apaixona por uma linda bailarina de papel', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
        {'texto': 'ROUPA NOVA DO REI', 'dica': 'Fabula sobre um alfaiate trapaceiro que vende um traje invisivel para um monarca vaidoso', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
        {'texto': 'OS TRES PORQUINHOS', 'dica': 'Irmãos construtores que testam a resistencia de suas casas contra o sopro do lobo', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
        {'texto': 'A PEQUENA SEREIA', 'dica': 'Criatura dos oceanos que troca sua propria voz com uma bruxa para ter pernas humanas', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
    ];

    for (final p in palavras) {
      await db.insert('palavras', p);
    }

    await db.insert('pontuacao', {'jogador': 'Jogador 1', 'vitorias': 0, 'derrotas': 0});
    await db.insert('pontuacao', {'jogador': 'Jogador 2', 'vitorias': 0, 'derrotas': 0});
  }

// ============================================================
  // BUSCAR PALAVRA COM LÓGICA DE ESCADA DE DIFICULDADE E MÚLTIPLAS CATEGORIAS
  // ============================================================
  Future<Palavra?> sortearPalavra({List<String>? categorias, String? modoJogo}) async {
    final db = await database;
    String idsIgnorados = _palavrasJogadasId.isEmpty ? "0" : _palavrasJogadasId.join(',');

    // NOVO: Filtro para múltiplas categorias
    String filtroCategoria = "";
    if (categorias != null && categorias.isNotEmpty && !categorias.contains('Todas')) {
      // Transforma ['Animais', 'Esportes'] em "'Animais', 'Esportes'"
      String listaCats = categorias.map((c) => "'$c'").join(', ');
      filtroCategoria = "categoria IN ($listaCats) AND ";
    }

    String ordemDificuldade;
    switch (modoJogo) {
      case 'rodinhas':
      case 'facil':
        ordemDificuldade = "CASE WHEN dificuldade = 'facil' THEN 1 WHEN dificuldade = 'medio' THEN 2 ELSE 3 END";
        break;
      case 'medio':
        ordemDificuldade = "CASE WHEN dificuldade IN ('facil', 'medio') THEN 1 ELSE 2 END";
        break;
      case 'dificil':
      default:
        ordemDificuldade = "CASE WHEN dificuldade = 'dificil' THEN 1 WHEN dificuldade = 'medio' THEN 2 ELSE 3 END";
        break;
    }

    final resultado = await db.rawQuery('''
      SELECT * FROM palavras 
      WHERE $filtroCategoria id NOT IN ($idsIgnorados) 
      ORDER BY $ordemDificuldade, RANDOM() 
      LIMIT 1
    ''');

    if (resultado.isEmpty) {
      _palavrasJogadasId.clear();
      return await sortearPalavra(categorias: categorias, modoJogo: modoJogo);
    }

    final palavraSorteada = Palavra.fromMap(resultado.first);
    _palavrasJogadasId.add(palavraSorteada.id!);

    return palavraSorteada;
  }

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
