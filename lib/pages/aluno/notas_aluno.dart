// import 'package:flutter/material.dart';

// class NotasAluno extends StatelessWidget {
//   const NotasAluno({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notas'),
//         backgroundColor: const Color(0xFF7DD3FC),
//         foregroundColor: Colors.black,
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.assignment, size: 100, color: Color(0xFF7DD3FC)),
//             SizedBox(height: 20),
//             Text(
//               'Suas Notas',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             Text('Notas e avaliações aparecerão aqui'),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

// Constante para definir o ponto de quebra (breakpoint) entre mobile e tablet/desktop
const double kTabletBreakpoint = 600.0;
// Cor de acento (Light Cyan/Sky Blue) baseada nas imagens do Figma
const Color kPrimaryColor = Color(0xFFA5E6FA); // Próximo ao sky-200/300 do Tailwind
// Cor de fundo do corpo da tela
// COR AJUSTADA: De volta ao suave off-white, agora que o layout está confirmado.
const Color kBackgroundColor = Color(0xFFF7F9FC);

/// Widget principal que exibe a tela de Notas de forma responsiva.
class NotasAluno extends StatelessWidget {
  const NotasAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      // O Drawer só será usado em telas pequenas (mobile),
      // pois a navegação lateral é incorporada no body em telas grandes.
      drawer:
          MediaQuery.of(context).size.width < kTabletBreakpoint ? const _SidebarNavigation() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Se a largura for maior ou igual ao breakpoint, exibe o layout de duas colunas (Desktop/Tablet)
          if (constraints.maxWidth >= kTabletBreakpoint) {
            // CORRIGIDO: Removido 'const' da Row e Expanded/child, pois '_NotasContent' é StatefulWidget.
            return Row(
              children: [
                // 1. Sidebar de navegação
                const _SidebarNavigation(),
                // 2. Área de conteúdo principal (expandida)
                Expanded(
                  child: _NotasContent(), // CORRIGIDO: Removido 'const'
                ),
              ],
            );
          } else {
            // Se a largura for menor que o breakpoint, exibe apenas o conteúdo principal (Mobile)
            return _NotasContent(); // CORRIGIDO: Removido 'const'
          }
        },
      ),
    );
  }

  // Constrói a AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Notas',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.black,
      centerTitle: true,
      elevation: 0, // Remove a sombra
    );
  }
}

/// Widget para o Painel de Navegação Lateral (Sidebar).
class _SidebarNavigation extends StatelessWidget {
  const _SidebarNavigation();

  @override
  Widget build(BuildContext context) {
    // Para telas grandes, a largura do sidebar é fixa. Para mobile, usa a largura padrão do Drawer.
    final bool isDesktop = MediaQuery.of(context).size.width >= kTabletBreakpoint;

    return Container(
      width: isDesktop ? 250 : null, // Largura fixa para desktop/tablet
      color: Colors.white, // Fundo branco do painel lateral
      child: ListView(
        padding: isDesktop
            ? const EdgeInsets.symmetric(vertical: 20)
            : EdgeInsets.zero,
        children: const [
          // Item "Arquivos"
          _SidebarItem(
            icon: Icons.folder_outlined,
            title: 'Arquivos',
            isSelected: false,
          ),
          // Item "Matérias"
          _SidebarItem(
            icon: Icons.book_outlined,
            title: 'Matérias',
            isSelected: false,
          ),
          // Item "Mensagem"
          _SidebarItem(
            icon: Icons.mail_outline,
            title: 'Mensagem',
            isSelected: false,
          ),
          // Item "Notas" (Selecionado)
          _SidebarItem(
            icon: Icons.assignment_outlined,
            title: 'Notas',
            isSelected: true,
          ),
        ],
      ),
    );
  }
}

