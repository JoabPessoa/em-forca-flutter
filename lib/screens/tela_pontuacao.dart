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

  Future<void> _resetar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resetar Placar?'),
        content: const Text('Isso vai zerar todas as pontuações.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetar', style: TextStyle(color: AppTema.vermelho)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.resetarPontuacao();
      _carregarPontuacao();
    }
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
        title: const Text(
          '🏆 Placar',
          style: TextStyle(color: AppTema.texto, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTema.vermelho),
            onPressed: _resetar,
            tooltip: 'Resetar placar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ..._pontuacao.map((p) {
              final nome = p['jogador'] as String;
              final vitorias = p['vitorias'] as int;
              final derrotas = p['derrotas'] as int;
              final total = vitorias + derrotas;
              final taxa = total > 0 ? (vitorias / total * 100).toStringAsFixed(0) : '0';
              final cor = nome == 'Jogador 1' ? AppTema.verde : AppTema.azul;

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
                        Text(
                          nome == 'Jogador 1' ? '🟢' : '🔵',
                          style: const TextStyle(fontSize: 24),
                        ),
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
                child: Text(
                  'Nenhuma partida jogada ainda!',
                  style: TextStyle(color: AppTema.neutroEsc),
                ),
              ),
          ],
        ),
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
            fontWeight: FontWeight.w600,
            color: AppTema.neutroEsc,
          ),
        ),
      ],
    );
  }
}
