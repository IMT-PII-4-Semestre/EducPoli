import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Buscar notas de um aluno específico
  Future<Map<String, dynamic>> buscarNotasAluno(String alunoId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('notas').doc(alunoId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw Exception('Erro ao buscar notas: ${e.toString()}');
    }
  }

  // Buscar notas do aluno logado
  Stream<Map<String, dynamic>> streamNotasAlunoLogado() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value({});
    }

    return _firestore.collection('notas').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    });
  }

  // Salvar/Atualizar notas de um aluno em uma matéria específica
  Future<void> salvarNotasMateria({
    required String alunoId,
    required String materia,
    double? bim1,
    double? bim2,
    double? bim3,
    double? bim4,
  }) async {
    try {
      // Validar notas
      if (bim1 != null && (bim1 < 0 || bim1 > 10)) {
        throw 'Nota do 1º Bimestre deve estar entre 0 e 10';
      }
      if (bim2 != null && (bim2 < 0 || bim2 > 10)) {
        throw 'Nota do 2º Bimestre deve estar entre 0 e 10';
      }
      if (bim3 != null && (bim3 < 0 || bim3 > 10)) {
        throw 'Nota do 3º Bimestre deve estar entre 0 e 10';
      }
      if (bim4 != null && (bim4 < 0 || bim4 > 10)) {
        throw 'Nota do 4º Bimestre deve estar entre 0 e 10';
      }

      // Calcular média
      final notas = [bim1, bim2, bim3, bim4].whereType<double>().toList();
      final media = notas.isNotEmpty
          ? double.parse(
              (notas.reduce((a, b) => a + b) / notas.length).toStringAsFixed(2))
          : null;

      // Determinar situação
      String? situacao;
      if (media != null) {
        if (media >= 7.0) {
          situacao = 'Aprovado';
        } else if (media >= 5.0) {
          situacao = 'Recuperação';
        } else {
          situacao = 'Reprovado';
        }
      }

      // Salvar no Firestore
      await _firestore.collection('notas').doc(alunoId).set({
        materia: {
          'bim1': bim1,
          'bim2': bim2,
          'bim3': bim3,
          'bim4': bim4,
          'media': media,
          'situacao': situacao,
          'ultima_atualizacao': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erro ao salvar notas: $e');
    }
  }

  // Buscar todos os alunos com notas de uma turma
  Stream<List<Map<String, dynamic>>> streamAlunosPorTurma(String turma) {
    return _firestore
        .collection('usuarios')
        .where('tipo', isEqualTo: 'aluno')
        .where('turma', isEqualTo: turma)
        .where('ativo', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> alunos = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> alunoData = doc.data();
        alunoData['id'] = doc.id;

        // Buscar notas do aluno
        final notasDoc = await _firestore.collection('notas').doc(doc.id).get();
        if (notasDoc.exists) {
          alunoData['notas'] = notasDoc.data();
        } else {
          alunoData['notas'] = {};
        }

        alunos.add(alunoData);
      }

      return alunos;
    });
  }

  // Buscar todos os alunos ativos
  Stream<List<Map<String, dynamic>>> streamTodosAlunos() {
    return _firestore
        .collection('usuarios')
        .where('tipo', isEqualTo: 'aluno')
        .where('ativo', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> alunos = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> alunoData = doc.data();
        alunoData['id'] = doc.id;

        // Buscar notas do aluno
        final notasDoc = await _firestore.collection('notas').doc(doc.id).get();
        if (notasDoc.exists) {
          alunoData['notas'] = notasDoc.data();
        } else {
          alunoData['notas'] = {};
        }

        alunos.add(alunoData);
      }

      return alunos;
    });
  }

  // Deletar todas as notas de um aluno
  Future<void> deletarNotasAluno(String alunoId) async {
    try {
      await _firestore.collection('notas').doc(alunoId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar notas: ${e.toString()}');
    }
  }

  // Deletar notas de uma matéria específica
  Future<void> deletarNotasMateria(String alunoId, String materia) async {
    try {
      await _firestore.collection('notas').doc(alunoId).update({
        materia: FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Erro ao deletar notas da matéria: ${e.toString()}');
    }
  }

  // Buscar estatísticas de um aluno
  Future<Map<String, dynamic>> buscarEstatisticasAluno(String alunoId) async {
    try {
      final notasDoc = await _firestore.collection('notas').doc(alunoId).get();

      if (!notasDoc.exists) {
        return {
          'total_materias': 0,
          'media_geral': 0.0,
          'aprovado_em': 0,
          'recuperacao_em': 0,
          'reprovado_em': 0,
        };
      }

      final notas = notasDoc.data() as Map<String, dynamic>;
      int totalMaterias = notas.length;
      int aprovado = 0;
      int recuperacao = 0;
      int reprovado = 0;
      double somaMedias = 0.0;
      int materiasComMedia = 0;

      notas.forEach((materia, dados) {
        if (dados is Map<String, dynamic>) {
          final media = dados['media'];
          if (media != null) {
            somaMedias += media;
            materiasComMedia++;

            if (media >= 7.0) {
              aprovado++;
            } else if (media >= 5.0) {
              recuperacao++;
            } else {
              reprovado++;
            }
          }
        }
      });

      return {
        'total_materias': totalMaterias,
        'media_geral': materiasComMedia > 0
            ? double.parse((somaMedias / materiasComMedia).toStringAsFixed(2))
            : 0.0,
        'aprovado_em': aprovado,
        'recuperacao_em': recuperacao,
        'reprovado_em': reprovado,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: ${e.toString()}');
    }
  }

  // Salvar notas detalhadas de um aluno em uma matéria e bimestre específicos
  Future<void> salvarNotasDetalhadas({
    required String alunoId,
    required String materia,
    required int bimestre,
    double? prova,
    double? trabalho,
  }) async {
    try {
      // Validar notas
      if (prova != null && (prova < 0 || prova > 10)) {
        throw 'Nota de prova deve estar entre 0 e 10';
      }
      if (trabalho != null && (trabalho < 0 || trabalho > 10)) {
        throw 'Nota de trabalho deve estar entre 0 e 10';
      }

      // Calcular média do bimestre
      double? mediaProva = prova;
      double? mediaTrabalho = trabalho;
      double? mediaBimestre;

      if (prova != null && trabalho != null) {
        mediaBimestre =
            double.parse(((prova + trabalho) / 2).toStringAsFixed(2));
      } else if (prova != null) {
        mediaBimestre = double.parse(prova.toStringAsFixed(2));
      } else if (trabalho != null) {
        mediaBimestre = double.parse(trabalho.toStringAsFixed(2));
      }

      final bimKey = 'bim$bimestre';

      // Salvar no Firestore
      await FirebaseFirestore.instance.collection('notas').doc(alunoId).set({
        materia: {
          bimKey: {
            'prova': prova,
            'trabalho': trabalho,
            'media': mediaBimestre,
          }
        }
      }, SetOptions(merge: true));

      // Calcular média geral da matéria
      final notasDoc = await FirebaseFirestore.instance
          .collection('notas')
          .doc(alunoId)
          .get();
      if (notasDoc.exists) {
        final todasNotas = notasDoc.data() as Map<String, dynamic>;
        final notasMateria = todasNotas[materia] as Map<String, dynamic>?;

        if (notasMateria != null) {
          List<double> medias = [];
          for (int i = 1; i <= 4; i++) {
            final bimData = notasMateria['bim$i'] as Map<String, dynamic>?;
            if (bimData?['media'] != null) {
              medias.add(bimData!['media']);
            }
          }

          double mediaFinal = 0.0;
          if (medias.isNotEmpty) {
            mediaFinal = double.parse(
                (medias.reduce((a, b) => a + b) / medias.length)
                    .toStringAsFixed(2));
          }

          String situacao = 'Pendente';
          if (mediaFinal > 0) {
            if (mediaFinal >= 7.0) {
              situacao = 'Aprovado';
            } else if (mediaFinal >= 5.0) {
              situacao = 'Recuperação';
            } else {
              situacao = 'Reprovado';
            }
          }

          await FirebaseFirestore.instance
              .collection('notas')
              .doc(alunoId)
              .update({
            '$materia.media_final': mediaFinal,
            '$materia.situacao': situacao,
          });
        }
      }
    } catch (e) {
      throw Exception('Erro ao salvar notas: $e');
    }
  }
}
