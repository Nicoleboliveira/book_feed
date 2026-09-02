import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EstatisticasCard extends StatelessWidget {
  const EstatisticasCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0E5FC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.import_contacts,
                  color: Color(0xFF5A458D),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minha Blibioteca',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '127',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF261C40),
                          ),
                        ),

                        const WidgetSpan(child: SizedBox(width: 8)), //Gap

                        TextSpan(
                          text: 'Livros',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8C79B7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16), //Gap
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              const SizedBox(width: 8), //Gap

              Column(
                children: [
                  Text(
                    '73',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                  Text(
                    'Lidos',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8), //Gap
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              const SizedBox(width: 8), //Gap
              Column(
                children: [
                  Text(
                    '18',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                  Text(
                    'Lendo',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8), //Gap
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              const SizedBox(width: 8), //Gap
              Column(
                children: [
                  Text(
                    '36',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                  Text(
                    'Quero ler',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF261C40),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
