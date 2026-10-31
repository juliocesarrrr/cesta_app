import 'dart:convert';

/// Um item da lista de compras.
///
/// A classe sabe se converter para Map e voltar, que e o que permite
/// gravar a lista inteira no aparelho como texto JSON.
class ItemCompra {
  final String id;
  final String nome;
  final String quantidade;
  final String categoria;
  final bool comprado;

  const ItemCompra({
    required this.id,
    required this.nome,
    this.quantidade = '',
    this.categoria = 'Outros',
    this.comprado = false,
  });

  /// Gera um id simples a partir do relogio. Serve para diferenciar dois
  /// itens de mesmo nome sem precisar de pacote externo.
  factory ItemCompra.novo({
    required String nome,
    String quantidade = '',
    String categoria = 'Outros',
  }) {
    return ItemCompra(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nome: nome,
      quantidade: quantidade,
      categoria: categoria,
    );
  }

  /// Devolve uma copia com um ou outro campo trocado.
  /// Em Dart o objeto e imutavel, entao "marcar como comprado" na verdade
  /// cria um item novo com comprado: true.
  ItemCompra copiarCom({
    String? nome,
    String? quantidade,
    String? categoria,
    bool? comprado,
  }) {
    return ItemCompra(
      id: id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      categoria: categoria ?? this.categoria,
      comprado: comprado ?? this.comprado,
    );
  }

  Map<String, dynamic> paraMapa() => {
        'id': id,
        'nome': nome,
        'quantidade': quantidade,
        'categoria': categoria,
        'comprado': comprado,
      };

  factory ItemCompra.doMapa(Map<String, dynamic> m) => ItemCompra(
        id: m['id'] as String,
        nome: m['nome'] as String,
        quantidade: (m['quantidade'] as String?) ?? '',
        categoria: (m['categoria'] as String?) ?? 'Outros',
        comprado: (m['comprado'] as bool?) ?? false,
      );

  String paraJson() => json.encode(paraMapa());

  factory ItemCompra.doJson(String texto) =>
      ItemCompra.doMapa(json.decode(texto) as Map<String, dynamic>);
}

/// Categorias oferecidas na tela de cadastro, na ordem em que aparecem
/// na lista. A ordem daqui e a ordem dos grupos na tela, e as mesmas
/// cinco do prototipo.
const categoriasDisponiveis = <String>[
  'Hortifruti',
  'Padaria',
  'Limpeza',
  'Bebidas',
  'Outros',
];
