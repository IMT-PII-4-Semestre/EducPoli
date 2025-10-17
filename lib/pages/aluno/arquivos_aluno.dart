import 'package:flutter/material.dart';

class ArquivosAluno extends StatelessWidget {
  const ArquivosAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arquivos'),
        backgroundColor: const Color(0xFF7DD3FC),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 100, color: Color(0xFF7DD3FC)),
            SizedBox(height: 20),
            Text(
              'Área de Arquivos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Seus arquivos aparecerão aqui'),
          ],
        ),
      ),
    );
  }
}

