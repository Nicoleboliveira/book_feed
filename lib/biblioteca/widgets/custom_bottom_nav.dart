import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatelessWidget {
  // "Props" (Parâmetros que o componente vai receber)
  final int abaSelecionada;
  final Function(int) aoClicarNaAba;

  const CustomBottomNav({
    super.key,
    required this.abaSelecionada,
    required this.aoClicarNaAba,
  });

  @override
  Widget build(BuildContext context) {
    // 2. ClipRRect: O nosso "border-radius" com "overflow: hidden"
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(25),
        bottom: Radius.circular(25),
      ), // Arredonda só o topo!
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        currentIndex: abaSelecionada,
        onTap: aoClicarNaAba,

        selectedItemColor: const Color(0xFF5A458D),
        unselectedItemColor: const Color(0xFF9E9BA7),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          // O item do meio fica vazio para dar o espaço exato do Botão Flutuante
          BottomNavigationBarItem(icon: Icon(null), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
