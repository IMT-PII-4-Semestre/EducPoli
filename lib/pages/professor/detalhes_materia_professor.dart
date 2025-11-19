import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/dialog_adicionar_material.dart';

// DESIGN PROFESSOR
const Color _primaryOrange = Color(0xFFFF9500);
const Color _contentRowColor = Color(0xFFF5F5F5);

class DetalhesMateriaProfessor extends StatelessWidget {
  final String materiaId;
  final String nomeMateria;

  const DetalhesMateriaProfessor({
    super.key,
    required this.materiaId,
    required this.nomeMateria,
  });

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'pasta':
        return Icons.folder;
      case 'documento':
      case 'arquivo':
        return Icons.description;
      case 'link':
        return Icons.link;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _abrirMaterial(
      BuildContext context, String aulaId, String materialId) async {
    try {
      final materialDoc = await FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .doc(aulaId)
          .collection('materiais')
          .doc(materialId)
          .get();

      final url = materialDoc.data()?['url'];
      final nome = materialDoc.data()?['nome'] ?? 'Material';

      if (url == null || url.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '"$nome": Este material não possui um link associado.')),
          );
        }
        return;
      }

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          throw 'Não foi possível abrir o link.';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir material: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR LARANJA COM BOTÃO VOLTAR
      appBar: AppBar(
        backgroundColor: _primaryOrange,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          nomeMateria,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Inter',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // CONTEÚDO OCUPA A TELA TODA (Sem Sidebar nesta tela interna)
      body: _buildMateriaContent(context),
    );
  }

  Widget _buildMateriaContent(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .orderBy('ordem')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Erro ao carregar aulas.'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final aulas = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32.0), // Padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...aulas.map((aulaDoc) {
                final aulaData = aulaDoc.data() as Map<String, dynamic>;
                final aulaId = aulaDoc.id;
                final titulo = aulaData['titulo'] ?? 'Aula Sem Título';

                return _buildAulaSection(context, titulo, aulaId);
              }).toList(),

              const SizedBox(height: 40),

              // Botão "Nova Seção" Centralizado e Estilizado
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarDialogAdicionarAula(context),
                    icon: const Icon(Icons.add),
                    label: const Text('NOVA SEÇÃO'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryOrange,
                      side: const BorderSide(color: _primaryOrange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAulaSection(BuildContext context, String title, String aulaId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER DA SEÇÃO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _mostrarDialogAdicionarMaterial(context, aulaId),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar Item'),
                    style:
                        TextButton.styleFrom(foregroundColor: _primaryOrange),
                  ),
                  // BOTÃO EDITAR SEÇÃO
                  IconButton(
                    icon: Icon(Icons.edit,
                        size: 20, color: Colors.grey[700]), // Cor neutra
                    tooltip: 'Editar Seção',
                    onPressed: () =>
                        _mostrarDialogEditarAula(context, aulaId, title),
                  ),
                  // BOTÃO EXCLUIR SEÇÃO
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 20, color: Colors.grey[700]), // Cor neutra
                    tooltip: 'Excluir Seção',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Excluir Seção?'),
                          content: Text(
                              'Tem certeza que deseja excluir a seção "$title"? Isso removerá todos os materiais contidos nela.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar')),
                            ElevatedButton(
                              onPressed: () => _excluirAula(ctx, aulaId, title),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Excluir',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(), // Linha divisória
          const SizedBox(height: 8),

          // LISTA DE MATERIAIS DA SEÇÃO
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materias')
                .doc(materiaId)
                .collection('aulas')
                .doc(aulaId)
                .collection('materiais')
                .orderBy('nome')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              final materiais = snapshot.data?.docs ?? [];

              if (materiais.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Nenhum material adicionado.',
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)),
                );
              }

              return Column(
                children: materiais.map((materialDoc) {
                  final material = materialDoc.data() as Map<String, dynamic>;
                  return _buildMaterialRow(
                    context,
                    material['nome'] ?? 'Item sem nome',
                    material['tipo'] ?? 'documento',
                    aulaId,
                    materialDoc.id,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(BuildContext context, String name, String type,
      String aulaId, String materialId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _contentRowColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(_getIconForType(type), color: Colors.grey.shade700),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        onTap: () {
          if (type != 'pasta') {
            _abrirMaterial(context, aulaId, materialId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pasta "$name": Apenas visualização.')),
            );
          }
        },
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _mostrarMenuMaterial(context, aulaId, materialId),
        ),
      ),
    );
  }

  // DIALOGS DE EDIÇÃO/ADIÇÃO

  void _mostrarDialogAdicionarMaterial(BuildContext context, String aulaId) {
    showDialog(
      context: context,
      builder: (context) => DialogAdicionarMaterial(
        materiaId: materiaId,
        aulaId: aulaId,
        corPrincipal: _primaryOrange,
      ),
    );
  }

  void _mostrarMenuMaterial(
      BuildContext context, String aulaId, String materialId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opções'),
        content: const Text('O que deseja fazer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarDialogEditarMaterial(context, aulaId, materialId);
            },
            child: const Text('Editar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _excluirMaterial(context, aulaId, materialId);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirMaterial(
      BuildContext context, String aulaId, String materialId) async {
    try {
      await FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .doc(aulaId)
          .collection('materiais')
          .doc(materialId)
          .delete();
    } catch (e) {
      // Tratar erro
    }
  }

  void _mostrarDialogEditarMaterial(
      BuildContext context, String aulaId, String materialId) async {
    final materialDoc = await FirebaseFirestore.instance
        .collection('materias')
        .doc(materiaId)
        .collection('aulas')
        .doc(aulaId)
        .collection('materiais')
        .doc(materialId)
        .get();

    final nomeController = TextEditingController(text: materialDoc['nome']);
    final urlController = TextEditingController(text: materialDoc['url']);
    String? tipoSelecionado = materialDoc['tipo'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Material'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration:
                          const InputDecoration(labelText: 'Nome do Material'),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Tipo', border: OutlineInputBorder()),
                      value: tipoSelecionado,
                      items: const [
                        DropdownMenuItem(
                            value: 'documento',
                            child: Text('Documento/Arquivo')),
                        DropdownMenuItem(
                            value: 'link', child: Text('Link/URL')),
                        DropdownMenuItem(value: 'pasta', child: Text('Pasta')),
                      ],
                      onChanged: (v) => setState(() => tipoSelecionado = v),
                    ),
                    const SizedBox(height: 15),
                    if (tipoSelecionado != 'pasta')
                      TextField(
                        controller: urlController,
                        decoration: const InputDecoration(
                            labelText: 'Link (URL)', hintText: 'https://...'),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.isNotEmpty &&
                        tipoSelecionado != null) {
                      await FirebaseFirestore.instance
                          .collection('materias')
                          .doc(materiaId)
                          .collection('aulas')
                          .doc(aulaId)
                          .collection('materiais')
                          .doc(materialId)
                          .update({
                        'nome': nomeController.text.trim(),
                        'tipo': tipoSelecionado!,
                        'url': tipoSelecionado != 'pasta' &&
                                urlController.text.isNotEmpty
                            ? urlController.text.trim()
                            : null,
                        'ultimaEdicao': FieldValue.serverTimestamp(),
                      });
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
                  child: const Text('Salvar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Lógica de Aulas (Seções)

  Future<void> _excluirAula(
      BuildContext context, String aulaId, String aulaTitulo) async {
    try {
      // Excluir todos os materiais dentro da aula primeiro
      final materiaisSnapshot = await FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .doc(aulaId)
          .collection('materiais')
          .get();

      for (var doc in materiaisSnapshot.docs) {
        await doc.reference.delete();
      }

      // Agora exclui a aula em si
      await FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .doc(aulaId)
          .delete();

      if (context.mounted) {
        Navigator.pop(context); // Fecha o AlertDialog de confirmação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Seção "$aulaTitulo" e seus materiais foram excluídos.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir seção: ${e.toString()}')),
        );
      }
    }
  }

  void _mostrarDialogAdicionarAula(BuildContext context) {
    final nomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Seção'),
        content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Título da Seção')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('materias')
                    .doc(materiaId)
                    .collection('aulas')
                    .add({
                  'titulo': nomeController.text.trim(),
                  'ordem': DateTime.now()
                      .millisecondsSinceEpoch, // Garante ordem na exibição
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
            child:
                const Text('Adicionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogEditarAula(
      BuildContext context, String aulaId, String tituloAtual) {
    final nomeController = TextEditingController(text: tituloAtual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Título da Seção'),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: 'Novo Título da Seção'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty &&
                  nomeController.text.trim() != tituloAtual) {
                await FirebaseFirestore.instance
                    .collection('materias')
                    .doc(materiaId)
                    .collection('aulas')
                    .doc(aulaId)
                    .update({'titulo': nomeController.text.trim()});
                if (context.mounted) Navigator.pop(context);
              } else if (context.mounted) {
                Navigator.pop(context); // Fechar se não houve alteração
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
