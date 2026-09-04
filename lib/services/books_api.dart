import 'dart:convert';

import 'package:http/http.dart' as http;

class BooksApi {
  static Future<List<Map<String, dynamic>>> buscarLivros(
    String termoDeBusca,
  ) async {
    // Cole a sua chave gerada dentro das aspas abaixo:
    const apiKey = 'AIzaSyAQb48kddEBjELC8fHaNpDIs-mde9un74Q';

    // 2. Troca os espaços por '+' (ex: 'harry potter' vira 'harry+potter')
    final buscaFormatada = termoDeBusca.replaceAll(' ', '+');

    // A nova URL já pede livros em português (langRestrict=pt)
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=$buscaFormatada&langRestrict=pt&orderBy=relevance&maxResults=40&key=$apiKey',
    );

    try {
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        List<Map<String, dynamic>> listaLivros = [];

        // Verifica se a API realmente encontrou os itens
        if (dados['items'] != null) {
          for (var item in dados['items']) {
            final volumeInfo = item['volumeInfo'];
            final imageLinks = volumeInfo['imageLinks'];

            final titulo = (volumeInfo['title'] as String? ?? '').toLowerCase();

            if (imageLinks != null &&
                imageLinks['thumbnail'] != null &&
                !titulo.contains('box')) {
              String capaSegura = imageLinks['thumbnail'].replaceAll(
                'http:',
                'https:',
              );

              listaLivros.add({
                'titulo': volumeInfo['title'] ?? 'Sem Título',
                'capa': capaSegura,
              });
            }
          }
        }
        return listaLivros;
      }
    } catch (erro) {
      print('Erro: $erro');
    }
    return [];
  }
}
