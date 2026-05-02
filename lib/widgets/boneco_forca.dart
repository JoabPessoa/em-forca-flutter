import 'package:flutter/material.dart';

class BonecoForca extends StatelessWidget {
  final int erros;
  final int maxErros;

  const BonecoForca({
    super.key,
    required this.erros,
    required this.maxErros,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 0. A estrutura da forca é a base (Sempre visível)
          Image.asset('assets/images/forca_completa.png', fit: BoxFit.contain),

          // 1. Primeiro erro: Cabeça
          if (erros >= 1) Image.asset('assets/images/boneco_cabeca.png', fit: BoxFit.contain),

          // 2. Segundo erro: Tronco
          if (erros >= 2) Image.asset('assets/images/boneco_tronco.png', fit: BoxFit.contain),

          // 3. Terceiro erro: Braço Esquerdo
          if (erros >= 3) Image.asset('assets/images/boneco_braco_esq.png', fit: BoxFit.contain),

          // 4. Quarto erro: Braço Direito
          if (erros >= 4) Image.asset('assets/images/boneco_braco_dir.png', fit: BoxFit.contain),

          // 5. Quinto erro: Perna Esquerda
          if (erros >= 5) Image.asset('assets/images/boneco_perna_esq.png', fit: BoxFit.contain),

          // 6. Sexto erro: Perna Direita
          if (erros >= 6) Image.asset('assets/images/boneco_perna_dir.png', fit: BoxFit.contain),

          // 7. Sétimo e último erro (Game Over): Rosto Morto
          if (erros >= 7) Image.asset('assets/images/boneco_rosto_morto.png', fit: BoxFit.contain),
        ],
      ),
    );
  }
}