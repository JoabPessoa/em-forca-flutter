import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/database_helper.dart';
import '../theme/app_tema.dart';
import '../audio_manager.dart';
import 'tela_jogo.dart';

class TelaPersonalizacao extends StatefulWidget {
  final bool modoMultiplayer;

  const TelaPersonalizacao({super.key, required this.modoMultiplayer});

  @override
  State<TelaPersonalizacao> createState() => _TelaPersonalizacaoState();
}

class _TelaPersonalizacaoState extends State<TelaPersonalizacao> {
  List<String> _todasCategorias = [];
  Set<String> _categoriasSelecionadas = {};
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
      _todasCategorias = cats;
      // Por padrão, começa com todas selecionadas
      _categoriasSelecionadas.addAll(cats);
      _carregando = false;
    });
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

  String _getImagemCategoriaLigada(String categoriaNome) {
    switch (categoriaNome) {
      case 'Animais': return 'assets/images/btn_cat_animais.png';
      case 'Comidas e Bebidas': return 'assets/images/btn_cat_comidas.png';
      case 'Esportes': return 'assets/images/btn_cat_esportes.png';
      case 'Filmes e Séries': return 'assets/images/btn_cat_filmes.png';
      case 'Música': return 'assets/images/btn_cat_musica.png';
      case 'Tecnologia': return 'assets/images/btn_cat_tecnologia.png';
      case 'Música - Cantores': return 'assets/images/btn_cat_cantores.png';
      case 'Mitologia': return 'assets/images/btn_cat_mitologias.png';
      case 'Contos de Fada': return 'assets/images/btn_cat_fadas.png';
      default: return 'assets/images/btn_cat_todas.png';
    }
  }

  String _getImagemCategoriaDesligada(String categoriaNome) {
    switch (categoriaNome) {
      case 'Animais': return 'assets/images/btn_cat_d_animais.png';
      case 'Comidas e Bebidas': return 'assets/images/btn_cat_d_comidas.png';
      case 'Esportes': return 'assets/images/btn_cat_d_esportes.png';
      case 'Filmes e Séries': return 'assets/images/btn_cat_d_filmes.png';
      case 'Música': return 'assets/images/btn_cat_d_musica.png';
      case 'Tecnologia': return 'assets/images/btn_cat_d_tecnologia.png';
      case 'Mitologia': return 'assets/images/btn_cat_d_mitologias.png';
      case 'Contos de Fada': return 'assets/images/btn_cat_d_fadas.png';
      case 'Música - Cantores': return 'assets/images/btn_cat_d_cantores.png';

      default: return 'assets/images/btn_cat_todas.png';
    }
  }

  Widget _buildEstrela(int nivelDaEstrela, String imgAcesa, String imgApagada) {
    bool isAcesa = _nivelDificuldade >= nivelDaEstrela;
    return GestureDetector(
      onTap: () {
        AudioManager.instance.playClique();
        setState(() => _nivelDificuldade = nivelDaEstrela);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, isAcesa ? -4 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Image.asset(isAcesa ? imgAcesa : imgApagada, width: 50),
      ),
    );
  }

  void _iniciarJogo() {
    if (_categoriasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma categoria!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTema.vermelho,
        ),
      );
      return;
    }

    AudioManager.instance.playClique();
    DatabaseHelper.instance.resetarMemoriaDePalavras();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TelaJogo(
          categorias: _categoriasSelecionadas.toList(),
          modoJogo: _modoJogoSelecionado,
          modoMultiplayer: widget.modoMultiplayer,
          jogadorAtual: widget.modoMultiplayer ? 1 : 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg_quadro_branco.jpg', fit: BoxFit.cover),
          SafeArea(
            child: _carregando
                ? const Center(child: CircularProgressIndicator(color: AppTema.verde))
                : Column(
              children: [
                // Header
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
                      const Text(
                        'Personalizar Partida',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTema.texto),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Seletor de Dificuldade
                const Text('Dificuldade:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTema.texto)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEstrela(1, 'assets/images/btn_nvl_bebe.png', 'assets/images/btn_nvl_bebe.png'),
                    _buildEstrela(2, 'assets/images/btn_nvl_facil.png', 'assets/images/btn_d_nvl_facil.png'),
                    _buildEstrela(3, 'assets/images/btn_nvl_medio.png', 'assets/images/btn_d_nvl_medio.png'),
                    _buildEstrela(4, 'assets/images/btn_nvl_dificil.png', 'assets/images/btn_d_nvl_dificil.png'),
                  ],
                ),
                const SizedBox(height: 16),

                // Botões Adicionar Tudo / Remover Tudo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        AudioManager.instance.playClique();
                        setState(() => _categoriasSelecionadas.addAll(_todasCategorias));
                      },
                      child: Image.asset('assets/images/btn_add.png', width: 150),
                    ),
                    GestureDetector(
                      onTap: () {
                        AudioManager.instance.playClique();
                        setState(() => _categoriasSelecionadas.clear());
                      },
                      child: Image.asset('assets/images/btn_rmv.png', width: 150),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de Categorias (Toggles)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _todasCategorias.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final cat = _todasCategorias[index];
                      final selecionada = _categoriasSelecionadas.contains(cat);

                      return GestureDetector(
                        onTap: () {
                          AudioManager.instance.playClique();
                          setState(() {
                            selecionada ? _categoriasSelecionadas.remove(cat) : _categoriasSelecionadas.add(cat);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(0, selecionada ? 0 : 2, 0),
                          child: Image.asset(
                            selecionada ? _getImagemCategoriaLigada(cat) : _getImagemCategoriaDesligada(cat),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Botão Jogar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: _iniciarJogo,
                    child: Image.asset('assets/images/btn_vamos.png', width: 150),
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