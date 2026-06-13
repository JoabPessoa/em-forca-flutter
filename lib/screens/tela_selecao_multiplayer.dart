import 'package:flutter/material.dart';
import 'package:jogo_forca/screens/tela_categorias.dart';
import 'package:jogo_forca/screens/tela_arquiteto.dart';
import '../audio_manager.dart';
import '../theme/app_tema.dart';

class TelaSelecaoMultiplayer extends StatelessWidget {
  const TelaSelecaoMultiplayer({super.key});

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
                // Estrutura central idêntica à Tela Inicial
                SizedBox(
                  width: larguraTela,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CABEÇALHO (Logo + Subtítulo do Modo)
                      Column(
                        children: [
                          Image.asset('assets/images/logo_icone.png', width: larguraTela * 0.3),
                          const SizedBox(height: 16),
                          Image.asset('assets/images/logo_em_forca.png', width: larguraTela * 0.8),
                          const SizedBox(height: 8),
                        ],
                      ),

                      // BOTÕES CENTRAIS (Agora com a mesma proporção 4.5 da tela inicial)
                      Column(
                        children: [
                          _BotaoModo(
                            imagem: 'assets/images/btn_modo_classico.png',
                            largura: larguraTela * 0.85,
                            onTap: () {
                              AudioManager.instance.playClique();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const TelaCategorias(
                                    modoMultiplayer: true,
                                    tipoMultiplayer: 'classico',
                                  )
                              ));
                            },
                          ),
                          const SizedBox(height: 16),
                          _BotaoModo(
                            imagem: 'assets/images/btn_modo_cabo.png',
                            largura: larguraTela * 0.85,
                            onTap: () {
                              AudioManager.instance.playClique();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const TelaCategorias(
                                    modoMultiplayer: true,
                                    tipoMultiplayer: 'cabo_de_guerra',
                                  )
                              ));
                            },
                          ),
                          const SizedBox(height: 16),
                          _BotaoModo(
                            imagem: 'assets/images/btn_modo_arquiteto.png',
                            largura: larguraTela * 0.85,
                            onTap: () {
                              AudioManager.instance.playClique();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const TelaArquiteto()
                              ));
                            },
                          ),
                        ],
                      ),

                      // RODAPÉ
                      Image.asset('assets/images/logo_jam_labs.png', height: 40),
                    ],
                  ),
                ),

                // BOTÃO DE VOLTAR (Posicionado no mesmo local da engrenagem, mas na esquerda)
                Positioned(
                  top: 10,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      AudioManager.instance.playClique();
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/images/ic_voltar.png', width: 36), // Usando o voltar padrão das categorias
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

class _BotaoModo extends StatelessWidget {
  final String imagem;
  final double largura;
  final VoidCallback onTap;

  const _BotaoModo({required this.imagem, required this.largura, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: largura,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(imagem), fit: BoxFit.contain)
        ),
        // O AspectRatio foi ajustado de 3.5 para 4.5 para ser idêntico à tela inicial!
        child: const AspectRatio(aspectRatio: 4.5),
      ),
    );
  }
}