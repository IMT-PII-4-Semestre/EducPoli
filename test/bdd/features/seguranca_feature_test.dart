import 'package:flutter_test/flutter_test.dart';

/// Mock para teste de Segurança e Autenticação
class MockSecurityService {
  final Map<String, Map<String, dynamic>> _usuarios = {
    'aluno123': {
      'email': 'aluno@test.com',
      'tipo': 'aluno',
      'ativo': true,
      'senha': 'senha123',
    },
    'prof456': {
      'email': 'prof@test.com',
      'tipo': 'professor',
      'ativo': true,
      'senha': 'prof123',
    },
    'dir789': {
      'email': 'diretor@test.com',
      'tipo': 'diretor',
      'ativo': true,
      'senha': 'dir123',
    },
  };

  String? _usuarioLogado;

  Future<bool> fazerLogin(String email, String senha) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final usuario = _usuarios.values.firstWhere(
      (u) => u['email'] == email && u['ativo'] == true,
      orElse: () => {},
    );

    if (usuario.isEmpty) {
      throw Exception('Usuário não encontrado ou inativo');
    }

    if (usuario['senha'] != senha) {
      throw Exception('Senha incorreta');
    }

    // Encontra a chave do usuário
    final chave = _usuarios.keys.firstWhere(
      (k) => _usuarios[k]!['email'] == email,
    );

