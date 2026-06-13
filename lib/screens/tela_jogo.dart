import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../database/database_helper.dart';
import '../models/palavra.dart';
import '../theme/app_tema.dart';
import '../widgets/boneco_forca.dart';
import '../audio_manager.dart';
import '../core/services/achievements_manager.dart';

class TelaJogo extends StatefulWidget {
  final List<String> categorias;
  final String modoJogo;
  final bool modoMultiplayer;
  final int jogadorAtual;
  final String tipoMultiplayer;
  final Palavra? palavraCustomizada;

  const TelaJogo({
    super.key,
    required this.categorias,
    required this.modoJogo,
    required this.modoMultiplayer,
    required this.jogadorAtual,
    this.tipoMultiplayer = 'nenhum',
    this.palavraCustomizada,
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

  // CONTROLES DE RODADA FECHADA
  int _rodadaAtual = 1;
  int _jogadorQueAbriuARodada = 1;
  int _jogadasNaRodada = 0;
  bool _j1VenceuRodada = false;
  bool _j2VenceuRodada = false;

  // CONTROLES DE MORTE SÚBITA (Cabo de Guerra)
  bool _morteSubita = false;

  // CONTROLES DE ANIMAÇÃO DE TURNO TELA CHEIA
  bool _animandoTurno = false;
  int _jogadorTurnoAnimacao = 1;

  bool _animandoDesbloqueio = false;
  bool _toastVisivel = false;
  bool _toastExpandido = false;
  String _mensagemToast = '';

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playMusica('musica_jogo.mp3');

    if (widget.modoMultiplayer && widget.tipoMultiplayer != 'arquiteto') {
      _sortearPrimeiroJogador();
    } else {
      _jogadorAtual = widget.jogadorAtual;
      if (widget.tipoMultiplayer == 'arquiteto') {
        _mostrarAnimacaoTurno(_jogadorAtual);
      }
    }

    _iniciarNovoJogo();
  }

  void _sortearPrimeiroJogador() {
    bool j1Comeca = Random().nextBool();
    _jogadorAtual = j1Comeca ? 1 : 2;
    _jogadorQueAbriuARodada = _jogadorAtual;

    // Dispara a animação em tela cheia logo no início
    Future.delayed(const Duration(milliseconds: 300), () {
      _mostrarAnimacaoTurno(_jogadorAtual);
    });
  }

  void _mostrarAnimacaoTurno(int jogador) async {
    if (!mounted) return;
    setState(() {
      _jogadorTurnoAnimacao = jogador;
      _animandoTurno = true;
    });

    // Tempo que a tela colorida fica visível
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      setState(() => _animandoTurno = false);
    }
  }

