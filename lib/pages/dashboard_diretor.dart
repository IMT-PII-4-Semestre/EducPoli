import 'package:flutter/material.dart';
import '../services/autenticacao.dart';
import '../widgets/responsive_layout.dart';

class DashboardDiretor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ResponsiveDashboard(
      title: 'Área do Diretor',
      headerColor: const Color(0xFFE74C3C),
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
