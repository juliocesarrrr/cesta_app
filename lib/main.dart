import 'package:flutter/material.dart';

import 'tema.dart';
import 'telas/tela_lista.dart';

void main() {
  runApp(const CestaApp());
}

class CestaApp extends StatelessWidget {
  const CestaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cesta',
      debugShowCheckedModeBanner: false,
      theme: Tema.montar(),
      home: const TelaLista(),
    );
  }
}
