import 'package:book_feed/shared/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

import 'biblioteca_screen.dart'; // Importa sua biblioteca
import 'explorar_screen.dart'; // Importa a tela nova (Passo 1)

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceAtual = 3; // 3 é a aba da Biblioteca

  // 👉 MUDANÇA AQUI: Usamos 'get' para o Flutter permitir o uso do setState aqui dentro!
  List<Widget> get _telas => [
    const Center(child: Text('Início')),
    const ExplorarScreen(), // <--- Nossa tela do Passo 1 está aqui, no índice 1 (Lupa)
    const Center(child: Text('Adicionar')),
    BibliotecaScreen(
      onMudarParaExplorar: () {
        setState(() {
          _indiceAtual = 1; // 👉 Ajustado para o nome real da sua variável
        });
      },
    ), // <--- Sua biblioteca continua segura aqui no índice 3
    const Center(child: Text('Perfil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indiceAtual, children: _telas),

      // Trouxemos o botão roxo de '+' pra cá
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF8C79B7),
        shape: const CircleBorder(),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Trouxemos a barra de navegação pra cá
      bottomNavigationBar: CustomBottomNav(
        abaSelecionada: _indiceAtual,
        aoClicarNaAba: (indice) {
          setState(() {
            _indiceAtual = indice;
          });
        },
      ),
    );
  }
}
