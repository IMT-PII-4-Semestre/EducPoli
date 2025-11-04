import 'package:flutter/material.dart';
import '../services/autenticacao.dart';
import '../widgets/responsive_layout.dart';

class DashboardProfessor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ResponsiveDashboard(
      title: 'Área do Professor',
      headerColor: const Color(0xFFFF9500),
      menuItems: menuItems,
      onLogout: () async {
        await ServicoAutenticacao().sair();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
  }
}
