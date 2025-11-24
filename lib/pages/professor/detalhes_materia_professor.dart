import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/dialog_adicionar_material.dart';

// DESIGN PROFESSOR
const Color _primaryOrange = Color(0xFFFF9500);
const Color _contentRowColor = Color(0xFFF5F5F5);

class DetalhesMateriaProfessor extends StatefulWidget {
  final String materiaId;
  final String nomeMateria;

  const DetalhesMateriaProfessor({
    super.key,
    required this.materiaId,
    required this.nomeMateria,
  });

  @override
  State<DetalhesMateriaProfessor> createState() =>
      _DetalhesMateriaProfessorState();
}

class _DetalhesMateriaProfessorState extends State<DetalhesMateriaProfessor> {
  String? _turmaSelecionada;
  List<String> _turmasDisponiveis = [];
  bool _carregandoTurmas = true;

  @override
  void initState() {
    super.initState();
    _carregarTurmasProfessor();
  }

  Future<void> _carregarTurmasProfessor() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final turmas = List<String>.from(data['turmas'] ?? []);
        setState(() {
          _turmasDisponiveis = turmas;
          if (turmas.isNotEmpty) {
            _turmaSelecionada = turmas.first;
          }
          _carregandoTurmas = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar turmas: $e');
      setState(() => _carregandoTurmas = false);
    }
  }

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
          .doc(widget.materiaId)
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

      // Tentar abrir a URL
      final uri = Uri.parse(url);
      
      try {
        // Tenta lançar a URL no navegador ou app externo
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o arquivo. Tente novamente.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao abrir: ${e.toString()}'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar material: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR LARANJA COM BOT�O VOLTAR
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
          widget.nomeMateria,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Inter',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // CONTE�DO OCUPA A TELA TODA (Sem Sidebar nesta tela interna)
      body: _buildMateriaContent(context),
    );
  }

  Widget _buildMateriaContent(BuildContext context) {
    if (_carregandoTurmas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_turmasDisponiveis.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Você não possui turmas vinculadas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filtro de Turma
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              const Text(
                'Turma:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _turmaSelecionada,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _turmasDisponiveis.map((turma) {
                    return DropdownMenuItem(
                      value: turma,
                      child: Text(turma),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _turmaSelecionada = value);
                  },
                ),
              ),
            ],
          ),
        ),

        // Conte�do das Aulas
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materias')
                .doc(widget.materiaId)
                .collection('aulas')
                .where('turma', isEqualTo: _turmaSelecionada)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Erro no StreamBuilder: ${snapshot.error}');
                return const Center(child: Text('Erro ao carregar aulas.'));
              }
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());

              var aulas = snapshot.data?.docs ?? [];
              // Ordenar manualmente por ordem
              aulas.sort((a, b) {
                final ordemA = (a.data() as Map<String, dynamic>)['ordem'] ?? 0;
                final ordemB = (b.data() as Map<String, dynamic>)['ordem'] ?? 0;
                return ordemA.compareTo(ordemB);
              });

              return SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...aulas.map((aulaDoc) {
                      final aulaData = aulaDoc.data() as Map<String, dynamic>;
                      final aulaId = aulaDoc.id;
                      final titulo = aulaData['titulo'] ?? 'Aula Sem T�tulo';

                      return _buildAulaSection(context, titulo, aulaId);
                    }).toList(),

                    const SizedBox(height: 40),

                    // Bot�o "Nova Se��o" Centralizado e Estilizado
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
          ),
        ),
      ],
    );
  }

  Widget _buildAulaSection(BuildContext context, String title, String aulaId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER DA SE��O
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
                  // BOT�O EDITAR SE��O
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
          const Divider(), // Linha divis�ria
          const SizedBox(height: 8),

          // LISTA DE MATERIAIS DA SEÇÃO
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materias')
                .doc(widget.materiaId)
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

  // DIALOGS DE EDI��O/ADI��O

  void _mostrarDialogAdicionarMaterial(BuildContext context, String aulaId) {
    showDialog(
      context: context,
      builder: (context) => DialogAdicionarMaterial(
        materiaId: widget.materiaId,
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
          .doc(widget.materiaId)
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
        .doc(widget.materiaId)
        .collection('aulas')
        .doc(aulaId)
        .collection('materiais')
        .doc(materialId)
        .get();

    if (!materialDoc.exists) return;

    final data = materialDoc.data();
    if (data == null) return;

    final nomeController = TextEditingController(text: data['nome'] ?? '');
    final urlController = TextEditingController(text: data['url'] ?? '');
    
    // Validar e normalizar o tipo
    String tipoSelecionado = data['tipo'] ?? 'documento';
    if (!['documento', 'link', 'pasta', 'arquivo'].contains(tipoSelecionado)) {
      tipoSelecionado = 'documento';
    }
    // Normalizar 'arquivo' para 'documento'
    if (tipoSelecionado == 'arquivo') {
      tipoSelecionado = 'documento';
    }

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
                      onChanged: (v) => setState(() => tipoSelecionado = v!),
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
                    if (nomeController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('materias')
                          .doc(widget.materiaId)
                          .collection('aulas')
                          .doc(aulaId)
                          .collection('materiais')
                          .doc(materialId)
                          .update({
                        'nome': nomeController.text.trim(),
                        'tipo': tipoSelecionado,
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

  // L�gica de Aulas (Se��es)

  Future<void> _excluirAula(
      BuildContext context, String aulaId, String aulaTitulo) async {
    try {
      // Excluir todos os materiais dentro da aula primeiro
      final materiaisSnapshot = await FirebaseFirestore.instance
          .collection('materias')
          .doc(widget.materiaId)
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
          .doc(widget.materiaId)
          .collection('aulas')
          .doc(aulaId)
          .delete();

      if (context.mounted) {
        Navigator.pop(context); // Fecha o AlertDialog de confirma��o
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Título da Seção'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('materias')
                    .doc(widget.materiaId)
                    .collection('aulas')
                    .add({
                  'titulo': nomeController.text.trim(),
                  'turma': _turmaSelecionada,
                  'ordem': DateTime.now().millisecondsSinceEpoch,
                });
                if (context.mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preencha o título da seção'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
            child: const Text('Adicionar',
                style: TextStyle(color: Colors.white)),
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
                    .doc(widget.materiaId)
                    .collection('aulas')
                    .doc(aulaId)
                    .update({'titulo': nomeController.text.trim()});
                if (context.mounted) Navigator.pop(context);
              } else if (context.mounted) {
                Navigator.pop(context); // Fechar se n�o houve altera��o
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
