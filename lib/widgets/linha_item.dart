import 'package:flutter/material.dart';

import '../modelos/item_compra.dart';
import '../tema.dart';

/// Uma linha da lista: circulo de marcacao, nome e quantidade.
class LinhaItem extends StatelessWidget {
  final ItemCompra item;
  final VoidCallback aoTocar;

  const LinhaItem({super.key, required this.item, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            _circulo(),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.nome,
                style: TextStyle(
                  fontSize: 15,
                  color: item.comprado ? Tema.apagado : Tema.tinta,
                  decoration: item.comprado ? TextDecoration.lineThrough : null,
                  decorationColor: Tema.apagado,
                ),
              ),
            ),
            if (item.quantidade.isNotEmpty)
              Text(
                item.quantidade,
                style: TextStyle(
                  fontSize: 12.5,
                  color: item.comprado ? Tema.apagado : Tema.fraco,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _circulo() {
    if (item.comprado) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(color: Tema.verdeClaro, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFC3CFCA), width: 1.6),
      ),
    );
  }
}
