import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuOpcoesLivro extends StatelessWidget {
  final Map<String, dynamic> livro;
  final void Function(String acao, {bool? valorEmprestimo}) onAction;

  const MenuOpcoesLivro({
    super.key,
    required this.livro,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmprestado = livro['emprestado'] ?? false;

    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF261C40)),
        // 👇 ESTILIZAÇÃO PREMIUM DO POPUP:
        color: Colors.white, // Fundo branco puro
        surfaceTintColor:
            Colors.white, // Tira aquele filtro cinza/roxo padrão do Android
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordas bem arredondadas
        ),
        elevation: 6, // Sombra suave
        onSelected: (acaoEscolhida) {
          if (acaoEscolhida == 'emprestar_devolver') {
            onAction('mudar_emprestimo', valorEmprestimo: !isEmprestado);
          } else {
            onAction(acaoEscolhida);
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            // Usamos uma função auxiliar lá embaixo para não repetir código visual
            _buildMenuItem(
              'lido',
              Icons.check_circle_outline,
              'Lido',
              const Color(0xFF8C79B7),
            ),
            _buildMenuItem(
              'lendo',
              Icons.menu_book,
              'Lendo',
              Colors.blueAccent,
            ),
            _buildMenuItem(
              'quero_ler',
              Icons.bookmark_outline,
              'Quero ler',
              Colors.orangeAccent,
            ),
            _buildMenuItem(
              'abandonado',
              Icons.block,
              'Abandonado',
              Colors.redAccent,
            ),

            const PopupMenuDivider(), // Linha divisória
            // Emprestar / Devolver
            PopupMenuItem(
              value: 'emprestar_devolver',
              child: Row(
                children: [
                  Icon(
                    isEmprestado
                        ? Icons.assignment_return
                        : Icons.handshake_outlined,
                    size: 18,
                    color: isEmprestado ? Colors.teal : const Color(0xFF6E6B78),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEmprestado ? 'Marcar Devolvido' : 'Emprestar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isEmprestado
                          ? Colors.teal
                          : const Color(0xFF261C40),
                    ),
                  ),
                ],
              ),
            ),

            const PopupMenuDivider(), // Outra linha divisória
            // Opção de Excluir
            _buildMenuItem(
              'excluir',
              Icons.delete_outline,
              'Excluir da biblioteca',
              Colors.red,
            ),
          ];
        },
      ),
    );
  }

  // 👇 Função auxiliar para desenhar os itens do menu com ícones padronizados
  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: (value == 'abandonado' || value == 'excluir')
                  ? color
                  : const Color(0xFF261C40),
            ),
          ),
        ],
      ),
    );
  }
}
