import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import 'detalhes_materia_professor.dart';

class MateriasProfessor extends StatefulWidget {
  const MateriasProfessor({super.key});

  @override
  State<MateriasProfessor> createState() => _MateriasProfessorState();
}

class _MateriasProfessorState extends State<MateriasProfessor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _minhasMaterias = [];
  bool _carregandoPerfil = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfilProfessor();
  }

  Future<void> _carregarPerfilProfessor() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final listaDoPerfil = List<String>.from(data['materias'] ?? []);

        if (mounted) {
          setState(() {
            _minhasMaterias = listaDoPerfil;
            _carregandoPerfil = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      if (mounted) setState(() => _carregandoPerfil = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Gerenciar Matérias',
      corPrincipal: MenuConfig.corProfessor,
      itensMenu: MenuConfig.menuProfessor,
      itemSelecionadoId: 'materias',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Matérias', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    if (_carregandoPerfil) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Botão adicionar no topo
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogAdicionarMateria(context),
                icon: const Icon(Icons.add),
                label: const Text('Nova Matéria'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MenuConfig.corProfessor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        // Lista de matérias
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildListaMaterias(),
          ),
        ),
      ],
    );
  }

  Widget _buildListaMaterias() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('materias').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar matérias'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final todasMaterias = snapshot.data?.docs ?? [];

        final materiasFiltradas = todasMaterias.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nomeMateria = data['nome'] ?? '';
          return _minhasMaterias.contains(nomeMateria);
        }).toList();

        if (materiasFiltradas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 20),
                const Text(
                  'Você não possui matérias vinculadas',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adicione uma nova ou peça ao diretor',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        if (isMobile) {
          return ListView.separated(
            itemCount: materiasFiltradas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final materiaDoc = materiasFiltradas[index];
              final materia = materiaDoc.data() as Map<String, dynamic>;
              return _buildMateriaCardMobile(materiaDoc.id, materia);
            },
          );
        } else {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              childAspectRatio: 1.5,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: materiasFiltradas.length,
            itemBuilder: (context, index) {
              final materiaDoc = materiasFiltradas[index];
              final materia = materiaDoc.data() as Map<String, dynamic>;
              return _buildMateriaCard(materiaDoc.id, materia);
            },
          );
        }
      },
    );
  }

  Widget _buildMateriaCard(String id, Map<String, dynamic> materia) {
    final materiaNome = materia['nome'] ?? 'Sem nome';
    final descricao = materia['descricao'] ?? 'Sem descrição';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesMateriaProfessor(
                materiaId: id,
                nomeMateria: materiaNome,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MenuConfig.corProfessor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.book,
                      color: MenuConfig.corProfessor,
                      size: 28,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'editar') {
                        _editarMateria(context, id, materia);
                      } else if (value == 'excluir') {
                        _excluirMateria(context, id, materiaNome);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                materiaNome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMateriaCardMobile(String id, Map<String, dynamic> materia) {
    final materiaNome = materia['nome'] ?? 'Sem nome';
    final descricao = materia['descricao'] ?? 'Sem descrição';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: MenuConfig.corProfessor.withOpacity(0.1),
          child: Icon(Icons.book, color: MenuConfig.corProfessor),
        ),
        title: Text(materiaNome,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesMateriaProfessor(
                materiaId: id,
                nomeMateria: materiaNome,
              ),
            ),
          );
        },
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(
              value: 'excluir',
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) {
            if (value == 'editar') {
              _editarMateria(context, id, materia);
            } else if (value == 'excluir') {
              _excluirMateria(context, id, materiaNome);
            }
          },
        ),
      ),
    );
  }

  void _mostrarDialogAdicionarMateria(BuildContext context) {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Matéria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Matéria'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                final nomeMateria = nomeController.text.trim();

                await FirebaseFirestore.instance.collection('materias').add({
                  'nome': nomeMateria,
                  'descricao': descricaoController.text.trim(),
                  'criadoEm': DateTime.now(),
                });

                final uid = _auth.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .update({
                    'materias': FieldValue.arrayUnion([nomeMateria])
                  });
                  setState(() {
                    _minhasMaterias.add(nomeMateria);
                  });
                }

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: MenuConfig.corProfessor),
            child:
                const Text('Adicionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editarMateria(
      BuildContext context, String id, Map<String, dynamic> materia) {
    final nomeController = TextEditingController(text: materia['nome']);
    final descricaoController =
        TextEditingController(text: materia['descricao']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Matéria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome (Cuidado ao alterar)',
                helperText: 'Alterar o nome afeta o perfil',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final novoNome = nomeController.text.trim();
              final antigoNome = materia['nome'];

              await FirebaseFirestore.instance
                  .collection('materias')
                  .doc(id)
                  .update({
                'nome': novoNome,
                'descricao': descricaoController.text.trim(),
              });

              if (novoNome != antigoNome) {
                final uid = _auth.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .update({
                    'materias': FieldValue.arrayRemove([antigoNome])
                  });
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .update({
                    'materias': FieldValue.arrayUnion([novoNome])
                  });
                  setState(() {
                    _minhasMaterias.remove(antigoNome);
                    _minhasMaterias.add(novoNome);
                  });
                }
              }

              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: MenuConfig.corProfessor),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _excluirMateria(BuildContext context, String id, String nomeMateria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Matéria'),
        content: Text('Tem certeza que deseja excluir "$nomeMateria"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('materias')
                  .doc(id)
                  .delete();

              final uid = _auth.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uid)
                    .update({
                  'materias': FieldValue.arrayRemove([nomeMateria])
                });
                setState(() {
                  _minhasMaterias.remove(nomeMateria);
                });
              }

              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
