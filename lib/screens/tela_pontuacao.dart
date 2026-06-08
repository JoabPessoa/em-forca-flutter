// ============================================================
// TELA DE PONTUAÇÃO E PROGRESSO
// Exibe o placar multiplayer salvo e o hub de conquistas evolutivas
// ============================================================

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../theme/app_tema.dart';

class TelaPontuacao extends StatefulWidget {
  const TelaPontuacao({super.key});

  @override
  State<TelaPontuacao> createState() => _TelaPontuacaoState();
}

class _TelaPontuacaoState extends State<TelaPontuacao> {
  List<Map<String, dynamic>> _pontuacao = [];
  Map<String, int> _estatisticas = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final db = DatabaseHelper.instance;
    final p = await db.buscarPontuacao();

    final categorias = [
      'Animais', 'Comidas e Bebidas', 'Contos de Fada', 'Esportes',
      'Filmes e Séries', 'Mitologia', 'Música', 'Música - Cantores', 'Paises', 'Tecnologia'
    ];

    Map<String, int> statsTemp = {};
    for (String cat in categorias) {
      statsTemp[cat] = await db.buscarEstatistica('cat_$cat');
    }

    if (mounted) {
      setState(() {
        _pontuacao = p;
        _estatisticas = statsTemp;
        _carregando = false;
      });
    }
  }

  Future<void> _resetar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
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
              const Text(
                'Resetar Placar?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTema.texto),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Isso vai zerar as pontuações (não afeta suas conquistas).',
                style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: const Text('Cancelar', style: TextStyle(color: AppTema.azul, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: const Text('Resetar', style: TextStyle(color: AppTema.vermelho, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    if (confirmar == true) {
      setState(() => _carregando = true);
      await DatabaseHelper.instance.resetarPontuacao();
      await _carregarDados();
    }
  }

  // --- NOVO DESIGN DO CARD EVOLUTIVO ---
  Widget _buildCardEvolutivo(String tituloCategoria, List<String> titulosNiveis) {
    int progressoAtual = _estatisticas[tituloCategoria] ?? 0;

    int meta;
    String tituloAtual;
    double porcentagem;
    bool concluido = false;

    // Lógica evolutiva (10 -> 25 -> 50)
    if (progressoAtual < 10) {
      meta = 10;
      tituloAtual = titulosNiveis[0];
    } else if (progressoAtual < 25) {
      meta = 25;
      tituloAtual = titulosNiveis[1];
    } else if (progressoAtual < 50) {
      meta = 50;
      tituloAtual = titulosNiveis[2];
    } else {
      meta = 50;
      progressoAtual = 50;
      tituloAtual = titulosNiveis[2];
      concluido = true;
    }

    porcentagem = progressoAtual / meta;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Fundo cinza com transparência alta ou verde se concluído
        color: concluido ? AppTema.verde.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: concluido ? AppTema.verde : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          // 1. ÍCONE DA CONQUISTA
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 16),
            child: Image.asset(
              // O Flutter vai procurar uma imagem com o nome EXATO do título atual
              'assets/images/$tituloAtual.png',
              fit: BoxFit.contain,
              // Fallback de Segurança: Se a imagem não for encontrada, mostra o troféu genérico
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/ic_vitoria.png',
                  fit: BoxFit.contain,
                  color: concluido ? null : Colors.grey.withOpacity(0.5), // Fica cinza se não concluído
                );
              },
            ),
          ),

          // 2. TEXTOS E BARRA DE PROGRESSO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tituloAtual,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTema.texto),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (concluido)
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Encontre e acerte palavras de $tituloCategoria.',
                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: porcentagem,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          color: concluido ? AppTema.verde : AppTema.azul,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$progressoAtual / $meta',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppTema.texto),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int vitoriasJ1 = 0;
    int vitoriasJ2 = 0;

    for (var p in _pontuacao) {
      if (p['jogador'] == 'Jogador 1') vitoriasJ1 = p['vitorias'] as int;
      if (p['jogador'] == 'Jogador 2') vitoriasJ2 = p['vitorias'] as int;
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_quadro_branco.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset('assets/images/ic_voltar.png', width: 36),
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/ic_vitoria.png', width: 32),
                          const SizedBox(width: 8),
                          const Text(
                            'Progresso e Placar',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppTema.texto
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _resetar,
                        child: Image.asset('assets/images/ic_reset.png', width: 36),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _carregando
                      ? const Center(child: CircularProgressIndicator(color: AppTema.verde))
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- PLACAR MULTIPLAYER ---
                        ..._pontuacao.map((p) {
                          final nome = p['jogador'] as String;
                          final vitorias = p['vitorias'] as int;
                          final derrotas = p['derrotas'] as int;
                          final total = vitorias + derrotas;
                          final taxa = total > 0 ? (vitorias / total * 100).toStringAsFixed(0) : '0';

                          final cor = nome == 'Jogador 1' ? AppTema.vermelho : AppTema.azul;

                          String caminhoAvatar = 'assets/images/ic_avatar_neutro.png';

                          if (vitoriasJ1 > vitoriasJ2) {
                            caminhoAvatar = nome == 'Jogador 1'
                                ? 'assets/images/ic_avatar_feliz.png'
                                : 'assets/images/ic_avatar_zangado.png';
                          } else if (vitoriasJ2 > vitoriasJ1) {
                            caminhoAvatar = nome == 'Jogador 2'
                                ? 'assets/images/ic_avatar_feliz.png'
                                : 'assets/images/ic_avatar_zangado.png';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cor.withOpacity(0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(caminhoAvatar, width: 28, height: 28),
                                    const SizedBox(width: 10),
                                    Text(
                                      nome,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: cor,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$taxa%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _Stat(valor: '$vitorias', label: 'Vitórias', cor: AppTema.verde),
                                    _Stat(valor: '$derrotas', label: 'Derrotas', cor: AppTema.vermelho),
                                    _Stat(valor: '$total', label: 'Total', cor: AppTema.azul),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        if (_pontuacao.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
                            child: Text(
                              'Nenhuma partida jogada ainda!',
                              style: TextStyle(
                                color: AppTema.neutroEsc,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 16),
                        const Divider(color: Colors.black26, thickness: 2),
                        const SizedBox(height: 16),

                        // --- HUB DE CONQUISTAS ---
                        const Text(
                          'Suas Conquistas',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTema.texto
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        _buildCardEvolutivo('Animais', ['Observador de Pássaros', 'Domador de Feras', 'Rei da Selva']),
                        _buildCardEvolutivo('Comidas e Bebidas', ['Degustador Curioso', 'Crítico Gastronômico', 'Chef Estrela Michelin']),
                        _buildCardEvolutivo('Contos de Fada', ['Era uma Vez', 'Nobre Cavaleiro', 'Guardião do Reino']),
                        _buildCardEvolutivo('Esportes', ['Reserva do Time', 'Titular Absoluto', 'Lenda Olímpica']),
                        _buildCardEvolutivo('Filmes e Séries', ['Espectador de Pipoca', 'Crítico de Cinema', 'Cineasta Premiado']),
                        _buildCardEvolutivo('Mitologia', ['Iniciado do Oráculo', 'Herói Lendário', 'Divindade Suprema']),
                        _buildCardEvolutivo('Música', ['Ouvinte de Rádio', 'Músico de Coreto', 'Virtuoso da Orquestra']),
                        _buildCardEvolutivo('Música - Cantores', ['Fã de Carteirinha', 'Astro do Palco', 'Ícone Global']),
                        _buildCardEvolutivo('Paises', ['Turista Local', 'Viajante de Elite', 'Cidadão do Mundo']),
                        _buildCardEvolutivo('Tecnologia', ['Hello World!', 'Arquiteto de Sistemas', 'Mestre do Código']),
                      ],
                    ),
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

class _Stat extends StatelessWidget {
  final String valor;
  final String label;
  final Color cor;

  const _Stat({required this.valor, required this.label, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: cor),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}