  Future<void> _iniciarNovoJogo() async {
    setState(() => _carregando = true);

    Palavra? palavra;
    if (widget.tipoMultiplayer == 'arquiteto' && widget.palavraCustomizada != null) {
      palavra = widget.palavraCustomizada;
    } else {
      palavra = await DatabaseHelper.instance.sortearPalavra(
        categorias: widget.categorias,
        modoJogo: widget.modoJogo,
      );
    }

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
      _morteSubita = false;
      _dicaRevelada = (widget.modoJogo == 'rodinhas');
      _carregando = false;
      _animandoDesbloqueio = false;
    });
  }

  void _processarJogada(String letra) {
    if (_palavraAtual == null) return;
    final palavraReal = _palavraAtual!.texto.toUpperCase();

    AudioManager.instance.playClique();

    setState(() {
      if (palavraReal.contains(letra)) {
        _letrasDescobertas.add(letra);
        _verificarVitoria();
      } else {
        _letrasErradas.add(letra);

        if (!_morteSubita) {
          int errosAntes = _erros;
          _erros++;
          if (errosAntes == 3 && _erros == 4) _animarDestrancarDica();
        }

        if (widget.tipoMultiplayer == 'cabo_de_guerra') {
          if (_morteSubita) {
            // Morte súbita: se errar o último coração, perdeu!
            _verificarDerrota();
          } else if (_erros >= _maxErros) {
            // Acabaram os erros normais. Ativa a morte súbita e passa a vez!
            _morteSubita = true;
            _jogadorAtual = _jogadorAtual == 1 ? 2 : 1;
            _mostrarAnimacaoTurno(_jogadorAtual);
          } else {
            // Erro normal, só passa a vez
            _jogadorAtual = _jogadorAtual == 1 ? 2 : 1;
            _mostrarAnimacaoTurno(_jogadorAtual);
          }
        } else {
          _verificarDerrota(); // Clássico e Arquiteto
        }
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
    setState(() { _mensagemToast = msg; _toastVisivel = true; _toastExpandido = false; });
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
    if (_erros < 4) { _mostrarAvisoCustomizado('Perca 4 corações primeiro!'); return; }
    if (_maxErros - _erros <= 1) { _mostrarAvisoCustomizado('Comprar agora seria fatal!'); return; }
    setState(() { _erros++; _dicaRevelada = true; });
  }

  void _verificarVitoria() {
    if (_palavraAtual == null) return;
    final palavraReal = _palavraAtual!.texto.toUpperCase();
    final todasLetras = palavraReal.split('').where((c) => c != ' ' && c != '-').toSet();

    if (todasLetras.every((l) => _letrasDescobertas.contains(l))) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _encerrarPartida(vitoria: true);
      });
    }
  }

  void _verificarDerrota() {
    if (_erros >= _maxErros || _morteSubita) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _encerrarPartida(vitoria: false);
      });
    }
  }

  Future<void> _encerrarPartida({required bool vitoria}) async {
    final db = DatabaseHelper.instance;
    await db.incrementarEstatistica('total_partidas');

    if (vitoria && _palavraAtual != null) {
      await db.incrementarEstatistica('sequencia_vitorias');
      await db.incrementarEstatistica('cat_${_palavraAtual!.categoria}');
    } else {
      final banco = await db.database;
      await banco.rawUpdate("UPDATE estatisticas SET valor = 0 WHERE nome = 'sequencia_vitorias'");
    }

    if (_palavraAtual != null) {
      AchievementsManager.processarFimDePartida(
        venceu: vitoria, categoriaJogada: _palavraAtual!.categoria,
        modoJogo: widget.modoJogo, modoMultiplayer: widget.modoMultiplayer,
        palavraTexto: _palavraAtual!.texto, categoriasSelecionadas: widget.categorias,
        errosCometidos: _erros,
      );
    }

    if (widget.tipoMultiplayer == 'classico') {
      _processarFimRodadaClassico(vitoria);
    } else if (widget.tipoMultiplayer == 'cabo_de_guerra') {
      _processarFimCaboDeGuerra(vitoria);
    } else if (widget.tipoMultiplayer == 'arquiteto') {
      _processarFimArquiteto(vitoria);
    } else {
      _mostrarDialogo(vitoria: vitoria);
    }
  }

  void _processarFimRodadaClassico(bool vitoria) {
    if (vitoria) {
      if (_jogadorAtual == 1) _j1VenceuRodada = true;
      else _j2VenceuRodada = true;
    }

    _jogadasNaRodada++;
    bool fimDeRodada = _jogadasNaRodada == 2;

    // Descobre quem é o próximo para chamar pelo número
    int proximoJogador = _jogadorAtual == 1 ? 2 : 1;

    // Monta o título dinâmico com quebra de linha
    String tituloDialogo;
    if (fimDeRodada) {
      tituloDialogo = 'Fim da Rodada $_rodadaAtual';
    } else {
      tituloDialogo = vitoria
          ? 'J$_jogadorAtual Acertou!\nJ$proximoJogador pronto?'
          : 'J$_jogadorAtual Errou!\nJ$proximoJogador pronto?';
    }

    _mostrarDialogo(
        vitoria: vitoria,
        tituloCustomizado: tituloDialogo,
        onAcaoBotao: () async {
          Navigator.pop(context);
          if (fimDeRodada) {
            if (_j1VenceuRodada) { _vitoriasJ1++; await DatabaseHelper.instance.registrarVitoria('Jogador 1'); }
            if (_j2VenceuRodada) { _vitoriasJ2++; await DatabaseHelper.instance.registrarVitoria('Jogador 2'); }

            setState(() {
              _rodadaAtual++;
              _jogadasNaRodada = 0;
              _j1VenceuRodada = false;
              _j2VenceuRodada = false;
              _jogadorQueAbriuARodada = _jogadorQueAbriuARodada == 1 ? 2 : 1;
              _jogadorAtual = _jogadorQueAbriuARodada;
            });
          } else {
            setState(() { _jogadorAtual = proximoJogador; });
          }

          _mostrarAnimacaoTurno(_jogadorAtual);
          _iniciarNovoJogo();
        }
    );
  }

  void _processarFimCaboDeGuerra(bool vitoria) async {
    if (vitoria) {
      if (_jogadorAtual == 1) _vitoriasJ1++; else _vitoriasJ2++;
      await DatabaseHelper.instance.registrarVitoria('Jogador $_jogadorAtual');
    }
    _mostrarDialogo(
        vitoria: vitoria,
        tituloCustomizado: vitoria ? 'Jogador $_jogadorAtual Venceu!' : 'Ambos Perderam!',
        onAcaoBotao: () {
          Navigator.pop(context);
          _sortearPrimeiroJogador();
          _iniciarNovoJogo();
        }
    );
  }

  void _processarFimArquiteto(bool vitoria) async {
    int vencedor = vitoria ? _jogadorAtual : (_jogadorAtual == 1 ? 2 : 1);
    if (vencedor == 1) _vitoriasJ1++; else _vitoriasJ2++;

    await DatabaseHelper.instance.registrarVitoria('Jogador $vencedor');

    _mostrarDialogo(
        vitoria: vitoria,
        tituloCustomizado: 'Jogador $vencedor levou o ponto!',
        onAcaoBotao: () {
          Navigator.pop(context);
          Navigator.pop(context);
        }
    );
  }

  void _mostrarDialogo({required bool vitoria, String? tituloCustomizado, VoidCallback? onAcaoBotao}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogResultado(
        vitoria: vitoria,
        palavra: _palavraAtual?.texto ?? '',
        modoMultiplayer: widget.modoMultiplayer,
        tituloCustom: tituloCustomizado,
        onJogarNovamente: onAcaoBotao ?? () {
          Navigator.pop(context);
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
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Erro'), content: Text(msg), actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('OK'))]));
  }

  void _confirmarSaida() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, elevation: 0,
        child: Container(
          width: 320, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/bg_dialog.png'), fit: BoxFit.fill)),
          padding: const EdgeInsets.fromLTRB(30, 45, 30, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sair do jogo?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTema.texto), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('Seu progresso será perdido.', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Continuar', style: TextStyle(color: AppTema.azul, fontWeight: FontWeight.w900, fontSize: 18))),
                  GestureDetector(onTap: () { AudioManager.instance.playMusica('musica_menu.mp3'); Navigator.pop(context); Navigator.pop(context); }, child: const Text('Sair', style: TextStyle(color: AppTema.vermelho, fontWeight: FontWeight.w900, fontSize: 18))),
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
    if (_carregando) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                      Align(alignment: Alignment.centerLeft, child: GestureDetector(onTap: () => _confirmarSaida(), child: Image.asset('assets/images/ic_fechar.png', width: 28))),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.modoMultiplayer) _buildPlacar(),
                          if (widget.modoMultiplayer) const SizedBox(height: 4),
                          Text(
                            widget.tipoMultiplayer == 'arquiteto' ? 'Modo Arquiteto' : (widget.categorias.length > 1 ? 'Modo Personalizado' : widget.categorias.first),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTema.texto),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildDica(),
                Expanded(flex: 3, child: BonecoForca(erros: _morteSubita ? _maxErros : _erros, maxErros: _maxErros)),
                _buildVidas(),
                _buildMascara(),
                const SizedBox(height: 16),
                _buildTeclado(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Toast Animado Antigo (Para Dica, etc)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack,
            bottom: _toastVisivel ? 40 : -100, left: 0, right: 0,
            child: IgnorePointer(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400), curve: Curves.easeInOut,
                  height: 50, width: _toastExpandido ? MediaQuery.of(context).size.width * 0.85 : 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0), borderRadius: BorderRadius.circular(25), border: Border.all(color: AppTema.texto, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut, alignment: _toastExpandido ? Alignment.centerLeft : Alignment.center, child: Padding(padding: EdgeInsets.only(left: _toastExpandido ? 14 : 0), child: Image.asset('assets/images/ic_cadeado_f.png', width: 20))),
                      if (_toastExpandido) Positioned(left: 45, right: 12, top: 0, bottom: 0, child: Center(child: Text(_mensagemToast, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTema.texto), textAlign: TextAlign.left))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // NOVA ANIMAÇÃO DE TURNO (Tela Cheia)
          IgnorePointer(
            ignoring: !_animandoTurno,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _animandoTurno ? 1.0 : 0.0,
              child: Container(
                color: (_jogadorTurnoAnimacao == 1 ? AppTema.vermelho : AppTema.azul).withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_morteSubita)
                        const Text(
                          'MORTE SÚBITA',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 4),
                        ).animate().shake(duration: 500.ms),
                      const SizedBox(height: 10),
                      Text(
                        'Vez do Jogador $_jogadorTurnoAnimacao!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white),
                      ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
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

  Widget _buildPlacar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('J1: $_vitoriasJ1', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTema.vermelho)),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
              color: _jogadorAtual == 1 ? AppTema.vermelho : AppTema.azul,
              borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            widget.tipoMultiplayer == 'classico'
                ? 'Rodada $_rodadaAtual • Vez do J$_jogadorAtual'
                : 'Vez do Jogador $_jogadorAtual',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
        const SizedBox(width: 16),
        Text('$_vitoriasJ2 :J2', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTema.azul)),
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
            ? Center(child: Text(dica, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTema.texto)))
            : GestureDetector(
          onTap: _revelarDica,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset((bloqueada || _animandoDesbloqueio) ? 'assets/images/ic_lampada_lckd.png' : 'assets/images/ic_lampada.png', width: 140),
              if (bloqueada || _animandoDesbloqueio)
                AnimatedOpacity(opacity: _animandoDesbloqueio ? 0.0 : 1.0, duration: const Duration(milliseconds: 600), child: AnimatedScale(scale: _animandoDesbloqueio ? 1.5 : 1.0, duration: const Duration(milliseconds: 600), child: Image.asset(_animandoDesbloqueio ? 'assets/images/ic_cadeado_a.png' : 'assets/images/ic_cadeado_f.png', width: 24))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVidas() {
    // Substitui a barra de vidas pelo coração pulsante na Morte Súbita!
    if (widget.tipoMultiplayer == 'cabo_de_guerra' && _morteSubita) {
      return Container(
        height: 30, // Mantém a altura fixa para não quebrar o layout
        alignment: Alignment.center,
        child: Image.asset('assets/images/ic_coracao_cheio.png', width: 32)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4), duration: 400.ms),
      );
    }

    final vidasRestantes = _maxErros - _erros;
    return Container(
      height: 30,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_maxErros, (i) {
          final viva = i < vidasRestantes;
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Image.asset(viva ? 'assets/images/ic_coracao_cheio.png' : 'assets/images/ic_coracao_vazio.png', width: 24));
        }),
      ),
    );
  }

  Widget _buildMascara() {
    if (_palavraAtual == null) return const SizedBox();
    final partes = _palavraAtual!.texto.toUpperCase().split(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center, spacing: 20, runSpacing: 12,
        children: partes.map((palavra) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: palavra.split('').map((letra) {
              final revelada = letra == '-' || _letrasDescobertas.contains(letra);
              return Container(
                width: 26, height: 36, margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTema.texto, width: 3))),
                child: Center(child: FittedBox(fit: BoxFit.contain, child: Text(revelada ? letra : '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTema.texto)))),
              );
            }).toList(),
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
        alignment: WrapAlignment.center, spacing: 6, runSpacing: 6,
        children: letras.split('').map((letra) {
          final acertou = _letrasDescobertas.contains(letra);
          final errou = _letrasErradas.contains(letra);
          final usado = acertou || errou;
          String imagemFundo = 'assets/images/key_bg_neutro.png';
          if (acertou) imagemFundo = 'assets/images/key_bg_certo.png';
          else if (errou) imagemFundo = 'assets/images/key_bg_errado.png';
          return _BotaoLetra(letra: letra, imagemFundo: imagemFundo, desativado: usado, largura: keyWidth, altura: keyHeight, onTap: usado ? null : () => _processarJogada(letra));
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
        duration: const Duration(milliseconds: 60), width: widget.largura, height: widget.altura,
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
  final String? tituloCustom;
  final VoidCallback onJogarNovamente;
  final VoidCallback onSair;

  const _DialogResultado({
    required this.vitoria, required this.palavra, required this.modoMultiplayer, this.tituloCustom, required this.onJogarNovamente, required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    final icone = vitoria ? 'assets/images/ic_vitoria.png' : 'assets/images/ic_derrota.png';
    final titulo = tituloCustom ?? (vitoria ? 'Acertou!' : 'Game Over!');
    final corTitulo = vitoria ? AppTema.verde : AppTema.vermelho;

    final String caminhoBotao = modoMultiplayer ? 'assets/images/btn_continuar.png' : (vitoria ? 'assets/images/btn_jogar_verde.png' : 'assets/images/btn_jogar_vermelho.png');

    return Dialog(
      backgroundColor: Colors.transparent, elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 320, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/bg_dialog.png'), fit: BoxFit.fill)),
            padding: const EdgeInsets.fromLTRB(30, 45, 30, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(icone, width: 75).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 8),
                Text(titulo, textAlign: TextAlign.center, style: TextStyle(fontSize: titulo.length > 12 ? 22 : 32, fontWeight: FontWeight.w900, color: corTitulo)),
                if (!vitoria) ...[
                  const SizedBox(height: 12),
                  const Text('A palavra era:', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  Text(palavra, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTema.texto), textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                GestureDetector(onTap: onJogarNovamente, child: Image.asset(caminhoBotao, width: 160)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(onTap: onSair, child: Image.asset('assets/images/Menu_btn.png', width: 120)),
        ],
      ),
    );
  }
}