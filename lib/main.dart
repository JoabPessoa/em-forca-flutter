// ============================================================
// MAIN.DART — Ponto de entrada do app
// Equivalente ao main() do seu JogoTela.java
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_tema.dart';
import 'screens/tela_inicial.dart';
import 'audio_manager.dart'; // <-- IMPORT DO ÁUDIO ADICIONADO AQUI!

void main() async {
  // 1. Garante que a fundação do Flutter esteja pronta antes de chamar regras de sistema
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Trava a orientação da tela exclusivamente na vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Liga o motor de áudio antes do jogo começar!
  await AudioManager.instance.init(); // <-- INICIALIZAÇÃO DO ÁUDIO AQUI!

  // 4. Inicia o aplicativo
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
      home: TelaInicial(),
    );
  }
}