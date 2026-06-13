import 'package:flutter/material.dart';
import 'package:jogo_forca/screens/tela_jogo.dart';
import '../models/palavra.dart';
import '../audio_manager.dart';
import '../theme/app_tema.dart';

class TelaArquiteto extends StatefulWidget {
  const TelaArquiteto({super.key});

  @override
  State<TelaArquiteto> createState() => _TelaArquitetoState();
}

class _TelaArquitetoState extends State<TelaArquiteto> {
  final TextEditingController _palavraController = TextEditingController();
  final TextEditingController _dicaController = TextEditingController();
  int _arquiteto = 1; // 1 = Jogador 1, 2 = Jogador 2

  void _iniciarDuelo() {
    final palavra = _palavraController.text.trim().toUpperCase();
    final dica = _dicaController.text.trim();

    if (palavra.isEmpty || palavra.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A palavra deve ter pelo menos 3 letras!'))
      );
      return;
    }

    AudioManager.instance.playClique();

    final palavraCustomizada = Palavra(
      texto: palavra,
      dica: dica.isNotEmpty ? dica : 'Boa sorte, você vai precisar!',
      categoria: 'Arquiteto',
      dificuldade: 'personalizada',
    );

    // O jogador atual será o oposto de quem criou a palavra
    int quemAdivinha = _arquiteto == 1 ? 2 : 1;

    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => TelaJogo(
          categorias: const ['Modo Arquiteto'],
          modoJogo: 'medio',
          modoMultiplayer: true,
          jogadorAtual: quemAdivinha,
          tipoMultiplayer: 'arquiteto',
          palavraCustomizada: palavraCustomizada,
        )
    ));
  }

  Widget _buildBotaoJogador(int numero, String corHex) {
    bool selecionado = _arquiteto == numero;
    Color corAcento = Color(int.parse(corHex));

    return GestureDetector(
      onTap: () {
        AudioManager.instance.playClique();
        setState(() => _arquiteto = numero);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selecionado ? corAcento : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: selecionado ? corAcento : Colors.black26, width: 2),
        ),
        child: Text(
          'Jogador $numero',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: selecionado ? Colors.white : Colors.black54
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg_quadro_branco.jpg', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/images/ic_fechar.png', width: 28),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Quem será o Arquiteto?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTema.texto),
                  ),
                  const SizedBox(height: 16),

                  // Seletor de Jogador
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBotaoJogador(1, '0xFFE53935'), // Vermelho
                      const SizedBox(width: 16),
                      _buildBotaoJogador(2, '0xFF1E88E5'), // Azul
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Escreva a Palavra',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTema.texto),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esconda a tela do seu adversário e digite!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _palavraController,
                    obscureText: false, // <-- Palavra agora fica visível para o Arquiteto!
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'PALAVRA SECRETA',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _dicaController,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Dica (Opcional)',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                  const Spacer(),
                  GestureDetector(
                    onTap: _iniciarDuelo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTema.verde,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Pronto! Passe para o Jogador ${_arquiteto == 1 ? 2 : 1}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}