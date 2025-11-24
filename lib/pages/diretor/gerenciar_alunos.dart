import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
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
    return LayoutBase(
      titulo: 'Gerenciar Alunos',
      corPrincipal: MenuConfig.corDiretor,
      itensMenu: MenuConfig.menuDiretor,
      itemSelecionadoId: 'alunos',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Alunos', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtros
          isMobile ? _buildMobileFilters() : _buildDesktopFilters(),
          const SizedBox(height: 24),

          // Tabela/Lista
          Expanded(child: _buildTableContent()),
        ],
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome, email ou RA',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) =>
                setState(() => _termoBusca = value.toLowerCase()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _statusFiltro,
            decoration: InputDecoration(
              labelText: 'Status',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: ['Sem filtro', 'Ativo', 'Inativo']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _statusFiltro = v!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: StreamBuilder<List<Turma>>(
            stream: _turmaService.buscarTurmasAtivas(),
            builder: (context, snapshot) {
              List<String> turmas = ['Selecione'];
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                turmas.addAll(snapshot.data!.map((t) => t.nome).toList());
              }
              return DropdownButtonFormField<String>(
                value: _turmaFiltro,
                decoration: InputDecoration(
                  labelText: 'Turma',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: turmas
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _turmaFiltro = v!),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushReplacementNamed(
              context, '/diretor/cadastrar-aluno'),
          icon: const Icon(Icons.add),
          label: const Text('Novo Aluno'),
          style: ElevatedButton.styleFrom(
            backgroundColor: MenuConfig.corDiretor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        TextField(
          controller: _buscaController,
          decoration: InputDecoration(
            hintText: 'Buscar por nome',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) =>
              setState(() => _termoBusca = value.toLowerCase()),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _statusFiltro,
          decoration: InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: ['Sem filtro', 'Ativo', 'Inativo']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _statusFiltro = v!),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Turma>>(
          stream: _turmaService.buscarTurmasAtivas(),
          builder: (context, snapshot) {
            List<String> turmas = ['Selecione'];
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              turmas.addAll(snapshot.data!.map((t) => t.nome).toList());
            }
            return DropdownButtonFormField<String>(
              value: _turmaFiltro,
              decoration: InputDecoration(
                labelText: 'Turma',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: turmas
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _turmaFiltro = v!),
            );
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushReplacementNamed(
              context, '/diretor/cadastrar-aluno'),
          icon: const Icon(Icons.add),
          label: const Text('Novo Aluno'),
          style: ElevatedButton.styleFrom(
            backgroundColor: MenuConfig.corDiretor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildTableContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('tipo', isEqualTo: 'aluno')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
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
              !ra.contains(_termoBusca)) return false;
          if (_statusFiltro == 'Ativo' && !ativo) return false;
          if (_statusFiltro == 'Inativo' && ativo) return false;
          if (_turmaFiltro != 'Selecione' && turma != _turmaFiltro)
            return false;

          return true;
        }).toList();

        if (alunos.isEmpty) {
          return const Center(child: Text('Nenhum aluno encontrado'));
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        if (isMobile) {
          return ListView.separated(
            itemCount: alunos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final aluno = alunos[index].data() as Map<String, dynamic>;
              final id = alunos[index].id;
              final ativo = aluno['ativo'] ?? true;
              return _buildMobileAlunoCard(id, aluno, ativo);
            },
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text('Nome',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text('Email',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('RA',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('Turma',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('Status',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
                // Linhas
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
                      return _buildDesktopAlunoRow(id, aluno, ativo);
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDesktopAlunoRow(
      String id, Map<String, dynamic> aluno, bool ativo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(aluno['nome'] ?? '-')),
          Expanded(flex: 2, child: Text(aluno['email'] ?? '-')),
          Expanded(child: Text(aluno['ra'] ?? '-')),
          Expanded(
            child: Text(
              aluno['turma'] ?? 'Sem turma',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  ativo ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: ativo ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(ativo ? 'Ativo' : 'Inativo'),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: PopupMenuButton(
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
  }

  Widget _buildMobileAlunoCard(
      String id, Map<String, dynamic> aluno, bool ativo) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    aluno['nome'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(
                      value: 'excluir',
                      child:
                          Text('Excluir', style: TextStyle(color: Colors.red)),
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
              ],
            ),
            Text(aluno['email'] ?? '-',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('RA: ',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(aluno['ra'] ?? '-', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                Icon(ativo ? Icons.check_circle : Icons.cancel,
                    size: 14, color: ativo ? Colors.green : Colors.grey),
                const SizedBox(width: 4),
                Text(ativo ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                        fontSize: 12,
                        color: ativo ? Colors.green : Colors.grey)),
              ],
            ),
          ],
        ),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: raCtrl,
                    decoration: const InputDecoration(labelText: 'RA'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
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
                                (t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setStateDialog(() => turma = v!),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Ativo'),
                    value: ativo,
                    onChanged: (v) => setStateDialog(() => ativo = v),
                  ),
                ],
              ),
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
                  backgroundColor: MenuConfig.corDiretor),
              child:
                  const Text('Salvar', style: TextStyle(color: Colors.white)),
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
