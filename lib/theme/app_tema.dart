// ============================================================
// TEMA DO APP - ESTILO QUADRO BRANCO
// ============================================================

import 'package:flutter/material.dart';

class AppTema {
  // --- PALETA DE CORES (Marcadores de Quadro Branco) ---
  static const Color fundo        = Color(0xFFFFFFFF); // Fundo limpo
  static const Color marcadorPreto = Color(0xFF1E1E1E);
  static const Color cinzaApagado  = Color(0xFFD3D3D3);

  // --- MAPEAMENTO DE CORES (A "Ponte" para as outras telas) ---
  static const Color texto        = marcadorPreto;
  static const Color neutro       = Color(0xFFF0F0F0);
  static const Color neutroEsc    = cinzaApagado;

  static const Color verde        = Color(0xFF008000);
  static const Color verdeEscuro  = Color(0xFF006400);
  static const Color vermelho     = Color(0xFFCC0000);
  static const Color vermelhoEsc  = Color(0xFF8B0000);
  static const Color azul         = Color(0xFF0033CC);
  static const Color azulEscuro   = Color(0xFF00008B);

  static const Color amarelo      = Color(0xFFFFD700);
  static const Color amareloBg    = Color(0xFFFFF9E6);

  static const Color madeira      = marcadorPreto;
  static const Color corda        = marcadorPreto;

  // --- HELPERS DE CATEGORIAS ---
  static const Map<String, Color> coresCategorias = {
    'Filmes e Séries': Color(0xFF9B59B6),
    'Esportes':        verde,
    'Tecnologia':      azul,
    'Comidas e Bebidas': Color(0xFFE67E22),
    'Música':          Color(0xFFE91E8C),
    'Todas':           marcadorPreto,
  };

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

  // --- TEMA MATERIAL GLOBAL ---
  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: fundo,

      fontFamily: 'FingerPaint',

      colorScheme: ColorScheme.fromSeed(
        seedColor: azul,
        background: fundo,
      ),

      // 2. APLICA A FONTE E A COR AOS TEXTOS
      textTheme: const TextTheme().apply(
        fontFamily: 'FingerPaint',
        bodyColor: texto,
        displayColor: texto,
      ),

      // Botões com contorno de caneta
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: fundo,
          foregroundColor: texto,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: texto, width: 2),
          ),
        ),
      ),
    );
  }
}