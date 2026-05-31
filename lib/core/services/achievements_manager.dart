import '../../database/database_helper.dart';
import 'play_games_helper.dart';
import '../constants/achievements_ids.dart';

class AchievementsManager {

  /// Método principal que deve ser chamado logo após o SQLite salvar a partida.
  /// Ele cruza os dados da rodada atual com o histórico do jogador.
  static Future<void> processarFimDePartida({
    required bool venceu,
    required String categoriaJogada,
    required String dificuldade,
    required int errosCometidos,
  }) async {

    // 1. Instância do seu banco local
    final db = DatabaseHelper.instance;

    // 2. Busca o estado mais atualizado do jogador após o salvamento da última rodada
    int totalPartidas = await db.buscarEstatistica('total_partidas');
    int sequenciaVitorias = await db.buscarEstatistica('sequencia_vitorias');
    int partidasCategoria = await db.buscarEstatistica('cat_$categoriaJogada');

    // 3. Direciona para os submódulos de validação
    _validarVolumeGeral(totalPartidas);
    _validarDesempenho(venceu, errosCometidos, dificuldade, sequenciaVitorias);
    _validarCategorias(categoriaJogada, partidasCategoria);
  }

  // ==========================================
  // MÓDULOS DE VALIDAÇÃO (Regras de Negócio)
  // ==========================================

  static void _validarVolumeGeral(int total) {
    if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.primeiroRascunho);
    if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.quadroPreenchido);
    if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.veteranoDoGiz);
  }

  static void _validarDesempenho(bool venceu, int erros, String dificuldade, int sequencia) {
    if (!venceu) return; // As conquistas abaixo exigem vitória

    if (erros == 0) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.tracoPerfeito);
    }

    if (erros == 5) { // Assumindo que a forca completa tem 6 partes (resta 1 coração)
      PlayGamesHelper.desbloquearConquista(AchievementIds.noLimiteDoFeltro);
    }

    if (sequencia >= 5) {
      PlayGamesHelper.desbloquearConquista(AchievementIds.quadroImaculado);
    }

    if (dificuldade == 'Dificil') {
      PlayGamesHelper.desbloquearConquista(AchievementIds.mestreDoMarcador);
    }
  }

  static void _validarCategorias(String categoria, int total) {
    switch (categoria) {
      case 'Animais':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais10);
        if (total >= 50) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais50);
        if (total >= 100) PlayGamesHelper.desbloquearConquista(AchievementIds.catAnimais100);
        break;

      case 'Tecnologia':
        if (total >= 10) PlayGamesHelper.desbloquearConquista(AchievementIds.helloWorld);
        // Implementar IDs de 50 e 100...
        break;

      case 'Tudo': // Conhecimento Geral
        PlayGamesHelper.desbloquearConquista(AchievementIds.conhecimentoGeral);
        break;
    }
  }
}