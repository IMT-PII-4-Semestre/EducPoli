import 'package:flutter_test/flutter_test.dart';

/// Mock do AuthGuard para testes
class MockAuthGuard {
  static String? _usuarioAtual;
  static String? _tipoUsuarioAtual;

  static void setUsuarioAtual(String uid, String tipo) {
    _usuarioAtual = uid;
    _tipoUsuarioAtual = tipo;
  }

  static void clearUsuario() {
    _usuarioAtual = null;
    _tipoUsuarioAtual = null;
  }

  static bool estaAutenticado() {
    return _usuarioAtual != null;
  }

  static String? obterTipoUsuario() {
    return _tipoUsuarioAtual;
  }

  static bool temPermissao(String rota) {
    if (!estaAutenticado()) {
      return false;
    }

    const rotasAluno = [
      '/dashboard-aluno',
      '/aluno/materias',
      '/aluno/notas',
      '/aluno/mensagem',
    ];

    const rotasProfessor = [
      '/dashboard-professor',
      '/professor/materias',
      '/professor/notas',
      '/professor/mensagens',
    ];

    const rotasDiretor = [
      '/dashboard-diretor',
      '/diretor/alunos',
      '/diretor/professores',
      '/diretor/cadastrar-aluno',
      '/diretor/cadastrar-professor',
    ];

    if (_tipoUsuarioAtual == 'aluno') {
      return rotasAluno.contains(rota);
    } else if (_tipoUsuarioAtual == 'professor') {
      return rotasProfessor.contains(rota);
    } else if (_tipoUsuarioAtual == 'diretor') {
      return rotasDiretor.contains(rota);
    }

    return false;
  }

  static String obterRotaPadrao() {
    switch (_tipoUsuarioAtual) {
      case 'aluno':
        return '/dashboard-aluno';
      case 'professor':
        return '/dashboard-professor';
      case 'diretor':
        return '/dashboard-diretor';
      default:
        return '/login';
    }
  }

  static List<String> obterRotasDisponiveisPara(String tipo) {
    switch (tipo) {
      case 'aluno':
        return [
          '/dashboard-aluno',
          '/aluno/materias',
          '/aluno/notas',
          '/aluno/mensagem',
        ];
      case 'professor':
        return [
          '/dashboard-professor',
          '/professor/materias',
          '/professor/notas',
          '/professor/mensagens',
        ];
      case 'diretor':
        return [
          '/dashboard-diretor',
          '/diretor/alunos',
          '/diretor/professores',
          '/diretor/cadastrar-aluno',
          '/diretor/cadastrar-professor',
        ];
      default:
        return [];
    }
  }
}

