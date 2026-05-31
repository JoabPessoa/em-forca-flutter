import '../../database/database_helper.dart';
import 'play_games_helper.dart';
import '../constants/achievements_ids.dart';

class AchievementsManager {
  /// Método principal que cruza os dados da rodada com o histórico do jogador.
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

    // 1. Procura os dados consolidados no SQLite local
    int totalPartidas = await db.buscarEstatistica('total_partidas');
    int sequenciaVitorias = await db.buscarEstatistica('sequencia_vitorias');
    int partidasCategoria = await db.buscarEstatistica('cat_$categoriaJogada');

    // 2. Direciona o fluxo para os submódulos de validação específicos
    _validarVolumeGeral(totalPartidas);
    _validarDesempenho(venceu, errosCometidos, modoJogo, sequenciaVitorias);
    _validarCategorias(categoriaJogada, partidasCategoria);
    _validarModosDeJogo(categoriasSelecionadas, modoMultiplayer);
    _validarEasterEggs(palavraTexto);

    // 3. Verifica a grande conquista final (Platina)
    await _verificarPlatina(db);
  }

  // ==========================================
  // MÓDULOS DE VALIDAÇÃO (Regras de Negócio)
  // ==========================================

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

  static void _validarModosDeJogo(List<String> categoriasSelecionadas, bool modoMultiplayer) {
    if (modoMultiplayer) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.dueloDePilotos);
      PlayGamesHelper.desbloquearConquista(AchievementIds.divisoriaNoQuadro);
    }

    if (categoriasSelecionadas.contains('Todas') && categoriasSelecionadas.length == 1) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.conhecimentoGeral);
    } else if (categoriasSelecionadas.length > 1 && !categoriasSelecionadas.contains('Todas')) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.arquitetoDaForca);
    }
  }

  static void _validarEasterEggs(String palavra) {
    final textoFormatado = palavra.toUpperCase().trim();

    if (textoFormatado == 'ARARA') {
      // Correção: A palavra Arara agora desbloqueia a conquista com as coordenadas!
      PlayGamesHelper.desbloquearConquista(AchievementIds.coordenadasSecretas);
    } else if (textoFormatado == 'LACRAIA') {
      PlayGamesHelper.desbloquearConquista(AchievementIds.lacrianeLacradora);
    }
  }

  static Future<void> _verificarPlatina(DatabaseHelper db) async {
    // A verdadeira Platina exige dedicação: 100 partidas em todas as categorias listadas.
    final categorias = [
      'Animais', 'Comidas e Bebidas', 'Contos de Fada', 'Esportes',
      'Filmes e Séries', 'Mitologia', 'Música', 'Música - Cantores',
      'Paises', 'Tecnologia'
    ];

    bool temMestriaEmTudo = true;

    for (String cat in categorias) {
      int partidasNaCategoria = await db.buscarEstatistica('cat_$cat');
      if (partidasNaCategoria < 100) {
        temMestriaEmTudo = false;
        break; // Se achar uma menor que 100, já aborta a verificação para economizar processamento
      }
    }

    // O prêmio final de agradecimento pela jornada do jogador
    if (temMestriaEmTudo) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.uauInesperado);
    }
  }

  static void _validarCategorias(String categoria, int total) {
    switch (categoria) {
      case 'Animais':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais100);
        break;
      case 'Comidas e Bebidas':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catComidas10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catComidas50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catComidas100);
        break;
      case 'Contos de Fada':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catContos10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catContos50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catContos100);
        break;
      case 'Esportes':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catEsportes10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catEsportes50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catEsportes100);
        break;
      case 'Filmes e Séries':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catFilmes10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catFilmes50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catFilmes100);
        break;
      case 'Mitologia':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catMitologia10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catMitologia50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catMitologia100);
        break;
      case 'Música':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catMusica10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catMusica50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catMusica100);
        break;
      case 'Música - Cantores':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catCantores10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catCantores50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catCantores100);
        break;
      case 'Paises':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catPaises10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catPaises50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catPaises100);
        break;
      case 'Tecnologia':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.helloWorld);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.arquitetoSistemas);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.mestreCodigo);
        break;
    }
  }
}