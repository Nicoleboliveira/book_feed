import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'botao_status_livro.dart';

class BookList extends StatelessWidget {
  final List<Map<String, dynamic>> livros;

  const BookList({super.key, required this.livros});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: livros.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFFEEEEEE), height: 25),
      itemBuilder: (context, index) {
        final livro = livros[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CAPA DO LIVRO ---
            Container(
              width: 75,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: NetworkImage(livro['capa']),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 2,
                    right: 2,
                    child: BotaoStatusLivro(livro: livro),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // --- INFORMAÇÕES CENTRAIS (Título, Autor, Tags) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    livro['titulo'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    livro['autor'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6E6B78),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Renderizando as tags
                  Wrap(
                    spacing: 8,
                    children: (livro['tags'] as List<dynamic>? ?? [])
                        .map<Widget>((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E5FC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5A458D),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
            ),

            // --- COLUNA DA DIREITA (Estrela) ---
            SizedBox(
              height: 110, // A mesma altura exata da capa do livro!
              child: Center(
                // O Center vai forçar a Row a ficar perfeitamente no meio dessa altura
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 16, color: Color(0xFF8C79B7)),
                    const SizedBox(width: 4),
                    Text(
                      '4,8', // Lembre-se de puxar a nota real da sua API aqui depois (ex: livro['nota'])!
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6E6B78),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
