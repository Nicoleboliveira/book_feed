import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/biblioteca/header/header_biblioteca.dart';
import '../widgets/biblioteca/header/estatisticas_card.dart';
import '../widgets/biblioteca/controles/categorias_menu.dart';
import '../widgets/biblioteca/controles/filters_menu.dart';
import '../widgets/biblioteca/book_components/book_grid.dart';
import '../widgets/biblioteca/book_components/book_list.dart';
import '../widgets/biblioteca/book_components/empty_state_biblioteca.dart';

class BibliotecaScreen extends StatefulWidget {
  final VoidCallback onMudarParaExplorar;
  const BibliotecaScreen({super.key, required this.onMudarParaExplorar});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  bool _carregando = true;
  bool _isGridView = true;

  // ==========================================
  // 1. VARIÁVEIS DE CONTROLE LIMPAS
  // ==========================================
  List<Map<String, dynamic>> _livrosNuvem = []; // Livros salvos no seu banco

  // 👉 NOVA VARIÁVEL: Guarda o que você digitar na lupa da biblioteca!
  String _termoBuscaLocal = '';

  String _abaSelecionada =
      'todos'; // Controla as abas (Todos, Lidos, Favoritos)

  @override
  void initState() {
    super.initState();
    // Quando o app abre, ele busca a SUA biblioteca no banco!
    _buscarLivrosDaNuvem();
  }

  // ==========================================
  // 2. FUNÇÃO SUPABASE (Agora em TEMPO REAL!)
  // ==========================================
  void _buscarLivrosDaNuvem() {
    setState(() => _carregando = true);

    final supabase = Supabase.instance.client;

    supabase
        .from('meus_livros')
        .stream(primaryKey: ['id'])
        .listen((resposta) {
          if (mounted) {
            setState(() {
              _livrosNuvem = List<Map<String, dynamic>>.from(resposta);
              _carregando = false;
            });
          }
        })
        .onError((erro) {
          debugPrint('Erro na rádio do Supabase: $erro');
          if (mounted) {
            setState(() => _carregando = false);
          }
        });
  }

  // ==========================================
  // 👉 NOVA FUNÇÃO: Atualiza o status do livro no banco
  // ==========================================
  Future<void> _atualizarStatusLivro(
    String idLivro,
    String acao, {
    bool? valorEmprestimo,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      if (acao == 'mudar_emprestimo') {
        await supabase
            .from('meus_livros')
            .update({'emprestado': valorEmprestimo})
            .eq('id', idLivro);
      }
      // 👇 MÁGICA DA EXCLUSÃO AQUI:
      else if (acao == 'excluir') {
        await supabase.from('meus_livros').delete().eq('id', idLivro);
      } else {
        await supabase
            .from('meus_livros')
            .update({'status': acao})
            .eq('id', idLivro);
      }
    } catch (erro) {
      debugPrint('Erro ao atualizar banco: $erro');
    }
  }

  // ==========================================
  // 3. O NOVO FILTRO INTELIGENTE (Abas + Busca Local)
  // ==========================================
  List<Map<String, dynamic>> get _livrosExibidos {
    List<Map<String, dynamic>> filtrados;

    // Converte a aba selecionada para minúsculo para evitar erros de digitação (ex: 'Lendo' vira 'lendo')
    final abaNormalizada = _abaSelecionada.toLowerCase();

    if (abaNormalizada == 'todos') {
      filtrados = _livrosNuvem;
    } else if (abaNormalizada == 'favoritos') {
      filtrados = _livrosNuvem
          .where((livro) => livro['favorito'] == true)
          .toList();
    }
    // 👇 AQUI ESTÁ O SEGREDO DO EMPRESTADO: Ele olha para a coluna booleana!
    else if (abaNormalizada == 'emprestados' ||
        abaNormalizada == 'emprestado') {
      filtrados = _livrosNuvem
          .where((livro) => livro['emprestado'] == true)
          .toList();
    }
    // 👇 E AQUI FICA A REGRA PRO RESTO (lido, lendo, quero_ler, abandonado)
    else {
      filtrados = _livrosNuvem
          .where((livro) => livro['status'] == abaNormalizada)
          .toList();
    }

    // Filtro pelo texto digitado na lupa (Busca Local Instantânea!)
    if (_termoBuscaLocal.isNotEmpty) {
      filtrados = filtrados.where((livro) {
        final titulo = (livro['titulo'] ?? '').toString().toLowerCase();
        final autor = (livro['autor'] ?? '').toString().toLowerCase();
        final termo = _termoBuscaLocal.toLowerCase();

        return titulo.contains(termo) || autor.contains(termo);
      }).toList();
    }

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    final int totalLivros = _livrosNuvem.length;
    final int totalLidos = _livrosNuvem
        .where((livro) => livro['status'] == 'lido')
        .length;
    final int totalLendo = _livrosNuvem
        .where((livro) => livro['status'] == 'lendo')
        .length;
    final int totalQueroLer = _livrosNuvem
        .where((livro) => livro['status'] == 'quero_ler')
        .length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 24.0,
            right: 24.0,
            bottom: 0,
          ),
          child: Column(
            children: [
              HeaderBiblioteca(
                onBuscar: (termoDigitado) {
                  setState(() {
                    _termoBuscaLocal = termoDigitado;
                  });
                },
              ),
              const SizedBox(height: 25),
              EstatisticasCard(
                total: totalLivros,
                lidos: totalLidos,
                lendo: totalLendo,
                queroLer: totalQueroLer,
              ),
              const SizedBox(height: 25),

              CategoriasMenu(
                abaSelecionada: _abaSelecionada,
                onAbaSelecionada: (novaAba) {
                  setState(() {
                    _abaSelecionada = novaAba;
                    _termoBuscaLocal = '';
                  });
                },
              ),

              const SizedBox(height: 17),
              FiltersMenu(
                isGridView: _isGridView,
                onViewChanged: (isGrid) {
                  setState(() {
                    _isGridView = isGrid;
                  });
                },
              ),
              const SizedBox(height: 17),

              // ==========================================
              // 4. RENDERIZAÇÃO DA LISTA CORRETA
              // ==========================================
              Expanded(
                child: _carregando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8C79B7),
                        ),
                      )
                    : _livrosExibidos.isEmpty
                    ? EmptyStateBiblioteca(
                        onExplorar: () {
                          widget.onMudarParaExplorar();
                        },
                      )
                    : _isGridView
                    ? BookGrid(
                        livros: _livrosExibidos,
                        onUpdateStatus: (id, acao, {valorEmprestimo}) =>
                            _atualizarStatusLivro(
                              id,
                              acao,
                              valorEmprestimo: valorEmprestimo,
                            ), // 👉 Conectamos a grade com a função!
                      )
                    : BookList(
                        livros: _livrosExibidos,
                        onUpdateStatus: (id, acao, {valorEmprestimo}) =>
                            _atualizarStatusLivro(
                              id,
                              acao,
                              valorEmprestimo: valorEmprestimo,
                            ), // 👉 Conectamos a lista com a função!
                      ),
              ),

              const SizedBox(height: 17),
            ],
          ),
        ),
      ),
    );
  }
}
