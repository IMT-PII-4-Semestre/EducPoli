import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/turma_service.dart';
import '../../models/turma.dart';

class AlunosDiretor extends StatefulWidget {
  const AlunosDiretor({super.key});

  @override
  State<AlunosDiretor> createState() => _AlunosDiretorState();
}

class _AlunosDiretorState extends State<AlunosDiretor> {
  final TextEditingController _buscaController = TextEditingController();
  final TurmaService _turmaService = TurmaService();
  String _statusFiltro = 'Sem filtro';
  String _turmaFiltro = 'Selecione';
  String _termoBusca = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gerenciar Alunos'),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuários cadastrados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Relação de usuários cadastrados',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, e-mail ou RA',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (value) =>
                        setState(() => _termoBusca = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _statusFiltro,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    items: ['Sem filtro', 'Ativo', 'Inativo']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _statusFiltro = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<List<Turma>>(
                    stream: _turmaService.buscarTurmasAtivas(),
                    builder: (context, snapshot) {
                      List<String> turmas = ['Selecione'];
                      if (snapshot.hasData) {
                        turmas.addAll(
                          snapshot.data!.map((t) => t.nome).toList(),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: _turmaFiltro,
                        decoration: InputDecoration(
                          labelText: 'Turma',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: turmas
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _turmaFiltro = v!),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/diretor/cadastrar-aluno'),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Novo usuário',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabela
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('tipo', isEqualTo: 'aluno')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var alunos = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nome = (data['nome'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final ra = (data['ra'] ?? '').toString().toLowerCase();
                  final ativo = data['ativo'] ?? true;
                  final turma = data['turma'] ?? '';

                  if (_termoBusca.isNotEmpty &&
                      !nome.contains(_termoBusca) &&
                      !email.contains(_termoBusca) &&
                      !ra.contains(_termoBusca))
                    return false;

                  if (_statusFiltro == 'Ativo' && !ativo) return false;
                  if (_statusFiltro == 'Inativo' && ativo) return false;

                  if (_turmaFiltro != 'Selecione' && turma != _turmaFiltro) {
                    return false;
                  }

                  return true;
                }).toList();

                if (alunos.isEmpty) {
                  return const Center(child: Text('Nenhum aluno encontrado'));
                }

                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Nome',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'E-mail',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'RA',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Turma',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 50),
                          ],
                        ),
                      ),

                      // Lista
                      Expanded(
                        child: ListView.builder(
                          itemCount: alunos.length,
                          itemBuilder: (context, index) {
                            final aluno =
                                alunos[index].data() as Map<String, dynamic>;
                            final id = alunos[index].id;
                            final ativo = aluno['ativo'] ?? true;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(aluno['nome'] ?? '-'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(aluno['email'] ?? '-'),
                                  ),
                                  Expanded(child: Text(aluno['ra'] ?? '-')),
                                  Expanded(child: Text(aluno['turma'] ?? '-')),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: ativo
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(ativo ? 'ativo' : 'inativo'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: PopupMenuButton(
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
                                              Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Excluir',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'editar') {
                                          _mostrarDialogEditar(id, aluno);
                                        } else {
                                          _excluirAluno(id, aluno['nome']);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Paginação
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total: ${alunos.length} itens'),
                            const Row(
                              children: [
                                Text('1'),
                                SizedBox(width: 16),
                                Text('10 / página'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogEditar(String id, Map<String, dynamic> aluno) {
    final nomeCtrl = TextEditingController(text: aluno['nome']);
    final raCtrl = TextEditingController(text: aluno['ra']);
    final emailCtrl = TextEditingController(text: aluno['email']);
    String turma = aluno['turma'] ?? 'Selecione';
    bool ativo = aluno['ativo'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Aluno'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: raCtrl,
                  decoration: const InputDecoration(labelText: 'RA'),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Turma>>(
                  stream: _turmaService.buscarTurmasAtivas(),
                  builder: (context, snapshot) {
                    List<String> turmas = ['Selecione'];
                    if (snapshot.hasData) {
                      turmas.addAll(snapshot.data!.map((t) => t.nome));
                    }
                    return DropdownButtonFormField<String>(
                      value: turma,
                      decoration: const InputDecoration(labelText: 'Turma'),
                      items: turmas
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setStateDialog(() => turma = v!),
                    );
                  },
                ),
                Row(
                  children: [
                    const Text('Status:'),
                    Switch(
                      value: ativo,
                      onChanged: (v) => setStateDialog(() => ativo = v),
                    ),
                    Text(ativo ? 'Ativo' : 'Inativo'),
                  ],
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
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(id)
                    .update({
                      'nome': nomeCtrl.text,
                      'ra': raCtrl.text,
                      'email': emailCtrl.text,
                      'turma': turma == 'Selecione' ? null : turma,
                      'ativo': ativo,
                    });
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _excluirAluno(String id, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Aluno'),
        content: Text('Deseja excluir "$nome"?'),
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

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }
}
