// ============================================================
// TELA DE PONTUAÇÃO
// Exibe o placar salvo no banco de dados SQLite
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

  @override
  void initState() {
    super.initState();
    _carregarPontuacao();
  }

  Future<void> _carregarPontuacao() async {
    final p = await DatabaseHelper.instance.buscarPontuacao();
    setState(() => _pontuacao = p);
  }

  // Novo pop-up de reset customizado com o papel amassado
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTema.texto),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Isso vai zerar todas as pontuações.',
                style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: const Text('Cancelar', style: TextStyle(color: AppTema.azul, fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: const Text('Resetar', style: TextStyle(color: AppTema.vermelho, fontWeight: FontWeight.w900, fontSize: 18)),
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
      await DatabaseHelper.instance.resetarPontuacao();
      _carregarPontuacao();
    }
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
          // 1. FUNDO DO QUADRO BRANCO
          Image.asset(
            'assets/images/bg_quadro_branco.jpg',
            fit: BoxFit.cover,
          ),

          // 2. CONTEÚDO
          SafeArea(
            child: Column(
              children: [
                // --- CABEÇALHO CUSTOMIZADO ---
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
                          Image.asset('assets/images/ic_vitoria.png', width: 32), // Troféu ilustrado
                          const SizedBox(width: 8),
                          const Text(
                            'Placar',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTema.texto
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _resetar,
                        child: Image.asset('assets/images/ic_reset.png', width: 36), // Ícone de reset ilustrado
                      ),
                    ],
                  ),
                ),

                // --- LISTA DE PONTUAÇÕES ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
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
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40.0),
                              child: Text(
                                'Nenhuma partida jogada ainda!',
                                style: TextStyle(
                                  color: AppTema.neutroEsc,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
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
            fontWeight: FontWeight.w900, // Fonte mais grossa para destacar
            color: Colors.black,         // Cor alterada para preto sólido
          ),
        ),
      ],
    );
  }
}