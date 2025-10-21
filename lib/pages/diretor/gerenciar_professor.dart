import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessoresDiretor extends StatefulWidget {
  const ProfessoresDiretor({super.key});

  @override
  State<ProfessoresDiretor> createState() => _ProfessoresDiretorState();
}

class _ProfessoresDiretorState extends State<ProfessoresDiretor> {
  final TextEditingController _buscaController = TextEditingController();
  String _statusFiltro = 'Sem filtro';
  String _disciplinaFiltro = 'Selecione';
  String _termoBusca = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gerenciar Professores'),
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
                  'Professores cadastrados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Relação de professores cadastrados',
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
                // Campo de busca
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, e-mail ou CPF',
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

                // Filtro de Status
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

                // Filtro de Disciplina
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usuarios')
                        .where('tipo', isEqualTo: 'professor')
                        .snapshots(),
                    builder: (context, snapshot) {
                      Set<String> disciplinas = {'Selecione'};

                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final disciplina = data['disciplina'];
                          if (disciplina != null && disciplina.isNotEmpty) {
                            disciplinas.add(disciplina);
                          }
                        }
                      }

                      return DropdownButtonFormField<String>(
                        value: _disciplinaFiltro,
                        decoration: InputDecoration(
                          labelText: 'Disciplina',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: disciplinas
                            .toList()
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _disciplinaFiltro = v!),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Botão Novo Professor
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/diretor/cadastrar-professor',
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Novo professor',
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
                  .where('tipo', isEqualTo: 'professor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var professores = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nome = (data['nome'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final cpf = (data['cpf'] ?? '').toString().toLowerCase();
                  final ativo = data['ativo'] ?? true;
                  final disciplina = data['disciplina'] ?? '';

                  if (_termoBusca.isNotEmpty &&
                      !nome.contains(_termoBusca) &&
                      !email.contains(_termoBusca) &&
                      !cpf.contains(_termoBusca))
                    return false;

                  if (_statusFiltro == 'Ativo' && !ativo) return false;
                  if (_statusFiltro == 'Inativo' && ativo) return false;

                  if (_disciplinaFiltro != 'Selecione' &&
                      disciplina != _disciplinaFiltro) {
                    return false;
                  }

                  return true;
                }).toList();

                if (professores.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 100, color: Colors.grey),
                        Text(
                          'Nenhum professor encontrado',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
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
                                'CPF',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Disciplina',
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
                          itemCount: professores.length,
                          itemBuilder: (context, index) {
                            final professor =
                                professores[index].data()
                                    as Map<String, dynamic>;
                            final id = professores[index].id;
                            final ativo = professor['ativo'] ?? true;

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
                                    child: Text(professor['nome'] ?? '-'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(professor['email'] ?? '-'),
                                  ),
                                  Expanded(
                                    child: Text(professor['cpf'] ?? '-'),
                                  ),
                                  Expanded(
                                    child: Text(professor['disciplina'] ?? '-'),
                                  ),
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
                                          _mostrarDialogEditar(id, professor);
                                        } else {
                                          _excluirProfessor(
                                            id,
                                            professor['nome'],
                                          );
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
                            Text('Total: ${professores.length} itens'),
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

  void _mostrarDialogEditar(String id, Map<String, dynamic> professor) {
    final nomeCtrl = TextEditingController(text: professor['nome']);
    final cpfCtrl = TextEditingController(text: professor['cpf']);
    final emailCtrl = TextEditingController(text: professor['email']);
    final disciplinaCtrl = TextEditingController(text: professor['disciplina']);
    bool ativo = professor['ativo'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Professor'),
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
                  controller: cpfCtrl,
                  decoration: const InputDecoration(labelText: 'CPF'),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: disciplinaCtrl,
                  decoration: const InputDecoration(labelText: 'Disciplina'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Status:'),
                    Switch(
                      value: ativo,
                      onChanged: (v) => setStateDialog(() => ativo = v),
                      activeColor: const Color(0xFFE74C3C),
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
                      'cpf': cpfCtrl.text,
                      'email': emailCtrl.text,
                      'disciplina': disciplinaCtrl.text,
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

  void _excluirProfessor(String id, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Professor'),
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
