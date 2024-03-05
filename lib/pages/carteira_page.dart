import 'package:cripto_app/configs/app_settings.dart';
import 'package:cripto_app/models/posicao.dart';
import 'package:cripto_app/repositories/conta_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CarteiraPage extends StatefulWidget {
  const CarteiraPage({super.key});

  @override
  State<CarteiraPage> createState() => _CarteiraPageState();
}

class _CarteiraPageState extends State<CarteiraPage> {
  // index que vai servir para cada parte do gráfico, para ter um controle de qual porção o usuário estará vendo
  int index = 0;

  // possui o somatório de todo o valor que o usuário possui dentro da carteira
  double totalCarteira = 0;

  // saldo que o usuário tem na carteira, lido do conta repository
  double saldo = 0;

  // para alterar a formatação entre reais ou dólar
  late NumberFormat real;

  // variável para recuperar dados da conta
  late ContaRepository conta;

  String graficoLabel = '';

  double graficoValor = 0;

  List<Posicao> carteira = [];

  @override
  Widget build(BuildContext context) {
    // inicialização da conta
    conta = context.watch<ContaRepository>();

    // recuperação do app settings pra recuperar o locale e ter um format para o real ou dólar
    final loc = context.read<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);

    saldo = conta.saldo;

    setTotalCarteira();

    return Scaffold(
      // como a tela irá mostrar todas as transações, esse widget permite o scroll de toda a tela
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 48, bottom: 8),
              child: Text(
                'Valor da carteira',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text(
              real.format(totalCarteira),
              style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5),
            ),
            loadGrafico(),
            loadHistorico(),
          ],
        ),
      ),
    );
  }

  setTotalCarteira() {
    final carteiraList = conta.carteira;
    setState(() {
      totalCarteira = conta.saldo;
      for (var posicao in carteiraList) {
        totalCarteira += posicao.moeda.preco * posicao.quantidade;
      }
    });
  }

  setGraficoDados(int index) {
    if (index < 0) return;

    if (index == carteira.length) {
      graficoLabel = 'Saldo';
      graficoValor = conta.saldo;
    } else {
      graficoLabel = carteira[index].moeda.nome;
      graficoValor = carteira[index].moeda.preco * carteira[index].quantidade;
    }
  }

  loadCarteira() {
    setGraficoDados(index);
    carteira = conta.carteira;
    final tamanhoLista = carteira.length + 1;

    return List.generate(tamanhoLista, (i) {
      final isTouched = i == index;
      final isSaldo = i == tamanhoLista - 1;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = isTouched ? Colors.tealAccent : Colors.tealAccent[400];

      double porcentagem = 0;
      if (!isSaldo) {
        porcentagem =
            carteira[i].moeda.preco * carteira[i].quantidade / totalCarteira;
      } else {
        porcentagem = (conta.saldo > 0) ? conta.saldo / totalCarteira : 0;
      }
      porcentagem *= 100;

      return PieChartSectionData(
          color: color,
          value: porcentagem,
          title: '${porcentagem.toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87));
    });
  }

  loadGrafico() {
    return (conta.saldo <= 0)
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 120,
                    sections: loadCarteira(),
                    pieTouchData: PieTouchData(
                        // Ações para quando o usuário tocar em porções do gráfico
                        touchCallback: (FlTouchEvent touch,
                                PieTouchResponse? touchResponse) =>
                            setState(() {
                              if (touchResponse != null &&
                                  touchResponse.touchedSection != null) {
                                index = touchResponse
                                    .touchedSection!.touchedSectionIndex;
                                setGraficoDados(index);
                              }
                            })))),
              ),
              Column(
                children: [
                  Text(
                    graficoLabel,
                    style: const TextStyle(fontSize: 20, color: Colors.teal),
                  ),
                  Text(
                    real.format(graficoValor),
                    style: const TextStyle(fontSize: 28),
                  )
                ],
              )
            ],
          );
  }

  loadHistorico() {
    final historico = conta.historico;
    final date = DateFormat('dd/MM/yyyy - hh:mm');
    List<Widget> widgets = [];

    for (var operacao in historico) {
      widgets.add(ListTile(
        title: Text(operacao.moeda.nome),
        subtitle: Text(date.format(operacao.dataOperacao)),
        trailing:
            Text(real.format((operacao.moeda.preco * operacao.quantidade))),
      ));

      widgets.add(const Divider());
    }

    return Column(
      children: widgets,
    );
  }
}
