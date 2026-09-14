import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👉 IMPORTANTE: Adicionado o import do Supabase!

class DiarioLeituraScreen extends StatefulWidget {
  final Map<String, dynamic> livro;

  const DiarioLeituraScreen({super.key, required this.livro});

  @override
  State<DiarioLeituraScreen> createState() => _DiarioLeituraScreenState();
}

class _DiarioLeituraScreenState extends State<DiarioLeituraScreen> {
  Color _corFundo = const Color(0xFF38727A);
  double _notaUsuario = 0;
  bool _sinopseExpandida = false;

  @override
  void initState() {
    super.initState();
    if (widget.livro['nota'] != null) {
      _notaUsuario = (widget.livro['nota'] as num).toDouble();
    }
    _extrairCorDaCapa();
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
  // 👉 NOVA FUNÇÃO: Salva a nota no Supabase
  // ==========================================
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar avaliação.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
              _construirAbaSobre(),
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
            color: const Color(0xFF6E6B78),
          ),
        ),
        const SizedBox(height: 16),

        // 👉 AVALIAÇÃO INTERATIVA ATUALIZADA
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                final double notaClicada = index + 1.0;

                // Se clicou na mesma nota que já estava, zera (0). Se não, assume a nova nota.
                final double novaNotaFinal = (_notaUsuario == notaClicada)
                    ? 0.0
                    : notaClicada;

                // Atualiza a tela instantaneamente (Optimistic UI)
                setState(() {
                  _notaUsuario = novaNotaFinal;
                });

                // Envia para o Supabase no fundo
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

  Widget _construirAbaSobre() {
    final String sinopse =
        widget.livro['sinopse'] ??
        'Nenhuma sinopse disponível para este livro.';
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
        Text(
          sinopse,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF6E6B78),
            height: 1.5,
          ),
          maxLines: _sinopseExpandida ? null : 4,
          overflow: _sinopseExpandida
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
        ),
        if (sinopse.length > 150)
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

        Text(
          'Avaliações da comunidade',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF261C40),
          ),
        ),
        const SizedBox(height: 16),
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

// ==========================================
// DELEGATE PARA GRUDAR AS ABAS NO TOPO
// ==========================================
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
