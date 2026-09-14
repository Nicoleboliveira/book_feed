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

  List<Map<String, dynamic>> _livrosNuvem = [];

  String _termoBuscaLocal = '';
  String _abaSelecionada = 'todos';
  String _filtroTempoSelecionado = 'recentes';

  @override
  void initState() {
    super.initState();
    _buscarLivrosDaNuvem();
  }

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
  // 👉 PASSO 1: Isolar os livros da aba atual!
  // ==========================================
  List<Map<String, dynamic>> get _livrosDaAbaAtual {
    final abaNormalizada = _abaSelecionada.toLowerCase();

    if (abaNormalizada == 'todos') {
      return List.from(_livrosNuvem);
    } else if (abaNormalizada == 'favoritos') {
      return _livrosNuvem.where((livro) => livro['favorito'] == true).toList();
    } else if (abaNormalizada == 'emprestados' ||
        abaNormalizada == 'emprestado') {
      return _livrosNuvem
          .where((livro) => livro['emprestado'] == true)
          .toList();
    } else {
      return _livrosNuvem
          .where((livro) => livro['status'] == abaNormalizada)
          .toList();
    }
  }

  // ==========================================
  // 👉 PASSO 2: O gerador de menu agora só olha para os livros da aba atual
  // ==========================================
  List<Map<String, String>> get _opcoesTempoDisponiveis {
    List<Map<String, String>> opcoes = [
      {'id': 'recentes', 'label': 'Mais recentes'},
    ];

    // 👇 Usamos a nova lista isolada aqui!
    final livrosBase = _livrosDaAbaAtual;

    if (livrosBase.isEmpty) return opcoes;

    bool temHoje = false;
    bool temOntem = false;
    bool temSemana = false;
    bool temMes = false;
    bool temAno = false;

    DateTime agora = DateTime.now();
    DateTime hojeBruto = DateTime(agora.year, agora.month, agora.day);
    DateTime ontemBruto = hojeBruto.subtract(const Duration(days: 1));
    DateTime segundaFeira = hojeBruto.subtract(
      Duration(days: agora.weekday - 1),
    );

    // Varre apenas os livros que estão visíveis na aba!
    for (var livro in livrosBase) {
      String dataStr = livro['created_at'] ?? livro['updated_at'] ?? '';
      if (dataStr.isEmpty) {
        temHoje = true;
        continue;
      }

      DateTime dtRaw = DateTime.parse(dataStr);
      DateTime dt = DateTime(
        dtRaw.toLocal().year,
        dtRaw.toLocal().month,
        dtRaw.toLocal().day,
      );

      if (dt == hojeBruto) temHoje = true;
      if (dt == ontemBruto) temOntem = true;
      if (!dt.isBefore(segundaFeira) && !dt.isAfter(hojeBruto))
        temSemana = true;
      if (dt.year == agora.year && dt.month == agora.month) temMes = true;
      if (dt.year == agora.year) temAno = true;
    }

    if (temHoje) opcoes.add({'id': 'hoje', 'label': 'Adicionados hoje'});
    if (temOntem) opcoes.add({'id': 'ontem', 'label': 'Adicionados ontem'});

    if (temSemana && agora.weekday >= 3) {
      opcoes.add({'id': 'semana', 'label': 'Esta semana'});
    }

    if (temMes) opcoes.add({'id': 'mes', 'label': 'Este mês'});
    if (temAno) opcoes.add({'id': 'ano', 'label': 'Este ano'});

    return opcoes;
  }

  Future<void> _atualizarStatusLivro(
    String idLivro,
    String acao, {
    bool? valorEmprestimo,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final dataAtualizacao = DateTime.now().toUtc().toIso8601String();

      if (acao == 'mudar_emprestimo') {
        await supabase
            .from('meus_livros')
            .update({
              'emprestado': valorEmprestimo,
              'updated_at': dataAtualizacao,
            })
            .eq('id', idLivro);
      } else if (acao == 'excluir') {
        await supabase.from('meus_livros').delete().eq('id', idLivro);
      } else {
        await supabase
            .from('meus_livros')
            .update({'status': acao, 'updated_at': dataAtualizacao})
            .eq('id', idLivro);
      }
    } catch (erro) {
      debugPrint('Erro ao atualizar banco: $erro');
    }
  }

  // ==========================================
  // 3. O NOVO FILTRO INTELIGENTE TOTAL
  // ==========================================
  List<Map<String, dynamic>> get _livrosExibidos {
    // 👇 Começamos a filtrar já a partir dos livros da aba atual!
    List<Map<String, dynamic>> filtrados = _livrosDaAbaAtual;

    // --- B. Ordenação Automática (Mais recentes no topo) ---
    filtrados.sort((a, b) {
      String dataA = a['updated_at'] ?? a['created_at'] ?? '';
      String dataB = b['updated_at'] ?? b['created_at'] ?? '';
      return dataB.compareTo(dataA);
    });

    // --- C. Filtro de Tempo ---
    if (_filtroTempoSelecionado != 'recentes') {
      DateTime agora = DateTime.now();
      DateTime hoje = DateTime(agora.year, agora.month, agora.day);
      DateTime segundaFeira = hoje.subtract(Duration(days: agora.weekday - 1));

      filtrados = filtrados.where((livro) {
        String dataStr = livro['created_at'] ?? livro['updated_at'] ?? '';
        if (dataStr.isEmpty) {
          return _filtroTempoSelecionado == 'hoje';
        }

        DateTime dtRaw = DateTime.parse(dataStr);
        DateTime dt = DateTime(
          dtRaw.toLocal().year,
          dtRaw.toLocal().month,
          dtRaw.toLocal().day,
        );

        if (_filtroTempoSelecionado == 'hoje') {
          return dt == hoje;
        } else if (_filtroTempoSelecionado == 'ontem') {
          DateTime ontem = hoje.subtract(const Duration(days: 1));
          return dt == ontem;
        } else if (_filtroTempoSelecionado == 'semana') {
          return !dt.isBefore(segundaFeira) && !dt.isAfter(hoje);
        } else if (_filtroTempoSelecionado == 'mes') {
          return dt.year == hoje.year && dt.month == hoje.month;
        } else if (_filtroTempoSelecionado == 'ano') {
          return dt.year == hoje.year;
        }
        return true;
      }).toList();
    }

    // --- D. Busca por Texto (Lupa) ---
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

    // Antes de renderizar, gera as opções disponíveis para a aba atual
    final opcoesTempo = _opcoesTempoDisponiveis;

    // Verificação de Segurança Oculta: Se a aba atual não suporta o filtro que estava selecionado antes,
    // nós ajustamos a variável silenciosamente para o build não dar erro de Dropdown nulo.
    if (!opcoesTempo.any((opcao) => opcao['id'] == _filtroTempoSelecionado)) {
      _filtroTempoSelecionado = 'recentes';
    }

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

                    // 👉 PASSO 3: Reseta a lupa e o filtro de tempo ao trocar de aba!
                    _termoBuscaLocal = '';
                    _filtroTempoSelecionado = 'recentes';
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
                filtroTempoAtual: _filtroTempoSelecionado,
                opcoesTempo:
                    opcoesTempo, // Passa as opções processadas para a aba atual
                onFiltroTempoChanged: (novoFiltro) {
                  setState(() {
                    _filtroTempoSelecionado = novoFiltro;
                  });
                },
              ),

              const SizedBox(height: 17),

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
                            ),
                      )
                    : BookList(
                        livros: _livrosExibidos,
                        onUpdateStatus: (id, acao, {valorEmprestimo}) =>
                            _atualizarStatusLivro(
                              id,
                              acao,
                              valorEmprestimo: valorEmprestimo,
                            ),
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
