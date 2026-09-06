import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BotaoStatusLivro extends StatefulWidget {
  final Map<String, dynamic> livro;

  const BotaoStatusLivro({super.key, required this.livro});

  @override
  State<BotaoStatusLivro> createState() => _BotaoStatusLivroState();
}

class _BotaoStatusLivroState extends State<BotaoStatusLivro> {
  // Começa desmarcado (você pode alterar a lógica depois se o livro já vier favoritado do banco)
  bool _isSelecionado = false;

  @override
  void initState() {
    super.initState();
    _verificarStatusNoBanco();
  }

  Future<void> _verificarStatusNoBanco() async {
    try {
      final supabase = Supabase.instance.client;

      // Fazemos um SELECT buscando apenas este ID específico.
      // O .maybeSingle() retorna o dado se achar, ou 'null' se o livro não estiver no banco.
      final resposta = await supabase
          .from('meus_livros')
          .select('id')
          .eq('id', widget.livro['id'])
          .maybeSingle();

      // Se a resposta não for nula, significa que o livro está salvo!
      if (resposta != null) {
        setState(() {
          _isSelecionado = true; // Pinta o botão de roxo
        });
      }
    } catch (erro) {
      // Se a internet piscar, ele apenas falha silenciosamente e deixa o botão transparente
      debugPrint('Aviso ao checar livro: $erro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isSelecionado = !_isSelecionado;
        });

        // 2. Prepara a chamada para o banco
        final supabase = Supabase.instance.client;
        final livro = widget.livro;

        try {
          if (_isSelecionado) {
            // Se marcou, INSERE no banco (o upsert evita dar erro de duplicidade)
            await supabase.from('meus_livros').upsert({
              'id': livro['id'],
              'titulo': livro['titulo'],
              'autor': livro['autor'],
              'capa': livro['capa'],
              'status': 'lido', // Por enquanto, vamos fixar como lido
              'favorito': true,
              'tags': livro['tags'],
            });
            debugPrint('✅ Livro salvo na nuvem: ${livro['titulo']}');
          } else {
            // Se desmarcou, DELETA do banco
            await supabase.from('meus_livros').delete().match({
              'id': livro['id'],
            });
            debugPrint('🗑️ Livro removido da nuvem: ${livro['titulo']}');
          }
        } catch (erro) {
          // 3. Rollback: Se der erro (ex: sem internet), desfaz a cor do botão
          setState(() {
            _isSelecionado = !_isSelecionado;
          });
          debugPrint('❌ Erro ao salvar no banco: $erro');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4), // O seu padding perfeito
        decoration: BoxDecoration(
          color: _isSelecionado ? const Color(0xFF8C79B7) : Color(0xFFF0E5FC),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color.fromARGB(240, 248, 245, 244), // A sua borda
            width: 1.0,
          ),
        ),
        child: Icon(
          Icons.check,
          size: 12, // O seu tamanho original
          // O ícone fica branco se selecionado. Se não, fica transparente (invisível)
          color: _isSelecionado ? Colors.white : Colors.transparent,
        ),
      ),
    );
  }
}
