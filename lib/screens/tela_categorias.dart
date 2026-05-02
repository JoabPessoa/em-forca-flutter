import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/database_helper.dart';
import '../theme/app_tema.dart';
import 'tela_jogo.dart';

class TelaCategorias extends StatefulWidget {
  final bool modoMultiplayer;

  const TelaCategorias({super.key, required this.modoMultiplayer});

  @override
  State<TelaCategorias> createState() => _TelaCategoriasState();
}

class _TelaCategoriasState extends State<TelaCategorias> {
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

  // Função para mapear o nome da categoria no Banco de Dados para a sua imagem desenhada
  String _getImagemCategoria(String categoriaNome) {
    switch (categoriaNome) {
      case 'Todas':
        return 'assets/images/btn_cat_todas.png';
      case 'Comidas e Bebidas':
        return 'assets/images/btn_cat_comidas.png';
      case 'Esportes':
        return 'assets/images/btn_cat_esportes.png';
      case 'Filmes e Séries':
        return 'assets/images/btn_cat_filmes.png';
      case 'Música':
        return 'assets/images/btn_cat_musica.png';
      case 'Tecnologia':
        return 'assets/images/btn_cat_tecnologia.png';
      default:
        return 'assets/images/btn_cat_todas.png'; // Fallback de segurança
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. FUNDO DO QUADRO BRANCO
          Image.asset(
            'assets/images/bg_quadro_branco.jpg',
            fit: BoxFit.cover,
          ),

          // 2. CONTEÚDO PRINCIPAL
          SafeArea(
            child: _carregando
                ? const Center(child: CircularProgressIndicator(color: AppTema.verde))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CABEÇALHO CUSTOMIZADO ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset('assets/images/ic_voltar.png', width: 36),
                        ),
                      ),
                      Text(
                        widget.modoMultiplayer ? '2 Jogadores' : '1 Jogador',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTema.texto,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- TÍTULOS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Escolha um tema:',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTema.texto,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 4),

                      const Text(
                        'O que vamos desenhar na forca hoje?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- LISTA DE CATEGORIAS (AGORA COM AS SUAS IMAGENS) ---
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _categorias.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final cat = _categorias[index];
                      return _BotaoCategoriaImagem(
                        caminhoImagem: _getImagemCategoria(cat),
                        delay: index * 80,
                        onTap: () => _iniciarJogo(cat),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
// WIDGET: Botão de Categoria usando Imagem Customizada
// ============================================================
class _BotaoCategoriaImagem extends StatefulWidget {
  final String caminhoImagem;
  final int delay;
  final VoidCallback onTap;

  const _BotaoCategoriaImagem({
    required this.caminhoImagem,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_BotaoCategoriaImagem> createState() => _BotaoCategoriaImagemState();
}

class _BotaoCategoriaImagemState extends State<_BotaoCategoriaImagem> {
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
        duration: const Duration(milliseconds: 60),
        // Efeito de pressionar a imagem para baixo
        transform: Matrix4.translationValues(0, _pressionado ? 4 : 0, 0),
        child: Image.asset(
          widget.caminhoImagem,
          fit: BoxFit.contain, // Garante que a proporção da sua arte se mantenha intacta
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.delay))
        .slideX(begin: 0.1, end: 0);
  }
}