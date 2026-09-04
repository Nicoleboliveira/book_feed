import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderBiblioteca extends StatelessWidget {
  // A prop que vai receber a função de busca da tela principal
  final Function(String) onBuscar;

  const HeaderBiblioteca({super.key, required this.onBuscar});

  @override
  Widget build(BuildContext context) {
    // Um controlador para ler o que o usuário digita
    final TextEditingController controladorBusca = TextEditingController();

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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
                  // O MODAL FLUTUANTE DE BUSCA

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Buscar Livros',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF261C40),
                          ),
                        ),
                        content: TextField(
                          controller: controladorBusca, // Conecta o input ao controlador
                          decoration: InputDecoration(
                            hintText: 'Ex: Ali Hazelwood, Nome do livro...',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF8C79B7),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF5A458D),
                                width: 2,
                              ),
                            ),
                          ),
                          // Se apertar "Enter" no teclado do celular
                          onSubmitted: (valorDigitado) {
                            if (valorDigitado.isNotEmpty) {
                              Navigator.pop(context); // Fecha o balão flutuante
                              onBuscar(valorDigitado); // Dispara a busca!
                            }
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context), // Apenas fecha
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.inter(
                                color: Color(0xFF261C40),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8C79B7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (controladorBusca.text.isNotEmpty) {
                                Navigator.pop(
                                  context,
                                ); // Fecha o balão flutuante
                                onBuscar(
                                  controladorBusca.text,
                                ); // Dispara a busca!
                              }
                            },
                            child: Text(
                              'Pesquisar',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
