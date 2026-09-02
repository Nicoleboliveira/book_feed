import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderBiblioteca extends StatelessWidget {
  const HeaderBiblioteca({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Biblioteca',
              style: GoogleFonts.dmSerifDisplay(
                textStyle: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF261C40),
                  height: 1.0,
                ),
              ),
            ),
            Text(
              'seus livros, do seu jeito.',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E6B78),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0E5FC),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFF5A458D),
                  size: 28,
                ),
                onPressed: () {
                  // Ação do botão de busca no futuro
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
