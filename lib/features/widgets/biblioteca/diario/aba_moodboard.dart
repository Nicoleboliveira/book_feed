import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:io';

class AbaMoodboard extends StatefulWidget {
  final Map<String, dynamic> livro;

  const AbaMoodboard({super.key, required this.livro});

  @override
  State<AbaMoodboard> createState() => _AbaMoodboardState();
}

class _AbaMoodboardState extends State<AbaMoodboard> {
  // Lista que armazenará as URLs das imagens vindas do Supabase
  List<String> _imagens = [];
  bool _carregando = true;

  final ImagePicker _picker = ImagePicker();
  late final SupabaseClient _supabase;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    // Carrega as fotos assim que a tela abre
    _carregarFotosDoSupabase();
  }

  // ==============================================================================
  // 1. BUSCAR FOTOS: Carrega do banco de dados as URLs relacionadas a este livro
  // ==============================================================================
  Future<void> _carregarFotosDoSupabase() async {
    try {
      final livroId = widget.livro['id'].toString();

      // Buscamos filtrando pelo ID do livro (removida a ordenação por created_at para evitar erro caso a coluna não exista)
      final response = await _supabase
          .from('moodboard')
          .select('imagem_url')
          .eq('livro_id', livroId);

      if (mounted) {
        setState(() {
          _imagens = List<String>.from(
            response.map((item) => item['imagem_url']),
          );
          _carregando = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar moodboard: $e');
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  // ==============================================================================
  // 2. UPLOAD GALERIA: Envia imagem para o Storage e salva a URL no banco
  // ==============================================================================
  Future<void> _adicionarDaGaleria() async {
    try {
      final XFile? imagemEscolhida = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (imagemEscolhida == null) return;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF8C79B7)),
          ),
        );
      }

      final file = File(imagemEscolhida.path);
      final fileExt = imagemEscolhida.path.split('.').last;
      final livroId = widget.livro['id'].toString();
      final fileName =
          'livro_${livroId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final filePath = fileName;

      // A. FAZER UPLOAD PARA O BUCKET "moodboard_fotos"
      await _supabase.storage.from('moodboard_fotos').upload(filePath, file);

      // B. OBTER A URL PÚBLICA DO ARQUIVO
      final publicUrl = _supabase.storage
          .from('moodboard_fotos')
          .getPublicUrl(filePath);

      // C. SALVAR A URL NO BANCO DE DADOS (tabela moodboard)
      await _supabase.from('moodboard').insert({
        'livro_id': livroId,
        'imagem_url': publicUrl,
      });

      if (mounted) Navigator.of(context).pop();

      _carregarFotosDoSupabase();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      debugPrint('Erro no upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar imagem. Tente novamente.'),
          ),
        );
      }
    }
  }

  // ==============================================================================
  // 3. ADICIONAR POR LINK: Salva a URL digitada diretamente no banco
  // ==============================================================================
  Future<void> _salvarUrlNoBanco(String url) async {
    try {
      final livroId = widget.livro['id'].toString();

      await _supabase.from('moodboard').insert({
        'livro_id': livroId,
        'imagem_url': url,
      });

      _carregarFotosDoSupabase();
    } catch (e) {
      debugPrint('Erro ao salvar URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link inválido ou erro ao salvar.')),
        );
      }
    }
  }

  // ==============================================================================
  // MODAL DE ESCOLHA (Estilo Pesquisa)
  // ==============================================================================
  void _mostrarOpcoesDeEscolha() {
    final TextEditingController urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Adicionar imagem ao Moodboard',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF261C40),
              ),
            ),
            const SizedBox(height: 20),
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
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF8C79B7),
                    ),
                    onPressed: () {
                      if (urlController.text.isNotEmpty) {
                        Navigator.pop(context);
                        _salvarUrlNoBanco(urlController.text);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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

  // ==============================================================================
  // BUILD PRINCIPAL
  // ==============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8C79B7)),
            )
          : ListView(
              padding: const EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: 24,
              ),
              children: [
                // BOTÃO PONTILHADO
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

                // ESTADO VAZIO OU GRADE DE FOTOS
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
                              'Ainda não há inspirações',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF261C40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicione imagens para criar a atmosfera visual deste livro.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, index) {
                          final caminhoImagem = _imagens[index];

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                              ),
                              child: Image.network(
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
