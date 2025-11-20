import 'package:flutter/material.dart';
import '../widgets/layout_base.dart';
import '../core/config/menu_config.dart';

class DashboardAluno extends StatelessWidget {
  const DashboardAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Área do Aluno',
      corPrincipal: MenuConfig.corAluno,
      itensMenu: MenuConfig.menuAluno,
      itemSelecionadoId: 'home',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(24),
      child: isMobile ? _buildMobileGrid(context) : _buildDesktopGrid(context),
    );
  }

  Widget _buildMobileGrid(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _buildCards(context).map((card) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 140,
            child: card,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopGrid(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 32,
        runSpacing: 32,
        alignment: WrapAlignment.center,
        children: _buildCards(context),
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    final opcoes = [
      {
        'titulo': 'Matérias',
        'icone': Icons.book_outlined,
        'rota': '/aluno/materias',
        'cor': const Color(0xFF3498DB),
      },
      {
        'titulo': 'Mensagens',
        'icone': Icons.message_outlined,
        'rota': '/aluno/mensagem',
        'cor': const Color(0xFF9B59B6),
      },
      {
        'titulo': 'Boletim',
        'icone': Icons.assessment_outlined,
        'descricao': 'Notas e desempenho completo',
        'rota': '/aluno/boletim',
        'cor': const Color(0xFF27AE60),
      },
    ];

    return opcoes.map((opcao) {
      return _buildCardOpcao(
        context,
        titulo: opcao['titulo'] as String,
        icone: opcao['icone'] as IconData,
        rota: opcao['rota'] as String,
        cor: opcao['cor'] as Color,
      );
    }).toList();
  }

  Widget _buildCardOpcao(
    BuildContext context, {
    required String titulo,
    required IconData icone,
    required String rota,
    required Color cor,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: isMobile ? double.infinity : 240,
      height: isMobile ? 140 : 200,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(context, rota);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: isMobile
                ? Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 20),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icone,
                          size: isMobile ? 32 : 48,
                          color: cor,
                        ),
                      ),
                      SizedBox(width: isMobile ? 16 : 20),
                      Expanded(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icone,
                          size: 48,
                          color: cor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
