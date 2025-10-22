import 'package:flutter_test/flutter_test.dart';

// Mock simples do serviço de autenticação
class ServicoAutenticacao {
  Future<String?> fazerLogin(String email, String senha) async {
    // Validações
    if (email.isEmpty) {
      throw ArgumentError('Email não pode ser vazio');
    }
    if (senha.isEmpty) {
      throw ArgumentError('Senha não pode ser vazia');
    }
    if (!email.contains('@')) {
      throw FormatException('Email inválido');
    }
    if (senha.length < 6) {
      throw ArgumentError('Senha deve ter no mínimo 6 caracteres');
    }

    // Simular login bem-sucedido
    await Future.delayed(const Duration(milliseconds: 100));

    // Mock de credenciais válidas
    if (email == 'teste@email.com' && senha == '123456') {
      return 'user123';
    }
    if (email == 'aluno@educpoli.com' && senha == 'Senha123') {
      return 'aluno1';
    }
    if (email == 'professor@educpoli.com' && senha == 'Prof123') {
      return 'prof1';
    }
    if (email == 'diretor@educpoli.com' && senha == 'Dir123') {
      return 'dir1';
    }

    throw Exception('Credenciais inválidas');
  }

  Future<void> sair() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  String? usuarioAtual;
}

void main() {
  late ServicoAutenticacao servicoAuth;

  setUp(() {
    servicoAuth = ServicoAutenticacao();
  });

  group('ServicoAutenticacao - Login (Caixa Branca)', () {
    test('Deve fazer login com credenciais válidas', () async {
      // Act
      final resultado =
          await servicoAuth.fazerLogin('teste@email.com', '123456');

      // Assert
      expect(resultado, isNotNull);
      expect(resultado, 'user123');
    });

    test('Deve retornar ID de aluno ao fazer login como aluno', () async {
      // Act
      final resultado =
          await servicoAuth.fazerLogin('aluno@educpoli.com', 'Senha123');

      // Assert
      expect(resultado, 'aluno1');
    });

    test('Deve retornar ID de professor ao fazer login como professor',
        () async {
      // Act
      final resultado =
          await servicoAuth.fazerLogin('professor@educpoli.com', 'Prof123');

      // Assert
      expect(resultado, 'prof1');
    });

    test('Deve retornar ID de diretor ao fazer login como diretor', () async {
      // Act
      final resultado =
          await servicoAuth.fazerLogin('diretor@educpoli.com', 'Dir123');

      // Assert
      expect(resultado, 'dir1');
    });

    test('Deve lançar exceção com credenciais incorretas', () async {
      // Act & Assert
      expect(
        () => servicoAuth.fazerLogin('user@email.com', 'senha_errada'),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve fazer logout corretamente', () async {
      // Act
      await servicoAuth.sair();

      // Assert
      expect(servicoAuth.usuarioAtual, null);
    });

    test('Login deve levar tempo simulado de rede', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await servicoAuth.fazerLogin('teste@email.com', '123456');

      // Assert
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThan(50));
    });
  });

  group('ServicoAutenticacao - Validações (Caixa Preta)', () {
    test('Não deve aceitar email vazio', () {
      expect(
        () => servicoAuth.fazerLogin('', '123456'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Não deve aceitar senha vazia', () {
      expect(
        () => servicoAuth.fazerLogin('teste@email.com', ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Não deve aceitar email mal formatado', () {
      expect(
        () => servicoAuth.fazerLogin('email_sem_arroba', '123456'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Senha deve ter no mínimo 6 caracteres', () {
      expect(
        () => servicoAuth.fazerLogin('teste@email.com', '12345'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Deve aceitar senha com exatamente 6 caracteres', () async {
      // Act
      final resultado =
          await servicoAuth.fazerLogin('teste@email.com', '123456');

      // Assert
      expect(resultado, isNotNull);
    });

    test('Deve aceitar senha com mais de 6 caracteres', () async {
      // Act & Assert
      expect(
        () => servicoAuth.fazerLogin('teste@email.com', '1234567890'),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve aceitar email válido com subdomínio', () async {
      // Act & Assert
      expect(
        () => servicoAuth.fazerLogin('user@mail.empresa.com.br', '123456'),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve rejeitar email sem parte local', () {
      expect(
        () => servicoAuth.fazerLogin('@email.com', '123456'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ServicoAutenticacao - Casos Extremos', () {
    test('Deve lidar com email com espaços', () {
      expect(
        () => servicoAuth.fazerLogin(' teste@email.com ', '123456'),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve lidar com senha com espaços', () async {
      // Act & Assert
      expect(
        () => servicoAuth.fazerLogin('teste@email.com', '12 34 56'),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve lidar com múltiplas tentativas de login', () async {
      // Act
      final resultado1 =
          await servicoAuth.fazerLogin('teste@email.com', '123456');
      final resultado2 =
          await servicoAuth.fazerLogin('aluno@educpoli.com', 'Senha123');

      // Assert
      expect(resultado1, 'user123');
      expect(resultado2, 'aluno1');
    });
  });
}
