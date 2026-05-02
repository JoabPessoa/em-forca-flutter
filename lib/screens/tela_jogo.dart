import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/database_helper.dart';
import '../models/palavra.dart';
import '../theme/app_tema.dart';
import '../widgets/boneco_forca.dart';
import '../audio_manager.dart';

class TelaJogo extends StatefulWidget {
  final String categoria;
  final bool modoMultiplayer;
  final int jogadorAtual;

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
  Palavra? _palavraAtual;
  Set<String> _letrasDescobertas = {};
  Set<String> _letrasErradas = {};
  int _erros = 0;
  static const int _maxErros = 7;
  bool _dicaRevelada = false;
  bool _carregando = true;
  int _jogadorAtual = 1;

  int _vitoriasJ1 = 0;
  int _vitoriasJ2 = 0;

  bool _animandoDesbloqueio = false;
  bool _toastVisivel = false;
  bool _toastExpandido = false;
  String _mensagemToast = '';

  @override
  void initState() {
    super.initState();
    _jogadorAtual = widget.jogadorAtual;
    _iniciarNovoJogo();

    // Toca a música da tela de jogo!
    AudioManager.instance.playMusica('musica_jogo.mp3');
  }

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
      _dicaRevelada = false;
      _carregando = false;
      _animandoDesbloqueio = false;
    });
  }

  void _processarJogada(String letra) {
    if (_palavraAtual == null) return;
    final palavraReal = _palavraAtual!.texto.toUpperCase();

    // 🎵 O SOM DO CLIQUE ENTRA EXATAMENTE AQUI!
    AudioManager.instance.playClique();

    setState(() {
      if (palavraReal.contains(letra)) {
        _letrasDescobertas.add(letra);
        _verificarVitoria();
      } else {
        int errosAntes = _erros;
        _letrasErradas.add(letra);
        _erros++;

        if (errosAntes == 3 && _erros == 4) {
          _animarDestrancarDica();
        }

        _verificarDerrota();
      }
    });
  }

  void _animarDestrancarDica() async {
    setState(() => _animandoDesbloqueio = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _animandoDesbloqueio = false);
  }

  void _mostrarAvisoCustomizado(String msg) async {
    if (_toastVisivel) return;

    setState(() {
      _mensagemToast = msg;
      _toastVisivel = true;
      _toastExpandido = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() => _toastExpandido = true);

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() => _toastExpandido = false);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() => _toastVisivel = false);
  }

  void _revelarDica() {
    if (_erros < 4) {
      _mostrarAvisoCustomizado('Perca 4 corações primeiro para liberar a dica!');
      return;
    }
    if (_maxErros - _erros <= 1) {
      _mostrarAvisoCustomizado('Atenção! Comprar a dica com 1 coração seria fatal!');
      return;
    }

    setState(() {
      _erros++;
      _dicaRevelada = true;
    });
  }

  void _verificarVitoria() {
    if (_palavraAtual == null) return;
    final palavraReal = _palavraAtual!.texto.toUpperCase();
    final todasLetras = palavraReal.split('').where((c) => c != ' ' && c != '-').toSet();

    if (todasLetras.every((l) => _letrasDescobertas.contains(l))) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _mostrarResultado(vitoria: true);
      });
    }
  }

  void _verificarDerrota() {
    if (_erros >= _maxErros) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _mostrarResultado(vitoria: false);
      });
    }
  }

  void _mostrarResultado({required bool vitoria}) {
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
        onJogarNovamente: () {
          Navigator.pop(context);
          if (widget.modoMultiplayer) {
            setState(() {
              _jogadorAtual = _jogadorAtual == 1 ? 2 : 1;
            });
          }
          _iniciarNovoJogo();
        },
        onSair: () {
          AudioManager.instance.playMusica('musica_menu.mp3');
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
  // NOVO POP-UP DE SAÍDA CUSTOMIZADO (Com o papel desenhado)
  // ============================================================
  void _confirmarSaida() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_dialog.png'),
              fit: BoxFit.fill,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(30, 45, 30, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sair do jogo?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTema.texto),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Seu progresso será perdido.',
                style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Continuar', style: TextStyle(color: AppTema.azul, fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Fecha o dialog
                      Navigator.pop(context); // Fecha a tela do jogo
                    },
                    child: const Text('Sair', style: TextStyle(color: AppTema.vermelho, fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg_quadro_branco.jpg', fit: BoxFit.cover),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => _confirmarSaida(),
                          child: Image.asset('assets/images/ic_fechar.png', width: 28),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.modoMultiplayer) _buildPlacar(),
                          if (widget.modoMultiplayer) const SizedBox(height: 4),
                          Text(
                            widget.categoria,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTema.texto),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _buildDica(),

                Expanded(
                  flex: 3,
                  child: BonecoForca(erros: _erros, maxErros: _maxErros),
                ),

                _buildVidas(),

                _buildMascara(),
                const SizedBox(height: 16),

                _buildTeclado(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            bottom: _toastVisivel ? 40 : -100,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: 50,
                  width: _toastExpandido ? MediaQuery.of(context).size.width * 0.85 : 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppTema.texto, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        alignment: _toastExpandido ? Alignment.centerLeft : Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(left: _toastExpandido ? 14 : 0),
                          child: Image.asset('assets/images/ic_cadeado_f.png', width: 20),
                        ),
                      ),
                      if (_toastExpandido)
                        Positioned(
                          left: 45, right: 12, top: 0, bottom: 0,
                          child: Center(
                            child: Text(
                              _mensagemToast,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTema.texto),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOVO PLACAR MULTIPLAYER (Pontuações nas laterais)
  // ============================================================
  Widget _buildPlacar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pontuação J1
        Text(
          'J1: $_vitoriasJ1',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTema.verde),
        ),

        const SizedBox(width: 16),

        // Pílula Central
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _jogadorAtual == 1 ? AppTema.verde : AppTema.azul,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Vez do Jogador $_jogadorAtual',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),

        const SizedBox(width: 16),

        // Pontuação J2
        Text(
          '$_vitoriasJ2 :J2',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTema.azul),
        ),
      ],
    );
  }

  Widget _buildDica() {
    final dica = _palavraAtual?.dica ?? '';
    bool bloqueada = _erros < 4;

    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: _dicaRevelada
            ? Center(
          child: Text(dica, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTema.texto)),
        )
            : GestureDetector(
          onTap: _revelarDica,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                (bloqueada || _animandoDesbloqueio) ? 'assets/images/ic_lampada_lckd.png' : 'assets/images/ic_lampada.png',
                width: 140,
              ),
              if (bloqueada || _animandoDesbloqueio)
                AnimatedOpacity(
                  opacity: _animandoDesbloqueio ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedScale(
                    scale: _animandoDesbloqueio ? 1.5 : 1.0,
                    duration: const Duration(milliseconds: 600),
                    child: Image.asset(
                      _animandoDesbloqueio ? 'assets/images/ic_cadeado_a.png' : 'assets/images/ic_cadeado_f.png',
                      width: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
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
          child: Image.asset(viva ? 'assets/images/ic_coracao_cheio.png' : 'assets/images/ic_coracao_vazio.png', width: 24),
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
          if (letra == ' ') return const SizedBox(width: 16);
          final revelada = letra == '-' || _letrasDescobertas.contains(letra);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30, height: 36,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppTema.texto, width: 3)
                )
            ),
            child: Center(child: Text(revelada ? letra : '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTema.texto))),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTeclado() {
    const letras = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final larguraTela = MediaQuery.of(context).size.width;
    final availableWidth = larguraTela - 32;
    final keyWidth = (availableWidth - (6 * 6)) / 7;
    final keyHeight = keyWidth * 1.2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6, runSpacing: 6,
        children: letras.split('').map((letra) {
          final acertou = _letrasDescobertas.contains(letra);
          final errou = _letrasErradas.contains(letra);
          final usado = acertou || errou;

          String imagemFundo = 'assets/images/key_bg_neutro.png';
          if (acertou) imagemFundo = 'assets/images/key_bg_certo.png';
          else if (errou) imagemFundo = 'assets/images/key_bg_errado.png';

          return _BotaoLetra(
            letra: letra, imagemFundo: imagemFundo, desativado: usado, largura: keyWidth, altura: keyHeight,
            onTap: usado ? null : () => _processarJogada(letra),
          );
        }).toList(),
      ),
    );
  }
}

