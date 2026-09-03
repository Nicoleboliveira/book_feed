import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FiltersMenu extends StatelessWidget {
  const FiltersMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ==========================================
        // LADO ESQUERDO: Botões Agrupados (Grade, Estante, Lista)
        // ==========================================
        Container(
          padding: const EdgeInsets.all(2), // Um respiro mínimo interno
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade200,
            ), // Borda cinza em volta de tudo
          ),
          child: Row(
            children: [
              _construirBotaoFiltro(
                Icons.grid_view,
                'Grade',
                isSelecionado: true,
              ),

              _construirBotaoFiltro(
                Icons.format_list_bulleted,
                'Lista',
                isSelecionado: false,
              ),
            ],
          ),
        ),

        // ==========================================
        // LADO DIREITO: "Mais recentes"
        // ==========================================
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
            ), // Borda cinza em volta de tudo
          ),
          child: Row(
            children: [
              const SizedBox(width: 6),
              Text(
                'Mais recentes',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5A458D),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF5A458D),
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // MINI-COMPONENTE: O Botão Individual
  // ==============================================================
  Widget _construirBotaoFiltro(
    IconData icone,
    String texto, {
    required bool isSelecionado,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // Se estiver selecionado, pinta o fundo de roxo claro. Se não, fica transparente.
        color: isSelecionado ? const Color(0xFFF0E5FC) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icone,
            size: 16,
            // Muda a cor do ícone dependendo se está selecionado ou não
            color: isSelecionado
                ? const Color(0xFF8C79B7)
                : const Color(0xFF6E6B78),
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelecionado ? FontWeight.w600 : FontWeight.w500,
              color: isSelecionado
                  ? const Color(0xFF8C79B7)
                  : const Color(0xFF6E6B78),
            ),
          ),
        ],
      ),
    );
  }
}
