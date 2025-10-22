import 'package:flutter_test/flutter_test.dart';
import 'package:educ_poli/models/usuarios.dart';

void main() {
  group('Modelo Usuario - Testes Unitários (Caixa Branca)', () {
    test('Deve criar um usuário do tipo Aluno com todos os campos', () {
      // Arrange & Act
      final usuario = Usuario(
        id: '123',
        nome: 'João Silva',
        email: 'joao@email.com',
        ra: '2025001',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: ['Matemática', 'Português'],
      );

      // Assert
      expect(usuario.id, '123');
      expect(usuario.nome, 'João Silva');
      expect(usuario.email, 'joao@email.com');
      expect(usuario.ra, '2025001');
      expect(usuario.tipo, TipoUsuario.aluno);
      expect(usuario.materias.length, 2);
      expect(usuario.materias, contains('Matemática'));
    });

    test('Deve criar um usuário do tipo Professor', () {
      // Arrange & Act
      final usuario = Usuario(
        id: '456',
        nome: 'Maria Santos',
        email: 'maria@email.com',
        ra: 'PROF001',
        tipo: TipoUsuario.professor,
        criadoEm: DateTime(2024, 1, 1),
        materias: ['Matemática', 'Física'],
      );

      // Assert
      expect(usuario.tipo, TipoUsuario.professor);
      expect(usuario.materias, contains('Matemática'));
      expect(usuario.ra, 'PROF001');
    });

    test('Deve criar um usuário do tipo Diretor', () {
      // Arrange & Act
      final usuario = Usuario(
        id: '789',
        nome: 'Pedro Costa',
        email: 'pedro@email.com',
        ra: 'DIR001',
        tipo: TipoUsuario.diretor,
        criadoEm: DateTime(2023, 1, 1),
        materias: [],
      );

      // Assert
      expect(usuario.tipo, TipoUsuario.diretor);
      expect(usuario.materias.isEmpty, true);
    });

    test('Deve converter Usuario para Map corretamente', () {
      // Arrange
      final usuario = Usuario(
        id: '123',
        nome: 'Ana Silva',
        email: 'ana@email.com',
        ra: '2025002',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: ['Biologia'],
      );

      // Act
      final map = usuario.toMap();

      // Assert
      expect(map['nome'], 'Ana Silva');
      expect(map['email'], 'ana@email.com');
      expect(map['ra'], '2025002');
      expect(map['tipo'], 'aluno');
      expect(map['materias'], contains('Biologia'));
    });

    test('Deve criar Usuario a partir de Map', () {
      // Arrange
      final map = {
        'id': 'abc123',
        'nome': 'Carlos Lima',
        'email': 'carlos@email.com',
        'ra': 'PROF002',
        'tipo': 'professor',
        'criadoEm': DateTime(2024, 1, 1).toIso8601String(),
        'materias': ['Física', 'Química'],
        'fotoUrl': null,
      };

      // Act
      final usuario = Usuario.fromMap(map);

      // Assert
      expect(usuario.id, 'abc123');
      expect(usuario.nome, 'Carlos Lima');
      expect(usuario.tipo, TipoUsuario.professor);
      expect(usuario.materias.length, 2);
    });

    test('Deve retornar tipo de usuário correto do enum', () {
      // Assert
      expect(TipoUsuario.aluno.toString(), 'TipoUsuario.aluno');
      expect(TipoUsuario.professor.toString(), 'TipoUsuario.professor');
      expect(TipoUsuario.diretor.toString(), 'TipoUsuario.diretor');
    });

    test('Deve criar usuário com foto URL', () {
      // Arrange & Act
      final usuario = Usuario(
        id: '999',
        nome: 'Usuário com Foto',
        email: 'foto@email.com',
        ra: '2025003',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: ['Matemática'],
        fotoUrl: 'https://exemplo.com/foto.jpg',
      );

      // Assert
      expect(usuario.fotoUrl, 'https://exemplo.com/foto.jpg');
    });

    test('Deve criar usuário sem materias', () {
      // Arrange & Act
      final usuario = Usuario(
        id: '888',
        nome: 'Diretor Teste',
        email: 'diretor@email.com',
        ra: 'DIR002',
        tipo: TipoUsuario.diretor,
        criadoEm: DateTime(2023, 1, 1),
        materias: [],
      );

      // Assert
      expect(usuario.materias.isEmpty, true);
    });

    test('Deve comparar dois usuários pela igualdade', () {
      // Arrange
      final usuario1 = Usuario(
        id: '123',
        nome: 'João',
        email: 'joao@email.com',
        ra: '2025001',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: ['Matemática'],
      );

      final usuario2 = Usuario(
        id: '123',
        nome: 'João',
        email: 'joao@email.com',
        ra: '2025001',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: ['Matemática'],
      );

      // Assert
      expect(usuario1.id, usuario2.id);
    });
  });

  group('Usuario - Testes de Validação (Caixa Preta)', () {
    test('Deve aceitar email válido', () {
      final usuario = Usuario(
        id: '1',
        nome: 'Teste',
        email: 'teste@email.com',
        ra: '2025001',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: [],
      );

      expect(usuario.email, contains('@'));
    });

    test('Deve aceitar diferentes formatos de RA', () {
      final usuario1 = Usuario(
        id: '1',
        nome: 'Teste 1',
        email: 'teste1@email.com',
        ra: '2025001',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: [],
      );

      final usuario2 = Usuario(
        id: '2',
        nome: 'Teste 2',
        email: 'teste2@email.com',
        ra: 'PROF001',
        tipo: TipoUsuario.professor,
        criadoEm: DateTime(2024, 1, 1),
        materias: ['Matemática'],
      );

      expect(usuario1.ra, '2025001');
      expect(usuario2.ra, 'PROF001');
    });

    test('Deve aceitar lista vazia de matérias', () {
      final usuario = Usuario(
        id: '3',
        nome: 'Teste 3',
        email: 'teste3@email.com',
        ra: 'DIR001',
        tipo: TipoUsuario.diretor,
        criadoEm: DateTime(2023, 1, 1),
        materias: [],
      );

      expect(usuario.materias, isEmpty);
    });

    test('Deve aceitar múltiplas matérias', () {
      final usuario = Usuario(
        id: '4',
        nome: 'Teste 4',
        email: 'teste4@email.com',
        ra: '2025002',
        tipo: TipoUsuario.aluno,
        criadoEm: DateTime(2025, 1, 15),
        materias: ['Matemática', 'Física', 'Química', 'Biologia'],
      );

      expect(usuario.materias.length, 4);
    });
  });
}
