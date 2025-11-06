import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/materias_service.dart';

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

  bool get isMobile => MediaQuery.of(context).size.width < 800;

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
                      'Professores cadastrados',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Título
                const Text(
                  'Professores cadastrados',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Relação de professores cadastrados',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // FILTROS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 40.0),
            child: isMobile ? _buildMobileFilters() : _buildDesktopFilters(),
          ),

          const SizedBox(height: 24),

          // TABELA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .where('tipo', isEqualTo: 'professor')
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

                  var professores = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nome = (data['nome'] ?? '').toString().toLowerCase();
                    final email =
                        (data['email'] ?? '').toString().toLowerCase();
                    final cpf = (data['cpf'] ?? '').toString().toLowerCase();
                    final ativo = data['ativo'] ?? true;
                    final materias = List<String>.from(data['materias'] ?? []);

                    if (_termoBusca.isNotEmpty &&
                        !nome.contains(_termoBusca) &&
                        !email.contains(_termoBusca) &&
                        !cpf.contains(_termoBusca)) return false;

                    if (_statusFiltro == 'Ativo' && !ativo) return false;
                    if (_statusFiltro == 'Inativo' && ativo) return false;

                    if (_disciplinaFiltro != 'Selecione' &&
                        !materias.contains(_disciplinaFiltro)) {
                      return false;
                    }

                    return true;
                  }).toList();

                  if (professores.isEmpty) {
                    return const Center(
                      child: Text('Nenhum professor encontrado'),
                    );
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
                                  'CPF',
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

                        // Lista de professores
                        Expanded(
                          child: ListView.separated(
                            itemCount: professores.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (context, index) {
                              final professor = professores[index].data()
                                  as Map<String, dynamic>;
                              final id = professores[index].id;
                              final ativo = professor['ativo'] ?? true;

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
                                        professor['nome'] ?? '-',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        professor['email'] ?? '-',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        professor['cpf'] ?? '-',
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
                                          color: const Color(0xFFFFF5F5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFFCDD2),
                                            width: 1,
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Wrap(
                                            spacing: 3,
                                            children: (professor['materias']
                                                            as List<dynamic>? ??
                                                        [])
                                                    .isEmpty
                                                ? [
                                                    const SizedBox(
                                                      height: 24,
                                                      child: Center(
                                                        child: Text(
                                                          'Sem matérias',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFFE74C3C),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                : (professor['materias']
                                                            as List<dynamic>)
                                                        .take(3)
                                                        .map<Widget>((m) =>
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 5,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3),
                                                              ),
                                                              child: Text(
                                                                m.toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ))
                                                        .toList() +
                                                    [
                                                      if ((professor['materias']
                                                                  as List<
                                                                      dynamic>)
                                                              .length >
                                                          3)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 5,
                                                            vertical: 2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[400],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                          ),
                                                          child: Text(
                                                            '+${(professor['materias'] as List<dynamic>).length - 3}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
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
                                'Total: ${professores.length} itens',
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
                                      color: const Color(0xFFE74C3C),
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

  Widget _buildMobileFilters() {
    return Column(
      children: [
        // Busca
        TextField(
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
        const SizedBox(height: 16),

        // Status
        DropdownButtonFormField<String>(
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
          items: [
            'Sem filtro',
            'Ativo',
            'Inativo',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _statusFiltro = v!),
        ),
        const SizedBox(height: 16),

        // Disciplina
        FutureBuilder<List<String>>(
          future: MateriasService.obterMateriasDisponiveis(),
          builder: (context, snapshot) {
            List<String> disciplinas = ['Selecione'];

            if (snapshot.hasData) {
              disciplinas.addAll(snapshot.data ?? []);
            }

            // Garante que o valor selecionado está na lista
            String valorFiltro = _disciplinaFiltro;
            if (!disciplinas.contains(_disciplinaFiltro)) {
              valorFiltro = 'Selecione';
            }

            return DropdownButtonFormField<String>(
              value: valorFiltro,
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
              items: disciplinas
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _disciplinaFiltro = v!),
            );
          },
        ),
        const SizedBox(height: 16),

        // Botão Novo
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, '/diretor/cadastrar-professor'),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text(
            'Novo professor',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF5F5),
            foregroundColor: const Color(0xFFE74C3C),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFFFCDD2), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
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
            items: [
              'Sem filtro',
              'Ativo',
              'Inativo',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _statusFiltro = v!),
          ),
        ),
        const SizedBox(width: 16),

        // Disciplina
        Expanded(
          flex: 2,
          child: FutureBuilder<List<String>>(
            future: MateriasService.obterMateriasDisponiveis(),
            builder: (context, snapshot) {
              List<String> disciplinas = ['Selecione'];

              if (snapshot.hasData) {
                disciplinas.addAll(snapshot.data ?? []);
              }

              // Garante que o valor selecionado está na lista
              String valorFiltro = _disciplinaFiltro;
              if (!disciplinas.contains(_disciplinaFiltro)) {
                valorFiltro = 'Selecione';
              }

              return DropdownButtonFormField<String>(
                value: valorFiltro,
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
                items: disciplinas
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _disciplinaFiltro = v!),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Botão Novo
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, '/diretor/cadastrar-professor'),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text(
            'Novo professor',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF5F5),
            foregroundColor: const Color(0xFFE74C3C),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFFFCDD2), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarDialogEditar(String id, Map<String, dynamic> professor) {
    final nomeCtrl = TextEditingController(text: professor['nome']);
    final cpfCtrl = TextEditingController(text: professor['cpf']);
    final emailCtrl = TextEditingController(text: professor['email']);
    bool ativo = professor['ativo'] ?? true;

    Set<String> materiasSelecionadas =
        Set<String>.from(professor['materias'] ?? []);

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
                  TextField(
                    controller: cpfCtrl,
                    decoration: const InputDecoration(labelText: 'CPF'),
                  ),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Matérias que leciona *',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: materiasSelecionadas.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Selecione pelo menos uma matéria',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: materiasSelecionadas.map((materia) {
                                return Chip(
                                  label: Text(materia),
                                  onDeleted: () {
                                    setStateDialog(() =>
                                        materiasSelecionadas.remove(materia));
                                  },
                                  backgroundColor:
                                      const Color(0xFFE74C3C).withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFE74C3C),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: FutureBuilder<List<String>>(
                      future: MateriasService.obterMateriasDisponiveis(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Erro: ${snapshot.error}'),
                          );
                        }

                        final materias = snapshot.data ?? [];

                        if (materias.isEmpty) {
                          return const Center(
                            child: Text('Nenhuma matéria disponível'),
                          );
                        }

                        return ListView.builder(
                          itemCount: materias.length,
                          itemBuilder: (context, index) {
                            final materia = materias[index];
                            final selecionada =
                                materiasSelecionadas.contains(materia);

                            return CheckboxListTile(
                              value: selecionada,
                              onChanged: (value) {
                                setStateDialog(() {
                                  if (value == true) {
                                    materiasSelecionadas.add(materia);
                                  } else {
                                    materiasSelecionadas.remove(materia);
                                  }
                                });
                              },
                              title: Text(materia),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            );
                          },
                        );
                      },
                    ),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (materiasSelecionadas.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecione pelo menos uma matéria'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(id)
                    .update({
                  'nome': nomeCtrl.text,
                  'cpf': cpfCtrl.text,
                  'email': emailCtrl.text,
                  'materias': materiasSelecionadas.toList(),
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
