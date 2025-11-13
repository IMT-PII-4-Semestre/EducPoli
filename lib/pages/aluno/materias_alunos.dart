import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalhes_materias_alunos.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

// DESIGN 
const double _kAppBarHeight = 80.0; 
const Color _primaryBlue = Color(0xFF7DD3FC);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class MateriasAluno extends StatefulWidget {
  const MateriasAluno({super.key});

  @override
  State<MateriasAluno> createState() => _MateriasAlunoState();
}

class _MateriasAlunoState extends State<MateriasAluno> {
  
  final String _selectedNavItemId = 'subjects'; 

  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Matérias', 'icon': Icons.book, 'id': 'subjects'}, 
    {'title': 'Mensagem', 'icon': Icons.chat_bubble_outline, 'id': 'messages'},
    {'title': 'Notas', 'icon': Icons.assignment_outlined, 'id': 'notes'},
  ]; 

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        toolbarHeight: _kAppBarHeight,
        centerTitle: true,
        title: const Text(
          'Matérias', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Inter', 
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [], 
      ),
      
      drawer: isDesktop ? null : _buildMobileDrawer(),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BARRA LATERAL
          if (isDesktop) 
            SizedBox(
              width: 280, 
              child: _buildSidebarContent(),
            ),

          // CONTEÚDO
          Expanded(
            child: Container(
              color: Colors.white, 
              child: _buildSubjectsGrid(isDesktop),
            ),
          ),
        ],
      ),
    );
  }

  // BARRA LATERAL DINÂMICA DO ALUNO (CONECTADA)
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 700; 

    return Column(
      children: [
        // HEADER COM DADOS DO FIREBASE
        Container(
          width: double.infinity,
          color: _primaryBlue, // Azul do Aluno
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            // Busca os dados do usuário logado
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Aluno"; 

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Aluno";
                } else {
                   nomeExibicao = "Aluno";
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FOTO / ÍCONE (COM SOMBRA)
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
                    // Ícone de Pessoa (Padrão do Dashboard do Aluno)
                    child: const Icon(Icons.person, size: 32, color: Colors.white), 
                  ),
                  const SizedBox(height: 12),
                  
                  // NOME DO ALUNO (DINÂMICO)
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
                  
                  // CARGO (TAG)
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
                      // Lógica de Navegação do Aluno
                      if (item['id'] == 'subjects') {
                         if (_selectedNavItemId == 'subjects' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'subjects') Navigator.pushNamed(context, '/aluno/materias');
                      } else if (item['id'] == 'messages') {
                         if (_selectedNavItemId == 'messages' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'messages') Navigator.pushNamed(context, '/aluno/mensagem');
                      } else if (item['id'] == 'notes') {
                         if (_selectedNavItemId == 'notes' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'notes') Navigator.pushNamed(context, '/aluno/notas');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        // Se selecionado: fundo azul bem clarinho e borda azul
                        color: isSelected ? const Color(0xFFE1F0FF) : _menuItemBg,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: _primaryBlue.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? _primaryBlue : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _primaryBlue : Colors.black87,
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

  Widget _buildMobileDrawer() {
    return Drawer(
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSubjectsGrid(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('materias').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar.'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('Nenhuma matéria encontrada.'));

          return GridView.builder(
            itemCount: docs.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 2.0,
            ),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFFF0F0F0),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesMateriaAluno(
                          materiaId: docs[index].id,
                          nomeMateria: data['nome'] ?? 'Sem nome',
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      data['nome'] ?? 'Matéria',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}