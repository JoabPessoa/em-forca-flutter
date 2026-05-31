import 'package:games_services/games_services.dart';

class PlayGamesHelper {
  /// Tenta logar o usuário silenciosamente
  static Future<void> iniciarLogin() async {
    try {
      await GamesServices.signIn();
      print("Login no Play Games realizado com sucesso!");
    } catch (e) {
      print("Erro ao autenticar no Play Games: $e");
    }
  }

  /// Desbloqueia uma conquista específica
  static Future<void> desbloquearConquista(String idConquista) async {
    try {
      await GamesServices.unlock(
        achievement: Achievement(androidID: idConquista),
      );
      print("Conquista $idConquista desbloqueada na nuvem!");
    } catch (e) {
      print("Falha ao desbloquear conquista: $e");
    }
  }
}