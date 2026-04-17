// ============================================================
// WIDGET: BonecoForca
// Equivalente ao método desenharCenario(Graphics g) do JogoTela.java
//
// Em Flutter, ao invés de Graphics2D, usamos CustomPainter.
// A lógica de desenho é IDÊNTICA à sua — mesma forca, mesmo boneco!
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_tema.dart';

class BonecoForca extends StatelessWidget {
  final int erros;
  final int maxErros;

  const BonecoForca({
    super.key,
    required this.erros,
    this.maxErros = 7,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ForcaPainter(erros: erros),
      child: const SizedBox(width: double.infinity, height: 220),
    );
  }
}

class _ForcaPainter extends CustomPainter {
  final int erros;

  _ForcaPainter({required this.erros});

  @override
  void paint(Canvas canvas, Size size) {
    // Ponto de referência central para escalar em qualquer tela
    final cx = size.width / 2;
    final baseY = size.height - 10;
    final topo = 10.0;
    final postX = cx - 60;
    final bracX = cx + 40;

    // --- 1. FORCA (madeira) ---
    final pintaMadeira = Paint()
      ..color = AppTema.madeira
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Chão
    canvas.drawLine(Offset(postX - 50, baseY), Offset(postX + 60, baseY), pintaMadeira);
    // Poste principal
    canvas.drawLine(Offset(postX, baseY), Offset(postX, topo), pintaMadeira);
    // Braço superior
    canvas.drawLine(Offset(postX, topo), Offset(bracX, topo), pintaMadeira);
    // Suporte diagonal
    final pintaDiag = Paint()
      ..color = AppTema.madeira
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(postX, topo + 40), Offset(postX + 40, topo), pintaDiag);

    // --- 2. CORDA ---
    final pintaCorda = Paint()
      ..color = AppTema.corda
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(bracX, topo), Offset(bracX, topo + 35), pintaCorda);

    // --- 3. BONECO ---
    final pintaBoneco = Paint()
      ..color = AppTema.texto
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cabecaY = topo + 35;
    final cabecaR = 22.0;
    final troncoTop = cabecaY + cabecaR * 2;
    final troncoBot = troncoTop + 60;

    // Cabeça
    if (erros >= 1) {
      canvas.drawCircle(Offset(bracX, cabecaY + cabecaR), cabecaR, pintaBoneco);
    }
    // Tronco
    if (erros >= 2) {
      canvas.drawLine(Offset(bracX, troncoTop), Offset(bracX, troncoBot), pintaBoneco);
    }
    // Braço esquerdo
    if (erros >= 3) {
      canvas.drawLine(
        Offset(bracX, troncoTop + 15),
        Offset(bracX - 30, troncoTop + 50),
        pintaBoneco,
      );
    }
    // Braço direito
    if (erros >= 4) {
      canvas.drawLine(
        Offset(bracX, troncoTop + 15),
        Offset(bracX + 30, troncoTop + 50),
        pintaBoneco,
      );
    }
    // Perna esquerda
    if (erros >= 5) {
      canvas.drawLine(
        Offset(bracX, troncoBot),
        Offset(bracX - 28, troncoBot + 45),
        pintaBoneco,
      );
    }
    // Perna direita
    if (erros >= 6) {
      canvas.drawLine(
        Offset(bracX, troncoBot),
        Offset(bracX + 28, troncoBot + 45),
        pintaBoneco,
      );
    }

    // --- 4. ROSTO GAME OVER (X X e boca triste) ---
    if (erros >= 7) {
      final pintaRosto = Paint()
        ..color = AppTema.vermelho
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final oy = cabecaY + cabecaR;

      // Olho X esquerdo
      canvas.drawLine(Offset(bracX - 12, oy - 8), Offset(bracX - 6, oy - 2), pintaRosto);
      canvas.drawLine(Offset(bracX - 6, oy - 8), Offset(bracX - 12, oy - 2), pintaRosto);

      // Olho X direito
      canvas.drawLine(Offset(bracX + 6, oy - 8), Offset(bracX + 12, oy - 2), pintaRosto);
      canvas.drawLine(Offset(bracX + 12, oy - 8), Offset(bracX + 6, oy - 2), pintaRosto);

      // Boca triste
      final boca = Path();
      boca.moveTo(bracX - 10, oy + 10);
      boca.quadraticBezierTo(bracX, oy + 5, bracX + 10, oy + 10);
      canvas.drawPath(boca, pintaRosto);
    }
  }

  @override
  bool shouldRepaint(_ForcaPainter old) => old.erros != erros;
}
