import 'package:flutter/material.dart';

import 'package:http/http.dart' as http; // vai permitir que façamos as requisições
import 'dart:async'; // fazer requisições e não ficar esperando
import 'dart:convert'; // converter em json

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=2fb65a79";

void main() async {
  // print(await getData()); // para eu ver o que a minha função está retornando

  runApp(MaterialApp(
      home: const MyApp(),
      theme: ThemeData( // estamos definindo uma cor padrão para o app inteiro, e essas cores serão usadas em alguns lugares especificos
        hintColor: Colors.amber,
        primaryColor: Colors.white
      ),
    )
  );
}

Future<Map> getData() async {
  // vai me retornar o futuro de um mapa
  http.Response response = await http.get(Uri.parse(request)); // o que vamos receber da url
  return json.decode(response.body);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void _realChanged(String text){
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "\$ Conversor \$",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.amber,
      ),

      body: FutureBuilder<Map>(
        future: getData(), // queremos o futuro do getData
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none: // estiver conectado
            case ConnectionState.waiting: // esperando conexão
              return const Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0
                  ),
                  textAlign: TextAlign.center, // vai ficar alinhado na orizontal
                ),
              );
            default:
              if(snapshot.hasError){
                return const Center(
                  child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0
                    ),
                    textAlign: TextAlign.center, // vai ficar alinhado na orizontal
                  ),
                );
              } else {
                dolar = snapshot.data?["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),

                      buildTextField("Reais", "R\$", realController, _realChanged),

                      const Divider(),

                      buildTextField("Dólares", "\$", dolarController, _dolarChanged),

                      const Divider(),

                      buildTextField("Euros", "€", euroController, _euroChanged),
                      
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function(String) funcao){
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),

      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(  
        borderSide: BorderSide(color: Colors.white)
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber)
      ),

      // prefixStyle: const TextStyle(color: Colors.amber),
      prefixText: prefix,
    ),
    
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),

    onChanged: funcao, // vai chamar a função
    keyboardType: TextInputType.number,
  );
}
