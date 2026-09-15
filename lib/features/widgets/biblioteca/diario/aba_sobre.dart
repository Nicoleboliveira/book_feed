import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbaSobre extends StatefulWidget {
  final Map<String, dynamic> livro;

  // Recebe as variáveis da API do Google Books passadas pela tela principal
  final bool carregandoGoogle;
  final double? mediaGoogle;
  final int totalAvaliacoesGoogle;

  const AbaSobre({
    super.key,
    required this.livro,
    required this.carregandoGoogle,
    required this.mediaGoogle,
    required this.totalAvaliacoesGoogle,
  });

  @override
  State<AbaSobre> createState() => _AbaSobreState();
}

class _AbaSobreState extends State<AbaSobre> {
  bool _sinopseExpandida = false;

  // 👉 Função para quebrar o texto corrido em parágrafos organizados
  String _formatarSinopse(String textoBruto) {
    return textoBruto
        .replaceAll('. ', '.\n\n')
        .replaceAll('? ', '?\n\n')
        .replaceAll('! ', '!\n\n');
  }

  @override
  Widget build(BuildContext context) {
    // 👉 Puxa a sinopse e tags do Supabase
    final String sinopseOriginal =
        widget.livro['sinopse'] ??
        'Nenhuma sinopse disponível para este livro.';

    final String sinopseFormatada = _formatarSinopse(sinopseOriginal);
    final List tags = widget.livro['tags'] ?? ['Romance', 'Ficção'];

    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
      children: [
        Text(
          'Sinopse',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF261C40),
          ),
        ),
        const SizedBox(height: 12),

        // 👉 Texto com parágrafos formatados e altura de linha elegante
        Text(
          sinopseFormatada,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6E6B78),
            height: 1.3, // Dá respiro entre as linhas
          ),
          maxLines: _sinopseExpandida
              ? null
              : 6, // Mais linhas visíveis inicialmente
          overflow: _sinopseExpandida
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
        ),

        if (sinopseOriginal.length > 150)
          GestureDetector(
            onTap: () => setState(() => _sinopseExpandida = !_sinopseExpandida),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _sinopseExpandida ? 'Ler menos' : 'Ver mais',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8C79B7),
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E5FC),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                tag.toString().toLowerCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5A458D),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // 👉 TÍTULO E AVALIAÇÕES DO GOOGLE NA MESMA LINHA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avaliações da comunidade',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF261C40),
              ),
            ),
            if (!widget.carregandoGoogle && widget.mediaGoogle != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFF8C79B7)),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.mediaGoogle!.toStringAsFixed(1)} (${widget.totalAvaliacoesGoogle})',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6E6B78),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        // AVALIAÇÕES MOCKADAS DA COMUNIDADE
        _construirReviewComunidade(
          'Mariana Silva',
          5,
          'Perfeito! A química deles é absurda, li em um dia só de tão viciante.',
          'https://i.pravatar.cc/150?img=1',
        ),
        const SizedBox(height: 16),

        _construirReviewComunidade(
          'Lucas Andrade',
          4,
          'Muito bom, a ambientação universitária é muito bem escrita. O final poderia ser menos corrido.',
          'https://i.pravatar.cc/150?img=11',
        ),
      ],
    );
  }

  // 👉 CARD DE REVIEW MANTIDO COM A FOTO E INFORMAÇÕES
  Widget _construirReviewComunidade(
    String nome,
    int estrelas,
    String comentario,
    String avatarUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nome,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF261C40),
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < estrelas ? Icons.star : Icons.star_border,
                    color: const Color(0xFF8C79B7),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comentario,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF6E6B78),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
