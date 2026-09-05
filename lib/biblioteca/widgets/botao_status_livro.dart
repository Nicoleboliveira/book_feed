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
            });
            print('✅ Livro salvo na nuvem: ${livro['titulo']}');
          } else {
            // Se desmarcou, DELETA do banco
            await supabase.from('meus_livros').delete().match({
              'id': livro['id'],
            });
            print('🗑️ Livro removido da nuvem: ${livro['titulo']}');
          }
        } catch (erro) {
          // 3. Rollback: Se der erro (ex: sem internet), desfaz a cor do botão
          setState(() {
            _isSelecionado = !_isSelecionado;
          });
          print('❌ Erro ao salvar no banco: $erro');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4), // O seu padding perfeito
        decoration: BoxDecoration(
          // Se estiver marcado, pinta com o seu roxo. Se não, fica com o fundo transparente.
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
