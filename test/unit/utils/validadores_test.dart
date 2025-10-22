import 'package:flutter_test/flutter_test.dart';

// Classe de validadores (criar em lib/utils/validadores.dart)
class Validadores {
  static String? validarEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email é obrigatório';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(email)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validarCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'CPF é obrigatório';
    }

    final numeros = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(numeros)) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? validarSenha(String? senha) {
    if (senha == null || senha.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (senha.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  static String? validarNota(double? nota) {
    if (nota == null) {
      return 'Nota é obrigatória';
    }
    if (nota < 0 || nota > 10) {
      return 'Nota deve estar entre 0 e 10';
    }
    return null;
  }

  static String? validarNome(String? nome) {
    if (nome == null || nome.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (nome.length < 3) {
      return 'Nome deve ter no mínimo 3 caracteres';
    }
    return null;
  }

  static String? validarTurma(String? turma) {
    if (turma == null || turma.isEmpty) {
      return 'Turma é obrigatória';
    }
    return null;
  }
}

void main() {
  group('Validadores - Email (Caixa Branca)', () {
    test('Email válido retorna null', () {
      expect(Validadores.validarEmail('usuario@email.com'), null);
      expect(Validadores.validarEmail('teste.user@dominio.com.br'), null);
      expect(Validadores.validarEmail('user123@test.co'), null);
    });

    test('Email vazio retorna erro', () {
      expect(Validadores.validarEmail(''), 'Email é obrigatório');
      expect(Validadores.validarEmail(null), 'Email é obrigatório');
    });

    test('Email sem @ retorna erro', () {
      expect(Validadores.validarEmail('usuarioemail.com'), 'Email inválido');
    });

    test('Email sem domínio retorna erro', () {
      expect(Validadores.validarEmail('usuario@'), 'Email inválido');
    });

    test('Email sem nome de usuário retorna erro', () {
      expect(Validadores.validarEmail('@dominio.com'), 'Email inválido');
    });
  });

  group('Validadores - CPF (Caixa Branca)', () {
    test('CPF válido retorna null', () {
      expect(Validadores.validarCPF('123.456.789-09'), null);
      expect(Validadores.validarCPF('12345678909'), null);
    });

    test('CPF vazio retorna erro', () {
      expect(Validadores.validarCPF(''), 'CPF é obrigatório');
      expect(Validadores.validarCPF(null), 'CPF é obrigatório');
    });

    test('CPF com menos de 11 dígitos retorna erro', () {
      expect(Validadores.validarCPF('123.456'), 'CPF deve ter 11 dígitos');
      expect(Validadores.validarCPF('123456789'), 'CPF deve ter 11 dígitos');
    });

    test('CPF com todos os dígitos iguais retorna erro', () {
      expect(Validadores.validarCPF('111.111.111-11'), 'CPF inválido');
      expect(Validadores.validarCPF('000.000.000-00'), 'CPF inválido');
      expect(Validadores.validarCPF('999.999.999-99'), 'CPF inválido');
    });

    test('CPF aceita formato com e sem pontuação', () {
      expect(Validadores.validarCPF('123.456.789-09'), null);
      expect(Validadores.validarCPF('12345678909'), null);
    });
  });

  group('Validadores - Senha (Caixa Preta)', () {
    test('Senha válida retorna null', () {
      expect(Validadores.validarSenha('senha123'), null);
      expect(Validadores.validarSenha('123456'), null);
      expect(Validadores.validarSenha('SenhaForte@123'), null);
    });

    test('Senha vazia retorna erro', () {
      expect(Validadores.validarSenha(''), 'Senha é obrigatória');
      expect(Validadores.validarSenha(null), 'Senha é obrigatória');
    });

    test('Senha menor que 6 caracteres retorna erro', () {
      expect(Validadores.validarSenha('12345'),
          'Senha deve ter no mínimo 6 caracteres');
      expect(Validadores.validarSenha('abc'),
          'Senha deve ter no mínimo 6 caracteres');
      expect(Validadores.validarSenha('1'),
          'Senha deve ter no mínimo 6 caracteres');
    });

    test('Senha com exatamente 6 caracteres é válida', () {
      expect(Validadores.validarSenha('123456'), null);
    });
  });

  group('Validadores - Nota (Caixa Preta)', () {
    test('Nota válida retorna null', () {
      expect(Validadores.validarNota(0.0), null);
      expect(Validadores.validarNota(5.0), null);
      expect(Validadores.validarNota(10.0), null);
      expect(Validadores.validarNota(8.5), null);
    });

    test('Nota null retorna erro', () {
      expect(Validadores.validarNota(null), 'Nota é obrigatória');
    });

    test('Nota maior que 10 retorna erro', () {
      expect(Validadores.validarNota(10.1), 'Nota deve estar entre 0 e 10');
      expect(Validadores.validarNota(15.0), 'Nota deve estar entre 0 e 10');
      expect(Validadores.validarNota(100.0), 'Nota deve estar entre 0 e 10');
    });

    test('Nota menor que 0 retorna erro', () {
      expect(Validadores.validarNota(-0.1), 'Nota deve estar entre 0 e 10');
      expect(Validadores.validarNota(-5.0), 'Nota deve estar entre 0 e 10');
    });

    test('Nota nos limites é válida', () {
      expect(Validadores.validarNota(0.0), null);
      expect(Validadores.validarNota(10.0), null);
    });
  });

  group('Validadores - Nome (Caixa Preta)', () {
    test('Nome válido retorna null', () {
      expect(Validadores.validarNome('João'), null);
      expect(Validadores.validarNome('Maria Silva'), null);
      expect(Validadores.validarNome('Pedro de Souza Costa'), null);
    });

    test('Nome vazio retorna erro', () {
      expect(Validadores.validarNome(''), 'Nome é obrigatório');
      expect(Validadores.validarNome(null), 'Nome é obrigatório');
    });

    test('Nome muito curto retorna erro', () {
      expect(Validadores.validarNome('Ab'),
          'Nome deve ter no mínimo 3 caracteres');
      expect(
          Validadores.validarNome('A'), 'Nome deve ter no mínimo 3 caracteres');
    });

    test('Nome com 3 caracteres é válido', () {
      expect(Validadores.validarNome('Ana'), null);
    });
  });

  group('Validadores - Turma (Caixa Preta)', () {
    test('Turma válida retorna null', () {
      expect(Validadores.validarTurma('A1'), null);
      expect(Validadores.validarTurma('B2'), null);
      expect(Validadores.validarTurma('3º Ano A'), null);
    });

    test('Turma vazia retorna erro', () {
      expect(Validadores.validarTurma(''), 'Turma é obrigatória');
      expect(Validadores.validarTurma(null), 'Turma é obrigatória');
    });
  });
}
