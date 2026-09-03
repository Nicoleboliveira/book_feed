import 'package:flutter/material.dart';

import 'widgets/header_biblioteca.dart';
import 'widgets/estatisticas_card.dart';
import 'widgets/categorias_menu.dart';
import 'widgets/filters_menu.dart';
import 'widgets/book_grid.dart';
import 'widgets/custom_bottom_nav.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  // 2. Nossa variável de estado (começa na aba 3: biblioteca)
  int _abaAtual = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              children: const [
                HeaderBiblioteca(),
                SizedBox(height: 25),
                EstatisticasCard(),
                SizedBox(height: 25),
                CategoriasMenu(),
                SizedBox(height: 17),
                FiltersMenu(),
                SizedBox(height: 17),
                BookGrid(),
              ],
            ),
          ),
        ),
      ),

      // ==========================================
      //  O BOTÃO FLUTUANTE ROXO
      // ==========================================
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF8C79B7),
        shape: const CircleBorder(),
        elevation: 0, // Tira a sombra para manter o design flat/clean
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      // Diz para o botão se ancorar no centro da barra inferior
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ==========================================
      // 4. CHAMADA DO SEU NOVO COMPONENTE
      // ==========================================
      bottomNavigationBar: CustomBottomNav(
        abaSelecionada: _abaAtual, // Passamos a aba atual como "prop"
        aoClicarNaAba: (indice) {
          // O setState recarrega a tela com a nova aba clicada
          setState(() {
            _abaAtual = indice;
          });
        },
      ),
    );
  }
}
