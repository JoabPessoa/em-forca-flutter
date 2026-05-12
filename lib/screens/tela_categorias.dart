import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/database_helper.dart';
import '../theme/app_tema.dart';
import '../audio_manager.dart';
import 'tela_jogo.dart';
import 'tela_personalizacao.dart';

class TelaCategorias extends StatefulWidget {
  final bool modoMultiplayer;

  const TelaCategorias({super.key, required this.modoMultiplayer});

  @override
  State<TelaCategorias> createState() => _TelaCategoriasState();
}

class _TelaCategoriasState extends State<TelaCategorias> {
  List<String> _categorias = [];
  bool _carregando = true;
  int _nivelDificuldade = 1;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final cats = await DatabaseHelper.instance.buscarCategorias();
    setState(() {
      // Aqui definimos a ordem exata: Personalizada no topo, Todas em seguida, e o resto depois!
      _categorias = ['Personalizada', 'Todas', ...cats];
      _carregando = false;
    });
  }

  String _getImagemCategoria(String categoriaNome) {
    switch (categoriaNome) {
      case 'Personalizada':
        return 'assets/images/btn_cat_personalizada.png'; // A sua nova arte do lápis!
      case 'Todas':
        return 'assets/images/btn_cat_todas.png'; // O botão de "Todas" de volta ao jogo!
      case 'Animais':
        return 'assets/images/btn_cat_animais.png';
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
      case 'Música - Cantores':
        return 'assets/images/btn_cat_cantores.png';
      default:
        return 'assets/images/btn_cat_todas.png';
    }
  }

  String get _modoJogoSelecionado {
    switch (_nivelDificuldade) {
      case 1: return 'rodinhas';
      case 2: return 'facil';
      case 3: return 'medio';
      case 4: return 'dificil';
      default: return 'rodinhas';
    }
  }

  Widget _buildEstrela(int nivelDaEstrela, String imgAcesa, String imgApagada) {
    bool isAcesa = _nivelDificuldade >= nivelDaEstrela;
    return GestureDetector(
      onTap: () {
        AudioManager.instance.playClique();
        setState(() {
          _nivelDificuldade = nivelDaEstrela;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, isAcesa ? -4 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Image.asset(
          isAcesa ? imgAcesa : imgApagada,
          width: 50,
        ),
      ),
    );
  }

  Widget _buildSeletorDificuldade() {
    return Column(
      children: [
        const Text(
          'Dificuldade:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTema.texto,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEstrela(1, 'assets/images/btn_nvl_bebe.png', 'assets/images/btn_nvl_bebe.png'),
            _buildEstrela(2, 'assets/images/btn_nvl_facil.png', 'assets/images/btn_d_nvl_facil.png'),
            _buildEstrela(3, 'assets/images/btn_nvl_medio.png', 'assets/images/btn_d_nvl_medio.png'),
            _buildEstrela(4, 'assets/images/btn_nvl_dificil.png', 'assets/images/btn_d_nvl_dificil.png'),
          ],
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_quadro_branco.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: _carregando
                ? const Center(child: CircularProgressIndicator(color: AppTema.verde))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            AudioManager.instance.playClique();
                            Navigator.pop(context);
                          },
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

                const SizedBox(height: 20),
                _buildSeletorDificuldade(),
                const SizedBox(height: 24),

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
    AudioManager.instance.playClique();

    if (categoria == 'Personalizada') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TelaPersonalizacao(modoMultiplayer: widget.modoMultiplayer)),
      );
      return;
    }

    // Se clicar em "Todas" ou numa categoria específica, o banco de dados vai receber a lista adequadamente.
    DatabaseHelper.instance.resetarMemoriaDePalavras();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaJogo(
          categorias: [categoria],
          modoJogo: _modoJogoSelecionado,
          modoMultiplayer: widget.modoMultiplayer,
          jogadorAtual: widget.modoMultiplayer ? 1 : 0,
        ),
      ),
    );
  }
}

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
        transform: Matrix4.translationValues(0, _pressionado ? 4 : 0, 0),
        child: Image.asset(
          widget.caminhoImagem,
          fit: BoxFit.contain,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.delay))
        .slideX(begin: 0.1, end: 0);
  }
}