/// Widget para um item individual na Sidebar.
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        // Adiciona um efeito visual de seleção e borda arredondada
        color: isSelected ? kPrimaryColor.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          onTap: () {
            // Ação ao clicar (ex: navegar para outra tela)
            if (MediaQuery.of(context).size.width < kTabletBreakpoint) {
              Navigator.pop(context); // Fecha o drawer no mobile
            }
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.black : Colors.black87,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// MODELO DE DADOS para simular as notas detalhadas (boletim)
class GradeData {
  final String subject;
  final String average;
  final Map<String, List<String>> grades; // Ex: {'P1': ['9.0', '8.5', 'Aprovado'], 'P2': [...]}

  const GradeData({
    required this.subject,
    required this.average,
    required this.grades,
  });
}

// Lista de matérias (dados mockados)
const List<GradeData> mockGrades = [
  GradeData(
    subject: 'Matemática',
    average: '8.5',
    grades: {
      '1º Bimestre': ['Prova', '9.0'],
      '2º Bimestre': ['Trabalho', '8.0'],
      '3º Bimestre': ['Final', '8.5'],
      'Média Final': ['--', '8.5'],
    },
  ),
  GradeData(
    subject: 'Língua Portuguesa',
    average: '9.2',
    grades: {
      '1º Bimestre': ['Prova', '9.5'],
      '2º Bimestre': ['Redação', '8.9'],
      '3º Bimestre': ['Final', '9.2'],
      'Média Final': ['--', '9.2'],
    },
  ),
  GradeData(
    subject: 'História',
    average: '7.8',
    grades: {
      '1º Bimestre': ['Prova', '7.0'],
      '2º Bimestre': ['Seminário', '8.5'],
      '3º Bimestre': ['Final', '7.9'],
      'Média Final': ['--', '7.8'],
    },
  ),
];


/// NOVO WIDGET para o item de Matéria sem o ExpansionTile.
/// Apenas exibe o nome e é clicável para abrir o boletim.
class _SubjectGradeItem extends StatelessWidget {
  final GradeData data;
  final Function(GradeData) onTap;

  const _SubjectGradeItem({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: () => onTap(data), // Chama a função para mostrar a tabela
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.subject,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black54), // Ícone de dropdown
            ],
          ),
        ),
      ),
    );
  }
}

/// NOVO WIDGET: Tabela de Notas/Boletim Detalhado
class _GradesTable extends StatelessWidget {
  final GradeData data;
  final VoidCallback onBack;

  const _GradesTable({required this.data, required this.onBack});

  @override
  Widget build(BuildContext context) {
    // Cabeçalhos da Tabela: Matéria, Avaliação (se houver) e Nota/Média
    final List<String> columns = ['Período', 'Avaliação', 'Nota/Média'];

    // Define a cor de fundo para o cabeçalho (um cinza suave)
    const Color headerColor = Color(0xFFEEEEEE);
    // Define a cor para a linha de média (destaque)
    const Color averageRowColor = Color(0xFFFFFBE5); // Amarelo suave

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão Voltar
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar para todas as Matérias'),
          ),
          const SizedBox(height: 15),

          // Título da Matéria Selecionada
          Text(
            data.subject,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Tabela de Notas
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              // Linha de Cabeçalho
              TableRow(
                decoration: const BoxDecoration(color: headerColor),
                children: columns.map((header) {
                  return TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          header,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Linhas de Conteúdo (Notas por período)
              ...data.grades.entries.map((entry) {
                final String period = entry.key;
                final String assessmentType = entry.value[0];
                final String grade = entry.value[1];

                final bool isAverageRow = period.contains('Média Final');

                return TableRow(
                  decoration: BoxDecoration(
                    color: isAverageRow ? averageRowColor : Colors.white,
                  ),
                  children: [
                    // Coluna Período
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(period, style: TextStyle(fontWeight: isAverageRow ? FontWeight.bold : FontWeight.normal)),
                      ),
                    ),
                    // Coluna Avaliação
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(assessmentType, textAlign: TextAlign.center),
                      ),
                    ),
                    // Coluna Nota/Média
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            grade,
                            style: TextStyle(
                              fontWeight: isAverageRow ? FontWeight.w900 : FontWeight.bold,
                              color: double.tryParse(grade) != null && double.parse(grade) < 7.0
                                  ? Colors.red.shade700 // Destaque para notas baixas
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 20),
          // Área para informações adicionais/legenda
          Text(
            'Média da Matéria: ${data.average}',
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Widget para a Área de Conteúdo Principal (Central).
class _NotasContent extends StatefulWidget {
  const _NotasContent();

  @override
  State<_NotasContent> createState() => _NotasContentState();
}

class _NotasContentState extends State<_NotasContent> {
  // O estado que guarda a matéria selecionada. Se for null, mostra a lista.
  GradeData? _selectedSubject;

  // Função para mudar o estado e exibir o boletim
  void _showGradesTable(GradeData subject) {
    setState(() {
      _selectedSubject = subject;
    });
  }

  // Função para retornar à lista de matérias
  void _hideGradesTable() {
    setState(() {
      _selectedSubject = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _selectedSubject == null
            ? ListView(
                // Se nenhuma matéria estiver selecionada, mostra a lista de matérias
                children: mockGrades.map((data) {
                  return _SubjectGradeItem(
                    data: data,
                    onTap: _showGradesTable,
                  );
                }).toList(),
              )
            // Se uma matéria estiver selecionada, mostra a tabela de boletim
            : _GradesTable(
                data: _selectedSubject!,
                onBack: _hideGradesTable,
              ),
      ),
    );
  }
}
