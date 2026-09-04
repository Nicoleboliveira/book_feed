import 'package:flutter/material.dart';

import 'widgets/header_biblioteca.dart';
import 'widgets/estatisticas_card.dart';
import 'widgets/categorias_menu.dart';
import 'widgets/filters_menu.dart';
import 'widgets/book_grid.dart';
import 'widgets/custom_bottom_nav.dart';
import '../services/books_api.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  int _abaAtual = 3;

  List<Map<String, dynamic>> _meusLivros = [];
  bool _carregando = true; // Controla o Loading

  @override
  void initState() {
    super.initState();
    _carregarDadosDaApi();
  }

  Future<void> _carregarDadosDaApi() async {
    final livrosDaApi = await BooksApi.buscarLivros();

    setState(() {
      _meusLivros = livrosDaApi;
      _carregando = false;
    });
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
              const HeaderBiblioteca(),
              const SizedBox(height: 25),
              const EstatisticasCard(),
              const SizedBox(height: 25),
              const CategoriasMenu(),
              const SizedBox(height: 17),
              const FiltersMenu(),
              const SizedBox(height: 17),
              Expanded(
                child: _carregando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8C79B7),
                        ),
                      )
                    : BookGrid(livros: _meusLivros),
              ),

              const SizedBox(height: 17),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BooksApi.buscarLivros();
        },
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
