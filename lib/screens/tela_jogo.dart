// ============================================================
// TELA DO JOGO
// Equivalente ao seu JogoTela.java — toda a lógica do jogo aqui!
//
// COMPARAÇÃO JAVA → FLUTTER:
//   JLabel lblPalavraSecreta   → Widget _buildMascara()
//   JPanel painelBoneco        → Widget BonecoForca()
//   JPanel painelTeclado       → Widget _buildTeclado()
//   processarJogada()          → _processarJogada()
//   verificarVitoria()         → _verificarVitoria()
//   verificarDerrota()         → _verificarDerrota()
//   comprarDica()              → _revelarDica()
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/database_helper.dart';
import '../models/palavra.dart';
import '../theme/app_tema.dart';
import '../widgets/boneco_forca.dart';

class TelaJogo extends StatefulWidget {
  final String categoria;
  final bool modoMultiplayer;
  final int jogadorAtual; // 1 ou 2 (0 = single player)

  const TelaJogo({
    super.key,
    required this.categoria,
    required this.modoMultiplayer,
    required this.jogadorAtual,
  });

  @override
  State<TelaJogo> createState() => _TelaJogoState();
}

class _TelaJogoState extends State<TelaJogo> {
  // --- ESTADO DO JOGO (equivalente às variáveis do JogoTela.java) ---
  Palavra? _palavraAtual;
  Set<String> _letrasDescobertas = {};
  Set<String> _letrasErradas = {};
  int _erros = 0;
  static const int _maxErros = 7;
  bool _categoriaRevelada = false;
  bool _dicaRevelada = false;
  bool _carregando = true;
  int _jogadorAtual = 1;

  // Pontuação da sessão (modo 2 jogadores)
  int _vitoriasJ1 = 0;
  int _vitoriasJ2 = 0;

  @override
  void initState() {
    super.initState();
    _jogadorAtual = widget.jogadorAtual;
    _iniciarNovoJogo();
  }

  // ============================================================
  // INICIAR NOVO JOGO
  // Equivalente ao iniciarNovoJogo() do JogoTela.java
  // ============================================================
  Future<void> _iniciarNovoJogo() async {
    setState(() => _carregando = true);

    final palavra = await DatabaseHelper.instance.sortearPalavra(
      categoria: widget.categoria,
    );

    if (!mounted) return;

    if (palavra == null) {
      _mostrarErro('Nenhuma palavra encontrada nessa categoria!');
      return;
    }

    setState(() {
      _palavraAtual = palavra;
      _letrasDescobertas = {};
      _letrasErradas = {};
      _erros = 0;
      _categoriaRevelada = false;
      _dicaRevelada = false;
      _carregando = false;
    });
  }

  // ============================================================
  // PROCESSAR JOGADA
  // Equivalente ao processarJogada(BotaoDuo btn) do JogoTela.java
  // ============================================================
  void _processarJogada(String letra) {
    if (_palavraAtual == null) return;
    final palavraReal = _palavraAtual!.texto.toUpperCase();

    setState(() {
      if (palavraReal.contains(letra)) {
        // ACERTOU!
        _letrasDescobertas.add(letra);
        _verificarVitoria();
      } else {
        // ERROU!
        _letrasErradas.add(letra);
        _erros++;
        _verificarDerrota();
      }
    });
  }

  // ============================================================
  // REVELAR DICA
  // A dica só é liberada após 3 erros.
  // Antes disso exibe mensagem de bloqueio.
  // ============================================================
  void _revelarDica(bool isCategoria) {
    if (_erros < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Text('🔒', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A dica só é liberada após perder 3 vidas.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: AppTema.texto,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Dica liberada após 3 erros — revela sem custar vida
    setState(() {
      if (isCategoria) {
        _categoriaRevelada = true;
      } else {
        _dicaRevelada = true;
      }
    });
  }

  // ============================================================
  // VERIFICAR VITÓRIA
  // ============================================================
  void _verificarVitoria() {
    if (_palavraAtual == null) return;
    final palavraReal = _palavraAtual!.texto.toUpperCase();
    final todasLetras = palavraReal.split('').where((c) => c != ' ' && c != '-').toSet();

    if (todasLetras.every((l) => _letrasDescobertas.contains(l))) {
      // Delay pequeno para o jogador ver a última letra antes do popup
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _mostrarResultado(vitoria: true);
      });
    }
  }

