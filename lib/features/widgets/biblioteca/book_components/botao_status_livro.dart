import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BotaoStatusLivro extends StatefulWidget {
  final Map<String, dynamic> livro;
  // 1. CRIAMOS A VARIÁVEL DE CONTROLE
  final bool isEstatico;

  const BotaoStatusLivro({
    super.key,
    required this.livro,
    // Por padrão é false. Assim, no Explorar, você não precisa mudar nada no código!
    this.isEstatico = false,
  });

  @override
  State<BotaoStatusLivro> createState() => _BotaoStatusLivroState();
}

class _BotaoStatusLivroState extends State<BotaoStatusLivro> {
  bool _isSelecionado = false;

  @override
  void initState() {
    super.initState();
    // 2. MUDAMOS A LÓGICA DE INICIALIZAÇÃO
    if (widget.isEstatico) {
      // Se está na biblioteca, não precisa ir no banco checar de novo.
      // Ele já lê direto da lista de livros que você puxou!
      _isSelecionado = widget.livro['status'] == 'lido';
    } else {
      // Só faz a busca individual no banco se estiver na tela Explorar
      _verificarStatusNoBanco();
    }
  }

  Future<void> _verificarStatusNoBanco() async {
    try {
      final supabase = Supabase.instance.client;
      final resposta = await supabase
          .from('meus_livros')
          .select('id')
          .eq('id', widget.livro['id'])
          .maybeSingle();

      if (resposta != null) {
        if (mounted) {
          setState(() {
            _isSelecionado = true;
          });
        }
      }
    } catch (erro) {
      debugPrint('Aviso ao checar livro: $erro');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. REGRA DO "QUERO LER": Se for estático e não for lido, desaparece!
    if (widget.isEstatico && !_isSelecionado) {
      return const SizedBox.shrink(); // SizedBox.shrink() é um widget invisível que não ocupa espaço
    }

    // 4. SEPARAMOS O DESENHO DO BOTÃO
    Widget visualBotao = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _isSelecionado
            ? const Color(0xFF8C79B7)
            : const Color(0xFFF0E5FC),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color.fromARGB(240, 248, 245, 244),
          width: 1.0,
        ),
      ),
      child: Icon(
        Icons.check,
        size: 12,
        color: _isSelecionado ? Colors.white : Colors.transparent,
      ),
    );

    // 5. A GRANDE DECISÃO DE TELA
    if (widget.isEstatico) {
      // Se for a biblioteca, retorna SÓ o desenho, sem função de clique
      return visualBotao;
    }

    // Se NÃO for estático (Explorar), retorna o botão abraçado com o GestureDetector original
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isSelecionado = !_isSelecionado;
        });

        final supabase = Supabase.instance.client;
        final livro = widget.livro;

        try {
          if (_isSelecionado) {
            await supabase.from('meus_livros').upsert({
              'id': livro['id'],
              'titulo': livro['titulo'],
              'autor': livro['autor'],
              'capa': livro['capa'],
              'status': 'lido',
              'favorito': true,
              'tags': livro['tags'] ?? [], // Previne erro caso tags venha nulo
            });
            debugPrint('✅ Livro salvo na nuvem: ${livro['titulo']}');
          } else {
            await supabase.from('meus_livros').delete().match({
              'id': livro['id'],
            });
            debugPrint('🗑️ Livro removido da nuvem: ${livro['titulo']}');
          }
        } catch (erro) {
          setState(() {
            _isSelecionado = !_isSelecionado;
          });
          debugPrint('❌ Erro ao salvar no banco: $erro');
        }
      },
      child: visualBotao,
    );
  }
}
