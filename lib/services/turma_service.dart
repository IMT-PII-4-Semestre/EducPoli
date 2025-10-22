import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/turma.dart';

class TurmaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Buscar todas as turmas ativas
  Stream<List<Turma>> buscarTurmasAtivas() {
    print('🔍 Buscando turmas ativas...');
    return _firestore
        .collection('turmas')
        .where('ativa', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('📚 Documentos encontrados: ${snapshot.docs.length}');

          final turmas = snapshot.docs.map((doc) {
            print('  📄 Documento ID: ${doc.id}');
            print('  📄 Dados: ${doc.data()}');
            return Turma.fromMap(doc.data(), doc.id);
          }).toList();

          return turmas;
        });
  }

  // Buscar todas as turmas
  Stream<List<Turma>> buscarTodasTurmas() {
    return _firestore.collection('turmas').orderBy('nome').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Turma.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Cadastrar nova turma
  Future<void> cadastrarTurma(Turma turma) async {
    await _firestore.collection('turmas').add(turma.toMap());
  }

  // Atualizar turma
  Future<void> atualizarTurma(String id, Turma turma) async {
    await _firestore.collection('turmas').doc(id).update(turma.toMap());
  }

  // Deletar turma
  Future<void> deletarTurma(String id) async {
    await _firestore.collection('turmas').doc(id).delete();
  }

  // Buscar turma por ID
  Future<Turma?> buscarTurmaPorId(String id) async {
    final doc = await _firestore.collection('turmas').doc(id).get();
    if (doc.exists) {
      return Turma.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
