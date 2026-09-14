import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiarioLeituraScreen extends StatelessWidget {
  // A tela recebe os dados do livro quando for aberta
  final Map<String, dynamic> livro;

  const DiarioLeituraScreen({super.key, required this.livro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Setinha de voltar
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF261C40),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Diário de Leitura',
          style: GoogleFonts.dmSerifDisplay(
            color: const Color(0xFF261C40),
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostraremos a capa só para confirmar
            if (livro['capa_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  livro['capa_url'],
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              livro['titulo'] ?? 'Sem Título',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF261C40),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
