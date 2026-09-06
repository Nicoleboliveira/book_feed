import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyStateBiblioteca extends StatelessWidget {
  final VoidCallback onExplorar; // Função para quando clicar no botão

  const EmptyStateBiblioteca({super.key, required this.onExplorar});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. A sua imagem ilustrativa
          Image.asset(
            'assets/images/image-removebg-preview.png',
            height: 170,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),

          // 2. Título principal
          Text(
            'Nenhum livro encontrado',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF261C40),
            ),
          ),
          const SizedBox(height: 8),

          // 3. Subtítulo (com padding para não encostar nas bordas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Tente ajustar sua busca ou explore a nossa biblioteca para adicionar novas histórias.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(
                  0xFF6E6B78,
                ), // Aquele cinza elegante do seu layout
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Botão "Explorar" com formato de pílula
          ElevatedButton.icon(
            onPressed: onExplorar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFFF0E5FC,
              ), // Fundo roxo bem clarinho
              foregroundColor: const Color(
                0xFF8C79B7,
              ), // Cor do texto e do ícone
              elevation: 0, // Sem sombra para manter o design flat/moderno
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: Text(
              'Explorar Biblioteca',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
