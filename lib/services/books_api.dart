import 'dart:convert';

import 'package:http/http.dart' as http;

class BooksApi {
  // Agora retornamos uma Lista de Mapas (como se fosse um Array de Objetos no JS)
  static Future<List<Map<String, dynamic>>> buscarLivros() async {
    final url = Uri.parse(
      'https://openlibrary.org/search.json?author=colleen+hoover',
    );

    try {
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        List<Map<String, dynamic>> listaLivros = []; // Nosso array vazio

        // Um loop simples (for...of) para pegar todos os livros
        for (var livro in dados['docs']) {
          final coverId = livro['cover_i'];

          listaLivros.add({
            'titulo': livro['title'],
            // Monta a URL da imagem, se houver um coverId. Senão, usa uma imagem em branco.
            'capa': coverId != null
                ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
                : 'https://via.placeholder.com/150/E8E0F5/8C79B7?text=Sem+Capa',
          });
        }
        return listaLivros; // Retorna os dados prontos!
      }
    } catch (erro) {
      print('Erro: $erro');
    }
    return []; // Retorna vazio se der erro
  }
}
