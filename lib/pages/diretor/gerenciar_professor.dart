import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';

class ProfessoresDiretor extends StatefulWidget {
  const ProfessoresDiretor({super.key});

  @override
  State<ProfessoresDiretor> createState() => _ProfessoresDiretorState();
}

class _ProfessoresDiretorState extends State<ProfessoresDiretor> {
  final TextEditingController _buscaController = TextEditingController();
  String _statusFiltro = 'Sem filtro';
  String _termoBusca = '';

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Gerenciar Professores',
      corPrincipal: MenuConfig.corDiretor,
      itensMenu: MenuConfig.menuDiretor,
      itemSelecionadoId: 'professores',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Professores', isAtivo: true),
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
              hintText: 'Buscar por nome, email ou CPF',
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
        ElevatedButton.icon(
          onPressed: () => Navigator.pushReplacementNamed(
              context, '/diretor/cadastrar-professor'),
          icon: const Icon(Icons.add),
          label: const Text('Novo Professor'),
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
          ),
          items: ['Sem filtro', 'Ativo', 'Inativo']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _statusFiltro = v!),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushReplacementNamed(
              context, '/diretor/cadastrar-professor'),
          icon: const Icon(Icons.add),
          label: const Text('Novo Professor'),
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
          .where('tipo', isEqualTo: 'professor')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
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

          if (_termoBusca.isNotEmpty &&
              !nome.contains(_termoBusca) &&
              !email.contains(_termoBusca) &&
              !cpf.contains(_termoBusca)) return false;
          if (_statusFiltro == 'Ativo' && !ativo) return false;
          if (_statusFiltro == 'Inativo' && ativo) return false;

          return true;
        }).toList();

        if (professores.isEmpty) {
          return const Center(child: Text('Nenhum professor encontrado'));
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        if (isMobile) {
          return ListView.separated(
            itemCount: professores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final professor =
                  professores[index].data() as Map<String, dynamic>;
              final id = professores[index].id;
              final ativo = professor['ativo'] ?? true;
              return _buildMobileProfessorCard(id, professor, ativo);
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
                          child: Text('CPF',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text('Perfil',
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
                    itemCount: professores.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, index) {
                      final professor =
                          professores[index].data() as Map<String, dynamic>;
                      final id = professores[index].id;
                      final ativo = professor['ativo'] ?? true;
                      return _buildDesktopProfessorRow(id, professor, ativo);
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

  Widget _buildDesktopProfessorRow(
      String id, Map<String, dynamic> professor, bool ativo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(professor['nome'] ?? '-')),
          Expanded(
            flex: 2,
            child: Text(
              professor['email'] ?? '-',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Expanded(child: Text(professor['cpf'] ?? '-')),
          Expanded(
            child: Text(
              professor['perfil'] ?? 'Professor',
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
                  _mostrarDialogEditar(id, professor);
                } else {
                  _excluirProfessor(id, professor['nome']);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProfessorCard(
      String id, Map<String, dynamic> professor, bool ativo) {
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
                    professor['nome'] ?? '-',
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
                      _mostrarDialogEditar(id, professor);
                    } else {
                      _excluirProfessor(id, professor['nome']);
                    }
                  },
                ),
              ],
            ),
            Text(
              professor['email'] ?? '-',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('CPF: ',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(professor['cpf'] ?? '-',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                Icon(
                  ativo ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: ativo ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  ativo ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                      fontSize: 12, color: ativo ? Colors.green : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogEditar(String id, Map<String, dynamic> professor) {
    final nomeCtrl = TextEditingController(text: professor['nome']);
    final cpfCtrl = TextEditingController(text: professor['cpf']);
    final emailCtrl = TextEditingController(text: professor['email']);
    String perfil = professor['perfil'] ?? 'Professor';
    bool ativo = professor['ativo'] ?? true;
    List<String> materiasSelecionadas =
        List<String>.from(professor['materias'] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Professor'),
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
                    controller: cpfCtrl,
                    decoration: const InputDecoration(labelText: 'CPF'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: perfil,
                    decoration: const InputDecoration(labelText: 'Perfil'),
                    items: ['Professor', 'Coordenador']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => perfil = v!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Ativo'),
                    value: ativo,
                    onChanged: (v) => setStateDialog(() => ativo = v),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Matérias',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('materias')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final materias = snapshot.data!.docs;

                      if (materias.isEmpty) {
                        return const Text('Nenhuma matéria cadastrada');
                      }

                      return Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: materias.length,
                          itemBuilder: (context, index) {
                            final materia =
                                materias[index].data() as Map<String, dynamic>;
                            final materiaNome = materia['nome'] ?? '';
                            final isSelected =
                                materiasSelecionadas.contains(materiaNome);

                            return CheckboxListTile(
                              title: Text(materiaNome),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  if (value == true) {
                                    materiasSelecionadas.add(materiaNome);
                                  } else {
                                    materiasSelecionadas.remove(materiaNome);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      );
                    },
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
                  'cpf': cpfCtrl.text,
                  'email': emailCtrl.text,
                  'perfil': perfil,
                  'ativo': ativo,
                  'materias': materiasSelecionadas,
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
