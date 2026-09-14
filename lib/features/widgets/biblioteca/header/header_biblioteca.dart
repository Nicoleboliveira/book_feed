import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderBiblioteca extends StatefulWidget {
  final Function(String) onBuscar;

  const HeaderBiblioteca({super.key, required this.onBuscar});

  @override
  State<HeaderBiblioteca> createState() => _HeaderBibliotecaState();
}

class _HeaderBibliotecaState extends State<HeaderBiblioteca> {
  // Lista inicial com limite sugerido
  final List<String> _buscasRecentes = [
    'rebecca yarros',
    'Ali Hazelwood',
    'A hipótese do amor',
    'Verity',
    'Colleen Hoover',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Biblioteca',
              style: GoogleFonts.dmSerifDisplay(
                textStyle: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF261C40),
                  height: 1.0,
                ),
              ),
            ),
            Text(
              'seus livros, do seu jeito.',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6E6B78),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0E5FC),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFF5A458D),
                  size: 28,
                ),
                onPressed: () {
                  _mostrarModalBusca(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _mostrarModalBusca(BuildContext context) {
    final TextEditingController controladorBusca = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            void executarBusca(String termo) {
              if (termo.trim().isNotEmpty) {
                String termoFormatado = termo.trim();

                setState(() {
                  // Remove se já existir para jogar ela lá para o topo
                  _buscasRecentes.remove(termoFormatado);

                  // Insere no começo da lista
                  _buscasRecentes.insert(0, termoFormatado);

                  // 👉 TRAVA DE LIMITE: Mantém no máximo 5 itens recentes
                  if (_buscasRecentes.length > 6) {
                    _buscasRecentes
                        .removeLast(); // Remove a mais antiga (última da lista)
                  }
                });

                Navigator.pop(context);
                widget.onBuscar(termoFormatado);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barrinha de cima
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCD6E7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    // Barra de Pesquisa + Botão de Lupa
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E5FC),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF5A458D),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: controladorBusca,
                                    autofocus: true,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF261C40),
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Pesquise por livro, autor ou gênero...',
                                      hintStyle: GoogleFonts.inter(
                                        color: const Color(0xFF9E95B5),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (val) {
                                      setStateModal(() {});
                                    },
                                    onSubmitted: (valor) {
                                      executarBusca(valor);
                                    },
                                  ),
                                ),
                                if (controladorBusca.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      controladorBusca.clear();
                                      setStateModal(() {});
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.close,
                                        color: Color(0xFF5A458D),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF8C79B7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {
                              executarBusca(controladorBusca.text);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Seção de Buscas Recentes
                    if (_buscasRecentes.isNotEmpty) ...[
                      Text(
                        'Buscas recentes',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF261C40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buscasRecentes.map((busca) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E5FC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controladorBusca.text = busca;
                                    executarBusca(busca);
                                  },
                                  child: Text(
                                    busca,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF5A458D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _buscasRecentes.remove(busca);
                                    });
                                    setStateModal(() {});
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Color(0xFF5A458D),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
