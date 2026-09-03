import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookGrid extends StatelessWidget {
  const BookGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // 1. Configurações essenciais para usar Grid dentro de um ScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      // 2. Quantos livros queremos renderizar (vamos simular 8)
      itemCount: 9,

      // 3. O 'CSS Grid' do Flutter
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 4 colunas, exatamente como no seu design
        childAspectRatio:
            0.55, // A proporção: eles são mais altos do que largos
        crossAxisSpacing: 12, // Espaço (gap) entre as colunas
        mainAxisSpacing: 16, // Espaço (gap) entre as linhas
      ),

      // 4. A função que constrói cada livro (nosso laço de repetição)
      itemBuilder: (context, index) {
        return _construirLivroCard();
      },
    );
  }

  // ==============================================================
  // MINI-COMPONENTE: O Cartão individual do Livro
  // ==============================================================
  Widget _construirLivroCard() {
    // 1. Envolvemos TUDO em um Container pai que será o "Cartão Branco"
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // O fundo branco que vai englobar tudo
        borderRadius: BorderRadius.circular(
          9,
        ), // Arredondamento do cartão inteiro
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ), // Sombra super suave e moderna
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      // A MÁGICA: Garante que a imagem não vaze pelas quinas arredondadas do cartão
      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- A CAPA DO LIVRO ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://m.media-amazon.com/images/I/71j0jmJKKIL._SL1500_.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFF8C79B7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.fromARGB(240, 248, 245, 244),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
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
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFF8C79B7)),
                    const SizedBox(width: 4),
                    Text(
                      '4,8',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6E6B78),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: Color(0xFF261C40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
