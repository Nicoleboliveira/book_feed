import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FiltersMenu extends StatelessWidget {
  final bool isGridView;
  final Function(bool) onViewChanged;
  final String filtroTempoAtual;
  final Function(String) onFiltroTempoChanged;
  final List<Map<String, String>> opcoesTempo;

  const FiltersMenu({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    required this.filtroTempoAtual,
    required this.onFiltroTempoChanged,
    required this.opcoesTempo,
  });

  IconData _getIconeParaFiltro(String id) {
    switch (id) {
      case 'recentes':
        return Icons.schedule_outlined;
      case 'hoje':
        return Icons.today_outlined;
      case 'ontem':
        return Icons.restore_outlined;
      case 'semana':
        return Icons.date_range_outlined;
      case 'mes':
        return Icons.calendar_month_outlined;
      case 'ano':
        return Icons.event_note_outlined;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ==========================================
        // LADO ESQUERDO: Botões Agrupados (Grade, Lista)
        // ==========================================
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _construirBotaoFiltro(
                Icons.grid_view,
                'Grade',
                isSelecionado: isGridView,
                onTap: () {
                  onViewChanged(true);
                },
              ),
              _construirBotaoFiltro(
                Icons.format_list_bulleted,
                'Lista',
                isSelecionado: !isGridView,
                onTap: () {
                  onViewChanged(false);
                },
              ),
            ],
          ),
        ),

        // ==========================================
        // LADO DIREITO: Filtro Dinâmico (Compacto e Protegido)
        // ==========================================
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                isExpanded: true, // Mantemos true para ele truncar textos grandes com "..." sem quebrar a tela
                value: filtroTempoAtual,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF5A458D),
                  size: 16,
                ),
                iconSize: 16,
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,

                selectedItemBuilder: (BuildContext context) {
                  return opcoesTempo.map<Widget>((opcao) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        opcao['label']!,
                        overflow: TextOverflow.ellipsis, // Coloca "..." se o texto for muito grande
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5A458D),
                        ),
                      ),
                    );
                  }).toList();
                },

                onChanged: (String? novoValor) {
                  if (novoValor != null) {
                    onFiltroTempoChanged(novoValor);
                  }
                },

                items: opcoesTempo.map<DropdownMenuItem<String>>((opcao) {
                  final isSelected = opcao['id'] == filtroTempoAtual;

                  return DropdownMenuItem<String>(
                    value: opcao['id'],
                    child: Row(
                      children: [
                        Icon(
                          _getIconeParaFiltro(opcao['id']!),
                          size: 16,
                          color: isSelected
                              ? const Color(0xFF5A458D)
                              : const Color(0xFF6E6B78),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            opcao['label']!,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF5A458D)
                                  : const Color(0xFF6E6B78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirBotaoFiltro(
    IconData icone,
    String texto, {
    required bool isSelecionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelecionado ? const Color(0xFFF0E5FC) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 16,
              color: isSelecionado
                  ? const Color(0xFF8C79B7)
                  : const Color(0xFF6E6B78),
            ),
            const SizedBox(width: 6),
            Text(
              texto,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelecionado ? FontWeight.w600 : FontWeight.w500,
                color: isSelecionado
                    ? const Color(0xFF8C79B7)
                    : const Color(0xFF6E6B78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