void main() {
  group('AuthGuard - Autenticação (Caixa Branca)', () {
    setUp(() {
      MockAuthGuard.clearUsuario();
    });

    test('Usuário não autenticado deve retornar false', () {
      expect(MockAuthGuard.estaAutenticado(), false);
    });

    test('Usuário autenticado deve retornar true', () {
      MockAuthGuard.setUsuarioAtual('user123', 'aluno');
      expect(MockAuthGuard.estaAutenticado(), true);
    });

    test('Deve limpar usuário autenticado', () {
      MockAuthGuard.setUsuarioAtual('user123', 'aluno');
      expect(MockAuthGuard.estaAutenticado(), true);

      MockAuthGuard.clearUsuario();
      expect(MockAuthGuard.estaAutenticado(), false);
    });

    test('Deve armazenar tipo de usuário corretamente', () {
      MockAuthGuard.setUsuarioAtual('user123', 'professor');
      expect(MockAuthGuard.obterTipoUsuario(), 'professor');
    });
  });

  group('AuthGuard - Permissões por Tipo de Usuário (Caixa Branca)', () {
    setUp(() {
      MockAuthGuard.clearUsuario();
    });

    test('Aluno deve acessar apenas rotas de aluno', () {
      MockAuthGuard.setUsuarioAtual('aluno123', 'aluno');

      expect(MockAuthGuard.temPermissao('/dashboard-aluno'), true);
      expect(MockAuthGuard.temPermissao('/aluno/materias'), true);
      expect(MockAuthGuard.temPermissao('/aluno/notas'), true);
    });

    test('Aluno não deve acessar rotas de professor', () {
      MockAuthGuard.setUsuarioAtual('aluno123', 'aluno');

      expect(MockAuthGuard.temPermissao('/dashboard-professor'), false);
      expect(MockAuthGuard.temPermissao('/professor/notas'), false);
    });

    test('Aluno não deve acessar rotas de diretor', () {
      MockAuthGuard.setUsuarioAtual('aluno123', 'aluno');

      expect(MockAuthGuard.temPermissao('/diretor/alunos'), false);
      expect(MockAuthGuard.temPermissao('/diretor/cadastrar-aluno'), false);
    });

    test('Professor deve acessar apenas rotas de professor', () {
      MockAuthGuard.setUsuarioAtual('prof123', 'professor');

      expect(MockAuthGuard.temPermissao('/dashboard-professor'), true);
      expect(MockAuthGuard.temPermissao('/professor/materias'), true);
      expect(MockAuthGuard.temPermissao('/professor/notas'), true);
    });

    test('Professor não deve acessar rotas de aluno', () {
      MockAuthGuard.setUsuarioAtual('prof123', 'professor');

      expect(MockAuthGuard.temPermissao('/dashboard-aluno'), false);
      expect(MockAuthGuard.temPermissao('/aluno/notas'), false);
    });

    test('Diretor deve acessar rotas de diretor', () {
      MockAuthGuard.setUsuarioAtual('dir123', 'diretor');

      expect(MockAuthGuard.temPermissao('/dashboard-diretor'), true);
      expect(MockAuthGuard.temPermissao('/diretor/alunos'), true);
      expect(MockAuthGuard.temPermissao('/diretor/cadastrar-professor'), true);
    });

    test('Diretor não deve acessar rotas de aluno ou professor', () {
      MockAuthGuard.setUsuarioAtual('dir123', 'diretor');

      expect(MockAuthGuard.temPermissao('/dashboard-aluno'), false);
      expect(MockAuthGuard.temPermissao('/dashboard-professor'), false);
    });
  });

  group('AuthGuard - Rotas Padrão (Caixa Branca)', () {
    setUp(() {
      MockAuthGuard.clearUsuario();
    });

    test('Aluno deve ser redirecionado para /dashboard-aluno', () {
      MockAuthGuard.setUsuarioAtual('aluno123', 'aluno');
      expect(MockAuthGuard.obterRotaPadrao(), '/dashboard-aluno');
    });

    test('Professor deve ser redirecionado para /dashboard-professor', () {
      MockAuthGuard.setUsuarioAtual('prof123', 'professor');
      expect(MockAuthGuard.obterRotaPadrao(), '/dashboard-professor');
    });

    test('Diretor deve ser redirecionado para /dashboard-diretor', () {
      MockAuthGuard.setUsuarioAtual('dir123', 'diretor');
      expect(MockAuthGuard.obterRotaPadrao(), '/dashboard-diretor');
    });

    test('Usuário não autenticado deve ir para /login', () {
      MockAuthGuard.clearUsuario();
      expect(MockAuthGuard.obterRotaPadrao(), '/login');
    });

    test('Tipo de usuário inválido deve ir para /login', () {
      MockAuthGuard.setUsuarioAtual('user123', 'tipo_invalido');
      expect(MockAuthGuard.obterRotaPadrao(), '/login');
    });
  });

  group('AuthGuard - Proteção de Rotas Desprotegidas (Caixa Preta)', () {
    setUp(() {
      MockAuthGuard.clearUsuario();
    });

    test('Rota não autenticada não deve permitir acesso', () {
      expect(MockAuthGuard.temPermissao('/dashboard-aluno'), false);
      expect(MockAuthGuard.temPermissao('/dashboard-professor'), false);
      expect(MockAuthGuard.temPermissao('/dashboard-diretor'), false);
    });

    test('Rota inexistente deve retornar false', () {
      MockAuthGuard.setUsuarioAtual('user123', 'aluno');
      expect(MockAuthGuard.temPermissao('/rota-inexistente'), false);
    });

    test('Aluno deve ter acesso a todas as suas rotas', () {
      MockAuthGuard.setUsuarioAtual('aluno123', 'aluno');
      final rotasAluno = MockAuthGuard.obterRotasDisponiveisPara('aluno');

      for (String rota in rotasAluno) {
        expect(
          MockAuthGuard.temPermissao(rota),
          true,
          reason: 'Aluno deve ter acesso a $rota',
        );
      }
    });

    test('Professor deve ter acesso a todas as suas rotas', () {
      MockAuthGuard.setUsuarioAtual('prof123', 'professor');
      final rotasProfessor =
          MockAuthGuard.obterRotasDisponiveisPara('professor');

      for (String rota in rotasProfessor) {
        expect(
          MockAuthGuard.temPermissao(rota),
          true,
          reason: 'Professor deve ter acesso a $rota',
        );
      }
    });

    test('Diretor deve ter acesso a todas as suas rotas', () {
      MockAuthGuard.setUsuarioAtual('dir123', 'diretor');
      final rotasDiretor = MockAuthGuard.obterRotasDisponiveisPara('diretor');

      for (String rota in rotasDiretor) {
        expect(
          MockAuthGuard.temPermissao(rota),
          true,
          reason: 'Diretor deve ter acesso a $rota',
        );
      }
    });
  });

  group('AuthGuard - Casos Extremos (Caixa Preta)', () {
    setUp(() {
      MockAuthGuard.clearUsuario();
    });

    test('Deve manter estado após múltiplas verificações', () {
      MockAuthGuard.setUsuarioAtual('user123', 'aluno');

      expect(MockAuthGuard.estaAutenticado(), true);
      expect(MockAuthGuard.estaAutenticado(), true);
      expect(MockAuthGuard.obterTipoUsuario(), 'aluno');
      expect(MockAuthGuard.obterTipoUsuario(), 'aluno');
    });

    test('Deve permitir mudança de usuário', () {
      MockAuthGuard.setUsuarioAtual('aluno123', 'aluno');
      expect(MockAuthGuard.temPermissao('/dashboard-aluno'), true);

      MockAuthGuard.setUsuarioAtual('prof123', 'professor');
      expect(MockAuthGuard.temPermissao('/dashboard-professor'), true);
      expect(MockAuthGuard.temPermissao('/dashboard-aluno'), false);
    });

    test('Tipo de usuário vazio deve negar todas permissões', () {
      MockAuthGuard.setUsuarioAtual('user123', '');
      expect(MockAuthGuard.temPermissao('/dashboard-aluno'), false);
      expect(MockAuthGuard.temPermissao('/dashboard-professor'), false);
      expect(MockAuthGuard.temPermissao('/dashboard-diretor'), false);
    });

    test('Usuário null deve ser tratado como não autenticado', () {
      MockAuthGuard.clearUsuario();
      expect(MockAuthGuard.estaAutenticado(), false);
      expect(MockAuthGuard.obterRotaPadrao(), '/login');
    });
  });
}
