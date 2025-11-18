import 'package:flutter/material.dart';
import '../services/autenticacao.dart';
import '../widgets/responsive_layout.dart';

/// Botão reutilizável para voltar para a área do diretor.
/// Coloque este widget em qualquer tela para garantir o mesmo comportamento.
class BackToDiretorAreaButton extends StatelessWidget {
  final String route;
  final String label;
  final IconData icon;

  const BackToDiretorAreaButton({
    super.key,
    this.route = '/diretor',
    this.label = 'Voltar para o menu',
    this.icon = Icons.home,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class DashboardDiretor extends StatefulWidget {
  const DashboardDiretor({super.key});

  static const menuItems = [
    DashboardMenuItem(
      title: 'alunos',
      icon: Icons.person,
      route: '/diretor/alunos',
    ),
    DashboardMenuItem(
      title: 'professores',
      icon: Icons.person_3,
      route: '/diretor/professores',
    ),
  ];

  @override
  State<DashboardDiretor> createState() => _DashboardDiretorState();
}

class _DashboardDiretorState extends State<DashboardDiretor> {
  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: BackToDiretorAreaButton(
              route: '/diretor',
              label: 'Voltar para o menu',
              icon: Icons.menu_book,
            ),
          ),
        ),
      ),
    );
  }

  void _insertOverlayIfNeeded() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    _overlayEntry = _createOverlayEntry();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry != null) overlay.insert(_overlayEntry!);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _insertOverlayIfNeeded();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveDashboard(
        title: 'Área do Diretor',
        headerColor: const Color(0xFFE74C3C),
        menuItems: DashboardDiretor.menuItems,
        onLogout: () async {
          await ServicoAutenticacao().sair();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
      ),
    );
  }
}
