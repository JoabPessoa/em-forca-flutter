import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class AudioManager with WidgetsBindingObserver {
  // Padrão Singleton para existir apenas uma instância de áudio a correr
  static final AudioManager instance = AudioManager._init();

  // O 'late' garante que estes players só são criados quando nós quisermos!
  late final AudioPlayer _bgmPlayer;
  late final AudioPlayer _sfxPlayer;

  double volumeMusica = 0.5;
  double volumeEfeitos = 1.0;

  // Construtor privado
  AudioManager._init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      _bgmPlayer.resume();
    }
  }

  Future<void> init() async {
    // 1. PRIMEIRO: Aplicamos a regra global para não interromper outras aplicações (Spotify)
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: [
          AVAudioSessionOptions.mixWithOthers,
        ],
      ),
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);

    // 2. SEGUNDO: Agora sim, criamos os reprodutores com as regras já em vigor
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    // Faz a música de fundo repetir infinitamente
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playMusica(String nomeArquivo) async {
    await _bgmPlayer.stop();
    await _bgmPlayer.setVolume(volumeMusica);
    await _bgmPlayer.play(AssetSource('audio/$nomeArquivo'));
  }

  Future<void> playClique() async {
    await _sfxPlayer.setVolume(volumeEfeitos);
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