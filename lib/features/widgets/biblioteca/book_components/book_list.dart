import 'package:book_feed/features/widgets/biblioteca/book_components/menu_opcoes_livro.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'botao_status_livro.dart';

class BookList extends StatelessWidget {
  final List<Map<String, dynamic>> livros;
  final void Function(String id, String acao, {bool? valorEmprestimo})
  onUpdateStatus;

  const BookList({
    super.key,
    required this.livros,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: livros.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFFEEEEEE), height: 32),
      itemBuilder: (context, index) {
        final livro = livros[index];
        final String titulo = livro['titulo'] ?? 'Título desconhecido';
        final String autor = livro['autor'] ?? 'Autor desconhecido';
        final String? capaUrl = livro['capa'];
        final double avaliacao = (livro['nota'] ?? 0).toDouble();
        final String id = livro['id'].toString();

        final List tags = livro['tags'] ?? ['Geral'];
        final String tag = tags.isNotEmpty ? tags[0] : 'Geral';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. CAPA DO LIVRO
            // ==========================================
            Container(
              width: 70,
              height: 105,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // A Imagem da Capa
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: capaUrl != null && capaUrl.isNotEmpty
                        ? Image.network(
                            capaUrl,
                            width: 70,
                            height: 105,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 70,
                            height: 105,
                            color: const Color(0xFFF0E5FC),
                            child: const Icon(
                              Icons.book,
                              color: Color(0xFF8C79B7),
                            ),
                          ),
                  ),

                  // Apenas o botão de status da leitura (No canto superior direito)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Transform.scale(
                      scale: 0.8,
                      child: BotaoStatusLivro(livro: livro, isEstatico: true),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // ==========================================
            // 2. INFORMAÇÕES DO LIVRO E MENU
            // ==========================================
            Expanded(
              child: SizedBox(
                height: 105,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO + 3 PONTINHOS NA MESMA LINHA
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF261C40),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 👉 O MENU DE 3 PONTINHOS
                        MenuOpcoesLivro(
                          livro: livro, // No grid a variável se chama livroAtual, passe ela.
                          onAction: (acao, {valorEmprestimo}) {
                            onUpdateStatus(
                              id,
                              acao,
                              valorEmprestimo: valorEmprestimo,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // AUTOR
                    Text(
                      autor,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6E6B78),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // ==========================================
                    // RODAPÉ: TAG E NOTA
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E5FC),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8C79B7),
                            ),
                          ),
                        ),

                        // Nota Fixada
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFF8C79B7),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              avaliacao.toStringAsFixed(1).replaceAll('.', ','),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6E6B78),
                              ),
                            ),
                          ],
                        ),
                      ],
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
