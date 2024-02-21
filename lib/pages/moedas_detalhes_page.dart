import 'package:cripto_app/models/moeda.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoedasDetalhesPage extends StatefulWidget {
  final Moeda moeda;

  const MoedasDetalhesPage({super.key, required this.moeda});

  @override
  State<MoedasDetalhesPage> createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedasDetalhesPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt-BR', name: 'R\$');

  // Chave (identificador) do formulário para recuperar dados do campo de texto e fazer eventuais validações. GlobalKey do tipo FormState. Já inicializa uma chave aleatória pro formulário
  final _form = GlobalKey<FormState>();

  // Valor da moeda que o usuário quer comprar. O tipo TextEditingController permite controlar todo o campo de texto para aquele valor em específico
  final _valor = TextEditingController();

  double quantidade = 0;

  comprar() {
    if (_form.currentState!.validate()) {
      // Salvar a compra

      // Forma programática de voltar pra tela anterior
      Navigator.pop(context);

      // Toast de feedback
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra realizada com sucesso!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.moeda.nome),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      child: Image.asset(widget.moeda.icone),
                    ),
                    Container(width: 10),
                    Text(
                      real.format(widget.moeda.preco),
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                          color: Colors.grey[800]),
                    )
                  ],
                ),
              ),
              (quantidade > 0)
                  ? SizedBox(
                      //Tamanho da tela; acessando o MediaQuery do contexto que está sendo trabalhado (dentro da lista), dessa forma o sizedbox fica do tamanho correto da coluna
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.05),
                        ),
                        child: Text(
                          '$quantidade ${widget.moeda.sigla}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(bottom: 24),
                    ),
              Form(
                key: _form,
                child: TextFormField(
                    controller: _valor,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Valor',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                        suffix: Text(
                          'reais',
                          style: TextStyle(fontSize: 14),
                        )),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    //Irá receber a função pra cada vez que você digitar no teclado ou clicar no botão de enviar o form
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe o valor da compra';
                      } else if (double.parse(value) < 50) {
                        return 'A compra mínima é de R\$ 50,00';
                      }
                      return null;
                    },
                    // Executa uma função sempre que um valor for digitado
                    onChanged: (value) {
                      setState(() {
                        quantidade = (value.isEmpty)
                            ? 0
                            : double.parse(value) / widget.moeda.preco;
                        // Limitando para dois números após o ponto decimal
                        quantidade =
                            double.parse(quantidade.toStringAsFixed(2));
                      });
                    }),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent),
                    onPressed: comprar,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Comprar',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        )
                      ],
                    )),
              )
            ],
          ),
        ));
  }
}
