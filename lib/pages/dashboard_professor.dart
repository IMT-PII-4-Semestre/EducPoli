import 'package:flutter/material.dart';
import '../services/autenticacao.dart';

class DashboardProfessor extends StatelessWidget {
  const DashboardProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Professor'),
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await ServicoAutenticacao().sair();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_3, size: 100, color: Color(0xFF27AE60)),
            SizedBox(height: 20),
            Text(
              'Bem-vindo, Professor!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Dashboard do Professor funcionando ✅',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
