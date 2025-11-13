import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'detalhes_materia_professor.dart'; 

// DESIGN PROFESSOR 
const double _kAppBarHeight = 80.0;
const Color _primaryOrange = Color(0xFFFF9500);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class MateriasProfessor extends StatefulWidget {
  const MateriasProfessor({super.key});

  @override
  State<MateriasProfessor> createState() => _MateriasProfessorState();
}

class _MateriasProfessorState extends State<MateriasProfessor> {
  // LÓGICA DE PERFIL
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _minhasMaterias = []; // Lista local para filtrar
  bool _carregandoPerfil = true;

  // MENU LATERAL 
  final String _selectedNavItemId = 'materias'; 
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Matérias', 'icon': Icons.book, 'id': 'materias'},
    {'title': 'Mensagem', 'icon': Icons.message, 'id': 'mensagem'},
    {'title': 'Notas', 'icon': Icons.assignment, 'id': 'notas'},
  ];

  @override
  void initState() {
    super.initState();
    _carregarPerfilProfessor();
  }

  // 1. Busca quais matérias este professor pode ver/editar
  Future<void> _carregarPerfilProfessor() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Pega o array 'materias' do perfil do usuário
        final listaDoPerfil = List<String>.from(data['materias'] ?? []);
        
        if (mounted) {
          setState(() {
            _minhasMaterias = listaDoPerfil;
            _carregandoPerfil = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      if (mounted) setState(() => _carregandoPerfil = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: _primaryOrange,
        elevation: 0,
        toolbarHeight: _kAppBarHeight,
        centerTitle: true,
        title: const Text(
          'Gerenciar Matérias',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Inter',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _mostrarDialogAdicionarMateria(context),
            icon: const Icon(Icons.add_circle_outline, size: 30),
            tooltip: 'Nova Matéria',
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      drawer: isDesktop ? null : _buildMobileDrawer(),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BARRA LATERAL
          if (isDesktop) 
            SizedBox(width: 280, child: _buildSidebarContent()),

          // CONTEÚDO
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: _carregandoPerfil 
                  ? const Center(child: CircularProgressIndicator())
                  : _buildListaMaterias(),
            ),
          ),
        ],
      ),
    );
  }

  // LISTA FILTRADA 
  Widget _buildListaMaterias() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('materias').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar matérias'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final todasMaterias = snapshot.data?.docs ?? [];

        // FILTRO INTELIGENTE:
        // Compara o nome da matéria no banco com a lista '_minhasMaterias' do professor
        final materiasFiltradas = todasMaterias.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nomeMateria = data['nome'] ?? '';
          return _minhasMaterias.contains(nomeMateria);
        }).toList();

        if (materiasFiltradas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Você não possui matérias vinculadas', style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text('Adicione uma nova ou peça ao diretor', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: materiasFiltradas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final materiaDoc = materiasFiltradas[index];
            final materia = materiaDoc.data() as Map<String, dynamic>;
            final materiaNome = materia['nome'] ?? 'Sem nome';
            final materiaId = materiaDoc.id;
            
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF3E0), // Laranja bem claro
                  child: Icon(Icons.book, color: _primaryOrange),
                ),
                title: Text(materiaNome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(materia['descricao'] ?? 'Sem descrição'),

                onTap: () {
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
                      onPressed: () => _editarMateria(context, materiaId, materia),
                      icon: Icon(Icons.edit, color: Colors.grey[700]), // Cor Neutra
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: () => _excluirMateria(context, materiaId, materiaNome), 
                      icon: Icon(Icons.delete, color: Colors.grey[700]), // Cor Neutra
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- BARRA LATERAL DINÂMICA (ATUALIZADA) ---
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    // Verificação de desktop para a lógica de fechar o drawer ou navegar
    final isDesktop = MediaQuery.of(context).size.width > 800; 

    return Column(
      children: [
        // HEADER COM DADOS E ÍCONE PADRONIZADO
        Container(
          width: double.infinity,
          color: _primaryOrange,
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Professor"; 

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Professor";
                } else {
                   nomeExibicao = "Professor";
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ÁREA DA FOTO (COM ÍCONE DE FORMATURA PADRONIZADO)
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
                    child: const Icon(Icons.school, size: 32, color: Colors.white), 
                  ),
                  const SizedBox(height: 12),
                  
                  // NOME COM SOMBRA
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

        // LISTA DE ITENS
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
                      // Lógica de navegação
                      if (item['id'] == 'materias') {
                         if (_selectedNavItemId == 'materias' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'materias') Navigator.pushNamed(context, '/professor/materias');
                      } else if (item['id'] == 'mensagem') {
                         if (_selectedNavItemId == 'mensagem' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'mensagem') Navigator.pushNamed(context, '/professor/mensagem');
                      } else if (item['id'] == 'notas') {
                         if (_selectedNavItemId == 'notas' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'notas') Navigator.pushNamed(context, '/professor/notas');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF3E0) : _menuItemBg,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: _primaryOrange.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? _primaryOrange : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _primaryOrange : Colors.black87,
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

  // FUNÇÕES CRUD PARA SINCRONIZAR PERFIL 

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
                final nomeMateria = nomeController.text.trim();
                
                // 1. Adiciona na coleção global 'materias'
                await FirebaseFirestore.instance.collection('materias').add({
                  'nome': nomeMateria,
                  'descricao': descricaoController.text.trim(),
                  'criadoEm': DateTime.now(),
                });

                // 2. Adiciona no perfil do professor logado (Sincronização)
                final uid = _auth.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
                    'materias': FieldValue.arrayUnion([nomeMateria])
                  });
                  
                  // Atualiza estado local para aparecer na lista imediatamente
                  setState(() {
                    _minhasMaterias.add(nomeMateria);
                  });
                }

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
            child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editarMateria(BuildContext context, String id, Map<String, dynamic> materia) {
    
    final nomeController = TextEditingController(text: materia['nome']); // Read-only idealmente
    final descricaoController = TextEditingController(text: materia['descricao']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Matéria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome (Cuidado ao alterar)'),
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
              // Se mudou o nome, precisamos atualizar o perfil do professor também
              final novoNome = nomeController.text.trim();
              final antigoNome = materia['nome'];
              
              await FirebaseFirestore.instance
                  .collection('materias')
                  .doc(id)
                  .update({
                    'nome': novoNome,
                    'descricao': descricaoController.text.trim(),
                  });
              
              // Atualiza array do professor se nome mudou
              if (novoNome != antigoNome) {
                 final uid = _auth.currentUser?.uid;
                 if (uid != null) {
                   // Remove antigo e adiciona novo
                   final userRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);
                   await userRef.update({
                     'materias': FieldValue.arrayRemove([antigoNome])
                   });
                   await userRef.update({
                     'materias': FieldValue.arrayUnion([novoNome])
                   });
                   
                   setState(() {
                     _minhasMaterias.remove(antigoNome);
                     _minhasMaterias.add(novoNome);
                   });
                 }
              }

              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _excluirMateria(BuildContext context, String id, String nomeMateria) {
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
              // 1. Remove da coleção global
              await FirebaseFirestore.instance
                  .collection('materias')
                  .doc(id)
                  .delete();
              
              // 2. Remove do perfil do professor
              final uid = _auth.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
                  'materias': FieldValue.arrayRemove([nomeMateria])
                });
                setState(() {
                  _minhasMaterias.remove(nomeMateria);
                });
              }

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