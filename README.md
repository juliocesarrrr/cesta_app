# Cesta — lista de compras

Aplicativo em Dart/Flutter para montar a lista de compras, marcar o que já foi
pego e enviar a lista pronta para outra pessoa.

## Requisitos do projeto atendidos

A lista do trabalho pede pelo menos um item. Este projeto entrega **dois**:

**1. Banco de dados local.** A lista é gravada no próprio aparelho com o pacote
`shared_preferences`, um armazenamento de chave e valor mantido pelo sistema
operacional. A lista inteira vira uma lista de textos JSON sob a chave
`itens_da_lista`, e é lida de volta quando o app abre. Fechar o app não perde
nada. Toda essa lógica fica em `lib/servicos/repositorio_lista.dart`.

**2. Compartilhamento.** O botão de compartilhar abre uma folha com a prévia do
texto e três destinos, como no protótipo: WhatsApp, e-mail e copiar. O ícone no
topo da folha abre o menu do sistema, que cobre qualquer outro aplicativo
instalado. As chamadas estão em `lib/telas/folha_compartilhar.dart`:

```dart
final resultado = await SharePlus.instance.share(
  ShareParams(text: widget.texto, subject: 'Compras da semana'),
);
```

Se o menu não estiver disponível (o que pode acontecer no navegador), o app cai
automaticamente para a área de transferência e avisa o usuário na tela.

O app **não usa internet**. Funciona em modo avião, o que elimina o risco de a
rede da faculdade derrubar a apresentação.

## Estrutura do código

```
lib/
├── main.dart                        Ponto de entrada e tema
├── tema.dart                        Cores e estilos reunidos em um lugar
├── modelos/item_compra.dart         O item e a lista de categorias
├── servicos/
│   ├── repositorio_lista.dart       Grava e lê a lista no aparelho
│   └── texto_lista.dart             Monta o texto do compartilhamento
├── telas/
│   ├── tela_lista.dart              Tela principal
│   ├── folha_novo_item.dart         Folha de cadastro que sobe de baixo
│   └── folha_compartilhar.dart      Prévia do texto, destinos e plano B
└── widgets/linha_item.dart          Uma linha da lista
test/texto_lista_test.dart           Testes automatizados
```

A separação segue uma regra: **a tela não sabe onde os dados moram**. Ela pede
"carregar" e "salvar" ao repositório. Se um dia a lista precisar ir para um
banco SQL ou para um servidor, só `repositorio_lista.dart` muda — nenhuma tela
é tocada. É o mesmo motivo de `texto_lista.dart` existir separado: o formato do
texto compartilhado pode mudar sem mexer na interface, e dá para testá-lo sem
abrir o aplicativo.

## Como rodar

```bash
cd cesta_app
flutter create --project-name cesta_app .
flutter pub get
flutter run -d chrome
```

O `flutter create` gera as pastas de plataforma (android, ios, web) sem apagar
o que está em `lib/`. Se reclamar que a pasta não está vazia, pode ignorar.

### Rodando no Chrome

O app foi preparado para funcionar no navegador:

- **O salvamento funciona normalmente.** Na web, o `shared_preferences` grava no
  armazenamento local do próprio navegador. Recarregue a página com F5 e os
  itens continuam lá — é essa a demonstração do requisito de banco local.
- **O compartilhamento tem plano B.** O botão abre uma folha com a prévia do
  texto e dois caminhos: "Enviar", que chama o menu de compartilhamento do
  navegador, e "Copiar", que joga a lista na área de transferência. Se o
  navegador não tiver o menu de compartilhamento disponível, o app detecta a
  falha, copia sozinho e avisa na tela. Assim o requisito sempre tem o que
  mostrar.

Duas observações técnicas que valem para a apresentação:

1. O envio é disparado direto pelo toque no botão, sem nenhuma operação
   assíncrona antes. Navegadores só liberam a API de compartilhamento quando
   ela parte de um gesto do usuário — adiar a chamada faria ela falhar.
2. Os dados ficam no navegador em que o app foi aberto. Se você limpar os dados
   do site ou usar uma janela anônima, a lista começa vazia.

### Testes

```bash
flutter test
```

Os testes conferem o texto gerado para compartilhamento e a conversão do item
para JSON e de volta.

## Telas e onde estão no código

| # | Tela | Onde está | O que acontece |
| --- | --- | --- | --- |
| 1 | Lista vazia | `tela_lista.dart` → `_ListaVazia` | Primeiro uso, antes de existir qualquer item |
| 2 | Lista | `tela_lista.dart` → `_corpoLista` | Itens agrupados por categoria, com progresso no topo |
| 3 | Adicionar item | `folha_novo_item.dart` | Nome, quantidade e categoria |
| 4 | Compra concluída | `tela_lista.dart` → `_cartaoConcluido` | Aparece quando tudo está marcado |
| 5 | Compartilhar | `_compartilhar()` | Menu do sistema operacional |
| 6 | Apagar item | `Dismissible` em `_corpoLista` | Arrastar para o lado, com opção de desfazer |

## Correspondência com o protótipo

O layout do código segue o protótipo feito no Figma: marca "CESTA" no topo,
progresso com contagem e porcentagem, categorias em maiúsculas, etiquetas de
categoria no cadastro, e os três destinos na folha de compartilhamento. As
cinco categorias são as mesmas nos dois.

## Pontos que valem citar na apresentação

- **Toda mudança passa por um único método** (`_aplicar`), que atualiza a tela e
  grava no aparelho na mesma linha. Isso evita o erro clássico de alterar a
  lista e esquecer de salvar.
- **O item é imutável.** Marcar como comprado não altera o objeto: cria uma
  cópia com `copiarCom(comprado: true)`. É o padrão que o Flutter espera e
  facilita comparar estados.
- **Apagar tem desfazer.** A remoção mostra um aviso com o botão "Desfazer", que
  devolve a lista anterior — um detalhe de acabamento que quase nenhum trabalho
  de faculdade tem.
- **Um registro corrompido não derruba a lista.** A leitura ignora o item
  inválido e continua carregando o resto.

## Versões dos pacotes

Conferidas na documentação oficial em setembro de 2026:

- `shared_preferences` 2.5.5 — usando a API `SharedPreferencesAsync`, que é a
  recomendada atualmente (a antiga `SharedPreferences.getInstance()` ainda
  funciona, mas está marcada como legada).
- `share_plus` 13.3.0 — usando `SharePlus.instance.share(ShareParams(...))`. O
  antigo `Share.share('texto')` que aparece na maioria dos tutoriais da internet
  está **obsoleto** nesta versão.
- `url_launcher` 6.3.2 — usando `launchUrl(Uri)`, que substituiu o antigo
  `launch(String)`. É o que abre o WhatsApp (por `wa.me`) e o aplicativo de
  e-mail (por `mailto:`).

Se o `flutter pub get` instalar uma versão diferente e alguma chamada acusar
erro, o caminho é abrir a página do pacote no pub.dev e conferir o exemplo do
README — foi exatamente assim que estas duas chamadas foram verificadas.
