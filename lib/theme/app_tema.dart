// ============================================================
// TEMA DO APP
// Centraliza todas as cores e estilos (igual às constantes
// de cor que você tinha no JogoTela.java)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTema {
  // --- PALETA DE CORES (inspirada no seu JogoTela.java) ---
  static const Color fundo        = Color(0xFFF8F9FA);
  static const Color verde        = Color(0xFF58CC02);
  static const Color verdeEscuro  = Color(0xFF45A300);
  static const Color vermelho     = Color(0xFFFF4B4B);
  static const Color vermelhoEsc  = Color(0xFFB40000);
  static const Color azul         = Color(0xFF1CB0F6);
  static const Color azulEscuro   = Color(0xFF1899D6);
  static const Color neutro       = Color(0xFFE5E5E5);
  static const Color neutroEsc    = Color(0xFFB4B4B4);
  static const Color texto        = Color(0xFF4B4B4B);
  static const Color madeira      = Color(0xFF8B4513);
  static const Color corda        = Color(0xFFA0522D);
  static const Color amarelo      = Color(0xFFFFD700);
  static const Color amareloBg    = Color(0xFFFFF9E6);

  // Cores por categoria
  static const Map<String, Color> coresCategorias = {
    'Filmes e Séries': Color(0xFF9B59B6),
    'Esportes':        Color(0xFF27AE60),
    'Tecnologia':      Color(0xFF2980B9),
    'Comidas e Bebidas': Color(0xFFE67E22),
    'Música':          Color(0xFFE91E8C),
    'Todas':           Color(0xFF1CB0F6),
  };

  // Ícones por categoria
  static const Map<String, String> iconesCategorias = {
    'Filmes e Séries':   '🎬',
    'Esportes':          '⚽',
    'Tecnologia':        '💻',
    'Comidas e Bebidas': '🍕',
    'Música':            '🎵',
    'Todas':             '🎲',
  };

  static Color corDaCategoria(String categoria) {
    return coresCategorias[categoria] ?? azul;
  }

  static String iconeDaCategoria(String categoria) {
    return iconesCategorias[categoria] ?? '❓';
  }

  // --- TEMA MATERIAL ---
  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: fundo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: verde,
        background: fundo,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
    );
  }
}
