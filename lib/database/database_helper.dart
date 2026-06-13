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
      version: 17, // <-- Nova versãobpara acionar a atualização
      onCreate: _criarTabelas,
      onUpgrade: (db, oldVersion, newVersion) async {
        // A MÁGICA ACONTECE AQUI:
        // Apagamos APENAS a tabela de palavras para atualizar o catálogo do jogo.
        await db.execute('DROP TABLE IF EXISTS palavras');

        // ATENÇÃO: Nunca mais daremos DROP nas tabelas 'estatisticas' e 'pontuacao'!
        // O progresso ficará intocável.

        // Chama a recriação (que agora está protegida)
        await _criarTabelas(db, newVersion);
      },
    );
  }

  Future<void> _criarTabelas(Database db, int version) async {
    // 1. Tabela de Palavras (Será recriada nas atualizações para receber palavras novas)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS palavras (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        texto       TEXT    NOT NULL,
        dica        TEXT    NOT NULL,
        categoria   TEXT    NOT NULL,
        dificuldade TEXT    NOT NULL DEFAULT 'medio'
      )
    ''');

    // 2. Tabela de Pontuação Multiplayer (Protegida)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pontuacao (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        jogador     TEXT    NOT NULL,
        vitorias    INTEGER NOT NULL DEFAULT 0,
        derrotas    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 3. Tabela para o perfil do usuário e conquistas (Protegida)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS estatisticas (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nome        TEXT    NOT NULL UNIQUE,
        valor       INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Inicializando as estatísticas base protegendo contra duplicações na atualização
    await db.insert('estatisticas', {'nome': 'total_partidas', 'valor': 0}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('estatisticas', {'nome': 'sequencia_vitorias', 'valor': 0}, conflictAlgorithm: ConflictAlgorithm.ignore);

    await _popularBancoDados(db);
  }

  Future<void> _popularBancoDados(Database db) async {
    final palavras = [
      // --- FILMES E SÉRIES ---
      // 50 palavras
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
      {'texto': 'SHREK', 'dica': 'Filme de animacao com um ogro verde e um burro falante', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'REI LEAO', 'dica': 'Filme da Disney sobre a jornada de Simba', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'TOY STORY', 'dica': 'Filme com brinquedos que ganham vida quando os humanos saem', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'LOST', 'dica': 'Serie sobre sobreviventes de um acidente de aviao em uma ilha misteriosa', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'GLADIADOR', 'dica': 'Filme sobre um general romano que vira escravo e lutador', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'MAD MAX', 'dica': 'Filme em um mundo pos-apocaliptico no deserto com muita perseguicao', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'PULP FICTION', 'dica': 'Filme classico de Quentin Tarantino com danca e criminosos', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'FORREST GUMP', 'dica': 'Filme sobre um homem simples que presencia eventos historicos', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'SUPER SUPREMA', 'dica': 'Serie animada inspirada nos anos 90 com tres meninas heroínas', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'CORRE', 'dica': 'Filme de suspense com uma mae superprotetora e uma filha cadeirante', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'GHOSTBUSTERS', 'dica': 'Filme classico sobre cientistas que cacam fantasmas em Nova York', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'DRACULA', 'dica': 'Filme ou serie sobre o vampiro mais famoso da Transilvania', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'BOJACK HORSEMAN', 'dica': 'Serie animada sobre um cavalo ator decadente em Hollywood', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'BROOKLYN NINE NINE', 'dica': 'Serie de comedia focada em uma delegacia de policia em Nova York', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'TARZAN', 'dica': 'Filme sobre um homem criado por macacos na selva', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'CENTRAL DO BRASIL', 'dica': 'Filme nacional famoso sobre uma mulher que escreve cartas', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'TODO MUNDO ODEIA O CHRIS', 'dica': 'Serie de comedia baseada na infancia de um comediante famoso', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'JOKER', 'dica': 'Nome em ingles do vilao que ganhou filme proprio em 2019', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'RICK AND MORTY', 'dica': 'Serie animada sobre um cientista genio e seu neto em viagens espaciais', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'FROZEN', 'dica': 'Filme de animacao com duas irmas e um boneco de neve que fala', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'MODERN FAMILY', 'dica': 'Sitcom gravada em formato de falso documentário sobre três núcleos de uma família', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'THE BIG BANG THEORY', 'dica': 'Sitcom sobre um grupo de cientistas nerds e sua vizinha Penny', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'UM MALUCO NO PEDACO', 'dica': 'Sitcom dos anos 90 que lançou Will Smith ao estrelato na TV', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'MINHA MAE E UMA PECA', 'dica': 'Franquia de comédia nacional baseada na icônica Dona Hermínia', 'categoria': 'Filmes e Séries', 'dificuldade': 'facil'},
      {'texto': 'HOW I MET YOUR MOTHER', 'dica': 'Sitcom onde o protagonista narra aos filhos a história de como conheceu a mãe deles', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'DOIS HOMENS E MEIO', 'dica': 'Sitcom sobre a vida de um solteirão rico, seu irmão certinho e o sobrinho', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'EU A PATROA E AS CRIANCAS', 'dica': 'Sitcom muito famosa no Brasil focada na divertida família Kyle', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'COMMUNITY', 'dica': 'Sitcom sobre um grupo de estudo bizarro em uma faculdade comunitária', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'A GRANDE FAMILIA', 'dica': 'A mais famosa e duradoura sitcom da televisão brasileira', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
      {'texto': 'SEINFELD', 'dica': 'Considerada uma das maiores sitcoms da história, famosa por ser uma série sobre o nada', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},
      {'texto': 'PARKS AND RECREATION', 'dica': 'Sitcom de escritório focada nos funcionários públicos do departamento de parques', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},

      // --- ESPORTES ---
      // 50 palavras
      {'texto': 'CORRIDA', 'dica': 'Esporte ou atividade de pedestrianismo onde o objetivo é correr o mais rápido possível', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'FUTEBOL', 'dica': 'Esporte mais popular do Brasil', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'BASQUETE', 'dica': 'Esporte com cesta e bola laranja', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'NATACAO', 'dica': 'Esporte praticado dentro da água', 'categoria': 'Esportes', 'dificuldade': 'facil'},
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
      {'texto': 'POLO AQUATICO', 'dica': 'Jogo coletivo com bola praticado em uma piscina', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'KUNG FU', 'dica': 'Arte marcial milenar de origem chinesa', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'MOTOCICLISMO', 'dica': 'Corrida ou esporte praticado com motocicletas', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'CANOAGEM', 'dica': 'Esporte aquatico praticado com uma embarcacao e remos', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'JOCKEY', 'dica': 'O profissional que monta cavalos em corridas', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'FISICULTURISMO', 'dica': 'Competicao focada na definicao e tamanho dos musculos', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'REMO', 'dica': 'Esporte de velocidade na agua usando barcos e remos', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'FUTEBOL AMERICANO', 'dica': 'Esporte dos Estados Unidos com bola oval e capacetes', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'MUAY THAI', 'dica': 'Luta tailandesa conhecida como a arte das oito armas', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'XADREZ', 'dica': 'Considerado um esporte da mente jogado em um tabuleiro', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'CROSSFIT', 'dica': 'Treinamento de alta intensidade que mistura varios exercicios', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'RAFTING', 'dica': 'Descida em corredeiras de rios usando botes inflaveis', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'TRIATLO', 'dica': 'Prova que combina natacao, ciclismo e corrida', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'SUMO', 'dica': 'Luta tradicional japonesa onde competidores pesados se empurram', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'BOLICHE', 'dica': 'Jogo cujo objetivo e derrubar dez pinos com uma bola pesada', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'CAPOEIRA', 'dica': 'Expressao cultural brasileira que mistura luta, danca e musica', 'categoria': 'Esportes', 'dificuldade': 'facil'},
      {'texto': 'MARATONA AQUATICA', 'dica': 'Corrida de longa distancia realizada em aguas abertas', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'FUTEVOLEI', 'dica': 'Esporte de areia que mistura futebol e volei', 'categoria': 'Esportes', 'dificuldade': 'medio'},
      {'texto': 'SAILING', 'dica': 'Termo em ingles para o esporte de corrida a vela', 'categoria': 'Esportes', 'dificuldade': 'dificil'},
      {'texto': 'ALPINISMO', 'dica': 'Esporte de escalar altas montanhas com gelo e rocha', 'categoria': 'Esportes', 'dificuldade': 'medio'},

      // --- TECNOLOGIA / PROGRAMAÇÃO ---
      // 50 palavras
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
      {'texto': 'DISCO RIGIDO', 'dica': 'Dispositivo tradicional de armazenamento magnetico conhecido como HD', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'PLACA DE VIDEO', 'dica': 'Componente responsavel por processar e gerar as imagens na tela', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'FONTE DE ALIMENTACAO', 'dica': 'Peca que fornece energia eletrica para todos os componentes', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'TECLADO', 'dica': 'Periferico de entrada cheio de letras e numeros usado para digitar', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'MONITOR', 'dica': 'Tela que exibe a imagem gerada pelo computador', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'GABINETE', 'dica': 'Caixa de metal ou plastico que abriga as pecas internas do PC', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'CABO DE REDE', 'dica': 'Fio usado para conectar o computador diretamente ao roteador', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'PENDRIVE', 'dica': 'Dispositivo portátil de memoria flash para transportar arquivos', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'COOLER', 'dica': 'Ventilador interno usado para resfriar o processador', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'PASTA TERMICA', 'dica': 'Liquido condutor usado entre o processador e o dissipador', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'FILTRO DE LINHA', 'dica': 'Dispositivo com varias tomadas que protege contra surtos leves', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'ESTABILIZADOR', 'dica': 'Equipamento antigo usado para tentar proteger o PC de variacoes de tensao', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'FONE DE OUVIDO', 'dica': 'Periferico usado para escutar audio de forma individual', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'WEBCAM', 'dica': 'Camera conectada ao computador usada para videochamadas', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'MICROFONE', 'dica': 'Dispositivo de entrada usado para capturar a voz do usuario', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'MODEM', 'dica': 'Aparelho que recebe o sinal da operadora e decodifica a internet', 'categoria': 'Tecnologia', 'dificuldade': 'medio'},
      {'texto': 'IMPRESSORA', 'dica': 'Dispositivo que passa documentos do computador para o papel', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
      {'texto': 'FIBRA OPTICA', 'dica': 'Tecnologia de cabeamento que transmite dados a velocidade da luz', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},
      {'texto': 'SWITCH', 'dica': 'Equipamento de rede usado para conectar varios computadores via cabo', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},

      // --- COMIDAS E BEBIDAS ---
      // 50 palavras
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
      {'texto': 'CACHORRO QUENTE', 'dica': 'Lanche feito com pão e salsicha', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'BATATA FRITA', 'dica': 'Acompanhamento crocante muito comum em lanchonetes', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'PANQUECA', 'dica': 'Massa fina recheada, doce ou salgada', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'TACOS', 'dica': 'Comida mexicana feita com tortilha e recheio', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'YAKISOBA', 'dica': 'Prato oriental com macarrão, legumes e molho', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'MILK SHAKE', 'dica': 'Bebida gelada feita com leite e sorvete', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'STROGONOFE', 'dica': 'Prato com pedacos de carne ou frango em molho de creme de leite e cogumelos', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'PIPOCA', 'dica': 'Milho estourado no calor, muito comum no cinema', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'VINHO', 'dica': 'Bebida alcoolica obtida pela fermentacao da uva', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'CERVEJA', 'dica': 'Bebida alcoolica fermentada a base de cevada e lupulo', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'CROISSANT', 'dica': 'Pao de massa folhada em formato de meia-lua', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'CHURROS', 'dica': 'Doce frito comprido recheado com doce de leite ou chocolate', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'OMELETE', 'dica': 'Prato feito com ovos batidos e fritos na frigideira', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'QUINDIM', 'dica': 'Doce amarelo brilhante feito com gema de ovo, acucar e coco ralado', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'SALPICAO', 'dica': 'Salada fria que leva frango desfiado, maionese e batata palha', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'MISTO QUENTE', 'dica': 'Sanduiche prensado com queijo e presunto derretidos', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'GUARANA', 'dica': 'Refrigerante tipico brasileiro feito com o fruto da Amazonia', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'CHAMPAGNE', 'dica': 'Vinho espumante celebre usado em comemoracoes e brindes', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'SOPA', 'dica': 'Alimento liquido ou pastoso servido quente, comum no inverno', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'EMPADAO', 'dica': 'Torta salgada com massa podre recheada de frango ou palmito', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'MOUSSE', 'dica': 'Sobremesa cremosa e aerada, muito comum sabor chocolate ou maracuja', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'ESFIHA', 'dica': 'Salgado de origem arabe aberto ou fechado com recheio de carne ou queijo', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
      {'texto': 'EMPADA', 'dica': 'Salgado pequeno feito com massa podre que derrete na boca', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'FONDUE', 'dica': 'Prato suico onde se mergulham alimentos em queijo ou chocolate derretido', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},
      {'texto': 'AGUA DE COCO', 'dica': 'Bebida natural e hidratante muito consumida na praia', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},
      {'texto': 'CEVICHE', 'dica': 'Prato peruano de peixe cru marinado em suco de limao ou citrico', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'dificil'},

      // --- MÚSICA ---
      // 50 palavras
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
      {'texto': 'BAIXO', 'dica': 'Instrumento de cordas responsavel pelos sons mais graves', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'SANFONA', 'dica': 'Instrumento de fole muito tradicional no forro', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'PANDEIRO', 'dica': 'Instrumento de percussao muito usado no samba e pagode', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'MOZART', 'dica': 'Compositor classico prodigio conhecido por suas operas e sinfonias', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'JAZZ', 'dica': 'Genero musical americano marcado pela improvisacao e saxofone', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'COMPOSITOR', 'dica': 'Pessoa que cria e escreve a letra ou a melodia de uma musica', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'ACORDES', 'dica': 'Conjunto de tres ou mais notas tocadas simultaneamente', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'VIVALDI', 'dica': 'Compositor italiano famoso pela obra As Quatro Estacoes', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'PAGODE', 'dica': 'Subgenero do samba muito popular em festas brasileiras', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'FONE DE OUVIDO', 'dica': 'Acessorio individual usado para escutar faixas musicais', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'CAVACAO', 'dica': 'Instrumento pequeno de quatro cordas tipico do samba', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'METRONOMO', 'dica': 'Aparelho que produz pulsaçoes regulares para marcar o tempo musical', 'categoria': 'Música', 'dificuldade': 'dificil'},
      {'texto': 'VOCALISTA', 'dica': 'O cantor principal de uma banda', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'SOLO', 'dica': 'Trecho musical tocado ou cantado por uma unica pessoa', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'SINFONIA', 'dica': 'Composicao musical longa escrita para ser tocada por uma orquestra', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'PLAYLIST', 'dica': 'Lista de musicas selecionadas in aplicativos de streaming', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'CONCERTO', 'dica': 'Apresentacao musical publica de carater erudito', 'categoria': 'Música', 'dificuldade': 'medio'},
      {'texto': 'TRIANGULO', 'dica': 'Instrumento de percussao de metal em formato geometrico usado no forro', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'ALBUM', 'dica': 'Colecao de musicas lancadas juntas por um artista ou banda', 'categoria': 'Música', 'dificuldade': 'facil'},
      {'texto': 'GRAVADORA', 'dica': 'Empresa responsavel por produzir, fabricar e distribuir a musica de artistas', 'categoria': 'Música', 'dificuldade': 'dificil'},

      // --- MÚSICA - CANTORES ---
      // 50 palavras
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
      {'texto': 'BOB MARLEY', 'dica': 'Artista jamaicano que popularizou o reggae pelo mundo', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'FREDDIE MERCURY', 'dica': 'Lider e vocalista da banda de rock Queen', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'MADONNA', 'dica': 'Artista internacional mundialmente consagrada como a Rainha do Pop', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'TIM MAIA', 'dica': 'Artista brasileiro dono de uma voz potente e sucessos do soul e funk', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'GILBERTO GIL', 'dica': 'Artista brasileiro de grande importancia na MPB e na Tropicalia', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'ROBERTO CARLOS', 'dica': 'Artista brasileiro conhecido como o Rei da musica romantica', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'SEU JORGE', 'dica': 'Artista brasileiro conhecido por sua voz grave no samba e mpb', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'DUA LIPA', 'dica': 'Artista britanica de grande sucesso atual no pop e dance music', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'BILLIE EILISH', 'dica': 'Artista pop alternativa norte-americana muito jovem e premiada', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'PABLLO VITTAR', 'dica': 'Artista drag queen brasileira de grande destaque no cenario pop', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'LUISA SONZA', 'dica': 'Artista pop brasileira conhecida por coreografias e albuns recentes', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'CHORAO', 'dica': 'Vocalista e principal letrista da banda Charlie Brown Jr', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'RAUL SEIXAS', 'dica': 'Artista historico considerado o Maluco Beleza do rock brasileiro', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ALCIONE', 'dica': 'Grande artista brasileira conhecida como a Marrom do samba', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'PERICLES', 'dica': 'Cantor e compositor brasileiro ex-vocalista do grupo Exaltasamba', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'JORGE BEN JOR', 'dica': 'Artista brasileiro que misturou samba com rock e funk', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'SNOOP DOGG', 'dica': 'Artista norte-americano icone do rap da costa oeste', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'THE WEEKND', 'dica': 'Artista canadense conhecido por hits de pop sintetico e R&B', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'KATY PERRY', 'dica': 'Artista norte-americana dona de grandes hits pop coloridos nos anos 2010', 'categoria': 'Música - Cantores', 'dificuldade': 'facil'},
      {'texto': 'HARRY STYLES', 'dica': 'Artista britanico que fez parte da boyband One Direction', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'ZANCA', 'dica': 'Sobrenome artistico do cantor brasileiro Leonardo da dupla com Leandro', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'DANIEL', 'dica': 'Cantor sertanejo brasileiro que fez dupla com Joao Paulo nos anos 90', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},
      {'texto': 'AMY WINEHOUSE', 'dica': 'Artista britanica dona de voz marcante ligada ao jazz e soul', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'DJAVAN', 'dica': 'Artista alagoano consagrado por misturar ritmos tradicionais e MPB', 'categoria': 'Música - Cantores', 'dificuldade': 'dificil'},
      {'texto': 'FERRUGEM', 'dica': 'Cantor brasileiro de grande destaque no pagode romantico atual', 'categoria': 'Música - Cantores', 'dificuldade': 'medio'},

      // --- ANIMAIS ---
      // 50 palavras
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
      {'texto': 'ARARA', 'dica': 'Ave colorida comum em regiões tropicais', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'ORNITORRINCO', 'dica': 'Animal incomum que bota ovos e é mamífero', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'CAMALEAO', 'dica': 'Réptil conhecido por mudar de cor', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'TATU BOLA', 'dica': 'Animal que pode se enrolar para se proteger', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'LOBO GUARA', 'dica': 'Canídeo típico do cerrado brasileiro', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'CAPIVARA', 'dica': 'Maior roedor do mundo, comum no Brasil', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'AXOLOTE', 'dica': 'Animal aquático conhecido por sua capacidade de regeneração', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'SURICATO', 'dica': 'Pequeno mamífero que costuma viver em grupos', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'QUATI', 'dica': 'Mamífero de focinho alongado encontrado nas Américas', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'BICHO PREGUICA', 'dica': 'Animal conhecido por se mover lentamente', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'TAMANDUA', 'dica': 'Animal que se alimenta principalmente de formigas', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'PORCO', 'dica': 'Animal de fazenda que gosta de rolar na lama', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'VACA', 'dica': 'Animal que nos fornece leite e vive no pasto', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'GALINHA', 'dica': 'Ave doméstica que bota ovos e cacareja', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'OVELHA', 'dica': 'Animal conhecido por sua lã macia e branca', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'ABELHA', 'dica': 'Inseto polinizador que produz mel e vive em colmeias', 'categoria': 'Animais', 'dificuldade': 'facil'},
      {'texto': 'LACRAIA', 'dica': 'Artrópode de corpo longo e muitas pernas, também chamado de centopeia', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'ZEBRA', 'dica': 'Mamífero africano conhecido por suas listras pretas e brancas', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'PANDA', 'dica': 'Urso asiático que se alimenta quase exclusivamente de bambu', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'ESCORPIAO', 'dica': 'Aracnídeo que possui um ferrão venenoso na ponta da cauda', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'MORCEGO', 'dica': 'O único mamífero capaz de voar verdadeiramente', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'HIPOPOTAMO', 'dica': 'Grande mamífero africano que passa a maior parte do dia na água', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'POLVO', 'dica': 'Molusco marinho com oito braços e alta inteligência', 'categoria': 'Animais', 'dificuldade': 'medio'},
      {'texto': 'DIABO DA TASMANIA', 'dica': 'Marsupial carnívoro de mordida poderosa encontrado na Austrália', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'DRAGAO DE KOMODO', 'dica': 'O maior lagarto do mundo, nativo da Indonésia', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'PEIXE BOI', 'dica': 'Mamífero aquático dócil que se alimenta de plantas', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'NARVAL', 'dica': 'Baleia conhecida como o unicórnio do mar devido à sua longa presa', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'PANGOLIM', 'dica': 'Único mamífero com o corpo coberto por escamas de queratina', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'LULA GIGANTE', 'dica': 'Invertebrado misterioso que vive nas profundezas do oceano', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'HIENA', 'dica': 'Mamífero carnívoro conhecido por emitir um som semelhante a uma risada', 'categoria': 'Animais', 'dificuldade': 'dificil'},
      {'texto': 'LEOPARDO', 'dica': 'Felino feroz conhecido por sua agilidade e pelagem cheia de pintas', 'categoria': 'Animais', 'dificuldade': 'medio'},


      // -- Mitologia
      // -- 50 Palavras
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
      {'texto': 'ARES', 'dica': 'Deus grego da guerra violenta e impulsiva', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
      {'texto': 'MINERVA', 'dica': 'Deusa romana da sabedoria e das artes equivalente a Atena', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
      {'texto': 'NARCISO', 'dica': 'Jovem mitologico que se apaixonou pelo proprio reflexo na agua', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'JUPITER', 'dica': 'O deus supremo dos raios na mitologia romana', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'HERMES', 'dica': 'Deus mensageiro dos olimpicos que usava sandalias aladas', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'FREYJA', 'dica': 'Deusa nordica do amor, da fertilidade e da magia', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
      {'texto': 'BALDER', 'dica': 'Deus nordico da luz e da beleza que foi morto por um ramo de visco', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
      {'texto': 'HORUS', 'dica': 'Deus egipcio dos ceus com cabeca de falcao', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'ORFEU', 'dica': 'Musico lendario que desceu ao submundo para resgatar sua amada Euridice', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
      {'texto': 'PANDORA', 'dica': 'Primeira mulher criada pelos deuses gregos que abriu uma caixa proibida', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'NEPTUNO', 'dica': 'Deus romano dos mares equivalente ao Poseidon grego', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
      {'texto': 'JASON', 'dica': 'Heroi grego lider dos Argonautas na busca pelo Velo de Ouro', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
      {'texto': 'MIDAS', 'dica': 'Rei mitologico que transformava tudo o que tocava em ouro', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'ISIS', 'dica': 'Deusa egipcia da maternidade e da magia esposa de Osiris', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'SEREIA', 'dica': 'Criatura marinha que atraia os marinheiros com seu canto hipnotico', 'categoria': 'Mitologia', 'dificuldade': 'facil'},
      {'texto': 'HEIMDALL', 'dica': 'Guardiao nordico da ponte Bifrost que vigiava a entrada de Asgard', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
      {'texto': 'HELENA DE TROIA', 'dica': 'Mulher cujo rapto foi o estopim para a grande guerra entre gregos e troianos', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'ARTEMIS', 'dica': 'Deusa grega da caca, dos animais selvagens e da lua', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'HELESTIA', 'dica': 'Deusa grega do lar e dos votos sagrados de familia', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
      {'texto': 'QUETZALCOATL', 'dica': 'A serpente emplumada deus da sabedoria na mitologia asteca', 'categoria': 'Mitologia', 'dificuldade': 'dificil'},
      {'texto': 'DIONISIO', 'dica': 'Deus grego do vinho, das festas e do teatro', 'categoria': 'Mitologia', 'dificuldade': 'medio'},
      {'texto': 'HARPIA', 'dica': 'Monstro mitologico com corpo de ave de rapina e rosto de mulher', 'categoria': 'Mitologia', 'dificuldade': 'medio'},

      // -- Contos de fadas
      // -- 50 Palavras
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
      {'texto': 'PO DE PIRLIMPIMPIM', 'dica': 'Substancia magica que permite que as criancas voem com Peter Pan', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'A BELA E A FERA', 'dica': 'Jovem que se torna prisioneira em um castelo para salvar o pai e descobre o amor', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'MACA ENVENENADA', 'dica': 'Fruta oferecida por uma velha disfarçada para fazer uma princesa dormir', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'SAPATINHO DE CRISTAL', 'dica': 'O calçado mais famoso dos contos que serve apenas em uma jovem', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'ALICE NO PAIS DAS MARAVILHAS', 'dica': 'Menina que cai em uma toca de coelho e vai parar em um mundo absurdo', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'CAPITAO GANCHO', 'dica': 'Pirata vilao que teme um jacare que engoliu um relogio', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'GENIO DA LAMPADA', 'dica': 'Entidade azul ou magica aprisionada que concede tres desejos', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'MALEVOLA', 'dica': 'Bruxa ou fada sombria que joga uma maldicao no batizado da princesa', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'GATO DE BOTAS', 'dica': 'Felino astuto que usa calçados e chapeu para enriquecer seu dono humilde', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'O PRINCIPE SAPO', 'dica': 'Nobre transformado em anfibio que precisa do beijo de uma princesa', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'POLEGARZINHA', 'dica': 'Menina minúscula nascida de uma flor que passa por varias aventuras', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
      {'texto': 'A PRINCESA E A ERVILHA', 'dica': 'Moça que prova sua nobreza ao sentir um pequeno grao sob vinte colchoes', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
      {'texto': 'BRUXA DO MAR', 'dica': 'Entidade sombria dos oceanos que faz pactos perigosos com sereias', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'TERRA DO NUNCA', 'dica': 'Lugar magico e distante onde as criancas jamais crescem', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'CACADOR', 'dica': 'Homem que salva Chapeuzinho Vermelho e sua avo abrindo a barriga do lobo', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'O LOBO E OS SETE CABRITINHOS', 'dica': 'Conto classico onde o vilao engana filhotes disfarçando sua voz e patas', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
      {'texto': 'BALEIA', 'dica': 'Criatura marinha gigante que engole Pinoquio e seu criador Gepeto', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'A PEQUENA VENDEDORA DE FOSFOROS', 'dica': 'Conto triste sobre uma menina que se aquece com visoes ao acender palitos no frio', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
      {'texto': 'GEPETO', 'dica': 'Marceneiro idoso e bondoso que esculpe um boneco que ganha vida', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'ROCA DE FIAR', 'dica': 'Objeto pontiagudo amaldiçoado que faz uma jovem adormecer por um seculo', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'TAPETE MAGICO', 'dica': 'Objeto voador que ajuda Aladim a passear pelos ceus com a princesa', 'categoria': 'Contos de Fada', 'dificuldade': 'facil'},
      {'texto': 'CRIADAS DE COZINHA', 'dica': 'Funçao humilde dada a Cinderela por sua madrasta antes do baile', 'categoria': 'Contos de Fada', 'dificuldade': 'dificil'},
      {'texto': 'COELHO BRANCO', 'dica': 'Animal apressado que usa colete e relogio de bolso guiando Alice', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},
      {'texto': 'A RAINHA DE COPAS', 'dica': 'Monarca autoritaria que adora gritar para cortarem as cabeças dos outros', 'categoria': 'Contos de Fada', 'dificuldade': 'medio'},

      // -- Países
      // -- 58 Palavras
      {'texto': 'ALEMANHA', 'dica': 'Nação europeia famosa pela Oktoberfest e pela fabricação de carros de luxo', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'ESPANHA', 'dica': 'País europeu conhecido pelas touradas, pelo flamenco e pela paella', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'ESTADOS UNIDOS', 'dica': 'Potência mundial da América do Norte onde fica a cidade de Nova York', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'RUSSIA', 'dica': 'O maior país do mundo em extensão territorial, localizado entre Europa e Ásia', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'PERU', 'dica': 'País sul-americano que abriga as ruínas históricas de Machu Picchu', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'SUICA', 'dica': 'País europeu famoso por seus relógios, chocolates e pelos Alpes', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'INGLATERRA', 'dica': 'Nação do Reino Unido conhecida pela monarquia e pelo relógio Big Ben', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'COLOMBIA', 'dica': 'País sul-americano famoso pela exportação de café e pelas esmeraldas', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'COREIA DO SUL', 'dica': 'Nação asiática famosa pela tecnologia e pelo fenômeno cultural do K-pop', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'MARROCOS', 'dica': 'País africano famoso por seus desertos, mercados e a cidade de Marraquexe', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'IRA', 'dica': 'País do Oriente Médio antigo berço do Império Persa', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'VIETNA', 'dica': 'País do sudeste asiático conhecido por suas baías de águas verdes e história de guerra', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'AFRICA DO SUL', 'dica': 'Nação que sediou a Copa de 2010 e foi lar de Nelson Mandela', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'HOLANDA', 'dica': 'País europeu famoso pelos moinhos de vento, tulipas e canais de Amsterdã', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'ISLANDIA', 'dica': 'País insular nórdico conhecido como a terra do gelo e do fogo', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'PARAGUAI', 'dica': 'País vizinho ao Brasil que não possui saída para o mar', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'AUSTRIA', 'dica': 'País europeu onde nasceu Mozart e famoso por sua música clássica', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'CUBA', 'dica': 'Ilha caribenha famosa por seus carros antigos e charutos feitos à mão', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'POLONIA', 'dica': 'País europeu onde viveu o Papa João Paulo II e o pianista Chopin', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'NOVA ZELANDIA', 'dica': 'País da Oceania onde foram filmadas as trilogias de O Senhor dos Anéis', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'SINGAPURA', 'dica': 'Cidade-estado asiática extremamente moderna e conhecida por sua limpeza rigorosa', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'ETIOPIA', 'dica': 'País africano considerado o berço da humanidade e do café', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'DINAMARCA', 'dica': 'País nórdico de onde surgiram os blocos de montar da LEGO', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'CATAR', 'dica': 'Pequeno e rico país do Oriente Médio que sediou a Copa do Mundo de 2022', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'URUGUAI', 'dica': 'País sul-americano que sediou e venceu a primeira Copa do Mundo em 1930', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'CROACIA', 'dica': 'País europeu com litoral deslumbrante no Mar Adriático e vice-campeão em 2018', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'LIBANO', 'dica': 'País do Oriente Médio representado pela árvore cedro em sua bandeira', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'MALDIVAS', 'dica': 'País insular no Oceano Índico famoso por seus resorts de luxo sobre a água', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'MONACO', 'dica': 'O segundo menor país do mundo, famoso pelo Grande Prêmio de Fórmula 1', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'BRASIL', 'dica': 'O único país pentacampeão mundial de futebol e maior da América Latina', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'JAPAO', 'dica': 'Arquipélago asiático conhecido como a Terra do Sol Nascente', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'FRANCA', 'dica': 'Nação europeia famosa pela Torre Eiffel e pela gastronomia refinada', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'EGITO', 'dica': 'País africano conhecido por suas pirâmides milenares e pelo Rio Nilo', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'ITALIA', 'dica': 'País europeu com formato de bota, berço do Império Romano', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'CHINA', 'dica': 'O país mais populoso do mundo, famoso por sua Grande Muralha', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'ARGENTINA', 'dica': 'País sul-americano conhecido pelo tango e por ser o berço de Messi', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'CANADA', 'dica': 'O segundo maior país em extensão territorial, representado pela folha de bordo', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'MEXICO', 'dica': 'País da América do Norte famoso pelos seus tacos e civilizações astecas', 'categoria': 'Paises', 'dificuldade': 'facil'},
      {'texto': 'AUSTRALIA', 'dica': 'País continental famoso por seus cangurus e pela Grande Barreira de Corais', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'TURQUIA', 'dica': 'Nação que une a Europa e a Ásia, famosa pela cidade de Istambul', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'NORUEGA', 'dica': 'País escandinavo conhecido por seus fiordes e pela Aurora Boreal', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'GRECIA', 'dica': 'Berço da democracia e da filosofia, composto por milhares de ilhas', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'INDIA', 'dica': 'País asiático com cultura milenar e o famoso monumento Taj Mahal', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'TAILANDIA', 'dica': 'Nação do sudeste asiático famosa por seus templos budistas e praias paradisíacas', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'PORTUGAL', 'dica': 'País europeu famoso pelo fado, pelo bacalhau e por sua história de navegação', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'CHILE', 'dica': 'País longo e estreito na América do Sul, lar da Cordilheira dos Andes', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'SUECIA', 'dica': 'País nórdico conhecido por marcas como Volvo, IKEA e a banda ABBA', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'EGITO', 'dica': 'País africano que abriga a única das Sete Maravilhas do Mundo Antigo que resta', 'categoria': 'Paises', 'dificuldade': 'medio'},
      {'texto': 'MADAGASCAR', 'dica': 'Grande ilha africana no Oceano Índico com fauna e flora únicas', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'LUXEMBURGO', 'dica': 'Um dos menores países da Europa, situado entre a Bélgica, França e Alemanha', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'INDONESIA', 'dica': 'O maior arquipélago do mundo, composto por mais de 17 mil ilhas', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'QUENIA', 'dica': 'País da África Oriental famoso por suas reservas de safári e maratonistas', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'FILIPINAS', 'dica': 'País insular no sudeste asiático que foi colônia da Espanha e dos EUA', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'SURINAME', 'dica': 'País vizinho ao Brasil que tem o holandês como língua oficial', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'CAZAQUISTAO', 'dica': 'O maior país do mundo sem costa marítima, localizado na Ásia Central', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'BUTAO', 'dica': 'Reino no Himalaia conhecido por medir o Índice de Felicidade Interna Bruta', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'FINLANDIA', 'dica': 'País europeu frequentemente eleito o mais feliz do mundo e lar do Papai Noel', 'categoria': 'Paises', 'dificuldade': 'dificil'},
      {'texto': 'UZBEQUISTAO', 'dica': 'País da Ásia Central famoso por sua arquitetura de mesquitas na Rota da Seda', 'categoria': 'Paises', 'dificuldade': 'dificil'},
    ];

    for (final p in palavras) {
      await db.insert('palavras', p);
    }

    // Segurança para não duplicar os jogadores no Multiplayer a cada atualização
    final listPontuacao = await db.query('pontuacao');
    if (listPontuacao.isEmpty) {
      await db.insert('pontuacao', {'jogador': 'Jogador 1', 'vitorias': 0, 'derrotas': 0});
      await db.insert('pontuacao', {'jogador': 'Jogador 2', 'vitorias': 0, 'derrotas': 0});
    }
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

  // ============================================================
  // SISTEMA DE CONQUISTAS (Estatísticas do Jogador)
  // ============================================================

  /// Busca um valor numérico de uma estatística no banco de dados
  Future<int> buscarEstatistica(String nomeEstatistica) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'estatisticas',
      columns: ['valor'],
      where: 'nome = ?',
      whereArgs: [nomeEstatistica],
    );

    if (maps.isNotEmpty) {
      return maps.first['valor'] as int;
    }
    return 0;
  }

  /// Incrementa uma estatística e retorna o novo valor
  Future<int> incrementarEstatistica(String nomeEstatistica) async {
    final db = await database;

    // Insere com valor 1 se não existir, ou ignora se já existir
    await db.rawInsert('''
      INSERT OR IGNORE INTO estatisticas (nome, valor) VALUES (?, 0)
    ''', [nomeEstatistica]);

    // Atualiza incrementando +1
    await db.rawUpdate('''
      UPDATE estatisticas SET valor = valor + 1 WHERE nome = ?
    ''', [nomeEstatistica]);

    return await buscarEstatistica(nomeEstatistica);
  }
  // ============================================================
  // MÉTODOS PARA O SISTEMA DE CONQUISTAS COMBINADAS
  // ============================================================

  /// Registra que o jogador acertou uma palavra específica.
  Future<void> registrarPalavraAcertada(String palavra) async {
    final palavraFormatada = palavra.toUpperCase().trim();
    await incrementarEstatistica('palavra_$palavraFormatada');
  }

  /// Verifica se TODAS as palavras de uma lista já foram acertadas pelo menos uma vez.
  Future<bool> verificouTodasPalavras(List<String> palavras) async {
    for (String p in palavras) {
      final count = await buscarEstatistica('palavra_${p.toUpperCase()}');
      if (count == 0) {
        return false; // Se faltar uma, interrompe e retorna falso
      }
    }
    return true; // Acertou todas as palavras da lista
  }

  /// Marca uma conquista como desbloqueada localmente
  Future<void> registrarConquistaLocal(String idConquista) async {
    await incrementarEstatistica('conq_local_$idConquista');
  }

  /// Verifica se a conquista já foi disparada anteriormente para evitar repetição
  Future<bool> conquistaJaDesbloqueada(String idConquista) async {
    final count = await buscarEstatistica('conq_local_$idConquista');
    return count > 0;
  }
}