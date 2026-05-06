import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class AudioManager with WidgetsBindingObserver {
  // Padrão Singleton para existir apenas uma instância de áudio rodando
  static final AudioManager instance = AudioManager._init();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double volumeMusica = 0.5;
  double volumeEfeitos = 1.0;

  // Construtor privado
  AudioManager._init() {
    // 1. Avisa ao Flutter para avisar o AudioManager quando o app minimizar/voltar
    WidgetsBinding.instance.addObserver(this);
  }

  // 2. Função mágica que é chamada automaticamente pelo sistema do celular
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // O usuário minimizou o app, abriu a multitarefa ou recebeu uma ligação
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      // O usuário voltou para o jogo!
      _bgmPlayer.resume();
    }
  }

  Future<void> init() async {
    // Faz a música de fundo repetir infinitamente
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playMusica(String nomeArquivo) async {
    await _bgmPlayer.stop(); // Para a música atual antes de tocar a nova
    await _bgmPlayer.setVolume(volumeMusica);
    await _bgmPlayer.play(AssetSource('audio/$nomeArquivo'));
  }

  Future<void> playClique() async {
    await _sfxPlayer.setVolume(volumeEfeitos);
    // Tocar o efeito não interrompe a música de fundo
    await _sfxPlayer.play(AssetSource('audio/clique.mp3'));
  }

  Future<void> setVolumeMusica(double vol) async {
    volumeMusica = vol;
    await _bgmPlayer.setVolume(vol);
  }

  Future<void> setVolumeEfeitos(double vol) async {
    volumeEfeitos = vol;
  }
}