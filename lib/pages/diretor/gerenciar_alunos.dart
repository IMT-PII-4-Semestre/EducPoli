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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PAGE HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(40, 24, 40, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Home',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('/', style: TextStyle(color: Colors.grey)),
                    ),
                    const Text(
                      'Alunos cadastrados',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Título
                const Text(
                  'Alunos cadastrados',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Relação de alunos cadastrados',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // FILTROS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                // Busca
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _termoBusca = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),

                // Status
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _statusFiltro,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: ['Sem filtro', 'Ativo', 'Inativo']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _statusFiltro = v!),
                  ),
                ),
                const SizedBox(width: 16),

                // Turma (COM DEBUG)
                Expanded(
                  flex: 2,
                  child: StreamBuilder<List<Turma>>(
                    stream: _turmaService.buscarTurmasAtivas(),
                    builder: (context, snapshot) {
                      // DEBUG
                      print('🔍 Snapshot state: ${snapshot.connectionState}');
                      print('🔍 Has data: ${snapshot.hasData}');
                      print('🔍 Has error: ${snapshot.hasError}');
                      if (snapshot.hasError) {
                        print('❌ Error: ${snapshot.error}');
                      }
                      if (snapshot.hasData) {
                        print('✅ Turmas carregadas: ${snapshot.data!.length}');
                        for (var turma in snapshot.data!) {
                          print('  - ${turma.nome}');
                        }
                      }

                      List<String> turmas = ['Selecione'];
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        turmas.addAll(
                          snapshot.data!.map((t) => t.nome).toList(),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: turmas.contains(_turmaFiltro)
                            ? _turmaFiltro
                            : 'Selecione',
                        decoration: InputDecoration(
                          labelText: 'Perfil/Atribuição',
                          labelStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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

                // Botão Novo
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/diretor/cadastrar-aluno'),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text(
                    'Novo Aluno',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFFFF5F5,
                    ), // Vermelho muito suave
                    foregroundColor: const Color(
                      0xFFE74C3C,
                    ), // Vermelho diretor
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Color(0xFFFFCDD2), // Borda vermelho claro
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // TABELA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .where('tipo', isEqualTo: 'aluno')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var alunos = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nome = (data['nome'] ?? '').toString().toLowerCase();
                    final email =
                        (data['email'] ?? '').toString().toLowerCase();
                    final ra = (data['ra'] ?? '').toString().toLowerCase();
                    final ativo = data['ativo'] ?? true;
                    final turma = data['turma'] ?? '';

                    if (_termoBusca.isNotEmpty &&
                        !nome.contains(_termoBusca) &&
                        !email.contains(_termoBusca) &&
                        !ra.contains(_termoBusca)) return false;

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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        // Header da tabela
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Nome',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'E-mail',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'RA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Perfil/Atribuição',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 50),
                            ],
                          ),
                        ),

                        // Lista de alunos
                        Expanded(
                          child: ListView.separated(
                            itemCount: alunos.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (context, index) {
                              final aluno =
                                  alunos[index].data() as Map<String, dynamic>;
                              final id = alunos[index].id;
                              final ativo = aluno['ativo'] ?? true;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        aluno['nome'] ?? '-',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        aluno['email'] ?? '-',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        aluno['ra'] ?? '-',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFFF5F5,
                                          ), // Fundo vermelho suave
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFFFFCDD2,
                                            ), // Borda vermelho claro
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          aluno['turma'] ?? 'Sem turma',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(
                                              0xFFE74C3C,
                                            ), // Texto vermelho diretor
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
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
                                                  : Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            ativo ? 'ativo' : 'inativo',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: PopupMenuButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.grey[600],
                                        ),
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'editar',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 18),
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
                                                  size: 18,
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

                        // Footer paginação
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${alunos.length} itens',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE74C3C,
                                      ), // Vermelho diretor
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '10 / página',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
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
          ),

          const SizedBox(height: 40),
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
