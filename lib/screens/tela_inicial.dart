// ============================================================
// TELA INICIAL — Atualizada
// - Nome do app: "Em Forca"
// - Logo: imagem personalizada (assets/logo.png)
// - Ícones dos botões: imagens personalizadas
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_tema.dart';
import 'tela_categorias.dart';
import 'tela_pontuacao.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo personalizada ---
                Image.asset(
                  'assets/logo.png',
                  height: 140,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 20),

                Text(
                  'EM FORCA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppTema.texto,
                    letterSpacing: 3,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Adivinhe a palavra letra por letra!',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTema.neutroEsc,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 48),

                _BotaoMenu(
                  imagemAsset: 'assets/um_jogador.png',
                  titulo: '1 Jogador',
                  subtitulo: 'Jogue sozinho',
                  cor: AppTema.verde,
                  corSombra: AppTema.verdeEscuro,
                  delay: 400,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaCategorias(modoMultiplayer: false),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _BotaoMenu(
                  imagemAsset: 'assets/dois_jogadores.png',
                  titulo: '2 Jogadores',
                  subtitulo: 'Vez a vez no mesmo celular',
                  cor: AppTema.azul,
                  corSombra: AppTema.azulEscuro,
                  delay: 500,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaCategorias(modoMultiplayer: true),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _BotaoMenu(
                  imagemAsset: 'assets/trofeu.png',
                  titulo: 'Placar',
                  subtitulo: 'Veja as pontuações',
                  cor: AppTema.amarelo,
                  corSombra: const Color(0xFFCCA800),
                  delay: 600,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaPontuacao()),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Feito por Joab, Augusto, Arthur e Michael. 💙',
                  style: TextStyle(fontSize: 12, color: AppTema.neutroEsc),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotaoMenu extends StatefulWidget {
  final String imagemAsset;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final Color corSombra;
  final int delay;
  final VoidCallback onTap;

  const _BotaoMenu({
    required this.imagemAsset,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.corSombra,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_BotaoMenu> createState() => _BotaoMenuState();
}

class _BotaoMenuState extends State<_BotaoMenu> {
  bool _pressionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressionado = true),
      onTapUp: (_) {
        setState(() => _pressionado = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressionado = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        height: 72,
        decoration: BoxDecoration(
          color: widget.cor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.corSombra,
              offset: Offset(0, _pressionado ? 1 : 5),
              blurRadius: 0,
            ),
          ],
        ),
        transform: Matrix4.translationValues(0, _pressionado ? 4 : 0, 0),
        child: Row(
          children: [
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                widget.imagemAsset,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.subtitulo,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            const SizedBox(width: 20),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.delay))
        .slideY(begin: 0.2, end: 0);
  }
}
