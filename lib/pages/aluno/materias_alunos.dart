import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importaremos a nova tela aqui
import 'detalhes_materias_alunos.dart'; // Você precisará criar este arquivo

// Cores baseadas no código original (azul claro)
const Color _primaryColor = Color(0xFF7DD3FC); 
const Color _sidebarBackgroundColor = Color(0xFFEBEBEB); 
const Color _cardBackgroundColor = Color(0xFFF0F0F0); 
const double _desktopBreakpoint = 700;
const double _maxContentWidth = 1000;

// ====================================================================
// Itens de navegação (simplificados)
// ====================================================================
const List<Map<String, dynamic>> _navItems = [
  {'title': 'Matérias', 'icon': Icons.book, 'id': 'subjects'},
  {'title': 'Arquivos', 'icon': Icons.folder_open, 'id': 'files'},
  {'title': 'Mensagem', 'icon': Icons.mail_outline, 'id': 'messages'},
  {'title': 'Notas', 'icon': Icons.description_outlined, 'id': 'notes'},
];

// ====================================================================
// PlaceholderScreen (mantida)
// ====================================================================
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Conteúdo desta seção será implementado aqui.'),
        ],
      ),
    );
  }
}

// ====================================================================
// Classe Principal: MateriasAluno
// ====================================================================
class MateriasAluno extends StatefulWidget {
  const MateriasAluno({super.key});

  @override
  State<MateriasAluno> createState() => _MateriasAlunoState();
}

class _MateriasAlunoState extends State<MateriasAluno> {
  String _selectedNavItemId = 'subjects';

  Widget _getCurrentScreenContent({required bool isDesktopLayout}) {
    switch (_selectedNavItemId) {
      case 'subjects':
        final int columns = isDesktopLayout ? 4 : 2;
        return _buildContentGrid(columns, isDesktopLayout); // Passando isDesktopLayout
      case 'files':
        return const PlaceholderScreen(title: 'Arquivos');
      case 'messages':
        return const PlaceholderScreen(title: 'Mensagens');
      case 'notes':
        return const PlaceholderScreen(title: 'Notas');
      default:
        return const PlaceholderScreen(title: 'Erro de Navegação');
    }
  }

  String _getCurrentTitle() {
    final item = _navItems.firstWhere(
      (item) => item['id'] == _selectedNavItemId,
      orElse: () => {'title': 'App'},
    );
    return item['title'] as String;
  }

  // ... (métodos build, _buildAppBar, _buildBody, _buildDesktopLayout, _buildSideNav, _buildDrawer) ...
  
  // (Mantendo os métodos de layout responsivo)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: MediaQuery.of(context).size.width < _desktopBreakpoint 
          ? _buildDrawer(context) 
          : null,
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        _getCurrentTitle(),
        style: const TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      backgroundColor: _primaryColor, 
      elevation: 0, 
      foregroundColor: Colors.black,
      
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.account_circle, size: 28),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > _desktopBreakpoint) {
          return _buildDesktopLayout();
        } 
        else {
          return _getCurrentScreenContent(isDesktopLayout: false);
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSideNav(),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: SingleChildScrollView( 
                child: _getCurrentScreenContent(isDesktopLayout: true), 
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 250,
      color: _sidebarBackgroundColor, 
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        itemCount: _navItems.length,
        itemBuilder: (context, index) {
          final item = _navItems[index];
          final isSelected = item['id'] == _selectedNavItemId;
          
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: isSelected ? Colors.black : Colors.black54,
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedNavItemId = item['id'] as String;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: _sidebarBackgroundColor,
        child: ListView.builder(
          itemCount: _navItems.length,
          itemBuilder: (context, index) {
            final item = _navItems[index];
            final isSelected = item['id'] == _selectedNavItemId;
            
            return ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: isSelected ? Colors.black : Colors.black54,
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.black54,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedNavItemId = item['id'] as String;
                });
                Navigator.pop(context); 
              },
            );
          },
        ),
      ),
    );
  }


  // ====================================================================
  // MÉTODO MODIFICADO: _buildContentGrid (com StreamBuilder)
  // ====================================================================

  Widget _buildContentGrid(int crossAxisCount, bool isDesktopLayout) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32.0),
      // StreamBuilder para buscar as matérias do Firestore
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('materias').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar matérias.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final materias = snapshot.data?.docs ?? [];
          
          if (materias.isEmpty) {
            return const Center(child: Text('Nenhuma matéria encontrada.'));
          }

          return GridView.builder(
            shrinkWrap: isDesktopLayout, 
            physics: isDesktopLayout ? const NeverScrollableScrollPhysics() : null,
            
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, 
              crossAxisSpacing: 32.0,
              mainAxisSpacing: 32.0,
              childAspectRatio: 2.0,
            ),
            itemCount: materias.length,
            itemBuilder: (context, index) {
              final materiaDoc = materias[index];
              final materiaData = materiaDoc.data() as Map<String, dynamic>;
              
              final materiaId = materiaDoc.id;
              final materiaTitle = materiaData['nome'] ?? 'Matéria Sem Nome';

              return _buildSubjectCard(materiaTitle, materiaId);
            },
          );
        },
      ),
    );
  }

  // ====================================================================
  // MÉTODO MODIFICADO: _buildSubjectCard (com navegação)
  // ====================================================================

  Widget _buildSubjectCard(String title, String materiaId) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: _cardBackgroundColor,
      child: InkWell(
        onTap: () {
          // Ação ao clicar: Navegar para a tela de detalhes
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesMateriaAluno(
                materiaId: materiaId,
                nomeMateria: title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}