import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/quotations?key=c509fc52";

void main() async {
  http.Response response = await http.get(request);
  print(json.decode(response.body)["results"]["currencies"]["USD"]);

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.amber),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _resetCampos();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _resetCampos();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _resetCampos();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  void _resetCampos() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetCampos,
            ),
          ],
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Errp ao Carregar Dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Divider(),
                          Icon(Icons.monetization_on,
                              color: Colors.amber, size: 150.0),
                          Divider(),
                          buildTextField("Valor em Reais", " R\$  ",
                              realController, _realChanged),
                          buildTextField("Valor em Dólars", "US\$ ",
                              dolarController, _dolarChanged),
                          buildTextField("Valor em Euros", "  €    ",
                              euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(width: 3.0, color: Colors.green)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[900]),
          border: OutlineInputBorder(
              borderSide: BorderSide(width: 100.0, color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          prefixText: prefix,
          prefixStyle: TextStyle(color: Colors.green, fontSize: 23.0)),
      style: TextStyle(color: Colors.green, fontSize: 25.0),
      onChanged: f,
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
