import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NOVO: Import do Supabase

import '../widgets/header/header_biblioteca.dart';
import '../widgets/header/estatisticas_card.dart';
import '../widgets/controles/categorias_menu.dart';
import '../widgets/controles/filters_menu.dart';
import '../widgets/book_components/book_grid.dart';
import '../widgets/book_components/book_list.dart';
import '../widgets/book_components/empty_state_biblioteca.dart';

// ❌ O import 'books_api.dart' foi removido porque a API só vai morar no Explorar!

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

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
  // 2. FUNÇÃO SUPABASE (Busca sua biblioteca)
  // ==========================================
  Future<void> _buscarLivrosDaNuvem() async {
    setState(() => _carregando = true);

    try {
      final supabase = Supabase.instance.client;
      final resposta = await supabase.from('meus_livros').select();

      setState(() {
        _livrosNuvem = List<Map<String, dynamic>>.from(resposta);
        _carregando = false;
      });
    } catch (erro) {
      debugPrint('Erro ao buscar do Supabase: $erro');
      setState(() => _carregando = false);
    }
  }

  // ❌ A função _carregarDadosDaApi foi removida! O Explorar cuida disso agora.

  // ==========================================
  // 3. O NOVO FILTRO INTELIGENTE (Abas + Busca Local)
  // ==========================================
  List<Map<String, dynamic>> get _livrosExibidos {
    List<Map<String, dynamic>> filtrados;

    // 1º Passo: Filtra pela aba (Todos, Lidos, Favoritos...)
    if (_abaSelecionada == 'todos') {
      filtrados = _livrosNuvem;
    } else if (_abaSelecionada == 'favoritos') {
      filtrados = _livrosNuvem
          .where((livro) => livro['favorito'] == true)
          .toList();
    } else {
      filtrados = _livrosNuvem
          .where((livro) => livro['status'] == _abaSelecionada)
          .toList();
    }

    // 2º Passo: Filtra pelo texto digitado na lupa (Busca Local Instantânea!)
    if (_termoBuscaLocal.isNotEmpty) {
      filtrados = filtrados.where((livro) {
        final titulo = (livro['titulo'] ?? '').toString().toLowerCase();
        final autor = (livro['autor'] ?? '').toString().toLowerCase();
        final termo = _termoBuscaLocal.toLowerCase();

        // Se o termo estiver no título ou no autor, ele mostra o livro!
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
                  // 👉 A MÁGICA É AQUI: Não chama API, só atualiza a variável da busca local!
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

              // Aqui está o seu menu de abas (Todos, Lidos, Favoritos...)
              CategoriasMenu(
                abaSelecionada: _abaSelecionada, // Passa a aba atual
                onAbaSelecionada: (novaAba) {
                  setState(() {
                    _abaSelecionada = novaAba;
                    _termoBuscaLocal = ''; // Limpa a busca ao trocar de aba!
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
                    // Mostra a sua mensagem bonitinha que nenhum livro foi encontrado
                    ? EmptyStateBiblioteca(
                        onExplorar: () {
                          // Ação do botão: Voltar para a aba "Todos" limpando a busca
                          setState(() {
                            _abaSelecionada = 'todos';
                            _termoBuscaLocal = '';
                          });
                        },
                      )
                    : _isGridView
                    ? BookGrid(livros: _livrosExibidos)
                    : BookList(livros: _livrosExibidos),
              ),

              const SizedBox(height: 17),
            ],
          ),
        ),
      ),
    );
  }
}
