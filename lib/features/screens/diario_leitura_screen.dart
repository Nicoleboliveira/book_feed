import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';

class DiarioLeituraScreen extends StatefulWidget {
  final Map<String, dynamic> livro;

  const DiarioLeituraScreen({super.key, required this.livro});

  @override
  State<DiarioLeituraScreen> createState() => _DiarioLeituraScreenState();
}

class _DiarioLeituraScreenState extends State<DiarioLeituraScreen> {
  // Cor padrão (aquele verde escuro do mockup) caso a capa não carregue
  Color _corFundo = const Color(0xFF38727A);

  // Variável para a avaliação (estrelinhas interativas)
  double _notaUsuario = 0;

  // Controle de expandir a sinopse
  bool _sinopseExpandida = false;

  @override
  void initState() {
    super.initState();
    // Se o livro já tiver uma nota sua no banco, ele carrega aqui
    if (widget.livro['nota'] != null) {
      _notaUsuario = (widget.livro['nota'] as num).toDouble();
    }
    _extrairCorDaCapa();
  }

  // 👉 A MÁGICA DA COR: Lê a imagem e acha a cor principal!
  Future<void> _extrairCorDaCapa() async {
    final String capaUrl =
        widget.livro['capa'] ?? widget.livro['capa_url'] ?? '';
    if (capaUrl.isNotEmpty) {
      try {
        final PaletteGenerator generator =
            await PaletteGenerator.fromImageProvider(NetworkImage(capaUrl));
        setState(() {
          // Pega a cor predominante. Se for muito clara ou falhar, mantém a padrão
          _corFundo = generator.dominantColor?.color ?? const Color(0xFF38727A);
        });
      } catch (e) {
        debugPrint('Erro ao extrair cor: $e');
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
      // DefaultTabController gerencia as abas automaticamente
      body: DefaultTabController(
        length: 5, // 5 abas
        child: NestedScrollView(
          // O Header (Fundo colorido, Capa, Título e Estrelas)
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _construirCabecalhoELivro(capaUrl, titulo, autor),
              ),
              // As abas que "grudam" no topo ao rolar a tela
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    tabs: const [
                      Tab(text: 'Sobre'),
                      Tab(text: 'Moodboard'),
                      Tab(text: 'Playlist'),
                      Tab(text: 'Review'),
                      Tab(text: 'Momentos'),
                    ],
                  ),
                ),
              ),
            ];
          },
          // O Conteúdo de cada Aba
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

  // ==========================================
  // COMPONENTES DA TELA
  // ==========================================

  Widget _construirCabecalhoELivro(
    String capaUrl,
    String titulo,
    String autor,
  ) {
    return Column(
      children: [
        // Fundo Colorido e Capa sobreposta
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Bloco de cor predominante
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 220,
              width: double.infinity,
              color: _corFundo,
            ),
            // Botão de Voltar (SafeArea garante que não fica embaixo do relógio do celular)
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
            // Capa do Livro (Começa no meio do fundo e cai para o branco)
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
        // Espaço para a capa que vazou do Stack
        const SizedBox(height: 85),

        // Título e Autor
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            titulo,
            style: GoogleFonts.inter(
              // Usando inter com bold para ficar parecido com o mockup
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

        // 👉 AVALIAÇÃO INTERATIVA (Estrelinhas clicáveis)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _notaUsuario = index + 1.0;
                });
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

  // ==========================================
  // CONTEÚDO DA ABA "SOBRE"
  // ==========================================
  Widget _construirAbaSobre() {
    final String sinopse =
        widget.livro['sinopse'] ??
        'Nenhuma sinopse disponível para este livro.';
    final List tags = widget.livro['tags'] ?? ['Romance', 'Ficção'];

    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
      children: [
        // --- SINOPSE ---
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
        if (sinopse.length >
            150) // Só mostra o botão se a sinopse for grandinha
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

        // --- TAGS (Semelhante ao que fizemos no BookList) ---
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

        // --- AVALIAÇÕES DA COMUNIDADE (Mockadas/Fake) ---
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

  // Design do cartão de review de outras pessoas
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

  // Telas vazias para as outras abas
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
    return Container(
      color: Colors.white, // Fundo branco quando a aba grudar no topo
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
