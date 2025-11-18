import 'package:flutter/material.dart';
import '../services/autenticacao.dart';
import '../widgets/responsive_layout.dart';

/// Botão reutilizável para voltar para a área do professor.
/// Coloque este widget em qualquer tela para garantir o mesmo comportamento.
class BackToProfessorAreaButton extends StatelessWidget {
  final String route;
  final String label;
  final IconData icon;

  const BackToProfessorAreaButton({
    super.key,
    this.route = '/professor',
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

class DashboardProfessor extends StatefulWidget {
  const DashboardProfessor({super.key});

  static const menuItems = [
    DashboardMenuItem(
      title: 'Matérias',
      icon: Icons.book,
      route: '/professor/materias',
    ),
    DashboardMenuItem(
      title: 'Mensagem',
      icon: Icons.message,
      route: '/professor/mensagem',
    ),
    DashboardMenuItem(
      title: 'Notas',
      icon: Icons.assignment,
      route: '/professor/notas',
    ),
  ];

  @override
  State<DashboardProfessor> createState() => _DashboardProfessorState();
}

class _DashboardProfessorState extends State<DashboardProfessor> {
  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: BackToProfessorAreaButton(
              route: '/professor',
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
        title: 'Área do Professor',
        headerColor: const Color(0xFFFF9500),
        menuItems: DashboardProfessor.menuItems,
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
