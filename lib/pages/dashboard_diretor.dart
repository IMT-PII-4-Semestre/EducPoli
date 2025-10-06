import 'package:flutter/material.dart';
import '../services/autenticacao.dart';

class DashboardDiretor extends StatelessWidget {
  const DashboardDiretor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Diretor'),
        backgroundColor: const Color(0xFFE74C3C),
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
            Icon(
              Icons.admin_panel_settings,
              size: 100,
              color: Color(0xFFE74C3C),
            ),
            SizedBox(height: 20),
            Text(
              'Bem-vindo, Diretor!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Dashboard do Diretor funcionando ✅',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
