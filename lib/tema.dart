import 'package:flutter/material.dart';

/// Cores e estilos do app, reunidos em um lugar so.
/// Os valores seguem o prototipo feito no Figma.
class Tema {
  static const verde = Color(0xFF12574A);
  static const verdeClaro = Color(0xFF2E8B74);
  static const verdeSuave = Color(0xFFE7F1EE);
  static const verdeBorda = Color(0xFFCFE3DD);
  static const fundo = Color(0xFFF2F5F3);
  static const papel = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF14231F);
  static const fraco = Color(0xFF6B7B76);
  static const apagado = Color(0xFF9FAFA9);
  static const linha = Color(0xFFE2E8E5);
  static const vermelho = Color(0xFFB4453A);

  // Cores dos aplicativos de destino, usadas na folha de compartilhar.
  static const whatsapp = Color(0xFF25D366);
  static const email = Color(0xFF4A7DBF);

  static ThemeData montar() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: fundo,
      colorScheme: base.colorScheme.copyWith(
        primary: verde,
        secondary: verdeClaro,
        surface: papel,
      ),
      textTheme: base.textTheme.apply(bodyColor: tinta, displayColor: tinta),
    );
  }

  /// Marca do app, no topo de todas as telas.
  static const marca = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: verde,
    letterSpacing: 1.2,
  );

  static const titulo = TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: tinta);
  static const rotulo = TextStyle(fontSize: 12, color: fraco);

  /// Cabecalho de categoria: maiusculas pequenas, como no prototipo.
  static const grupo = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: fraco,
    letterSpacing: 1.1,
  );

  /// Rotulo acima dos campos da folha de cadastro.
  static const campo = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: fraco,
    letterSpacing: 1.0,
  );
}
