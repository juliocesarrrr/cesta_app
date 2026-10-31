import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/item_compra.dart';

/// Guarda e le a lista de compras no proprio aparelho.
///
/// Usa shared_preferences, que e um armazenamento simples de chave e valor
/// mantido pelo sistema operacional. A lista inteira e gravada como uma
/// lista de textos JSON sob uma unica chave.
///
/// Esta classe e a unica que conhece o armazenamento: a tela apenas pede
/// "carregar" e "salvar" e nao sabe onde os dados moram. Se um dia a lista
/// precisar ir para um banco SQL ou para um servidor, so este arquivo muda.
class RepositorioLista {
  static const _chave = 'itens_da_lista';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  /// Le a lista gravada. Devolve lista vazia no primeiro uso.
  Future<List<ItemCompra>> carregar() async {
    final textos = await _prefs.getStringList(_chave);
    if (textos == null) return <ItemCompra>[];

    final itens = <ItemCompra>[];
    for (final texto in textos) {
      try {
        itens.add(ItemCompra.doJson(texto));
      } catch (_) {
        // Um registro corrompido nao pode derrubar a lista inteira:
        // o item invalido e ignorado e o resto continua carregando.
        continue;
      }
    }
    return itens;
  }

  /// Regrava a lista inteira. E chamado a cada mudanca, porque a lista
  /// de compras de uma familia tem dezenas de itens, nao milhares.
  Future<void> salvar(List<ItemCompra> itens) async {
    final textos = itens.map((i) => i.paraJson()).toList();
    await _prefs.setStringList(_chave, textos);
  }

  /// Apaga tudo o que foi gravado.
  Future<void> limpar() async => _prefs.remove(_chave);
}
