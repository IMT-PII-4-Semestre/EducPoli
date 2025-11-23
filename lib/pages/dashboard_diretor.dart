import 'package:flutter/material.dart';
import '../widgets/layout_base.dart';
import '../core/config/menu_config.dart';

class DashboardDiretor extends StatelessWidget {
  const DashboardDiretor({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Área do Diretor',
      corPrincipal: MenuConfig.corDiretor,
      itensMenu: MenuConfig.menuDiretor,
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
        'titulo': 'Gerenciar Alunos',
        'icone': Icons.people_outline,
        'rota': '/diretor/alunos',
        'cor': const Color(0xFF3498DB),
      },
      {
        'titulo': 'Gerenciar Professores',
        'icone': Icons.person_outline,
        'rota': '/diretor/professores',
        'cor': const Color(0xFF9B59B6),
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
      height: isMobile ? 140 : 220,
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
                      Flexible(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
