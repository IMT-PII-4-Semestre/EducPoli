import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessoresDiretor extends StatelessWidget {
  const ProfessoresDiretor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Professores'),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/diretor/cadastrar-professor'),
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar Novo Professor',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com botão de cadastro
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Lista de Professores',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/diretor/cadastrar-professor',
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Novo Professor',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
          ),

          // Lista de professores
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('tipo', isEqualTo: 'professor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar professores'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final professores = snapshot.data?.docs ?? [];

                if (professores.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_3, size: 100, color: Colors.grey),
                        Text(
                          'Nenhum professor encontrado',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text('Clique no + para adicionar'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: professores.length,
                  itemBuilder: (context, index) {
                    final professor =
                        professores[index].data() as Map<String, dynamic>;
                    final materias = List<String>.from(
                      professor['materias'] ?? [],
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE74C3C),
                          child: Text(
                            professor['nome']?.substring(0, 1).toUpperCase() ??
                                'P',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(professor['nome'] ?? 'Sem nome'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${professor['email'] ?? 'Sem email'}'),
                            Text('RA: ${professor['ra'] ?? 'Sem RA'}'),
                            if (materias.isNotEmpty)
                              Text('Matérias: ${materias.join(', ')}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _editarProfessor(
                                context,
                                professores[index].id,
                                professor,
                              ),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _excluirProfessor(
                                context,
                                professores[index].id,
                                professor['nome'],
                              ),
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
          ),
        ],
      ),
    );
  }

  void _editarProfessor(
    BuildContext context,
    String id,
    Map<String, dynamic> professor,
  ) {
    final nomeController = TextEditingController(text: professor['nome']);
    final emailController = TextEditingController(text: professor['email']);
    final raController = TextEditingController(text: professor['ra']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Professor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: raController,
              decoration: const InputDecoration(labelText: 'RA'),
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
                  .collection('usuarios')
                  .doc(id)
                  .update({
                    'nome': nomeController.text.trim(),
                    'email': emailController.text.trim(),
                    'ra': raController.text.trim(),
                  });
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _excluirProfessor(BuildContext context, String id, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Professor'),
        content: Text('Tem certeza que deseja excluir o professor "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('usuarios')
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
