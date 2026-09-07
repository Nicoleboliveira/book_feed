import 'package:book_feed/features/widgets/biblioteca/book_components/menu_opcoes_livro.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'icon_status_livro.dart';

class BookGrid extends StatelessWidget {
  final List<Map<String, dynamic>> livros;
  final void Function(String id, String acao, {bool? valorEmprestimo})
  onUpdateStatus;

  const BookGrid({
    super.key,
    required this.livros,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: livros.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final livroAtual = livros[index];
        return _construirLivroCard(livroAtual);
      },
    );
  }

  // ==============================================================
  // MINI-COMPONENTE: O Cartão individual do Livro
  // ==============================================================
  Widget _construirLivroCard(Map<String, dynamic> livro) {
    // Puxa a nota real e formata (Ex: 4.8)
    final double avaliacao = (livro['nota'] ?? 0).toDouble();
    final String id = livro['id'].toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- A CAPA DO LIVRO ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(livro['capa'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BotaoStatusLivro(livro: livro, isEstatico: true),
                  ),
                ],
              ),
            ),
          ),

          // --- O RODAPÉ (Estrela e os 3 pontinhos) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Estrela e Nota Real
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFF8C79B7)),
                    const SizedBox(width: 4),
                    Text(
                      avaliacao
                          .toStringAsFixed(1)
                          .replaceAll(
                            '.',
                            ',',
                          ), // Troca ponto por vírgula no visual
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6E6B78),
                      ),
                    ),
                  ],
                ),

                // 👉 A MÁGICA AQUI: O Menu dos 3 Pontinhos
                MenuOpcoesLivro(
                  livro: livro, // No grid a variável se chama livroAtual, passe ela.
                  onAction: (acao, {valorEmprestimo}) {
                    onUpdateStatus(id, acao, valorEmprestimo: valorEmprestimo);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
