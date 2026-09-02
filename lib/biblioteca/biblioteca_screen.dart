import 'package:flutter/material.dart';

import 'widgets/header_biblioteca.dart';
import 'widgets/estatisticas_card.dart';

class BibliotecaScreen extends StatelessWidget {
  const BibliotecaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                HeaderBiblioteca(),

                SizedBox(height: 25),

                EstatisticasCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
