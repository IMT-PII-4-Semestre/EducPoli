import 'package:flutter/material.dart';
import '../services/autenticacao.dart';
import '../widgets/responsive_layout.dart';

class DashboardAluno extends StatelessWidget {
  const DashboardAluno({super.key});

  static const menuItems = [
    DashboardMenuItem(
      title: 'Arquivos',
      icon: Icons.folder,
      route: '/aluno/arquivos',
    ),
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
  Widget build(BuildContext context) {
    return ResponsiveDashboard(
      title: 'Área do Aluno',
      headerColor: const Color(0xFF7DD3FC),
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
