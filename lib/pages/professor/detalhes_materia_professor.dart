
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 

// Definindo as cores do layout
const Color primaryOrange = Color(0xFFFF9500);
const Color contentRowColor = Color(0xFFE0E0E0); 

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
        return Icons.insert_drive_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _abrirMaterial(BuildContext context, String aulaId, String materialId) async {
    try {
      final materialDoc = await FirebaseFirestore.instance
          .collection('materias').doc(materiaId)
          .collection('aulas').doc(aulaId)
          .collection('materiais').doc(materialId).get();

      final url = materialDoc.data()?['url'];
      final nome = materialDoc.data()?['nome'] ?? 'Material';

      if (url == null || url.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$nome": Este material não possui um link associado para abrir.')),
          );
        }
        return;
      }

      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          throw 'Não foi possível abrir o link: $url. Verifique se o formato está correto.';
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
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      // Removendo o Drawer e a chamada para PainelSidebar
      drawer: null, 
      
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false, // Desabilitamos o padrão
          
          backgroundColor: primaryOrange,
          foregroundColor: Colors.black,
          
          // ÍCONE DE SETA PARA VOLTAR
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Volta para a tela anterior (MateriasProfessor)
              Navigator.pop(context); 
            },
          ),
          
          title: Padding(
            padding: EdgeInsets.zero,
            child: Text(
              nomeMateria,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          centerTitle: isLargeScreen,
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.account_circle, size: 32),
            ),
          ],
        ),
      ),
      
      // CONTEÚDO OCUPA A LARGURA TOTAL
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
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar aulas.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final aulas = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...aulas.map((aulaDoc) {
                final aulaData = aulaDoc.data() as Map<String, dynamic>;
                final aulaId = aulaDoc.id;
                final titulo = aulaData['titulo'] ?? 'Aula Sem Título';
                
                return _buildAulaSection(context, titulo, aulaId);
              }).toList(),

              const SizedBox(height: 30),
              
              // Botão "nova seção"
              Center(
                child: SizedBox(
                  width: 150,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _mostrarDialogAdicionarAula(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('nova seção'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TÍTULO DA AULA
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BOTÃO: ADICIONAR MATERIAL
                  InkWell(
                    onTap: () {
                      _mostrarDialogAdicionarMaterial(context, aulaId);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: primaryOrange),
                          SizedBox(width: 4),
                          Text(
                            'Adicionar Item',
                            style: TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BOTÃO DE OPÇÕES DA AULA (Excluir Seção)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'excluir') {
                        // Confirmação antes de excluir a aula
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Excluir Seção?'),
                            content: Text('Tem certeza que deseja excluir a seção "$title"? Isso removerá todos os materiais dentro dela.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                              ElevatedButton(
                                onPressed: () => _excluirAula(ctx, aulaId, title),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'excluir',
                        child: Text('Excluir Seção'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // StreamBuilder para ler os MATERIAIS de cada aula
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
              if (snapshot.hasError) {
                return const Text('Erro ao carregar materiais.');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              final materiais = snapshot.data?.docs ?? [];
              
              if (materiais.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Nenhum material adicionado nesta seção.'),
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

  Widget _buildMaterialRow(
    BuildContext context, 
    String name, 
    String type, 
    String aulaId,
    String materialId,
  ) {
    return InkWell( 
      onTap: () {
        if (type != 'pasta') {
          _abrirMaterial(context, aulaId, materialId);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pasta "$name": Esta funcionalidade abre apenas materiais com links.')),
          );
        }
      },
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: contentRowColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(_getIconForType(type), size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(color: Colors.grey.shade800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Botão de Opções para o Professor (Editar/Excluir Material)
            IconButton(
              onPressed: () => _mostrarMenuMaterial(context, aulaId, materialId),
              icon: const Icon(Icons.more_vert, size: 18),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  // =========================================================
  // MÉTODOS DE ADIÇÃO E EXCLUSÃO/EDIÇÃO
  // =========================================================

  // --- MATERIAIS: ADIÇÃO ---
  void _mostrarDialogAdicionarMaterial(BuildContext context, String aulaId) {
    final nomeController = TextEditingController();
    final urlController = TextEditingController();
    String? tipoSelecionado = 'documento'; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Material'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome do Material'),
                    ),
                    const SizedBox(height: 15),
                    
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      value: tipoSelecionado,
                      items: const [
                        DropdownMenuItem(value: 'documento', child: Text('Documento/Arquivo')),
                        DropdownMenuItem(value: 'link', child: Text('Link/URL (Vídeo, Página)')),
                        DropdownMenuItem(value: 'pasta', child: Text('Pasta (Agrupador)')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          tipoSelecionado = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    if (tipoSelecionado != 'pasta')
                      TextField(
                        controller: urlController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: tipoSelecionado == 'link' 
                              ? 'Link Completo (URL)' 
                              : 'Link do Arquivo (URL/Cloud)',
                          hintText: 'Ex: https://...',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.isNotEmpty && tipoSelecionado != null) {
                      await _salvarMaterial(
                        context,
                        aulaId,
                        nomeController.text.trim(),
                        tipoSelecionado!,
                        urlController.text.trim(),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _salvarMaterial(
    BuildContext context,
    String aulaId,
    String nome,
    String tipo,
    String url,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .doc(aulaId)
          .collection('materiais')
          .add({
        'nome': nome,
        'tipo': tipo,
        'url': tipo != 'pasta' && url.isNotEmpty ? url : null, 
        'criadoEm': FieldValue.serverTimestamp(),
      });
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar material: $e')),
        );
      }
    }
  }


  // --- MATERIAIS: EXCLUSÃO ---

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

      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
           Navigator.pop(context); 
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material excluído com sucesso!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERRO AO EXCLUIR MATERIAL: $e. Verifique as Regras de Segurança do seu Firestore!'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- MATERIAIS: EDIÇÃO ---

  Future<void> _salvarEdicaoMaterial(
      BuildContext context,
      String aulaId,
      String materialId,
      String nome,
      String tipo,
      String url,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .doc(aulaId)
          .collection('materiais')
          .doc(materialId)
          .update({
        'nome': nome,
        'tipo': tipo,
        'url': tipo != 'pasta' && url.isNotEmpty ? url : null, 
      });
      if (context.mounted) {
        Navigator.pop(context); // Fecha o diálogo de edição
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material editado com sucesso!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar material: $e')),
        );
      }
    }
  }


  void _mostrarDialogEditarMaterial(
      BuildContext context, String aulaId, String materialId) async {
    
    // 1. Busca os dados atuais do material
    final materialDoc = await FirebaseFirestore.instance
        .collection('materias').doc(materiaId)
        .collection('aulas').doc(aulaId)
        .collection('materiais').doc(materialId).get();

    if (!materialDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material não encontrado para edição.')),
        );
      }
      return;
    }
    
    final materialData = materialDoc.data()!;
    final nomeController = TextEditingController(text: materialData['nome'] ?? '');
    final urlController = TextEditingController(text: materialData['url'] ?? '');
    String? tipoSelecionado = materialData['tipo'] ?? 'documento'; 

    // 2. Exibe o diálogo de edição
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
                      decoration: const InputDecoration(labelText: 'Nome do Material'),
                    ),
                    const SizedBox(height: 15),
                    
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      value: tipoSelecionado,
                      items: const [
                        DropdownMenuItem(value: 'documento', child: Text('Documento/Arquivo')),
                        DropdownMenuItem(value: 'link', child: Text('Link/URL (Vídeo, Página)')),
                        DropdownMenuItem(value: 'pasta', child: Text('Pasta (Agrupador)')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          tipoSelecionado = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    if (tipoSelecionado != 'pasta')
                      TextField(
                        controller: urlController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: tipoSelecionado == 'link' 
                              ? 'Link Completo (URL)' 
                              : 'Link do Arquivo (URL/Cloud)',
                          hintText: 'Ex: https://...',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.isNotEmpty && tipoSelecionado != null) {
                      await _salvarEdicaoMaterial(
                        context,
                        aulaId,
                        materialId,
                        nomeController.text.trim(),
                        tipoSelecionado!,
                        urlController.text.trim(),
                      );
                    }
                  },
                  child: const Text('Salvar Edição'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- MATERIAIS: MENU DE OPÇÕES ---

  void _mostrarMenuMaterial(BuildContext context, String aulaId, String materialId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opções do Material'),
        content: const Text('O que você deseja fazer com este material?'),
        actions: [
          // AÇÃO 1: EDITAR
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o diálogo de opções
              _mostrarDialogEditarMaterial(context, aulaId, materialId); // Abre o diálogo de edição
            },
            child: const Text('Editar'),
          ),
          
          // AÇÃO 2: EXCLUIR
          ElevatedButton(
            onPressed: () {
              // Diálogo de confirmação para exclusão
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: const Text('Tem certeza que deseja excluir este material?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    ElevatedButton(
                      onPressed: () async {
                        // Chama a função de exclusão
                        await _excluirMaterial(ctx, aulaId, materialId);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              // Fecha o primeiro diálogo de "Opções"
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context); 
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- SEÇÕES (AULAS): ADIÇÃO E EXCLUSÃO ---

  Future<void> _excluirAula(BuildContext context, String aulaId, String aulaTitulo) async {
    try {
      // 1. Excluir todos os materiais dentro da aula (exclusão em cascata)
      final materiaisSnapshot = await FirebaseFirestore.instance
          .collection('materias').doc(materiaId)
          .collection('aulas').doc(aulaId)
          .collection('materiais').get();

      for (var doc in materiaisSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // 2. Excluir a aula em si
      await FirebaseFirestore.instance
          .collection('materias').doc(materiaId)
          .collection('aulas').doc(aulaId)
          .delete();

      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
           Navigator.pop(context); // Fecha o diálogo de confirmação
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seção "$aulaTitulo" excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir seção: $e')),
        );
      }
    }
  }


  void _mostrarDialogAdicionarAula(BuildContext context) {
    final nomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Nova Seção (Aula)'),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: 'Título da Aula'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('materias')
                    .doc(materiaId)
                    .collection('aulas')
                    .add({
                      'titulo': nomeController.text.trim(),
                      'ordem': DateTime.now().millisecondsSinceEpoch, 
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}