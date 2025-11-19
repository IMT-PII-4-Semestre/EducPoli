import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../services/arquivo_service.dart';

class DialogAdicionarMaterial extends StatefulWidget {
  final String materiaId;
  final String aulaId;
  final Color corPrincipal;

  const DialogAdicionarMaterial({
    super.key,
    required this.materiaId,
    required this.aulaId,
    required this.corPrincipal,
  });

  @override
  State<DialogAdicionarMaterial> createState() =>
      _DialogAdicionarMaterialState();
}

class _DialogAdicionarMaterialState extends State<DialogAdicionarMaterial> {
  final nomeController = TextEditingController();
  final urlController = TextEditingController();
  String tipoSelecionado = 'arquivo';
  PlatformFile? arquivoSelecionado;
  bool enviando = false;
  double progressoUpload = 0.0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_circle_outline, color: widget.corPrincipal),
          const SizedBox(width: 12),
          const Text('Adicionar Material'),
        ],
      ),
      content: SizedBox(
        width: isMobile ? double.maxFinite : 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do material
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Material',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 20),

              // Tipo de material
              const Text(
                'Tipo de Material',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'arquivo',
                    label: Text('Arquivo'),
                    icon: Icon(Icons.upload_file),
                  ),
                  ButtonSegment(
                    value: 'link',
                    label: Text('Link'),
                    icon: Icon(Icons.link),
                  ),
                  ButtonSegment(
                    value: 'pasta',
                    label: Text('Pasta'),
                    icon: Icon(Icons.folder),
                  ),
                ],
                selected: {tipoSelecionado},
                onSelectionChanged: (Set<String> selected) {
                  setState(() {
                    tipoSelecionado = selected.first;
                    arquivoSelecionado = null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Upload de arquivo
              if (tipoSelecionado == 'arquivo') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      if (arquivoSelecionado == null) ...[
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: enviando
                              ? null
                              : () async {
                                  final arquivo =
                                      await ArquivoService.selecionarArquivo();
                                  if (arquivo != null) {
                                    setState(() {
                                      arquivoSelecionado = arquivo;
                                      if (nomeController.text.isEmpty) {
                                        nomeController.text = arquivo.name;
                                      }
                                    });
                                  }
                                },
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Selecionar Arquivo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.corPrincipal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PDF, Word, Excel, PowerPoint, Imagens',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Text(
                              ArquivoService.obterIconePorExtensao(
                                  arquivoSelecionado!.name),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    arquivoSelecionado!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ArquivoService.formatarTamanho(
                                        arquivoSelecionado!.size),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: enviando
                                  ? null
                                  : () {
                                      setState(() {
                                        arquivoSelecionado = null;
                                      });
                                    },
                              icon: const Icon(Icons.close),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Campo de link
              if (tipoSelecionado == 'link')
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'URL do Link',
                    hintText: 'https://...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),

              // Pasta
              if (tipoSelecionado == 'pasta')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pastas servem apenas para organização visual',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Barra de progresso
              if (enviando) ...[
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progressoUpload,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.corPrincipal),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progressoUpload * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: enviando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: enviando ? null : _salvarMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.corPrincipal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: enviando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Adicionar'),
        ),
      ],
    );
  }

  Future<void> _salvarMaterial() async {
    // Validações
    if (nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o material')),
      );
      return;
    }

    if (tipoSelecionado == 'arquivo' && arquivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um arquivo')),
      );
      return;
    }

    if (tipoSelecionado == 'link' && urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite a URL do link')),
      );
      return;
    }

    setState(() => enviando = true);

    try {
      String? downloadUrl;

      // Upload do arquivo
      if (tipoSelecionado == 'arquivo' && arquivoSelecionado != null) {
        downloadUrl = await ArquivoService.uploadArquivo(
          arquivo: arquivoSelecionado!,
          materiaId: widget.materiaId,
          aulaId: widget.aulaId,
          onProgress: (progress) {
            setState(() => progressoUpload = progress);
          },
        );

        if (downloadUrl == null) {
          throw 'Erro ao fazer upload do arquivo';
        }
      } else if (tipoSelecionado == 'link') {
        downloadUrl = urlController.text.trim();
      }

      // Salvar no Firestore
      await FirebaseFirestore.instance
          .collection('materias')
          .doc(widget.materiaId)
          .collection('aulas')
          .doc(widget.aulaId)
          .collection('materiais')
          .add({
        'nome': nomeController.text.trim(),
        'tipo': tipoSelecionado,
        'url': downloadUrl,
        'nomeArquivo':
            tipoSelecionado == 'arquivo' ? arquivoSelecionado!.name : null,
        'tamanhoArquivo':
            tipoSelecionado == 'arquivo' ? arquivoSelecionado!.size : null,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => enviando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    urlController.dispose();
    super.dispose();
  }
}
