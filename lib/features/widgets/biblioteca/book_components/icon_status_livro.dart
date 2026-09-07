import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BotaoStatusLivro extends StatefulWidget {
  final Map<String, dynamic> livro;
  final bool isEstatico;

  const BotaoStatusLivro({
    super.key,
    required this.livro,
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
    if (!widget.isEstatico) {
      // No Explorar, verifica se o livro já foi salvo
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
    // ==============================================================
    // 1. COMPORTAMENTO NA BIBLIOTECA (Visuais livres e diferentes)
    // ==============================================================
    if (widget.isEstatico) {
      final String statusAtual = widget.livro['status'] ?? 'quero_ler';

      switch (statusAtual) {
        case 'lido':
          // Mantém a bolinha roxa com o checkzinho
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF8C79B7),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(240, 248, 245, 244),
                width: 1.0,
              ),
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          );

        case 'lendo':
          return Transform.translate(
            offset: const Offset(6, -13),
            child: const Icon(
              Icons.bookmark, // Ícone de marcador de página cheio
              size: 28, // Deixei um pouquinho maior para dar destaque
              color: Color(0xFF4A7A7E),
              // 👇 TRUQUE DE DESIGN: Sombras sólidas para todos os lados criam o contorno!
              shadows: [
                Shadow(offset: Offset(-1.5, -1.5), color: Colors.white),
                Shadow(offset: Offset(1.5, -1.5), color: Colors.white),
                Shadow(offset: Offset(1.5, 1.5), color: Colors.white),
                Shadow(offset: Offset(-1.5, 1.5), color: Colors.white),
                Shadow(offset: Offset(0, 2.0), color: Colors.white),
                Shadow(offset: Offset(0, -2.0), color: Colors.white),
                Shadow(offset: Offset(2.0, 0), color: Colors.white),
                Shadow(offset: Offset(-2.0, 0), color: Colors.white),
              ],
            ),
          );

        case 'abandonado':
          return Transform.translate(
            // Sobe o ícone 10 pixels (puxando para compensar o top: 8 do Grid) e empurra 6 pixels para a direita
            offset: const Offset(6, -9),
            child: const Icon(
              Icons.bookmark_remove_sharp,
              size: 28,
              color: Color(0xFF4A7A7E),
              shadows: [
                Shadow(offset: Offset(-1.5, -1.5), color: Colors.white),
                Shadow(offset: Offset(1.5, -1.5), color: Colors.white),
                Shadow(offset: Offset(1.5, 1.5), color: Colors.white),
                Shadow(offset: Offset(-1.5, 1.5), color: Colors.white),
                Shadow(offset: Offset(0, 2.0), color: Colors.white),
                Shadow(offset: Offset(0, -2.0), color: Colors.white),
                Shadow(offset: Offset(2.0, 0), color: Colors.white),
                Shadow(offset: Offset(-2.0, 0), color: Colors.white),
              ],
            ),
          );

        case 'quero_ler':
        default:
          // Não traz ícone nenhum (capa limpa)
          return const SizedBox.shrink();
      }
    }

    // ==============================================================
    // 2. COMPORTAMENTO NO EXPLORAR (Botão interativo de salvar)
    // ==============================================================
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
              'status': 'lido', // Salva como lido por padrão no explorar
              'favorito': true,
              'tags': livro['tags'] ?? [],
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
      // Aqui usamos o estilo de bolinha dinâmico (com clique)
      child: Container(
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
      ),
    );
  }
}
