import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tema.dart';

/// Folha que mostra o texto antes de enviar, com os destinos do prototipo:
/// WhatsApp, e-mail e copiar.
///
/// Cada botao usa o caminho adequado ao destino. O WhatsApp e o e-mail abrem
/// o aplicativo por um endereco proprio; o copiar usa a area de
/// transferencia, que funciona em qualquer lugar e serve de plano B quando
/// os outros nao estao disponiveis.
class FolhaCompartilhar extends StatefulWidget {
  final String texto;

  const FolhaCompartilhar({super.key, required this.texto});

  @override
  State<FolhaCompartilhar> createState() => _FolhaCompartilharState();
}

class _FolhaCompartilharState extends State<FolhaCompartilhar> {
  String? _aviso;

  /// Chamado direto pelo toque do usuario, sem nenhum await antes.
  /// Navegadores so liberam abrir outro endereco quando a acao parte de um
  /// gesto, entao adiar essa chamada faria ela falhar na web.
  Future<void> _abrirWhatsApp() async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(widget.texto)}');
    await _abrir(uri, 'WhatsApp');
  }

  Future<void> _abrirEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'Compras da semana',
        'body': widget.texto,
      },
    );
    await _abrir(uri, 'aplicativo de e-mail');
  }

  Future<void> _abrir(Uri uri, String destino) async {
    try {
      final foi = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!foi) {
        await _copiar(motivo: 'Não foi possível abrir o $destino.');
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      await _copiar(motivo: 'Não foi possível abrir o $destino.');
    }
  }

  /// Menu do sistema, acionado pelo icone de compartilhar do cabecalho
  /// da folha. Cobre qualquer aplicativo instalado alem dos dois acima.
  Future<void> _menuDoSistema() async {
    try {
      final r = await SharePlus.instance.share(
        ShareParams(text: widget.texto, subject: 'Compras da semana'),
      );
      if (mounted && r.status == ShareResultStatus.success) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      await _copiar(motivo: 'Este navegador não abre o menu de compartilhar.');
    }
  }

  Future<void> _copiar({String? motivo}) async {
    await Clipboard.setData(ClipboardData(text: widget.texto));
    if (!mounted) return;
    setState(() {
      _aviso = motivo == null
          ? 'Lista copiada. É só colar onde quiser.'
          : '$motivo A lista foi copiada — é só colar.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              const Text('Compartilhar lista',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Tema.tinta)),
              const Spacer(),
              InkWell(
                onTap: _menuDoSistema,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.ios_share, size: 19, color: Tema.verde),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 230),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Tema.fundo,
              border: Border.all(color: Tema.linha),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SingleChildScrollView(
              child: Text(
                widget.texto,
                style: const TextStyle(fontSize: 12.5, color: Tema.tinta, height: 1.55),
              ),
            ),
          ),

          if (_aviso != null) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 17, color: Tema.verdeClaro),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_aviso!,
                      style: const TextStyle(fontSize: 12.5, color: Tema.verde, height: 1.4)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
          const Text('ENVIAR POR', style: Tema.campo),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _destino('WhatsApp', Icons.chat_bubble_outline,
                    Tema.whatsapp, _abrirWhatsApp),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _destino('E-mail', Icons.mail_outline, Tema.email, _abrirEmail),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => _copiar(),
              icon: const Icon(Icons.copy_rounded, size: 17),
              label: const Text('Copiar texto da lista'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Tema.fraco,
                side: const BorderSide(color: Tema.linha),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _destino(String nome, IconData icone, Color cor, VoidCallback aoTocar) {
    return SizedBox(
      height: 46,
      child: FilledButton.icon(
        onPressed: aoTocar,
        icon: Icon(icone, size: 17),
        label: Text(nome, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
