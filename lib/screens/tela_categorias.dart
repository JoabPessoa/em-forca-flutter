// ============================================================
// TELA DE CATEGORIAS
// O jogador escolhe em qual categoria quer jogar
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/database_helper.dart';
import '../theme/app_tema.dart';
import 'tela_jogo.dart';

class TelaCategorias extends StatefulWidget {
  final bool modoMultiplayer;

  const TelaCategorias({super.key, required this.modoMultiplayer});

  @override
  State<TelaCategorias> createState() => _TeleCategoriasState();
}

class _TeleCategoriasState extends State<TelaCategorias> {
  List<String> _categorias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final cats = await DatabaseHelper.instance.buscarCategorias();
    setState(() {
      _categorias = ['Todas', ...cats]; // Adiciona "Todas" no início
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        backgroundColor: AppTema.fundo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTema.texto),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.modoMultiplayer ? '2 Jogadores' : '1 Jogador',
          style: const TextStyle(
            color: AppTema.texto,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: AppTema.verde))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escolha uma categoria',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTema.texto,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 6),

                  Text(
                    'Em qual tema você quer jogar?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTema.neutroEsc,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  Expanded(
                    child: ListView.separated(
                      itemCount: _categorias.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cat = _categorias[index];
                        return _CartaoCategoria(
                          categoria: cat,
                          delay: index * 80,
                          onTap: () => _iniciarJogo(cat),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _iniciarJogo(String categoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaJogo(
          categoria: categoria,
          modoMultiplayer: widget.modoMultiplayer,
          jogadorAtual: widget.modoMultiplayer ? 1 : 0,
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Cartão de Categoria
// ============================================================
class _CartaoCategoria extends StatefulWidget {
  final String categoria;
  final int delay;
  final VoidCallback onTap;

  const _CartaoCategoria({
    required this.categoria,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_CartaoCategoria> createState() => _CartaoCategoriaState();
}

class _CartaoCategoriaState extends State<_CartaoCategoria> {
  bool _pressionado = false;

  @override
  Widget build(BuildContext context) {
    final cor = AppTema.corDaCategoria(widget.categoria);
    final corSombra = HSLColor.fromColor(cor)
        .withLightness(
          (HSLColor.fromColor(cor).lightness - 0.15).clamp(0.0, 1.0),
        )
        .toColor();
    final emoji = AppTema.iconeDaCategoria(widget.categoria);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressionado = true),
      onTapUp: (_) {
        setState(() => _pressionado = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressionado = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 72,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: corSombra,
              offset: Offset(0, _pressionado ? 1 : 5),
              blurRadius: 0,
            ),
          ],
        ),
        transform: Matrix4.translationValues(0, _pressionado ? 4 : 0, 0),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 16),
            Text(
              widget.categoria,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            const SizedBox(width: 20),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.delay))
        .slideX(begin: 0.1, end: 0);
  }
}
