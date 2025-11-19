import 'package:flutter/material.dart';
import 'menu_lateral.dart';

/// Layout Base - Estrutura padrão para todas as páginas da aplicação
class LayoutBase extends StatelessWidget {
  final String titulo;
  final Widget conteudo;
  final List<ItemMenu> itensMenu;
  final String itemSelecionadoId;
  final Color corPrincipal;
  final List<Widget>? breadcrumbs;
  final List<Widget>? acoesAppBar;

  const LayoutBase({
    super.key,
    required this.titulo,
    required this.conteudo,
    required this.itensMenu,
    required this.itemSelecionadoId,
    required this.corPrincipal,
    this.breadcrumbs,
    this.acoesAppBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar sem botão de voltar
      appBar: AppBar(
        backgroundColor: corPrincipal,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        automaticallyImplyLeading:
            isDesktop ? false : true, // Só mostra hamburger no mobile
        leading: isDesktop
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
            if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildBreadcrumbs(),
            ],
          ],
        ),
        actions: acoesAppBar,
      ),

      // Drawer apenas para mobile
      drawer: isDesktop
          ? null
          : MenuLateralDrawer(
              itensMenu: itensMenu,
              itemSelecionadoId: itemSelecionadoId,
              corPrincipal: corPrincipal,
            ),

      // Corpo da aplicação
      body: Row(
        children: [
          // Menu lateral fixo no desktop
          if (isDesktop)
            MenuLateral(
              itensMenu: itensMenu,
              itemSelecionadoId: itemSelecionadoId,
              corPrincipal: corPrincipal,
            ),

          // Conteúdo principal
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: conteudo,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a navegação breadcrumb
  Widget _buildBreadcrumbs() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < breadcrumbs!.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          breadcrumbs![i],
        ],
      ],
    );
  }
}

/// Widget de breadcrumb
class Breadcrumb extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;
  final bool isAtivo;

  const Breadcrumb({
    super.key,
    required this.texto,
    this.onTap,
    this.isAtivo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          color: isAtivo ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isAtivo ? FontWeight.w600 : FontWeight.w400,
          decoration: onTap != null ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}
