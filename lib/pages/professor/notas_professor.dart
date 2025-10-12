import 'package:flutter/material.dart';

class NotasProfessor extends StatelessWidget {
  const NotasProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Notas'),
        backgroundColor: const Color(0xFFFF9500),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 100, color: Color(0xFFFF9500)),
            SizedBox(height: 20),
            Text(
              'Notas dos Alunos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Gerencie as notas dos seus alunos'),
          ],
        ),
      ),
    );
  }
}
