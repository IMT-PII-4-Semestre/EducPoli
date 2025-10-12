import 'package:flutter/material.dart';

class MensagemProfessor extends StatelessWidget {
  const MensagemProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: const Color(0xFFFF9500),
        foregroundColor: Colors.black,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 100, color: Color(0xFFFF9500)),
            SizedBox(height: 20),
            Text(
              'Mensagens do Professor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Envie mensagens para os alunos'),
          ],
        ),
      ),
    );
  }
}
