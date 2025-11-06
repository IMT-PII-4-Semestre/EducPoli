import 'package:cloud_firestore/cloud_firestore.dart';

class MateriasService {
  static const List<String> MATERIAS_PADRAO = [
    'Matemática',
    'Português',
    'História',
    'Geografia',
    'Ciências',
    'Inglês',
    'Educação Física',
    'Artes',
    'Física',
    'Química',
    'Biologia',
    'Filosofia',
    'Sociologia',
  ];

  static Future<void> inicializarMaterias() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('materias').get();

      if (querySnapshot.docs.isEmpty) {
        // Se não houver matérias, cria todas
        for (String materia in MATERIAS_PADRAO) {
          await FirebaseFirestore.instance.collection('materias').add({
            'nome': materia,
            'descricao': 'Disciplina de $materia',
            'criadoEm': DateTime.now(),
            'ativa': true,
          });
        }
        print('✅ Matérias inicializadas com sucesso!');
      }
    } catch (e) {
      print('❌ Erro ao inicializar matérias: $e');
    }
  }

  static Future<List<String>> obterMateriasDisponiveis() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('materias')
          .where('ativa', isEqualTo: true)
          .orderBy('nome')
          .get();

      return querySnapshot.docs.map((doc) => doc['nome'] as String).toList();
    } catch (e) {
      print('❌ Erro ao obter matérias: $e');
      return MATERIAS_PADRAO;
    }
  }

  static Stream<List<String>> obterMateriasStream() {
    return FirebaseFirestore.instance
        .collection('materias')
        .where('ativa', isEqualTo: true)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['nome'] as String).toList());
  }

  static Future<List<String>> obterMateriasDoProf(String professoresId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(professoresId)
          .get();

      if (doc.exists) {
        final materias = doc.data()?['materias'] as List<dynamic>? ?? [];
        return materias.cast<String>();
      }
      return [];
    } catch (e) {
      print('❌ Erro ao obter matérias do professor: $e');
      return [];
    }
  }
}
