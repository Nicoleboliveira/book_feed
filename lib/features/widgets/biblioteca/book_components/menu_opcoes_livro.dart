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
    // 👉 Descobre o status atual para desenhar o check (padrão é quero_ler)
    final String statusAtual = livro['status'] ?? 'quero_ler';

    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF261C40)),
        // 👇 SUA ESTILIZAÇÃO DO POPUP:
        color: const Color(0xFFF8F5F4),
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        onSelected: (acaoEscolhida) {
          if (acaoEscolhida == 'emprestar_devolver') {
            onAction('mudar_emprestimo', valorEmprestimo: !isEmprestado);
          } else {
            onAction(acaoEscolhida);
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            // Agora passamos o último parâmetro para comparar o statusAtual!
            _buildMenuItem(
              'lido',
              Icons.check_circle_outline,
              'Lido',
              const Color(0xFF8C79B7),
              statusAtual == 'lido',
            ),
            _buildMenuItem(
              'lendo',
              Icons.bookmark_outline,
              'Lendo',
              const Color(0xFF8C79B7),
              statusAtual == 'lendo',
            ),
            _buildMenuItem(
              'quero_ler',
              Icons.menu_book_outlined,
              'Quero ler',
              const Color(0xFF8C79B7),
              statusAtual == 'quero_ler',
            ),

            // Emprestar / Devolver
            PopupMenuItem(
              value: 'emprestar_devolver',
              child: Row(
                children: [
                  Icon(
                    isEmprestado
                        ? Icons.bookmark_added_outlined
                        : Icons.local_library_outlined,
                    size: 18,
                    color: const Color(0xFF8C79B7), // Simplifiquei pois os dois lados eram iguais no seu código
                  ),
                  const SizedBox(width: 12),
                  // Coloquei o Expanded aqui também para alinhar certinho
                  Expanded(
                    child: Text(
                      isEmprestado ? 'Devolvido' : 'Emprestar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF8C79B7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const PopupMenuDivider(color: Colors.grey),

            _buildMenuItem(
              'abandonado',
              Icons.bookmark_remove_outlined,
              'Abandonado',
              const Color(0xFF4A7A7E),
              statusAtual == 'abandonado',
            ),

            // Opção de Excluir (Nunca recebe check, então é false)
            _buildMenuItem(
              'excluir',
              Icons.delete_outlined,
              'Excluir da biblioteca',
              const Color(0xFF4A7A7E),
              false,
            ),
          ];
        },
      ),
    );
  }

  // 👇 Função auxiliar atualizada para desenhar o "vezinho"
  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color color,
    bool isSelected, // 👉 Novo parâmetro obrigatório
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          // O Expanded empurra o conteúdo seguinte (o ícone de check) para a direita
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                // Opcional: deixa a fonte um pouco mais grossa se estiver selecionado

                color:
                    (value == 'abandonado' ||
                        value == 'excluir' ||
                        value == 'lido' ||
                        value == 'lendo' ||
                        value == 'quero_ler')
                    ? color
                    : const Color(0xFF261C40),
              ),
            ),
          ),
          // 👉 A MÁGICA: O ícone de check só aparece se essa opção for a atual
          if (isSelected) Icon(Icons.check, size: 18, color: color),
        ],
      ),
    );
  }
}