  // ============================================================
  // VERIFICAR DERROTA
  // ============================================================
  void _verificarDerrota() {
    if (_erros >= _maxErros) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _mostrarResultado(vitoria: false);
      });
    }
  }

  // ============================================================
  // MOSTRAR RESULTADO (Dialog de vitória ou derrota)
  // ============================================================
  void _mostrarResultado({required bool vitoria}) {
    // Atualiza pontuação do jogador atual
    if (widget.modoMultiplayer) {
      if (vitoria) {
        if (_jogadorAtual == 1) _vitoriasJ1++;
        else _vitoriasJ2++;
        DatabaseHelper.instance.registrarVitoria('Jogador $_jogadorAtual');
      } else {
        DatabaseHelper.instance.registrarDerrota('Jogador $_jogadorAtual');
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogResultado(
        vitoria: vitoria,
        palavra: _palavraAtual?.texto ?? '',
        modoMultiplayer: widget.modoMultiplayer,
        jogadorAtual: _jogadorAtual,
        vitoriasJ1: _vitoriasJ1,
        vitoriasJ2: _vitoriasJ2,
        onJogarNovamente: () {
          Navigator.pop(context);
          // No modo 2 jogadores, alterna o jogador
          if (widget.modoMultiplayer) {
            setState(() {
              _jogadorAtual = _jogadorAtual == 1 ? 2 : 1;
            });
          }
          _iniciarNovoJogo();
        },
        onSair: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _mostrarErro(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================
  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        backgroundColor: AppTema.fundo,
        body: Center(child: CircularProgressIndicator(color: AppTema.verde)),
      );
    }

    final corCategoria = AppTema.corDaCategoria(widget.categoria);

    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        backgroundColor: AppTema.fundo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTema.texto),
          onPressed: () => _confirmarSaida(),
        ),
        title: widget.modoMultiplayer
            ? _buildIndicadorJogador()
            : _buildInfoCategoria(corCategoria),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Placar multiplayer
            if (widget.modoMultiplayer) _buildPlacar(),

            // Botões de dica
            _buildBotoesDica(),

            // Boneco da forca
            Expanded(
              flex: 3,
              child: BonecoForca(erros: _erros, maxErros: _maxErros),
            ),

            // Vidas restantes
            _buildVidas(),

            // Máscara da palavra
            _buildMascara(),

            const SizedBox(height: 8),

            // Teclado
            Expanded(
              flex: 3,
              child: _buildTeclado(),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildIndicadorJogador() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _jogadorAtual == 1 ? AppTema.verde : AppTema.azul,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '🎮 Vez do Jogador $_jogadorAtual',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoCategoria(Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Text(
        '${AppTema.iconeDaCategoria(widget.categoria)} ${widget.categoria}',
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPlacar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          _ChipPlacar(
            nome: 'J1',
            vitorias: _vitoriasJ1,
            ativo: _jogadorAtual == 1,
            cor: AppTema.verde,
          ),
          const Spacer(),
          Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppTema.neutroEsc,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          _ChipPlacar(
            nome: 'J2',
            vitorias: _vitoriasJ2,
            ativo: _jogadorAtual == 2,
            cor: AppTema.azul,
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesDica() {
    final dicaBloqueada = _erros < 3;
    final dica = _palavraAtual?.dica ?? '';
    final catIcone = AppTema.iconeDaCategoria(_palavraAtual?.categoria ?? '');
    final catNome = _palavraAtual?.categoria ?? '';
    final mostrarCategoria = widget.categoria == 'Todas';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (mostrarCategoria) ...[
            Expanded(
              child: _BotaoDica(
                texto: _categoriaRevelada ? '$catIcone $catNome' : '🏷️ Categoria',
                ativo: !_categoriaRevelada,
                bloqueada: dicaBloqueada && !_categoriaRevelada,
                onTap: () => _revelarDica(true),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: _BotaoDica(
              texto: _dicaRevelada ? '💡 $dica' : '💡 Dica',
              ativo: !_dicaRevelada,
              bloqueada: dicaBloqueada && !_dicaRevelada,
              onTap: () => _revelarDica(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVidas() {
    final vidasRestantes = _maxErros - _erros;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_maxErros, (i) {
        final viva = i < vidasRestantes;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            viva ? '❤️' : '🖤',
            style: TextStyle(fontSize: viva ? 18 : 14),
          ),
        );
      }),
    );
  }

  Widget _buildMascara() {
    if (_palavraAtual == null) return const SizedBox();
    final palavraReal = _palavraAtual!.texto.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: palavraReal.split('').map((letra) {
          if (letra == ' ') {
            return const SizedBox(width: 16);
          }
          final revelada = letra == '-' || _letrasDescobertas.contains(letra);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 36,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: revelada ? AppTema.verde : AppTema.neutroEsc,
                  width: 3,
                ),
              ),
            ),
            child: Center(
              child: Text(
                revelada ? letra : '',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTema.texto,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTeclado() {
    const letras = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        physics: const NeverScrollableScrollPhysics(),
        children: letras.split('').map((letra) {
          final acertou = _letrasDescobertas.contains(letra);
          final errou = _letrasErradas.contains(letra);
          final usado = acertou || errou;

          Color corFundo = AppTema.neutro;
          Color corSombra = AppTema.neutroEsc;
          Color corTexto = AppTema.texto;

          if (acertou) {
            corFundo = AppTema.verde;
            corSombra = AppTema.verdeEscuro;
            corTexto = Colors.white;
          } else if (errou) {
            corFundo = AppTema.vermelho;
            corSombra = AppTema.vermelhoEsc;
            corTexto = Colors.white;
          }

          return _BotaoLetra(
            letra: letra,
            corFundo: corFundo,
            corSombra: corSombra,
            corTexto: corTexto,
            desativado: usado,
            onTap: usado ? null : () => _processarJogada(letra),
          );
        }).toList(),
      ),
    );
  }

  void _confirmarSaida() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair do jogo?'),
        content: const Text('Seu progresso será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Sair', style: TextStyle(color: AppTema.vermelho)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGETS AUXILIARES
// ============================================================

class _BotaoLetra extends StatefulWidget {
  final String letra;
  final Color corFundo;
  final Color corSombra;
  final Color corTexto;
  final bool desativado;
  final VoidCallback? onTap;

  const _BotaoLetra({
    required this.letra,
    required this.corFundo,
    required this.corSombra,
    required this.corTexto,
    required this.desativado,
    this.onTap,
  });

  @override
  State<_BotaoLetra> createState() => _BotaoLetraState();
}

class _BotaoLetraState extends State<_BotaoLetra> {
  bool _pressionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.desativado ? null : (_) => setState(() => _pressionado = true),
      onTapUp: widget.desativado
          ? null
          : (_) {
              setState(() => _pressionado = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _pressionado = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        decoration: BoxDecoration(
          color: widget.corFundo,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: widget.corSombra,
              offset: Offset(0, _pressionado || widget.desativado ? 1 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        transform: Matrix4.translationValues(
          0,
          _pressionado ? 3 : 0,
          0,
        ),
        child: Center(
          child: Text(
            widget.letra,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: widget.corTexto,
            ),
          ),
        ),
      ),
    );
  }
}

class _BotaoDica extends StatelessWidget {
  final String texto;
  final bool ativo;
  final bool bloqueada;
  final VoidCallback onTap;

  const _BotaoDica({
    required this.texto,
    required this.ativo,
    required this.onTap,
    this.bloqueada = false,
  });

  @override
  Widget build(BuildContext context) {
    // Estados visuais:
    // bloqueada = cinza com cadeado (menos de 3 erros)
    // ativo     = azul clicável (3+ erros, ainda não revelada)
    // !ativo    = cinza desabilitado (já revelada)

    Color corFundo;
    Color corBorda;
    Color corTexto;

    if (bloqueada) {
      corFundo = AppTema.neutro.withOpacity(0.6);
      corBorda = AppTema.neutroEsc.withOpacity(0.4);
      corTexto = AppTema.neutroEsc;
    } else if (ativo) {
      corFundo = AppTema.azul.withOpacity(0.15);
      corBorda = AppTema.azul.withOpacity(0.4);
      corTexto = AppTema.azulEscuro;
    } else {
      corFundo = AppTema.neutro;
      corBorda = AppTema.neutroEsc;
      corTexto = AppTema.neutroEsc;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: corBorda),
        ),
        child: Opacity(
          opacity: bloqueada ? 0.6 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (bloqueada)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.lock, size: 12, color: AppTema.neutroEsc),
                ),
              Flexible(
                child: Text(
                  bloqueada ? '🔒 Bloqueada' : texto,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: corTexto,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipPlacar extends StatelessWidget {
  final String nome;
  final int vitorias;
  final bool ativo;
  final Color cor;

  const _ChipPlacar({
    required this.nome,
    required this.vitorias,
    required this.ativo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: ativo ? cor : AppTema.neutro,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ativo
            ? [BoxShadow(color: cor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]
            : [],
      ),
      child: Text(
        '$nome  $vitorias ⭐',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: ativo ? Colors.white : AppTema.neutroEsc,
        ),
      ),
    );
  }
}

// ============================================================
// DIALOG DE RESULTADO (Vitória / Derrota)
// ============================================================
class _DialogResultado extends StatelessWidget {
  final bool vitoria;
  final String palavra;
  final bool modoMultiplayer;
  final int jogadorAtual;
  final int vitoriasJ1;
  final int vitoriasJ2;
  final VoidCallback onJogarNovamente;
  final VoidCallback onSair;

  const _DialogResultado({
    required this.vitoria,
    required this.palavra,
    required this.modoMultiplayer,
    required this.jogadorAtual,
    required this.vitoriasJ1,
    required this.vitoriasJ2,
    required this.onJogarNovamente,
    required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = vitoria ? '🎉' : '💀';
    final titulo = vitoria ? 'Acertou!' : 'Game Over!';
    final cor = vitoria ? AppTema.verde : AppTema.vermelho;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 60))
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 12),

            Text(
              titulo,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: cor,
              ),
            ),

            if (!vitoria) ...[
              const SizedBox(height: 8),
              Text(
                'A palavra era:',
                style: TextStyle(color: AppTema.neutroEsc, fontSize: 13),
              ),
              Text(
                palavra,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTema.texto,
                  letterSpacing: 2,
                ),
              ),
            ],

            if (modoMultiplayer) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTema.neutro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      const Text('J1', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text('$vitoriasJ1 ⭐', style: TextStyle(color: AppTema.verde, fontWeight: FontWeight.w900)),
                    ]),
                    const Text('VS', style: TextStyle(color: AppTema.neutroEsc)),
                    Column(children: [
                      const Text('J2', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text('$vitoriasJ2 ⭐', style: TextStyle(color: AppTema.azul, fontWeight: FontWeight.w900)),
                    ]),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: onJogarNovamente,
                child: Text(
                  modoMultiplayer ? '▶️  Vez do Jogador ${jogadorAtual == 1 ? 2 : 1}' : '▶️  Jogar Novamente',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: onSair,
              child: const Text(
                'Voltar ao Menu',
                style: TextStyle(color: AppTema.neutroEsc, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
