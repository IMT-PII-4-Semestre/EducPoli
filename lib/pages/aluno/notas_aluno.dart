import 'package:flutter/material.dart';

class NotasAluno extends StatelessWidget {
  const NotasAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        backgroundColor: const Color(0xFF7DD3FC),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 100, color: Color(0xFF7DD3FC)),
            SizedBox(height: 20),
            Text(
              'Suas Notas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Notas e avaliações aparecerão aqui'),
          ],
        ),
      ),
    );
  }
}
