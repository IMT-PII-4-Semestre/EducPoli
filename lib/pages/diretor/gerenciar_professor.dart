import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/turma_service.dart';
import '../../models/turma.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

// DESIGN 
const double _kAppBarHeight = 80.0;
const Color _primaryRed = Color(0xFFE74C3C);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class ProfessoresDiretor extends StatefulWidget {
  const ProfessoresDiretor({super.key});

  @override
  State<ProfessoresDiretor> createState() => _ProfessoresDiretorState();
}

class _ProfessoresDiretorState extends State<ProfessoresDiretor> {
  final TextEditingController _buscaController = TextEditingController();
  String _statusFiltro = 'Sem filtro';
  String _perfilFiltro = 'Selecione';
  String _termoBusca = '';

  // Menu Lateral
  final String _selectedNavItemId = 'professores'; 
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Alunos', 'icon': Icons.person, 'id': 'alunos'},
    {'title': 'Professores', 'icon': Icons.person_3, 'id': 'professores'},
  ];

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !_isMobile(context);

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // APP BAR 
      appBar: AppBar(
        backgroundColor: _primaryRed,
        elevation: 0,
        toolbarHeight: _kAppBarHeight,
        centerTitle: true,
        title: const Text(
          'Professores Cadastrados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      drawer: isDesktop ? null : _buildMobileDrawer(),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BARRA LATERAL
          if (isDesktop) SizedBox(width: 280, child: _buildSidebarContent()),

          // CONTEÚDO
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtros
                  isDesktop ? _buildDesktopFilters() : _buildMobileFilters(),
                  const SizedBox(height: 24),
                  // Tabela
                  _buildTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BARRA LATERAL DINÂMICA 
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        // HEADER VERMELHO COM DADOS DO FIREBASE
        Container(
          width: double.infinity,
          color: const Color(0xFFE74C3C), // Vermelho do Diretor
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Diretor";

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Diretor";
                } else {
                   nomeExibicao = "Diretor";
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ÍCONE DO DIRETOR (PADRÃO DASHBOARD)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    // O ÍCONE PADRÃO DO DASHBOARD DO DIRETOR
                    child: const Icon(Icons.admin_panel_settings, size: 32, color: Colors.white), 
                  ),
                  const SizedBox(height: 12),
                  
                  // NOME DINÂMICO
                  Text(
                    nomeExibicao,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // CARGO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cargoExibicao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // LISTA DE ITENS DO MENU
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = item['id'] == _selectedNavItemId;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                       if (item['id'] == 'alunos') {
                         if (_selectedNavItemId == 'alunos' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'alunos') Navigator.pushNamed(context, '/diretor/alunos');
                       } else if (item['id'] == 'professores') {
                         if (_selectedNavItemId == 'professores' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'professores') Navigator.pushNamed(context, '/diretor/professores');
                       }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF5F5) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? const Color(0xFFE74C3C) : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? const Color(0xFFE74C3C) : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer() => Drawer(child: _buildSidebarContent());

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _termoBusca = value.toLowerCase()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _statusFiltro,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: ['Sem filtro', 'Ativo', 'Inativo'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _statusFiltro = v!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _perfilFiltro,
            decoration: InputDecoration(
              labelText: 'Perfil/Atribuição',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: ['Selecione', 'Professor', 'Coordenador'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => _perfilFiltro = v!),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/diretor/cadastrar-professor'),
          icon: const Icon(Icons.add),
          label: const Text('Novo professor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          onChanged: (value) => setState(() => _termoBusca = value.toLowerCase()),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _statusFiltro,
          decoration: InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: ['Sem filtro', 'Ativo', 'Inativo'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _statusFiltro = v!),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _perfilFiltro,
          decoration: InputDecoration(
            labelText: 'Perfil/Atribuição',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: ['Selecione', 'Professor', 'Coordenador'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) => setState(() => _perfilFiltro = v!),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/diretor/cadastrar-professor'),
          icon: const Icon(Icons.add),
          label: const Text('Novo professor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: _buildTableContent(),
    );
  }

  Widget _buildMobileList() {
    return _buildTableContent();
  }

  Widget _buildTableContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').where('tipo', isEqualTo: 'professor').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var professores = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nome = (data['nome'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final cpf = (data['cpf'] ?? '').toString().toLowerCase();
          final ativo = data['ativo'] ?? true;
          final perfil = data['perfil'] ?? '';

          if (_termoBusca.isNotEmpty && !nome.contains(_termoBusca) && !email.contains(_termoBusca) && !cpf.contains(_termoBusca)) return false;
          if (_statusFiltro == 'Ativo' && !ativo) return false;
          if (_statusFiltro == 'Inativo' && ativo) return false;
          if (_perfilFiltro != 'Selecione' && perfil != _perfilFiltro) return false;

          return true;
        }).toList();

        if (professores.isEmpty) return const Center(child: Text('Nenhum professor encontrado'));

        final isMobile = _isMobile(context);

        if (isMobile) {
          return ListView.separated(
            itemCount: professores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final professor = professores[index].data() as Map<String, dynamic>;
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: Colors.grey[50],
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('E-mail', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('CPF', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Perfil/Atribuição', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: professores.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final professor = professores[index].data() as Map<String, dynamic>;
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

  Widget _buildDesktopProfessorRow(String id, Map<String, dynamic> professor, bool ativo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(professor['nome'] ?? '-')),
          Expanded(flex: 2, child: Text(professor['email'] ?? '-', style: TextStyle(color: Colors.grey[700]))),
          Expanded(child: Text(professor['cpf'] ?? '-')),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Text(professor['perfil'] ?? 'Professor', style: const TextStyle(fontSize: 12, color: _primaryRed)),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: ativo ? Colors.green : Colors.grey, shape: BoxShape.circle)),
                const SizedBox(width: 8),
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
                const PopupMenuItem(value: 'excluir', child: Text('Excluir', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (value) {
                if (value == 'editar') _mostrarDialogEditar(id, professor);
                else _excluirProfessor(id, professor['nome']);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProfessorCard(String id, Map<String, dynamic> professor, bool ativo) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(professor['nome'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(value: 'excluir', child: Text('Excluir', style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') _mostrarDialogEditar(id, professor);
                    else _excluirProfessor(id, professor['nome']);
                  },
                ),
              ],
            ),
            Text(professor['email'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(4)),
                  child: Text(professor['perfil'] ?? 'Professor', style: const TextStyle(fontSize: 11, color: _primaryRed)),
                ),
                const Spacer(),
                Text(ativo ? 'Ativo' : 'Inativo', style: TextStyle(fontSize: 12, color: ativo ? Colors.green : Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MÉTODOS DE EDIÇÃO E EXCLUSÃO 
  void _mostrarDialogEditar(String id, Map<String, dynamic> professor) {
    final nomeCtrl = TextEditingController(text: professor['nome']);
    final cpfCtrl = TextEditingController(text: professor['cpf']);
    final emailCtrl = TextEditingController(text: professor['email']);
    String perfil = professor['perfil'] ?? 'Professor';
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
                TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome')),
                TextField(controller: cpfCtrl, decoration: const InputDecoration(labelText: 'CPF')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: perfil,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: ['Professor', 'Coordenador'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setStateDialog(() => perfil = v!),
                ),
                Row(
                  children: [
                    const Text('Status:'),
                    Switch(value: ativo, onChanged: (v) => setStateDialog(() => ativo = v)),
                    Text(ativo ? 'Ativo' : 'Inativo'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('usuarios').doc(id).update({
                  'nome': nomeCtrl.text,
                  'cpf': cpfCtrl.text,
                  'email': emailCtrl.text,
                  'perfil': perfil,
                  'ativo': ativo,
                });
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryRed),
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('usuarios').doc(id).delete();
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