import 'package:book_feed/features/widgets/explorar/book_list_explorar.dart';
import 'package:book_feed/services/books_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  bool _isBuscando = false;
  bool _carregando = false;
  List<Map<String, dynamic>> _resultadosBusca = [];

  final TextEditingController _buscaController = TextEditingController();

  // A função que vai até o Google!
  Future<void> _fazerBuscaNaApi(String termo) async {
    setState(() {
      _isBuscando = true;
      _carregando = true;
    });

    // Chama a API do Google (precisa do import do BooksApi)
    final resultados = await BooksApi.buscarLivros(termo);

    setState(() {
      _resultadosBusca = resultados;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. CABEÇALHO (Título e Sino)
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explorar',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF261C40),
                    height: 1.3,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF261C40)),
                  onPressed: () {},
                ),
              ],
            ),
            Text(
              'Descubra novos mundos',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6E6B78),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // 2. BARRA DE BUSCA
            // ==========================================
            TextField(
              controller: _buscaController, // 👇 Liga o controlador ao campo
              textInputAction:
                  TextInputAction.search, // Mantém o teclado preparado
              onChanged: (termo) {
                // Se o campo ficar vazio (o usuário apagou tudo)
                if (termo.isEmpty) {
                  setState(() {
                    _isBuscando = false; // Desliga a tela de resultados
                    _resultadosBusca.clear(); // Limpa a lista antiga
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Pesquise por livro, autor ou gênero...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF261C40),
                  fontSize: 14,
                ),

                // 👇 A mágica acontece aqui: suffixIcon fica na direita!
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min, // Mantém a Row pequena
                  children: [
                    // Botão X: Só aparece se a tela estiver em modo de busca (e tiver texto)
                    if (_isBuscando || _buscaController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF6E6B78),
                          size: 20,
                        ),
                        onPressed: () {
                          _buscaController.clear(); // Limpa o texto
                          setState(() {
                            _isBuscando = false; // Volta pra tela inicial
                            _resultadosBusca.clear();
                          });
                          FocusScope.of(context).unfocus(); // Esconde teclado
                        },
                      ),
                    // O Botão da Lupa
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF261C40)),
                      onPressed: () {
                        final termo = _buscaController.text;
                        if (termo.isNotEmpty) {
                          _fazerBuscaNaApi(termo);
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  ],
                ),
                filled: true,
                fillColor: const Color(0xFFF0E5FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
              ),
              onSubmitted: (termo) {
                if (termo.isNotEmpty) {
                  _fazerBuscaNaApi(termo);
                }
              },
            ),
            const SizedBox(height: 24),

            // ==========================================
            // 3. O CORPO DA TELA (Resultados ou Banner)
            // ==========================================
            Expanded(
              child: _isBuscando
                  ? _buildResultadosDaBusca()
                  : _buildTelaInicialExplorar(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGETS AUXILIARES
  // ==========================================
  Widget _buildResultadosDaBusca() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8C79B7)),
      );
    }

    if (_resultadosBusca.isEmpty) {
      return Center(
        child: Text(
          "Nenhum livro encontrado.",
          style: GoogleFonts.inter(color: const Color(0xFF6E6B78)),
        ),
      );
    }

    return BookListExplorar(
      livros: _resultadosBusca,
      onAddBiblioteca: (livro, status) async {
        try {
          // 1. Prepara a conexão com o seu banco
          final supabase = Supabase.instance.client;

          // 2. Monta o pacote apenas com as colunas que o seu banco aceita
          final dadosParaSalvar = {
            'id': livro['id'],
            'titulo': livro['titulo'],
            'autor': livro['autor'],
            'capa': livro['capa'],
            'status': status, // 'lido' ou 'quero_ler' (veio do clique!)
            'favorito': false, // Por padrão, começa sem ser favorito
            // Se o seu banco tiver uma coluna para as tags ou notas, você pode adicionar aqui depois!
          };

          // 3. Envia para a tabela 'meus_livros'
          await supabase.from('meus_livros').insert(dadosParaSalvar);

          // 4. Mostra uma mensagem bonitinha de sucesso na tela
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${livro['titulo']} salvo na biblioteca!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                backgroundColor: const Color(0xFF8C79B7),
                behavior: SnackBarBehavior.floating, // Fica flutuando na tela
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        } catch (erro) {
          debugPrint("Erro ao salvar no Supabase: $erro");

          // Opcional: Mensagem de erro para você saber o que houve
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ops! Erro ao salvar o livro.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildTelaInicialExplorar() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Aquele banner da IA vai entrar aqui depois
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E5FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text("Banner de Recomendações (Em Breve)"),
            ),
          ),
        ],
      ),
    );
  }
}
