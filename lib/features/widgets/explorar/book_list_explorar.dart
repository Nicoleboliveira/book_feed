import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookListExplorar extends StatelessWidget {
  final List<Map<String, dynamic>> livros;

  // Essa função vai ser disparada quando clicarmos nos novos botões
  final Function(Map<String, dynamic> livro, String status) onAddBiblioteca;

  const BookListExplorar({
    super.key,
    required this.livros,
    required this.onAddBiblioteca,
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

        // Tentamos pegar as informações da API com segurança
        final String titulo = livro['titulo'] ?? 'Título desconhecido';
        final String autor = livro['autor'] ?? 'Autor desconhecido';
        final String? capaUrl = livro['capa'];

        // Pega a nota
        final double avaliacao = (livro['nota'] ?? 0).toDouble();

        // Pega as tags
        final List tags = livro['tags'] ?? ['Geral'];
        final String tag = tags.isNotEmpty ? tags[0] : 'Geral';

        return Row(
          // 👇 A MÁGICA DO ALINHAMENTO ESTÁ AQUI:
          // Se a coluna da direita for menor, ela se centraliza em relação à capa!
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==========================================
            // 1. CAPA DO LIVRO COM SOMBRA
            // ==========================================
            Container(
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
              child: ClipRRect(
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
                        child: const Icon(Icons.book, color: Color(0xFF8C79B7)),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // ==========================================
            // 2. INFORMAÇÕES DO LIVRO
            // ==========================================
            Expanded(
              // Usamos um height de 105 (mesmo da capa) para forçar que os textos
              // não empurrem a linha inteira, mantendo a simetria com a capa.
              child: SizedBox(
                height: 105,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Centraliza os textos verticalmente
                  children: [
                    Text(
                      titulo,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF261C40),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      autor,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6E6B78),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

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
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ==========================================
            // 3. COLUNA LATERAL INTELIGENTE
            // ==========================================
            Column(
              mainAxisSize: MainAxisSize
                  .min, // Força a coluna a ser só do tamanho dos filhos
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Botão: LIDO
                Container(
                  width: 95,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF261C40).withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    onTap: () => onAddBiblioteca(livro, 'lido'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF8C79B7),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lido',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8C79B7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Botão: QUERO LER
                Container(
                  width: 95,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF261C40).withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    onTap: () => onAddBiblioteca(livro, 'quero_ler'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bookmark_add_outlined,
                            color: Color(0xFF8C79B7),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Quero ler',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8C79B7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 👇 A CONDICIONAL DAS ESTRELAS
                // Só renderiza o espaço e a estrela se a avaliação for maior que 0!
                if (avaliacao > 0) ...[
                  const SizedBox(height: 8),
                  // Colocamos a estrela numa caixa com a mesma largura exata dos botões
                  SizedBox(
                    width: 95,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Centraliza perfeitamente dentro dos 95px
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFF8C79B7),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          avaliacao.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6E6B78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ], // Fecha o if
              ],
            ),
          ],
        );
      },
    );
  }
}
