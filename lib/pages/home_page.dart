import 'package:cripto_app/pages/carteira_page.dart';
import 'package:cripto_app/pages/configuracoes_page.dart';
import 'package:cripto_app/pages/favoritas_page.dart';
import 'package:cripto_app/pages/moedas_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controlar os índices das páginas que serão colocadas dentro do slider
  int paginaAtual = 0;

  // Controlar o slider 'pc'
  late PageController pc;

  // Inicializar o page controller
  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  // Função que atualiza o estado da página atual e chama setState, o que faz com que o Flutter reconstrua a UI com a nova página atualizada
  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        // As páginas pelas quais o usuário navega pelo slider fica dentro do controller
        controller: pc,
        // Propriedade do PageView que é executada cada vez que ele é alterado
        onPageChanged: setPaginaAtual,
        children: const [
          MoedasPage(),
          FavoritasPage(),
          CarteiraPage(),
          ConfiguracoesPage()
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            backgroundColor: Colors.lightBlue.withOpacity(0.1),
            indicatorColor: Colors.blue[100],
            labelTextStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        child: NavigationBar(
          selectedIndex: paginaAtual,
          onDestinationSelected: (pagina) {
            // animateToPage é um método que o controller 'pc' possui por padrão por ser um controller
            pc.animateToPage(
              // Página que o usuário está tentando acessar
              pagina,
              // Duração da animação
              duration: const Duration(milliseconds: 400),
              // Tipo de animação
              curve: Curves.ease,
            );
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.list_outlined, size: 30),
                selectedIcon: Icon(Icons.list, size: 30),
                label: 'Todas'),
            NavigationDestination(
                icon: Icon(Icons.star_outline, size: 30),
                selectedIcon: Icon(Icons.star, size: 30),
                label: 'Favoritas'),
            NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined, size: 30),
                selectedIcon: Icon(Icons.account_balance_wallet, size: 30),
                label: 'Carteira'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined, size: 30),
                selectedIcon: Icon(Icons.settings, size: 30),
                label: 'Conta'),
          ],
        ),
      ),
    );
  }
}
