import '../../database/database_helper.dart';
import 'play_games_helper.dart';
import '../constants/achievements_ids.dart';

class AchievementsManager {
  static Future<void> processarFimDePartida({
    required bool venceu,
    required String categoriaJogada,
    required String modoJogo,
    required bool modoMultiplayer,
    required String palavraTexto,
    required List<String> categoriasSelecionadas,
    required int errosCometidos,
  }) async {
    final db = DatabaseHelper.instance;

    int totalPartidas = await db.buscarEstatistica('total_partidas');
    int sequenciaVitorias = await db.buscarEstatistica('sequencia_vitorias');
    int palavrasAcertadasCategoria = await db.buscarEstatistica('cat_$categoriaJogada');

    // NOVO: Contador específico para partidas Multiplayer
    int totalMultiplayer = 0;
    if (modoMultiplayer) {
      totalMultiplayer = await db.incrementarEstatistica('total_multiplayer');
    }

    _validarVolumeGeral(totalPartidas);
    _validarDesempenho(venceu, errosCometidos, modoJogo, sequenciaVitorias);
    _validarModosDeJogo(categoriasSelecionadas, modoMultiplayer, totalMultiplayer); // Passando o novo contador
    _validarEasterEggs(palavraTexto);

    // Avalia as conquistas evolutivas e secretas apenas se o jogador acertou a palavra
    if (venceu) {
      _validarCategoriasEvolutivas(categoriaJogada, palavrasAcertadasCategoria);
      await _validarConquistasSecretas(palavraTexto);
    }
  }

  static void _validarVolumeGeral(int total) {
    if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.primeiroRascunho);
    if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.quadroPreenchido);
    if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.veteranoDoGiz);
  }

  static void _validarDesempenho(bool venceu, int erros, String modoJogo, int sequencia) {
    if (!venceu) return;
    if (erros == 0) PlayGamesHelper.desbloquearConquista(AchievementIds.tracoPerfeito);
    if (erros == 5) PlayGamesHelper.desbloquearConquista(AchievementIds.noLimiteDoFeltro);
    if (sequencia >= 5) PlayGamesHelper.desbloquearConquista(AchievementIds.quadroImaculado);
    if (modoJogo == 'dificil') PlayGamesHelper.desbloquearConquista(AchievementIds.mestreDoMarcador);
  }

  // ATUALIZADO: Agora gerencia corretamente as partidas e o novo Modo Arquiteto
  static void _validarModosDeJogo(List<String> categoriasSelecionadas, bool modoMultiplayer, int totalMultiplayer) {
    if (modoMultiplayer) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.divisoriaNoQuadro); // 1ª Partida

      // Só desbloqueia quando o banco registrar 10 partidas multiplayer
      if (totalMultiplayer >= 10) {
        PlayGamesHelper.desbloquearConquista(AchievementIds.dueloDePilotos);
      }
    }

    if (categoriasSelecionadas.contains('Todas') && categoriasSelecionadas.length == 1) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.conhecimentoGeral);
    } else if ((categoriasSelecionadas.length > 1 && !categoriasSelecionadas.contains('Todas')) || categoriasSelecionadas.contains('Modo Arquiteto')) {
      // O jogador ganha a conquista se selecionar várias categorias OU se jogar o Modo Arquiteto!
      PlayGamesHelper.desbloquearConquista(AchievementIds.arquitetoDaForca);
    }
  }

  static void _validarEasterEggs(String palavra) {
    final textoFormatado = palavra.toUpperCase().trim();
    if (textoFormatado == 'ARARA') PlayGamesHelper.desbloquearConquista(AchievementIds.coordenadasSecretas);
    if (textoFormatado == 'LACRAIA') PlayGamesHelper.desbloquearConquista(AchievementIds.lacrianeLacradora);
  }

  static void _validarCategoriasEvolutivas(String categoria, int acertos) {
    switch (categoria) {
      case 'Animais':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais100);
        break;
      case 'Comidas e Bebidas':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catComidas10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catComidas50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catComidas100);
        break;
      case 'Contos de Fada':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catContos10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catContos50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catContos100);
        break;
      case 'Esportes':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catEsportes10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catEsportes50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catEsportes100);
        break;
      case 'Filmes e Séries':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catFilmes10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catFilmes50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catFilmes100);
        break;
      case 'Mitologia':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catMitologia10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catMitologia50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catMitologia100);
        break;
      case 'Música':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catMusica10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catMusica50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catMusica100);
        break;
      case 'Música - Cantores':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catCantores10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catCantores50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catCantores100);
        break;
      case 'Paises':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catPaises10);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.catPaises50);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catPaises100);
        break;
      case 'Tecnologia':
        if (acertos >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.helloWorld);
        if (acertos >= 25) PlayGamesHelper.desbloquearConquista(AchievementIds.arquitetoSistemas);
        if (acertos >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.mestreCodigo);
        break;
    }
  }

  static Future<void> _validarConquistasSecretas(String palavra) async {
    final db = DatabaseHelper.instance;

    await db.registrarPalavraAcertada(palavra);

    final Map<String, List<String>> requisitos = {
      AchievementIds.achTriatlo: ['CORRIDA', 'NATACAO', 'CICLISMO'],
      AchievementIds.achZoologo: ['ORNITORRINCO', 'AXOLOTE', 'PANGOLIM', 'NARVAL'],
      AchievementIds.achFullstack: ['HTML', 'CSS', 'JAVASCRIPT', 'BANCO DE DADOS'],
      AchievementIds.achDeuses: ['ZEUS', 'POSEIDON', 'HADES'],
      AchievementIds.achInfantil: ['PIZZA', 'BRIGADEIRO', 'COXINHA', 'CACHORRO QUENTE', 'BATATA FRITA', 'BOLO'],
      AchievementIds.achNerd: ['HOMEM ARANHA', 'BATMAN', 'THE FLASH', 'SUPERMAN'],
      AchievementIds.achSitcons: [
        'FRIENDS', 'MODERN FAMILY', 'THE BIG BANG THEORY', 'UM MALUCO NO PEDACO',
        'HOW I MET YOUR MOTHER', 'DOIS HOMENS E MEIO', 'EU A PATROA E AS CRIANCAS',
        'COMMUNITY', 'A GRANDE FAMILIA', 'SEINFELD', 'PARKS AND RECREATION'
      ],
    };

    for (var entry in requisitos.entries) {
      String idConquista = entry.key;
      List<String> palavrasNecessarias = entry.value;

      bool jaDesbloqueada = await db.conquistaJaDesbloqueada(idConquista);
      if (jaDesbloqueada) continue;

      bool cumpriuRequisitos = await db.verificouTodasPalavras(palavrasNecessarias);

      if (cumpriuRequisitos) {
        PlayGamesHelper.desbloquearConquista(idConquista);
        await db.registrarConquistaLocal(idConquista);
      }
    }
  }
}