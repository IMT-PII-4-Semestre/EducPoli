import 'package:flutter/material.dart';
import '../services/autenticacao.dart';
import '../widgets/responsive_layout.dart';

/// Botão reutilizável para voltar para a área do aluno.
/// Coloque este widget em qualquer tela para garantir o mesmo comportamento.
class BackToAlunoAreaButton extends StatelessWidget {
  final String route;
  final String label;
  final IconData icon;

  const BackToAlunoAreaButton({
    super.key,
    this.route = '/aluno',
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

class DashboardAluno extends StatefulWidget {
  const DashboardAluno({super.key});

  static const menuItems = [
    DashboardMenuItem(
      title: 'Matérias',
      icon: Icons.book,
      route: '/aluno/materias',
    ),
    DashboardMenuItem(
      title: 'Mensagem',
      icon: Icons.message,
      route: '/aluno/mensagem',
    ),
    DashboardMenuItem(
      title: 'Notas',
      icon: Icons.assignment,
      route: '/aluno/notas',
    ),
  ];

  @override
  State<DashboardAluno> createState() => _DashboardAlunoState();
}

class _DashboardAlunoState extends State<DashboardAluno> {
  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: BackToAlunoAreaButton(
              route: '/aluno',
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
      // Removido floatingActionButton do Scaffold para que o botão fique fornecido
      // pelo Overlay (assim permanece visível em todas as telas do dashboard).
      body: ResponsiveDashboard(
        title: 'Área do Aluno',
        headerColor: const Color(0xFF7DD3FC),
        menuItems: DashboardAluno.menuItems,
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
