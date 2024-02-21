import 'package:cripto_app/models/moeda.dart';
import 'package:cripto_app/pages/moedas_detalhes_page.dart';
import 'package:cripto_app/repositories/favoritas_repository.dart';
import 'package:cripto_app/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoedasPage extends StatefulWidget {
  const MoedasPage({super.key});

  @override
  State<MoedasPage> createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  final tabela = MoedaRepository.tabela;

  NumberFormat real = NumberFormat.currency(locale: 'pt-BR', name: 'R\$');

  List<Moeda> selecionadas = [];

  // Variável para acessar o repositório de favoritas
  late FavoritasRepository favoritas;

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Center(
          child: Text(
            'Cripto Moedas',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // setState informa ao Flutter que ele deve chamar o método build novamente, ou seja, redesenhar a tela
              setState(() {
                selecionadas = [];
              });
            }),
        title: Text(
          '${selecionadas.length} selecionadas',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      );
    }
  }

  mostrarDetalhes(Moeda moeda) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => MoedasDetalhesPage(moeda: moeda)));
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Formas de recuperar os dados do rep de favoritas:

    // Acessando o Provider especificando o tipo de Provider; acessando favoritas.list, se tem acesso a todos os métodos e dados disponíveis
    //favoritas = Provider.of<FavoritasRepository>(context);

    // Acessando o Provider por meio do context do build; o método watch espera por mudanças; também há o read, caso seja preciso somente ler dados do Provider, mas sem a necessidade de responsividade na tela
    favoritas = context.watch<FavoritasRepository>();

    return Scaffold(
      appBar: appBarDinamica(),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int moeda) {
            return ListTile(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              leading: (selecionadas.contains(tabela[moeda]))
                  ? const CircleAvatar(
                      child: Icon(Icons.check),
                    )
                  : SizedBox(
                      width: 40,
                      child: Image.asset(tabela[moeda].icone),
                    ),
              title: Row(
                children: [
                  Text(
                    tabela[moeda].nome,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (favoritas.lista.contains(tabela[moeda]))
                    const Icon(Icons.star, color: Colors.amber, size: 14)
                ],
              ),
              trailing: Text(
                real.format(tabela[moeda].preco),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              selected: selecionadas.contains(tabela[moeda]),
              selectedTileColor: const Color.fromARGB(255, 168, 200, 255),
              onLongPress: () {
                setState(() {
                  (selecionadas.contains(tabela[moeda]))
                      ? selecionadas.remove(tabela[moeda])
                      : selecionadas.add(tabela[moeda]);
                  debugPrint(tabela[moeda].nome);
                });
              },
              onTap: () => mostrarDetalhes(tabela[moeda]),
            );
          },
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: tabela.length),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // Não é necessário usar o SetState pois dentro do repositório, o método já possui o notifyListeners
                favoritas.saveAll(selecionadas);
                limparSelecionadas();
              },
              icon: const Icon(Icons.star),
              label: const Text(
                'Favoritar',
                style: TextStyle(letterSpacing: 0, fontWeight: FontWeight.bold),
              ))
          : null,
    );
  }
}