class _BotaoLetra extends StatefulWidget {
  final String letra;
  final String imagemFundo;
  final bool desativado;
  final double largura;
  final double altura;
  final VoidCallback? onTap;

  const _BotaoLetra({required this.letra, required this.imagemFundo, required this.desativado, required this.largura, required this.altura, this.onTap});

  @override
  State<_BotaoLetra> createState() => _BotaoLetraState();
}

class _BotaoLetraState extends State<_BotaoLetra> {
  bool _pressionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.desativado ? null : (_) => setState(() => _pressionado = true),
      onTapUp: widget.desativado ? null : (_) { setState(() => _pressionado = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressionado = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.largura, height: widget.altura,
        transform: Matrix4.translationValues(0, _pressionado ? 3 : 0, 0),
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(widget.imagemFundo), fit: BoxFit.fill)),
        child: Center(child: Text(widget.letra, style: TextStyle(fontSize: widget.largura * 0.55, fontWeight: FontWeight.w600, color: widget.desativado ? Colors.white : AppTema.texto))),
      ),
    );
  }
}

class _DialogResultado extends StatelessWidget {
  final bool vitoria;
  final String palavra;
  final bool modoMultiplayer;
  final int jogadorAtual;
  final VoidCallback onJogarNovamente;
  final VoidCallback onSair;

  const _DialogResultado({
    required this.vitoria, required this.palavra, required this.modoMultiplayer, required this.jogadorAtual, required this.onJogarNovamente, required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    final icone = vitoria ? 'assets/images/ic_vitoria.png' : 'assets/images/ic_derrota.png';
    final titulo = vitoria ? 'Acertou!' : 'Game Over!';
    final corTitulo = vitoria ? AppTema.verde : AppTema.vermelho;

    // NOVA REGRA DO BOTÃO: Se for multiplayer, carrega o botão azul de Continuar
    final String caminhoBotao;
    if (modoMultiplayer) {
      caminhoBotao = 'assets/images/btn_continuar.png';
    } else {
      caminhoBotao = vitoria ? 'assets/images/btn_jogar_verde.png' : 'assets/images/btn_jogar_vermelho.png';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 320,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_dialog.png'),
                fit: BoxFit.fill,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(30, 45, 30, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(icone, width: 75).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 8),
                Text(titulo, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: corTitulo)),

                if (!vitoria) ...[
                  const SizedBox(height: 12),
                  const Text('A palavra era:', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  Text(palavra, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTema.texto), textAlign: TextAlign.center),
                ],

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: onJogarNovamente,
                  child: Image.asset(caminhoBotao, width: 160),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: onSair,
            child: Image.asset(
              'assets/images/Menu_btn.png',
              width: 120,
            ),
          ),
        ],
      ),
    );
  }
}