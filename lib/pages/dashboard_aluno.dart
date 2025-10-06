import 'package:flutter/material.dart';
import '../services/autenticacao.dart';

class DashboardAluno extends StatelessWidget {
  const DashboardAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Aluno'),
        backgroundColor: const Color(0xFF3498DB),
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
            Icon(Icons.school, size: 100, color: Color(0xFF3498DB)),
            SizedBox(height: 20),
            Text(
              'Bem-vindo, Aluno!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Dashboard do Aluno funcionando ✅',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
