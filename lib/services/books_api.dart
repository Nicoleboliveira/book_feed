import 'dart:convert';

import 'package:http/http.dart' as http;

class BooksApi {
  static Future<List<Map<String, dynamic>>> buscarLivros(
    String termoDeBusca,
  ) async {
    // Cole a sua chave real aqui no seu arquivo:
    const apiKey = 'AIzaSyAQb48kddEBjELC8fHaNpDIs-mde9un74Q';

    final buscaFormatada = termoDeBusca.replaceAll(' ', '+');

    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=$buscaFormatada&printType=books&langRestrict=pt&orderBy=relevance&maxResults=40&key=$apiKey',
    );

    try {
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        List<Map<String, dynamic>> listaLivros = [];

        List<String> palavrasDigitadas = termoDeBusca.toLowerCase().split(' ');
        bool buscaAvancada = termoDeBusca.contains(':');

        if (dados['items'] != null) {
          for (var item in dados['items']) {
            final volumeInfo = item['volumeInfo'];
            final imageLinks = volumeInfo['imageLinks'];

            final titulo = (volumeInfo['title'] as String? ?? '').toLowerCase();

            // ==========================================
            // CORREÇÃO: Subimos a extração do autor para cá!
            // ==========================================
            String autor = 'Autor desconhecido';
            if (volumeInfo['authors'] != null &&
                (volumeInfo['authors'] as List).isNotEmpty) {
              autor = volumeInfo['authors'][0];
            }
            // Criamos a versão minúscula para usar na pesquisa
            final autorMinusculo = autor.toLowerCase();

            bool ehRelevante = buscaAvancada;

            if (!buscaAvancada) {
              for (String palavra in palavrasDigitadas) {
                // Agora o autorMinusculo existe e pode ser lido aqui!
                if (palavra.length > 2 &&
                    (titulo.contains(palavra) ||
                        autorMinusculo.contains(palavra))) {
                  ehRelevante = true;
                  break;
                }
              }
            }

            if (termoDeBusca.length <= 2) ehRelevante = true;

            // ==========================================
            // O Filtro Supremo
            // ==========================================
            if (ehRelevante &&
                imageLinks != null &&
                imageLinks['thumbnail'] != null &&
                !titulo.contains('box')) {
              String capaSegura = imageLinks['thumbnail'].replaceAll(
                'http:',
                'https:',
              );

              // Pegando a categoria (Sem tradução, em inglês original)
              List<String> tags = [];
              if (volumeInfo['categories'] != null &&
                  (volumeInfo['categories'] as List).isNotEmpty) {
                String categoriaCrua = volumeInfo['categories'][0];
                tags = categoriaCrua.split(' / ').take(2).toList();
              } else {
                tags = ['Geral'];
              }

              listaLivros.add({
                'titulo': volumeInfo['title'] ?? 'Sem Título',
                'capa': capaSegura,
                'autor': autor,
                'tags': tags,
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
