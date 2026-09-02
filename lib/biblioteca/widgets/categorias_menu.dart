import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriasMenu extends StatelessWidget {
  const CategoriasMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. A LINHA CINZA CONTÍNUA (Fundo)
        // Usamos Positioned para grudar ela exatamente na base (bottom: 0)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 1.5, // Deixei fina para dar destaque ao roxo
            color: Colors.grey.shade200,
          ),
        ),

        // 2. AS ABAS QUE ROLAM (Frente)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _construirAba('Todos', isSelecionada: true),
              const SizedBox(width: 14), //Gap
              _construirAba('Lidos', isSelecionada: false),
              const SizedBox(width: 14),
              _construirAba('Favoritos', isSelecionada: false),
              const SizedBox(width: 14),
              _construirAba('Lendo', isSelecionada: false),
              const SizedBox(width: 14),
              _construirAba('Quero ler', isSelecionada: false),
              const SizedBox(width: 14),
              _construirAba('Emprestado', isSelecionada: false),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // MINI-COMPONENTE: A estrutura individual de cada Aba
  // ==============================================================
  Widget _construirAba(String titulo, {required bool isSelecionada}) {
    return Container(
      // O padding inferior (bottom: 4) substitui o seu SizedBox(height: 4)
      padding: const EdgeInsets.only(bottom: 6.0, left: 12.0, right: 12.0),
      decoration: BoxDecoration(
        // Aqui criamos a linha sublinhada que se ajusta ao tamanho do texto!
        border: Border(
          bottom: BorderSide(
            color: isSelecionada ? const Color(0xFF8C79B7) : Colors.transparent,
            width: 2.0, // Espessura da linha
          ),
        ),
      ),

      child: Text(
        titulo,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isSelecionada ? FontWeight.w600 : FontWeight.w400,
          color: isSelecionada
              ? const Color(0xFF8C79B7)
              : const Color(0xFF6E6B78),
        ),
      ),
    );
  }
}
