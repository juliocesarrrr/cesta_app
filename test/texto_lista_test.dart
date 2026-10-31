import 'package:flutter_test/flutter_test.dart';
import 'package:cesta_app/modelos/item_compra.dart';
import 'package:cesta_app/servicos/texto_lista.dart';

/// Testes do texto que o app compartilha.
///
/// Rode com: flutter test
void main() {
  group('TextoLista.montar', () {
    test('avisa quando a lista esta vazia', () {
      final texto = TextoLista.montar(<ItemCompra>[]);
      expect(texto, contains('A lista esta vazia'));
    });

    test('agrupa por categoria e marca o que ja foi comprado', () {
      final itens = <ItemCompra>[
        const ItemCompra(
            id: '1', nome: 'Tomate', quantidade: '1 kg', categoria: 'Hortifruti'),
        const ItemCompra(
            id: '2', nome: 'Pao', quantidade: '10 unid.', categoria: 'Padaria',
            comprado: true),
      ];

      final texto = TextoLista.montar(itens);

      expect(texto, contains('Hortifruti'));
      expect(texto, contains('[ ] Tomate — 1 kg'));
      expect(texto, contains('[x] Pao — 10 unid.'));
      expect(texto, contains('1 de 2 itens ja no carrinho.'));
    });

    test('omite o travessao quando nao ha quantidade', () {
      final itens = <ItemCompra>[
        const ItemCompra(id: '1', nome: 'Alface', categoria: 'Hortifruti'),
      ];
      expect(TextoLista.montar(itens), contains('[ ] Alface\n'));
    });
  });

  group('ItemCompra', () {
    test('sobrevive a ida e volta do JSON', () {
      final original = ItemCompra.novo(
          nome: 'Cafe', quantidade: '500 g', categoria: 'Mercearia');
      final voltou = ItemCompra.doJson(original.paraJson());

      expect(voltou.id, original.id);
      expect(voltou.nome, 'Cafe');
      expect(voltou.quantidade, '500 g');
      expect(voltou.categoria, 'Mercearia');
      expect(voltou.comprado, isFalse);
    });

    test('copiarCom troca so o campo pedido', () {
      final item = ItemCompra.novo(nome: 'Cafe');
      final marcado = item.copiarCom(comprado: true);

      expect(marcado.comprado, isTrue);
      expect(marcado.nome, 'Cafe');
      expect(marcado.id, item.id);
    });
  });
}
