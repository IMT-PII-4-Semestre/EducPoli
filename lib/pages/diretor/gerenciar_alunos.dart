import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlunosDiretor extends StatelessWidget {
  const AlunosDiretor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Alunos'),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/diretor/cadastrar-aluno'),
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar Novo Aluno',
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
                  'Lista de Alunos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/diretor/cadastrar-aluno'),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Novo Aluno',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
          ),

          // Lista de alunos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('tipo', isEqualTo: 'aluno')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar alunos'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final alunos = snapshot.data?.docs ?? [];

                if (alunos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 100, color: Colors.grey),
                        Text(
                          'Nenhum aluno encontrado',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text('Clique no + para adicionar'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alunos.length,
                  itemBuilder: (context, index) {
                    final aluno = alunos[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE74C3C),
                          child: Text(
                            aluno['nome']?.substring(0, 1).toUpperCase() ?? 'A',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(aluno['nome'] ?? 'Sem nome'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${aluno['email'] ?? 'Sem email'}'),
                            Text('RA: ${aluno['ra'] ?? 'Sem RA'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _editarAluno(
                                context,
                                alunos[index].id,
                                aluno,
                              ),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _excluirAluno(
                                context,
                                alunos[index].id,
                                aluno['nome'],
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

  void _editarAluno(
    BuildContext context,
    String id,
    Map<String, dynamic> aluno,
  ) {
    final nomeController = TextEditingController(text: aluno['nome']);
    final emailController = TextEditingController(text: aluno['email']);
    final raController = TextEditingController(text: aluno['ra']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Aluno'),
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

  void _excluirAluno(BuildContext context, String id, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Aluno'),
        content: Text('Tem certeza que deseja excluir o aluno "$nome"?'),
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
