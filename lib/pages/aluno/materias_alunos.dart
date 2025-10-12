import 'package:flutter/material.dart';

class MateriasAluno extends StatelessWidget {
  const MateriasAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matérias'),
        backgroundColor: const Color(0xFF7DD3FC),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 100, color: Color(0xFF7DD3FC)),
            SizedBox(height: 20),
            Text(
              'Suas Matérias',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Lista de matérias aparecerá aqui'),
          ],
        ),
      ),
    );
  }
}
