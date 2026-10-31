import 'package:flutter/material.dart';

import '../modelos/item_compra.dart';
import '../servicos/repositorio_lista.dart';
import '../servicos/texto_lista.dart';
import '../tema.dart';
import '../widgets/linha_item.dart';
import 'folha_compartilhar.dart';
import 'folha_novo_item.dart';

/// Tela unica do app: mostra a lista, recebe itens novos, marca o que ja
/// foi comprado e compartilha o resultado.
class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  final _repositorio = RepositorioLista();
  final _campoRapido = TextEditingController();

  List<ItemCompra> _itens = <ItemCompra>[];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _campoRapido.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final salvos = await _repositorio.carregar();
    if (!mounted) return;
    setState(() {
      _itens = salvos;
      _carregando = false;
    });
  }

  /// Toda mudanca passa por aqui: atualiza a tela e grava no aparelho.
  /// Centralizar isso evita o erro classico de mudar a lista e esquecer
  /// de salvar.
  Future<void> _aplicar(List<ItemCompra> novos) async {
    setState(() => _itens = novos);
    await _repositorio.salvar(novos);
  }

  Future<void> _adicionar(ItemCompra item) =>
      _aplicar(<ItemCompra>[..._itens, item]);

  Future<void> _alternar(ItemCompra item) {
    final novos = _itens
        .map((i) => i.id == item.id ? i.copiarCom(comprado: !i.comprado) : i)
        .toList();
    return _aplicar(novos);
  }

  Future<void> _remover(ItemCompra item) async {
    final anteriores = List<ItemCompra>.from(_itens);
    await _aplicar(_itens.where((i) => i.id != item.id).toList());

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.nome} apagado'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _aplicar(anteriores),
          ),
        ),
      );
  }

  Future<void> _limpar() async {
    await _aplicar(<ItemCompra>[]);
    await _repositorio.limpar();
  }

  /// Adiciona pelo campo da barra de baixo, sem abrir a folha.
  Future<void> _adicionarRapido() async {
    final nome = _campoRapido.text.trim();
    if (nome.isEmpty) return;
    _campoRapido.clear();
    await _adicionar(ItemCompra.novo(nome: nome));
  }

  Future<void> _abrirFolha() async {
    final novo = await showModalBottomSheet<ItemCompra>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FolhaNovoItem(),
    );
    if (novo != null) await _adicionar(novo);
  }

  /// Requisito de compartilhamento: abre a folha com a previa do texto.
  /// O envio acontece la dentro, no toque do usuario.
  Future<void> _compartilhar() async {
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione um item antes de compartilhar')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FolhaCompartilhar(texto: TextoLista.montar(_itens)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comprados = _itens.where((i) => i.comprado).length;
    final total = _itens.length;
    final tudoPronto = total > 0 && comprados == total;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(comprados, total),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : total == 0
                      ? const _ListaVazia()
                      : _corpoLista(tudoPronto, comprados, total),
            ),
            _barraInferior(),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(int comprados, int total) {
    final pct = total == 0 ? 0 : (comprados * 100 / total).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('CESTA', style: Tema.marca),
              const Spacer(),
              if (total > 0)
                InkWell(
                  onTap: _compartilhar,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.ios_share, size: 19, color: Tema.verde),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Compras da semana', style: Tema.titulo),
          if (total == 0) ...[
            const SizedBox(height: 6),
            const Text('Sua lista está vazia', style: Tema.rotulo),
          ] else ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Progresso da lista', style: Tema.rotulo),
                const Spacer(),
                Text('$comprados de $total ($pct%)', style: Tema.rotulo),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: comprados / total,
                minHeight: 6,
                backgroundColor: Tema.linha,
                valueColor: const AlwaysStoppedAnimation(Tema.verdeClaro),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Monta a lista agrupada por categoria, na ordem de categoriasDisponiveis.
  Widget _corpoLista(bool tudoPronto, int comprados, int total) {
    final blocos = <Widget>[];

    if (tudoPronto) blocos.add(_avisoConcluido(total));

    for (final categoria in categoriasDisponiveis) {
      final doGrupo = _itens.where((i) => i.categoria == categoria).toList();
      if (doGrupo.isEmpty) continue;

      blocos.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
        child: Text(categoria.toUpperCase(), style: Tema.grupo),
      ));

      for (final item in doGrupo) {
        blocos.add(Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Tema.vermelho,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => _remover(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                LinhaItem(item: item, aoTocar: () => _alternar(item)),
                const Divider(height: 1, color: Tema.linha),
              ],
            ),
          ),
        ));
      }
    }

    blocos.add(const SizedBox(height: 24));

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Tema.papel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(padding: EdgeInsets.zero, children: blocos),
    );
  }

  /// Faixa verde no topo da lista quando tudo foi comprado.
  Widget _avisoConcluido(int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: Tema.verdeSuave,
        border: Border.all(color: Tema.verdeBorda),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: Tema.verdeClaro, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compra concluída!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Tema.verde)),
                const SizedBox(height: 3),
                Text('Todos os $total itens foram comprados.',
                    style: const TextStyle(fontSize: 11.5, color: Tema.fraco)),
              ],
            ),
          ),
          TextButton(
            onPressed: _limpar,
            style: TextButton.styleFrom(
              backgroundColor: Tema.verde,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
            child: const Text('Limpar', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _barraInferior() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Tema.papel,
        border: Border(top: BorderSide(color: Tema.linha)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _campoRapido,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _adicionarRapido(),
              decoration: InputDecoration(
                hintText: 'Adicionar item...',
                hintStyle: const TextStyle(color: Tema.apagado, fontSize: 14),
                filled: true,
                fillColor: Tema.fundo,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Tema.linha),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _botao(Icons.ios_share, _compartilhar, fundo: Tema.fundo, cor: Tema.verde),
          const SizedBox(width: 8),
          _botao(Icons.add, _abrirFolha, fundo: Tema.verde, cor: Colors.white),
        ],
      ),
    );
  }

  Widget _botao(IconData icone, VoidCallback aoTocar,
      {required Color fundo, required Color cor}) {
    final clarinho = fundo == Tema.fundo;
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(12),
          border: clarinho ? Border.all(color: Tema.linha) : null,
        ),
        child: Icon(icone, color: cor, size: 20),
      ),
    );
  }
}

/// Tela de primeiro uso: diz o que fazer em vez de mostrar area vazia.
class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
        decoration: BoxDecoration(
          color: Tema.papel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Tema.linha),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Tema.verdeSuave,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.shopping_basket_outlined,
                  size: 26, color: Tema.verdeClaro),
            ),
            const SizedBox(height: 18),
            const Text('Sua lista começa aqui',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Tema.tinta)),
            const SizedBox(height: 9),
            const Text(
              'Os itens adicionados ficam salvos automaticamente '
              'para sua próxima ida ao mercado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Tema.fraco, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
