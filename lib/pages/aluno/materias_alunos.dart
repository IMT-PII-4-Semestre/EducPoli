// import 'package:flutter/material.dart';

// class MateriasAluno extends StatelessWidget {
//   const MateriasAluno({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Matérias'),
//         backgroundColor: const Color(0xFF7DD3FC),
//         foregroundColor: Colors.black,
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.book, size: 100, color: Color(0xFF7DD3FC)),
//             SizedBox(height: 20),
//             Text(
//               'Suas Matérias',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             Text('Lista de matérias aparecerá aqui'),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

// Definindo a lista de itens de navegação (com um ID único)
const List<Map<String, dynamic>> _navItems = [
  {'title': 'Arquivos', 'icon': Icons.folder_open, 'id': 'files'},
  {'title': 'Matérias', 'icon': Icons.book, 'id': 'subjects'},
  {'title': 'Mensagem', 'icon': Icons.mail_outline, 'id': 'messages'},
  {'title': 'Notas', 'icon': Icons.description_outlined, 'id': 'notes'},
];

// Definindo a lista de matérias para o Grid
const List<String> _subjects = [
  'Língua Portuguesa',
  'Matemática',
  'Biologia',
  'História',
  'Geografia',
  'Física',
  'Química',
  'Lingua Inglesa',
];

// Cores baseadas no Figma/código original
const Color _primaryColor = Color(0xFFB2EBF2); // Fundo do AppBar e Sidebar (cor clara do Figma)
const Color _sidebarBackgroundColor = Color(0xFFEBEBEB); // Fundo da Sidebar
const Color _cardBackgroundColor = Color(0xFFF0F0F0); // Cor dos cards de matéria
const double _desktopBreakpoint = 700; // Ponto de quebra para layout Desktop/Mobile
const double _maxContentWidth = 1000; // Largura máxima do conteúdo centralizado

// ====================================================================
// 1. Classe de Tela de Placeholder (para as outras opções do menu)
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
// 2. Classe Principal (StatefulWidget) para gerenciar o estado
// ====================================================================
class MateriasAluno extends StatefulWidget {
  const MateriasAluno({super.key});

  @override
  State<MateriasAluno> createState() => _MateriasAlunoState();
}

class _MateriasAlunoState extends State<MateriasAluno> {
  // Estado para rastrear o item selecionado (inicia em 'subjects' - Matérias)
  String _selectedNavItemId = 'subjects';

  // Define o conteúdo da tela principal com base no item selecionado e no layout
  Widget _getCurrentScreenContent({required bool isDesktopLayout}) {
    switch (_selectedNavItemId) {
      case 'subjects':
        // CORREÇÃO: Define a contagem de colunas correta para o layout
        final int columns = isDesktopLayout ? 4 : 2;
        return _buildContentGrid(columns); 
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

  // Define o título da AppBar com base no item selecionado
  String _getCurrentTitle() {
    final item = _navItems.firstWhere(
      (item) => item['id'] == _selectedNavItemId,
      orElse: () => {'title': 'App'},
    );
    return item['title'] as String;
  }

  // ====================================================================
  // 3. Métodos de Construção
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    // Scaffold principal que adapta a AppBar e o corpo
    return Scaffold(
      appBar: _buildAppBar(),
      // O Drawer só é visível no modo Mobile quando o ícone de menu é clicado
      drawer: MediaQuery.of(context).size.width < _desktopBreakpoint 
          ? _buildDrawer(context) 
          : null,
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      // Título dinâmico
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
      
      // Ícone de perfil à direita
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
        // Se a largura for maior que o breakpoint, usa o layout Desktop
        if (constraints.maxWidth > _desktopBreakpoint) {
          return _buildDesktopLayout();
        } 
        // Caso contrário, usa o layout Mobile (Drawer implícito pela AppBar)
        else {
          // No mobile, o conteúdo é retornado no modo isDesktopLayout: false
          return _getCurrentScreenContent(isDesktopLayout: false);
        }
      },
    );
  }

  // Layout para telas largas (Desktop/Tablet)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // 1. Sidebar (Navigation Rail) à esquerda
        _buildSideNav(),
        
        // 2. Conteúdo Principal (Centralizado)
        Expanded(
          // Adiciona Center para centralizar vertical e horizontalmente 
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              // Envolve o conteúdo em SingleChildScrollView para permitir 
              // centralização vertical e evitar overflow.
              child: SingleChildScrollView( 
                // Passa o flag de desktop para que o grid saiba usar 4 colunas
                child: _getCurrentScreenContent(isDesktopLayout: true), 
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Sidebar Fixa para Desktop
  Widget _buildSideNav() {
    return Container(
      width: 250, // Largura da Sidebar
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
              // Atualiza o estado
              setState(() {
                _selectedNavItemId = item['id'] as String;
              });
            },
          );
        },
      ),
    );
  }

  // Drawer (Menu Lateral) para Mobile
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
                // 1. Atualiza o estado
                setState(() {
                  _selectedNavItemId = item['id'] as String;
                });
                // 2. Fecha o Drawer
                Navigator.pop(context); 
              },
            );
          },
        ),
      ),
    );
  }

  // Grid de Cards de Matérias
  Widget _buildContentGrid(int crossAxisCount) {
    // A flag isDesktop é true apenas quando crossAxisCount é 4 (o valor passado pelo desktop)
    final isDesktopLayout = crossAxisCount == 4; 

    return Container(
      color: Colors.white, // Fundo branco para a área de conteúdo
      padding: const EdgeInsets.all(32.0),
      child: GridView.builder(
        // shrinkWrap: true é essencial quando dentro de SingleChildScrollView (Desktop)
        shrinkWrap: isDesktopLayout, 
        // Desabilita o scroll do grid se o SingleChildScrollView o estiver envolvendo
        physics: isDesktopLayout ? const NeverScrollableScrollPhysics() : null,
        
        // Usa a contagem de colunas passada (4 ou 2)
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, 
          crossAxisSpacing: 32.0,
          mainAxisSpacing: 32.0,
          childAspectRatio: 2.0, // Proporção da altura para a largura do card
        ),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          return _buildSubjectCard(_subjects[index]);
        },
      ),
    );
  }

  // Card de Matéria individual
  Widget _buildSubjectCard(String title) {
    return Card(
      elevation: 0, // Sem sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Bordas arredondadas
      ),
      color: _cardBackgroundColor, // Cor de fundo do card
      child: InkWell(
        onTap: () {
          // Ação ao clicar no card da matéria
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