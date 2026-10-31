import 'package:flutter/material.dart';

import '../modelos/item_compra.dart';
import '../tema.dart';

/// Folha que sobe de baixo para cadastrar um item com quantidade e categoria.
///
/// Devolve o ItemCompra pronto por Navigator.pop, ou null se o usuario
/// fechar sem confirmar. Quem chama decide o que fazer com o resultado.
class FolhaNovoItem extends StatefulWidget {
  const FolhaNovoItem({super.key});

  @override
  State<FolhaNovoItem> createState() => _FolhaNovoItemState();
}

class _FolhaNovoItemState extends State<FolhaNovoItem> {
  final _nome = TextEditingController();
  final _quantidade = TextEditingController();
  String _categoria = categoriasDisponiveis.first;

  @override
  void dispose() {
    _nome.dispose();
    _quantidade.dispose();
    super.dispose();
  }

  void _confirmar() {
    final nome = _nome.text.trim();
    if (nome.isEmpty) return;
    Navigator.of(context).pop(
      ItemCompra.novo(
        nome: nome,
        quantidade: _quantidade.text.trim(),
        categoria: _categoria,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // O padding de baixo acompanha o teclado, para os campos nao ficarem
    // escondidos quando ele abre.
    final teclado = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Tema.papel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7E0DC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Novo item',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Tema.tinta)),
            const SizedBox(height: 22),

            const Text('NOME DO ITEM', style: Tema.campo),
            const SizedBox(height: 8),
            TextField(
              controller: _nome,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _confirmar(),
              decoration: _decoracao('Tomate'),
            ),
            const SizedBox(height: 18),

            const Text('QUANTIDADE', style: Tema.campo),
            const SizedBox(height: 8),
            TextField(
              controller: _quantidade,
              decoration: _decoracao('500g'),
            ),
            const SizedBox(height: 18),

            const Text('CATEGORIA', style: Tema.campo),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoriasDisponiveis.map(_chip).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _confirmar,
                style: FilledButton.styleFrom(
                  backgroundColor: Tema.verde,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Adicionar à lista',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Etiqueta de categoria: a escolhida fica verde escura, as outras claras.
  Widget _chip(String c) {
    final ativa = c == _categoria;
    return GestureDetector(
      onTap: () => setState(() => _categoria = c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: ativa ? Tema.verde : Tema.fundo,
          border: Border.all(color: ativa ? Tema.verde : Tema.linha),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          c,
          style: TextStyle(
            fontSize: 13,
            fontWeight: ativa ? FontWeight.w600 : FontWeight.w400,
            color: ativa ? Colors.white : Tema.fraco,
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracao(String exemplo) => InputDecoration(
        hintText: exemplo,
        hintStyle: const TextStyle(color: Tema.apagado, fontSize: 14.5),
        filled: true,
        fillColor: Tema.fundo,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Tema.linha),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Tema.linha),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Tema.verde, width: 1.5),
        ),
      );
}
