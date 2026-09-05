import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'biblioteca/biblioteca_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://tpdlxrlkhjgjheqxtgvr.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwZGx4cmxraGpnamhlcXh0Z3ZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2NDE4OTYsImV4cCI6MjEwNDIxNzg5Nn0.6QL9AyFshOpmrYueYo50JF0kUo0YEvNJ-C4dFyHUX24',
  );
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
