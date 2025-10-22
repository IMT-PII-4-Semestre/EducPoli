import 'package:flutter_test/flutter_test.dart';

// Modelo de Nota (criar em lib/models/nota.dart se não existir)
class Nota {
  final String id;
  final String alunoId;
  final String professorId;
  final String disciplina;
  final double valor;
  final String bimestre;
  final DateTime data;

  const Nota({
    required this.id,
    required this.alunoId,
    required this.professorId,
    required this.disciplina,
    required this.valor,
    required this.bimestre,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'alunoId': alunoId,
      'professorId': professorId,
      'disciplina': disciplina,
      'valor': valor,
      'bimestre': bimestre,
      'data': data.toIso8601String(),
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map, String id) {
    return Nota(
      id: id,
      alunoId: map['alunoId'] ?? '',
      professorId: map['professorId'] ?? '',
      disciplina: map['disciplina'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      bimestre: map['bimestre'] ?? '',
      data: DateTime.parse(map['data']),
    );
  }
}

void main() {
  group('Modelo Nota - Testes Unitários (Caixa Branca)', () {
    test('Deve criar uma nota válida', () {
      // Arrange & Act
      final nota = Nota(
        id: '1',
        alunoId: 'aluno123',
        professorId: 'prof456',
        disciplina: 'Matemática',
        valor: 8.5,
        bimestre: '1º Bimestre',
        data: DateTime(2025, 3, 15),
      );

      // Assert
      expect(nota.id, '1');
      expect(nota.valor, 8.5);
      expect(nota.disciplina, 'Matemática');
      expect(nota.bimestre, '1º Bimestre');
    });

    test('Deve converter Nota para Map', () {
      // Arrange
      final nota = Nota(
        id: '2',
        alunoId: 'aluno789',
        professorId: 'prof101',
        disciplina: 'Física',
        valor: 9.0,
        bimestre: '2º Bimestre',
        data: DateTime(2025, 6, 20),
      );

      // Act
      final map = nota.toMap();

      // Assert
      expect(map['alunoId'], 'aluno789');
      expect(map['disciplina'], 'Física');
      expect(map['valor'], 9.0);
    });

    test('Deve criar Nota a partir de Map', () {
      // Arrange
      final map = {
        'alunoId': 'aluno999',
        'professorId': 'prof888',
        'disciplina': 'Química',
        'valor': 7.5,
        'bimestre': '3º Bimestre',
        'data': '2025-09-10T00:00:00.000',
      };

      // Act
      final nota = Nota.fromMap(map, 'nota123');

      // Assert
      expect(nota.id, 'nota123');
      expect(nota.valor, 7.5);
      expect(nota.disciplina, 'Química');
    });
  });

  group('Nota - Validações (Caixa Preta)', () {
    test('Nota deve estar entre 0 e 10', () {
      // Notas válidas
      expect(
          () => Nota(
                id: '1',
                alunoId: 'a1',
                professorId: 'p1',
                disciplina: 'Mat',
                valor: 0.0,
                bimestre: '1º',
                data: DateTime.now(),
              ),
          returnsNormally);

      expect(
          () => Nota(
                id: '2',
                alunoId: 'a1',
                professorId: 'p1',
                disciplina: 'Mat',
                valor: 10.0,
                bimestre: '1º',
                data: DateTime.now(),
              ),
          returnsNormally);

      // Notas inválidas
      expect(
          () => Nota(
                id: '3',
                alunoId: 'a1',
                professorId: 'p1',
                disciplina: 'Mat',
                valor: -1.0,
                bimestre: '1º',
                data: DateTime.now(),
              ),
          throwsA(isA<RangeError>()));

      expect(
          () => Nota(
                id: '4',
                alunoId: 'a1',
                professorId: 'p1',
                disciplina: 'Mat',
                valor: 11.0,
                bimestre: '1º',
                data: DateTime.now(),
              ),
          throwsA(isA<RangeError>()));
    });

    test('Deve aceitar notas com decimais', () {
      final nota = Nota(
        id: '1',
        alunoId: 'a1',
        professorId: 'p1',
        disciplina: 'Matemática',
        valor: 8.75,
        bimestre: '1º',
        data: DateTime.now(),
      );

      expect(nota.valor, 8.75);
    });
  });
}