    _usuarioLogado = chave;
    return true;
  }

  bool estaAutenticado() {
    return _usuarioLogado != null;
  }

  String? obterTipoUsuarioLogado() {
    if (_usuarioLogado == null) return null;
    return _usuarios[_usuarioLogado]?['tipo'];
  }

  void sair() {
    _usuarioLogado = null;
  }

  bool verificarPermissao(String tipo, String rota) {
    const rotasAluno = [
      '/dashboard-aluno',
      '/aluno/materias',
      '/aluno/notas',
    ];

    const rotasProfessor = [
      '/dashboard-professor',
      '/professor/materias',
      '/professor/notas',
    ];

    const rotasDiretor = [
      '/dashboard-diretor',
      '/diretor/alunos',
      '/diretor/professores',
    ];

    switch (tipo) {
      case 'aluno':
        return rotasAluno.contains(rota);
      case 'professor':
        return rotasProfessor.contains(rota);
      case 'diretor':
        return rotasDiretor.contains(rota);
      default:
        return false;
    }
  }

  Future<void> bloquearUsuario(String uid) async {
    if (_usuarios.containsKey(uid)) {
      _usuarios[uid]!['ativo'] = false;
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> desbloquearUsuario(String uid) async {
    if (_usuarios.containsKey(uid)) {
      _usuarios[uid]!['ativo'] = true;
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }

  bool usuarioEstaAtivo(String uid) {
    return _usuarios[uid]?['ativo'] ?? false;
  }

  Future<bool> alterarSenha(
      String uid, String senhaAntiga, String senhaNova) async {
    if (!_usuarios.containsKey(uid)) {
      throw Exception('Usuário não encontrado');
    }

    if (_usuarios[uid]!['senha'] != senhaAntiga) {
      throw Exception('Senha anterior incorreta');
    }

    if (senhaAntiga == senhaNova) {
      throw Exception('Nova senha não pode ser igual à anterior');
    }

    if (senhaNova.length < 6) {
      throw ArgumentError('Senha deve ter no mínimo 6 caracteres');
    }

    _usuarios[uid]!['senha'] = senhaNova;
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
}

void main() {
  group('Segurança - BDD: Autenticação e Login', () {
    late MockSecurityService service;

    setUp(() {
      service = MockSecurityService();
    });

    test('Cenário: Aluno faz login com credenciais válidas', () async {
      // Given
      final email = 'aluno@test.com';
      final senha = 'senha123';

      // When
      final resultado = await service.fazerLogin(email, senha);

      // Then
      expect(resultado, true);
      expect(service.estaAutenticado(), true);
      expect(service.obterTipoUsuarioLogado(), 'aluno');
    });

    test('Cenário: Professor faz login com credenciais válidas', () async {
      // When
      final resultado = await service.fazerLogin('prof@test.com', 'prof123');

      // Then
      expect(resultado, true);
      expect(service.obterTipoUsuarioLogado(), 'professor');
    });

    test('Cenário: Diretor faz login com credenciais válidas', () async {
      // When
      final resultado = await service.fazerLogin('diretor@test.com', 'dir123');

      // Then
      expect(resultado, true);
      expect(service.obterTipoUsuarioLogado(), 'diretor');
    });

    test('Cenário: Login com email inválido falha', () async {
      // When & Then
      expect(
        () => service.fazerLogin('inexistente@test.com', 'senha123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Login com senha incorreta falha', () async {
      // When & Then
      expect(
        () => service.fazerLogin('aluno@test.com', 'senhaErrada'),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Logout limpa sessão de usuário', () async {
      // Given
      await service.fazerLogin('aluno@test.com', 'senha123');
      expect(service.estaAutenticado(), true);

      // When
      service.sair();

      // Then
      expect(service.estaAutenticado(), false);
      expect(service.obterTipoUsuarioLogado(), null);
    });
  });

  group('Segurança - BDD: Controle de Acesso por Tipo', () {
    late MockSecurityService service;

    setUp(() {
      service = MockSecurityService();
    });

    test('Cenário: Aluno acessa apenas rotas de aluno', () async {
      // Given
      await service.fazerLogin('aluno@test.com', 'senha123');

      // Then
      expect(service.verificarPermissao('aluno', '/dashboard-aluno'), true);
      expect(service.verificarPermissao('aluno', '/aluno/notas'), true);
      expect(
          service.verificarPermissao('aluno', '/dashboard-professor'), false);
      expect(service.verificarPermissao('aluno', '/diretor/alunos'), false);
    });

    test('Cenário: Professor acessa apenas rotas de professor', () async {
      // Given
      await service.fazerLogin('prof@test.com', 'prof123');

      // Then
      expect(service.verificarPermissao('professor', '/dashboard-professor'),
          true);
      expect(service.verificarPermissao('professor', '/professor/notas'), true);
      expect(
          service.verificarPermissao('professor', '/dashboard-aluno'), false);
      expect(service.verificarPermissao('professor', '/diretor/alunos'), false);
    });

    test('Cenário: Diretor acessa apenas rotas de diretor', () async {
      // Given
      await service.fazerLogin('diretor@test.com', 'dir123');

      // Then
      expect(service.verificarPermissao('diretor', '/dashboard-diretor'), true);
      expect(service.verificarPermissao('diretor', '/diretor/alunos'), true);
      expect(service.verificarPermissao('diretor', '/dashboard-aluno'), false);
      expect(service.verificarPermissao('diretor', '/professor/notas'), false);
    });

    test('Cenário: Tipo inválido não tem permissão', () async {
      // When & Then
      expect(service.verificarPermissao('tipo_invalido', '/dashboard-aluno'),
          false);
      expect(service.verificarPermissao('tipo_invalido', '/professor/notas'),
          false);
    });
  });

  group('Segurança - BDD: Bloqueio e Desbloqueio de Usuários', () {
    late MockSecurityService service;

    setUp(() {
      service = MockSecurityService();
    });

    test('Cenário: Diretor bloqueia usuário inativo', () async {
      // Given
      final uid = 'aluno123';
      expect(service.usuarioEstaAtivo(uid), true);

      // When
      await service.bloquearUsuario(uid);

      // Then
      expect(service.usuarioEstaAtivo(uid), false);
      expect(
        () => service.fazerLogin('aluno@test.com', 'senha123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Diretor desbloqueia usuário', () async {
      // Given
      final uid = 'aluno123';
      await service.bloquearUsuario(uid);
      expect(service.usuarioEstaAtivo(uid), false);

      // When
      await service.desbloquearUsuario(uid);

      // Then
      expect(service.usuarioEstaAtivo(uid), true);
      final resultado = await service.fazerLogin('aluno@test.com', 'senha123');
      expect(resultado, true);
    });

    test('Cenário: Usuário bloqueado não consegue fazer login', () async {
      // Given
      await service.bloquearUsuario('prof456');

      // When & Then
      expect(
        () => service.fazerLogin('prof@test.com', 'prof123'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Segurança - BDD: Alteração de Senha', () {
    late MockSecurityService service;

    setUp(() {
      service = MockSecurityService();
    });

    test('Cenário: Usuário altera senha com sucesso', () async {
      // Given
      final uid = 'aluno123';
      const senhaAntiga = 'senha123';
      const senhaNova = 'novaSenha123';

      // When
      final resultado = await service.alterarSenha(uid, senhaAntiga, senhaNova);

      // Then
      expect(resultado, true);
      expect(
        () => service.fazerLogin('aluno@test.com', senhaAntiga),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Não permite alterar senha com senha antiga incorreta',
        () async {
      // When & Then
      expect(
        () => service.alterarSenha('aluno123', 'senhaErrada', 'nova123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Não permite nova senha igual à anterior', () async {
      // When & Then
      expect(
        () => service.alterarSenha('aluno123', 'senha123', 'senha123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Não permite senha com menos de 6 caracteres', () async {
      // When & Then
      expect(
        () => service.alterarSenha('aluno123', 'senha123', '12345'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Cenário: Usuário pode fazer login com nova senha', () async {
      // Given
      const senhaAntiga = 'senha123';
      const senhaNova = 'novaSenha456';
      await service.alterarSenha('aluno123', senhaAntiga, senhaNova);

      // When
      final resultado = await service.fazerLogin('aluno@test.com', senhaNova);

      // Then
      expect(resultado, true);
    });
  });

  group('Segurança - BDD: Casos de Ataque (Caixa Preta)', () {
    late MockSecurityService service;

    setUp(() {
      service = MockSecurityService();
    });

    test('Cenário: Força bruta - múltiplas tentativas de login falham',
        () async {
      // When
      for (int i = 0; i < 5; i++) {
        expect(
          () => service.fazerLogin('aluno@test.com', 'senhaErrada$i'),
          throwsA(isA<Exception>()),
        );
      }

      // Then - Usuário ainda pode fazer login com credenciais corretas
      final resultado = await service.fazerLogin('aluno@test.com', 'senha123');
      expect(resultado, true);
    });

    test('Cenário: Mudança rápida entre usuários', () async {
      // When
      await service.fazerLogin('aluno@test.com', 'senha123');
      expect(service.obterTipoUsuarioLogado(), 'aluno');

      service.sair();

      await service.fazerLogin('prof@test.com', 'prof123');
      expect(service.obterTipoUsuarioLogado(), 'professor');

      // Then
      service.sair();
      expect(service.estaAutenticado(), false);
    });

    test('Cenário: Tentativa de acesso a rota protegida sem autenticação',
        () async {
      // Given
      service.sair(); // Garante que não há usuário autenticado

      // Then
      expect(service.estaAutenticado(), false);
      expect(service.verificarPermissao('aluno', '/dashboard-aluno'), false);
    });

    test('Cenário: Token não persiste após logout', () async {
      // Given
      await service.fazerLogin('aluno@test.com', 'senha123');
      expect(service.estaAutenticado(), true);

      // When
      service.sair();

      // Then
      expect(service.estaAutenticado(), false);
      expect(service.obterTipoUsuarioLogado(), null);
      expect(service.verificarPermissao('aluno', '/dashboard-aluno'), false);
    });
  });
}
