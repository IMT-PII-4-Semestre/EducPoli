import 'package:flutter/material.dart';

class MensagemAluno extends StatelessWidget {
  const MensagemAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: const Color(0xFF7DD3FC),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 100, color: Color(0xFF7DD3FC)),
            SizedBox(height: 20),
            Text(
              'Mensagens',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Suas mensagens aparecerão aqui'),
          ],
        ),
      ),
    );
  }
}
