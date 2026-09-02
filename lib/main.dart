import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'biblioteca/biblioteca_screen.dart';

void main() {
  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F5F4),
        primarySwatch: Colors.purple,

        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const BibliotecaScreen(),
    );
  }
}
