import 'package:flutter/material.dart';
import 'package:jogo_forca/screens/tela_categorias.dart';
import 'package:jogo_forca/screens/tela_pontuacao.dart';
import '../audio_manager.dart';
import '../theme/app_tema.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {

  @override
  void initState() {
    super.initState();
    // Inicia a música do menu assim que o app abre
    AudioManager.instance.playMusica('musica_menu.mp3');
  }

  void _abrirConfiguracoesAudio() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 320,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bg_dialog.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(30, 45, 30, 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Som', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTema.texto)),
                          const SizedBox(height: 24),

                          // Slider de Música
                          const Text('Música', style: TextStyle(fontWeight: FontWeight.w700)),
                          Slider(
                            value: AudioManager.instance.volumeMusica,
                            activeColor: AppTema.azul,
                            onChanged: (val) {
                              setStateDialog(() => AudioManager.instance.setVolumeMusica(val));
                            },
                          ),

                          const SizedBox(height: 16),

                          // Slider de Efeitos
                          const Text('Efeitos', style: TextStyle(fontWeight: FontWeight.w700)),
                          Slider(
                            value: AudioManager.instance.volumeEfeitos,
                            activeColor: AppTema.verde,
                            onChanged: (val) {
                              setStateDialog(() => AudioManager.instance.setVolumeEfeitos(val));
                            },
                            onChangeEnd: (val) => AudioManager.instance.playClique(),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BOTÃO DE FITA
                    GestureDetector(
                      onTap: () {
                        AudioManager.instance.playClique();
                        Navigator.pop(context);
                      },
                      child: Image.asset('assets/images/sair_btn.png', width: 120),
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg_quadro_branco.jpg', fit: BoxFit.cover),

          SafeArea(
            child: Stack(
              children: [
                // Envolvemos a Column em um SizedBox com a largura total da tela para forçar a centralização
                SizedBox(
                  width: larguraTela,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CABEÇALHO
                      Column(
                        children: [
                          Image.asset('assets/images/logo_icone.png', width: larguraTela * 0.3),
                          const SizedBox(height: 16),
                          Image.asset('assets/images/logo_em_forca.png', width: larguraTela * 0.8),
                          const SizedBox(height: 10),
                        ],
                      ),

                      // BOTÕES CENTRAIS
                      Column(
                        children: [
                          _BotaoCustomizado(
                            imagem: 'assets/images/btn_1_jogador.png',
                            largura: larguraTela * 0.85,
                            aoPressionar: () {
                              AudioManager.instance.playClique();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaCategorias(modoMultiplayer: false)));
                            },
                          ),
                          const SizedBox(height: 16),
                          _BotaoCustomizado(
                            imagem: 'assets/images/btn_2_jogadores.png',
                            largura: larguraTela * 0.85,
                            aoPressionar: () {
                              AudioManager.instance.playClique();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaCategorias(modoMultiplayer: true)));
                            },
                          ),
                          const SizedBox(height: 16),
                          _BotaoCustomizado(
                            imagem: 'assets/images/btn_placar.png',
                            largura: larguraTela * 0.85,
                            aoPressionar: () {
                              AudioManager.instance.playClique();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaPontuacao()));
                            },
                          ),
                        ],
                      ),

                      Image.asset('assets/images/logo_jam_labs.png', height: 40),
                    ],
                  ),
                ),

                // Ícone de configuração reduzido para 30
                Positioned(
                  top: 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      AudioManager.instance.playClique();
                      _abrirConfiguracoesAudio();
                    },
                    child: Image.asset('assets/images/ic_config.png', width: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoCustomizado extends StatelessWidget {
  final String imagem;
  final double largura;
  final VoidCallback aoPressionar;

  const _BotaoCustomizado({required this.imagem, required this.largura, required this.aoPressionar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoPressionar,
      child: Container(
        width: largura,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(imagem), fit: BoxFit.contain)),
        child: const AspectRatio(aspectRatio: 4.5),
      ),
    );
  }
}