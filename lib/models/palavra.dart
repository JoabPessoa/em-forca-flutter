// ============================================================
// MODELO: Palavra
// Equivalente ao seu Palavra.java
// Representa uma palavra do jogo com texto, dica e categoria
// ============================================================

class Palavra {
  final int? id;
  final String texto;
  final String dica;
  final String categoria;
  final String dificuldade; // 'facil', 'medio', 'dificil'

  Palavra({
    this.id,
    required this.texto,
    required this.dica,
    required this.categoria,
    required this.dificuldade,
  });

  // Converte um Map (linha do banco) em um objeto Palavra
  // Equivalente ao rs.getString() do seu JogoDAO.java
  factory Palavra.fromMap(Map<String, dynamic> map) {
    return Palavra(
      id: map['id'],
      texto: map['texto'],
      dica: map['dica'],
      categoria: map['categoria'],
      dificuldade: map['dificuldade'] ?? 'medio',
    );
  }

  // Converte um objeto Palavra em Map para salvar no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texto': texto.toUpperCase(),
      'dica': dica,
      'categoria': categoria,
      'dificuldade': dificuldade,
    };
  }

  @override
  String toString() {
    return 'Palavra: $texto (Dica: $dica - Categoria: $categoria)';
  }
}
