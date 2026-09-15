import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class AbaMoodboard extends StatefulWidget {
  final Map<String, dynamic> livro;

  const AbaMoodboard({super.key, required this.livro});

  @override
  State<AbaMoodboard> createState() => _AbaMoodboardState();
}

class _AbaMoodboardState extends State<AbaMoodboard> {
  // Lista de imagens
  final List<String> _imagens = [];

  final ImagePicker _picker = ImagePicker();

  // Função para abrir a Galeria do celular
  Future<void> _adicionarDaGaleria() async {
    final XFile? imagemEscolhida = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagemEscolhida != null) {
      setState(() {
        _imagens.insert(0, imagemEscolhida.path);
      });
    }
  }

  // 👉 MODAL NO MESMO ESTILO DA PESQUISA (Com barra em cima, input de URL e botão de galeria)
  void _mostrarOpcoesDeEscolha() {
    final TextEditingController urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite ajustar ao teclado se necessário
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 👉 Barrinha puxador cinza em cima
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              'Adicionar imagem ao Moodboard',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF261C40),
              ),
            ),
            const SizedBox(height: 20),

            // 👉 Campo de texto para inserir a URL da imagem (estilo barra de pesquisa)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6FE),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFEADBFA), width: 1),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.link, color: Color(0xFF8C79B7), size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF261C40),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cole o link da imagem aqui...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF9E95B5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  // Botão de confirmar link dentro da barra
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF8C79B7),
                    ),
                    onPressed: () {
                      if (urlController.text.isNotEmpty) {
                        setState(() {
                          _imagens.insert(0, urlController.text);
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 👉 Opção para abrir a galeria do celular
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _adicionarDaGaleria();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEADBFA), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF8C79B7),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Escolher foto da galeria',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A458D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        children: [
          // 👉 BOTÃO COM BORDA PONTILHADA
          GestureDetector(
            onTap: _mostrarOpcoesDeEscolha,
            child: CustomPaint(
              painter: _DottedBorderPainter(
                color: const Color(0xFF8C79B7),
                strokeWidth: 2.5,
                radius: 12,
                dashWidth: 9,
                dashSpace: 2,
              ),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8C79B7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Adicionar foto',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8C79B7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 👉 ESTADO VAZIO OU GRADE DE FOTOS
          _imagens.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEADBFA),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.collections_outlined,
                        size: 48,
                        color: Color(0xFF8C79B7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ainda não há inspirações por aqui',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF261C40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reúna aqui todas as imagens que fazem este livro ganhar vida na sua imaginação.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6E6B78),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _imagens.length,
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final caminhoImagem = _imagens[index];
                    final bool eArquivoLocal = !caminhoImagem.startsWith(
                      'http',
                    );

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        child: eArquivoLocal
                            ? Image.file(File(caminhoImagem), fit: BoxFit.cover)
                            : Image.network(
                                caminhoImagem,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          color: const Color(0xFF8C79B7),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// =========================================================
// PAINTER AUXILIAR PARA CRIAR A BORDA PONTILHADA PERFEITA
// =========================================================
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rRect);

    for (final PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double len = dashWidth;
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + len),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
