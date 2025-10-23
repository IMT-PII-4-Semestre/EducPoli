import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalhes_materia_professor.dart'; 

class MateriasProfessor extends StatelessWidget {
  const MateriasProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Matérias'),
        backgroundColor: const Color(0xFFFF9500),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => _mostrarDialogAdicionarMateria(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('materias').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar matérias'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final materias = snapshot.data?.docs ?? [];

          if (materias.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 100, color: Colors.grey),
                  Text('Nenhuma matéria encontrada'),
                  Text('Clique no + para adicionar'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materias.length,
            itemBuilder: (context, index) {
              final materia = materias[index].data() as Map<String, dynamic>;
              final materiaNome = materia['nome'] ?? 'Sem nome';
              
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(materiaNome),
                  subtitle: Text(materia['descricao'] ?? 'Sem descrição'),

                  // Lógica de navegação 
                  onTap: () {
                    final materiaDoc = materias[index]; 
                    final materiaNome = materia['nome'] ?? 'Sem nome';
                    final materiaId = materiaDoc.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesMateriaProfessor(
                          materiaId: materiaId,
                          nomeMateria: materiaNome, 
                        ),
                      ),
                    );
                  },

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editarMateria(
                          context,
                          materias[index].id,
                          materia,
                        ),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () =>
                            _excluirMateria(context, materias[index].id),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
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
                await FirebaseFirestore.instance.collection('materias').add({
                  'nome': nomeController.text.trim(),
                  'descricao': descricaoController.text.trim(),
                  'criadoEm': DateTime.now(),
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

  void _editarMateria(
    BuildContext context,
    String id,
    Map<String, dynamic> materia,
  ) {
    final nomeController = TextEditingController(text: materia['nome']);
    final descricaoController = TextEditingController(
      text: materia['descricao'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Matéria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Matéria'),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
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
              await FirebaseFirestore.instance
                  .collection('materias')
                  .doc(id)
                  .update({
                    'nome': nomeController.text.trim(),
                    'descricao': descricaoController.text.trim(),
                  });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _excluirMateria(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Matéria'),
        content: const Text('Tem certeza que deseja excluir esta matéria?'),
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