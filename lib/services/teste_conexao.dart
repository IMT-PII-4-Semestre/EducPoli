import 'package:cloud_firestore/cloud_firestore.dart';

class TesteConexao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> testarConexao() async {
    try {
      // Teste de escrita
      await _firestore.collection('teste').doc('conexao').set({
        'timestamp': DateTime.now(),
        'status': 'conectado',
        'teste': true,
      });

      // Teste de leitura
      DocumentSnapshot doc = await _firestore.collection('teste').doc('conexao').get();
      
      if (doc.exists) {
        return {
          'sucesso': true,
          'dados': doc.data(),
          'timestamp': DateTime.now().toIso8601String()
        };
      } else {
        return {
          'sucesso': false,
          'erro': 'Documento não encontrado'
        };
      }
    } catch (e) {
      return {
        'sucesso': false,
        'erro': e.toString()
      };
    }
  }

  Future<List<Map<String, dynamic>>> buscarUsuarios() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('usuarios').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }
}