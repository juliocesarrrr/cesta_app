import '../modelos/item_compra.dart';

/// Monta o texto que sai do app quando o usuario compartilha a lista.
///
/// Fica separado da tela por dois motivos: o formato do texto pode mudar
/// sem mexer na interface, e assim da para testar o resultado sem abrir
/// o aplicativo (ver test/texto_lista_test.dart).
class TextoLista {
  static String montar(List<ItemCompra> itens, {String titulo = 'Cesta - Compras da semana'}) {
    if (itens.isEmpty) {
      return '$titulo\n\nA lista esta vazia.';
    }

    final linhas = <String>[titulo, ''];

    // Agrupa por categoria, respeitando a ordem de categoriasDisponiveis.
    for (final categoria in categoriasDisponiveis) {
      final doGrupo = itens.where((i) => i.categoria == categoria).toList();
      if (doGrupo.isEmpty) continue;

      linhas.add(categoria);
      for (final item in doGrupo) {
        final marca = item.comprado ? '[x]' : '[ ]';
        final quantidade = item.quantidade.isEmpty ? '' : ' — ${item.quantidade}';
        linhas.add('$marca ${item.nome}$quantidade');
      }
      linhas.add('');
    }

    final comprados = itens.where((i) => i.comprado).length;
    linhas.add('$comprados de ${itens.length} itens ja no carrinho.');

    return linhas.join('\n');
  }
}
