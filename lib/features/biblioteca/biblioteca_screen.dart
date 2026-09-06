import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NOVO: Import do Supabase

import '../widgets/header/header_biblioteca.dart';
import '../widgets/header/estatisticas_card.dart';
import '../widgets/controles/categorias_menu.dart';
import '../widgets/controles/filters_menu.dart';
import '../widgets/book_components/book_grid.dart';
import '../../shared/custom_bottom_nav.dart';
import '../../services/books_api.dart';
import '../widgets/book_components/book_list.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  int _abaAtual = 3;
  bool _carregando = true;
  bool _isGridView = true;

  // ==========================================
  // 1. NOSSAS DUAS LISTAS E VARIÁVEIS DE CONTROLE
  // ==========================================
  List<Map<String, dynamic>> _livrosNuvem = []; // Livros salvos no seu banco
  List<Map<String, dynamic>> _livrosPesquisa =
      []; // Resultados da API do Google

  bool _mostrandoResultadosBusca = false; // O nosso "interruptor"
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
        _mostrandoResultadosBusca = false; // Garante que está mostrando o banco
        _carregando = false;
      });
    } catch (erro) {
      debugPrint('Erro ao buscar do Supabase: $erro');
      setState(() => _carregando = false);
    }
  }

  // ==========================================
  // 3. FUNÇÃO GOOGLE API (Busca livros novos)
  // ==========================================
  Future<void> _carregarDadosDaApi({required String termo}) async {
    setState(() {
      _carregando = true;
      _mostrandoResultadosBusca =
          true; // Virou a chave! Agora vai mostrar a pesquisa.
    });

    final livrosDaApi = await BooksApi.buscarLivros(termo);

    setState(() {
      _livrosPesquisa = livrosDaApi;
      _carregando = false;
    });
  }

  // ==========================================
  // 4. O FILTRO INTELIGENTE (Decide o que vai pra tela)
  // ==========================================
  List<Map<String, dynamic>> get _livrosExibidos {
    // Se o usuário pesquisou algo na lupa, mostra a lista do Google
    if (_mostrandoResultadosBusca) {
      return _livrosPesquisa;
    }

    // Se não, mostra a sua biblioteca com os filtros das abas!
    if (_abaSelecionada == 'todos') return _livrosNuvem;

    if (_abaSelecionada == 'favoritos') {
      return _livrosNuvem.where((livro) => livro['favorito'] == true).toList();
    }

    return _livrosNuvem
        .where((livro) => livro['status'] == _abaSelecionada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                  // Se a pessoa apagar a busca (deixar vazio), voltamos para a biblioteca local
                  if (termoDigitado.isEmpty) {
                    _buscarLivrosDaNuvem();
                  } else {
                    _carregarDadosDaApi(termo: termoDigitado);
                  }
                },
              ),
              const SizedBox(height: 25),
              const EstatisticasCard(),
              const SizedBox(height: 25),

              // Aqui está o seu menu de abas (Todos, Lidos, Favoritos...)
              CategoriasMenu(
                abaSelecionada: _abaSelecionada, // Passa a aba atual
                onAbaSelecionada: (novaAba) {
                  setState(() {
                    _abaSelecionada = novaAba; // Atualiza a tela quando clicar!
                    _mostrandoResultadosBusca = false;
                  });
                  _buscarLivrosDaNuvem();
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
              // 5. RENDERIZAÇÃO DA LISTA CORRETA
              // ==========================================
              Expanded(
                child: _carregando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8C79B7),
                        ),
                      )
                    : _livrosExibidos.isEmpty
                    // Mostra uma mensagem bonitinha se a lista estiver vazia
                    ? const Center(child: Text('Nenhum livro encontrado =/'))
                    : _isGridView
                    ? BookGrid(
                        livros: _livrosExibidos,
                      ) // Usamos a variável inteligente aqui!
                    : BookList(livros: _livrosExibidos), // E aqui!
              ),

              const SizedBox(height: 17),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF8C79B7),
        shape: const CircleBorder(),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        abaSelecionada: _abaAtual,
        aoClicarNaAba: (indice) {
          setState(() {
            _abaAtual = indice;
          });
        },
      ),
    );
  }
}
