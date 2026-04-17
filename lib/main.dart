// ============================================================
// MAIN.DART — Ponto de entrada do app
// Equivalente ao main() do seu JogoTela.java
// ============================================================

import 'package:flutter/material.dart';
import 'theme/app_tema.dart';
import 'screens/tela_inicial.dart';

void main() {
  runApp(const JogoForcaApp());
}

class JogoForcaApp extends StatelessWidget {
  const JogoForcaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Forca',
      debugShowCheckedModeBanner: false, // Remove o banner "DEBUG" no canto
      theme: AppTema.tema,
      home: const TelaInicial(),
    );
  }
}