import 'dart:convert';

import 'package:book_feed/features/widgets/biblioteca/diario/aba_sobre.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 👉 IMPORTANTE: Ajuste o caminho abaixo conforme a pasta onde você salvou o aba_sobre.dart

class DiarioLeituraScreen extends StatefulWidget {
  final Map<String, dynamic> livro;

  const DiarioLeituraScreen({super.key, required this.livro});

  @override
  State<DiarioLeituraScreen> createState() => _DiarioLeituraScreenState();
}

class _DiarioLeituraScreenState extends State<DiarioLeituraScreen> {
  Color _corFundo = const Color(0xFF38727A);
  double _notaUsuario = 0;

  // Variáveis para a API do Google Books (Serão passadas para a AbaSobre)
  double? _mediaGoogle;
  int _totalAvaliacoesGoogle = 0;
  bool _carregandoGoogle = true;

  @override
  void initState() {
    super.initState();
    if (widget.livro['nota'] != null) {
      _notaUsuario = (widget.livro['nota'] as num).toDouble();
    }
    _extrairCorDaCapa();
    _buscarDadosGoogleBooks();
  }

  Future<void> _extrairCorDaCapa() async {
    final String capaUrl =
        widget.livro['capa'] ?? widget.livro['capa_url'] ?? '';
    if (capaUrl.isNotEmpty) {
      try {
        final PaletteGenerator generator =
            await PaletteGenerator.fromImageProvider(NetworkImage(capaUrl));
        setState(() {
          _corFundo = generator.dominantColor?.color ?? const Color(0xFF38727A);
        });
      } catch (e) {
        debugPrint('Erro ao extrair cor: $e');
      }
    }
  }

  // ==========================================
  // BUSCA DADOS DA GOOGLE BOOKS API
  // ==========================================
  Future<void> _buscarDadosGoogleBooks() async {
    final String titulo = widget.livro['titulo'] ?? '';
    final String autor = widget.livro['autor'] ?? '';

    if (titulo.isEmpty) {
      setState(() => _carregandoGoogle = false);
      return;
    }

    try {
      final query = Uri.encodeComponent('$titulo $autor');
      final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=1',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final volumeInfo = data['items'][0]['volumeInfo'];

          setState(() {
            _mediaGoogle = (volumeInfo['averageRating'] as num?)?.toDouble();
            _totalAvaliacoesGoogle = (volumeInfo['ratingsCount'] as int?) ?? 0;
            _carregandoGoogle = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Erro ao consultar Google Books API: $e');
    }

    if (mounted) {
      setState(() => _carregandoGoogle = false);
    }
  }

  Future<void> _salvarNotaNoBanco(double novaNota) async {
    try {
      final supabase = Supabase.instance.client;
      final String idLivro = widget.livro['id'].toString();

      await supabase
          .from('meus_livros')
          .update({'nota': novaNota})
          .eq('id', idLivro);
    } catch (e) {
      debugPrint('Erro ao salvar a nota: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String capaUrl =
        widget.livro['capa'] ?? widget.livro['capa_url'] ?? '';
    final String titulo = widget.livro['titulo'] ?? 'Título Desconhecido';
    final String autor = widget.livro['autor'] ?? 'Autor Desconhecido';

    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 5,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _construirCabecalhoELivro(capaUrl, titulo, autor),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: const Color(0xFF8C79B7),
                    labelColor: const Color(0xFF261C40),
                    unselectedLabelColor: const Color(0xFF9E95B5),
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    tabs: const [
                      Tab(text: 'sobre'),
                      Tab(text: 'moodboard'),
                      Tab(text: 'playlist'),
                      Tab(text: 'review'),
                      Tab(text: 'momentos'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // 👉 AQUI A MÁGICA ACONTECE! Chamamos a nossa classe separada.
              AbaSobre(
                livro: widget.livro,
                carregandoGoogle: _carregandoGoogle,
                mediaGoogle: _mediaGoogle,
                totalAvaliacoesGoogle: _totalAvaliacoesGoogle,
              ),

              _construirAbaEmBreve('Moodboard'),
              _construirAbaEmBreve('Playlist'),
              _construirAbaEmBreve('Review'),
              _construirAbaEmBreve('Momentos'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCabecalhoELivro(
    String capaUrl,
    String titulo,
    String autor,
  ) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 220,
              width: double.infinity,
              color: _corFundo,
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 80,
              child: Container(
                width: 140,
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: capaUrl.isNotEmpty
                      ? Image.network(capaUrl, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade300),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 85),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF261C40),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          autor,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6E6B78),
          ),
        ),
        const SizedBox(height: 16),

        // 👉 AVALIAÇÃO DO USUÁRIO (Estrelas Clicáveis)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                final double notaClicada = index + 1.0;
                final double novaNotaFinal = (_notaUsuario == notaClicada)
                    ? 0.0
                    : notaClicada;

                setState(() {
                  _notaUsuario = novaNotaFinal;
                });

                _salvarNotaNoBanco(novaNotaFinal);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  index < _notaUsuario ? Icons.star : Icons.star_border,
                  color: const Color(0xFF8C79B7),
                  size: 28,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _construirAbaEmBreve(String titulo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 16),
          Text(
            '$titulo\nEm breve',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
