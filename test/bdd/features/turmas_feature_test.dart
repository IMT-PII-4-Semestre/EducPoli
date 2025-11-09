import 'package:flutter_test/flutter_test.dart';

/// Mock de Turma para testes
class Turma {
  final String id;
  final String nome;
  final String serie;
  final String turno;
  final int anoLetivo;
  final bool ativa;
  final List<String> professores;
  final List<String> alunos;

  Turma({
    required this.id,
    required this.nome,
    required this.serie,
    required this.turno,
    required this.anoLetivo,
    this.ativa = true,
    this.professores = const [],
    this.alunos = const [],
  });

  factory Turma.fromMap(Map<String, dynamic> map, String id) {
    return Turma(
      id: id,
      nome: map['nome'] ?? '',
      serie: map['serie'] ?? '',
      turno: map['turno'] ?? '',
      anoLetivo: map['anoLetivo'] ?? DateTime.now().year,
      ativa: map['ativa'] ?? true,
      professores: List<String>.from(map['professores'] ?? []),
      alunos: List<String>.from(map['alunos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'serie': serie,
      'turno': turno,
      'anoLetivo': anoLetivo,
      'ativa': ativa,
      'professores': professores,
      'alunos': alunos,
    };
  }
}

/// Mock do TurmaService para testes
class MockTurmaService {
  final Map<String, Turma> _turmas = {};

  Future<void> cadastrarTurma(Turma turma) async {
    if (turma.nome.isEmpty) {
      throw ArgumentError('Nome da turma não pode ser vazio');
    }

    if (turma.serie.isEmpty) {
      throw ArgumentError('Série não pode ser vazio');
    }

    if (turma.turno.isEmpty) {
      throw ArgumentError('Turno não pode ser vazio');
    }

    // Verifica duplicação
    if (_turmas.values.any(
      (t) => t.nome == turma.nome && t.anoLetivo == turma.anoLetivo,
    )) {
      throw Exception(
          'Turma "${turma.nome}" já existe para o ano ${turma.anoLetivo}');
    }

    await Future.delayed(const Duration(milliseconds: 50));
    _turmas[turma.id] = turma;
  }

  Future<List<Turma>> buscarTurmasAtivas() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _turmas.values.where((t) => t.ativa).toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<List<Turma>> buscarTodasTurmas() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _turmas.values.toList()..sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<Turma?> buscarTurmaPorId(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _turmas[id];
  }

  Future<void> atualizarTurma(String id, Turma turmaAtualizada) async {
    if (!_turmas.containsKey(id)) {
      throw Exception('Turma não encontrada');
    }

    await Future.delayed(const Duration(milliseconds: 50));
    _turmas[id] = turmaAtualizada;
  }

  Future<void> deletarTurma(String id) async {
    if (!_turmas.containsKey(id)) {
      throw Exception('Turma não encontrada');
    }

    await Future.delayed(const Duration(milliseconds: 50));
    _turmas.remove(id);
  }

  Future<bool> adicionarAlunoTurma(String turmaId, String alunoId) async {
    final turma = _turmas[turmaId];
    if (turma == null) {
      throw Exception('Turma não encontrada');
    }

    if (turma.alunos.contains(alunoId)) {
      throw Exception('Aluno já está na turma');
    }

    _turmas[turmaId] = Turma(
      id: turma.id,
      nome: turma.nome,
      serie: turma.serie,
      turno: turma.turno,
      anoLetivo: turma.anoLetivo,
      ativa: turma.ativa,
      professores: turma.professores,
      alunos: [...turma.alunos, alunoId],
    );

    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Future<void> removerAlunoTurma(String turmaId, String alunoId) async {
    final turma = _turmas[turmaId];
    if (turma == null) {
      throw Exception('Turma não encontrada');
    }

    _turmas[turmaId] = Turma(
      id: turma.id,
      nome: turma.nome,
      serie: turma.serie,
      turno: turma.turno,
      anoLetivo: turma.anoLetivo,
      ativa: turma.ativa,
      professores: turma.professores,
      alunos: turma.alunos.where((a) => a != alunoId).toList(),
    );

    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<int> obterQuantidadeAlunos(String turmaId) async {
    final turma = _turmas[turmaId];
    if (turma == null) {
      throw Exception('Turma não encontrada');
    }

    await Future.delayed(const Duration(milliseconds: 50));
    return turma.alunos.length;
  }

  Future<List<Turma>> buscarTurmasPorSerie(String serie) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _turmas.values.where((t) => t.serie == serie && t.ativa).toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<List<Turma>> buscarTurmasPorTurno(String turno) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _turmas.values.where((t) => t.turno == turno && t.ativa).toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  void limpar() {
    _turmas.clear();
  }
}

void main() {
  group('TurmaService - BDD: Cadastrar Turma', () {
    late MockTurmaService service;

    setUp(() {
      service = MockTurmaService();
    });

    test('Cenário: Diretor cadastra nova turma com dados válidos', () async {
      // Given (Dado que)
      final turma = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );

      // When (Quando)
      await service.cadastrarTurma(turma);

      // Then (Então)
      final turmasCadastradas = await service.buscarTodasTurmas();
      expect(turmasCadastradas, contains(turma));
    });

    test('Cenário: Não permite cadastrar turma sem nome', () async {
      // Given
      final turmaInvalida = Turma(
        id: '1',
        nome: '',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );

      // When & Then
      expect(
        () => service.cadastrarTurma(turmaInvalida),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Cenário: Não permite cadastrar turma sem série', () async {
      // Given
      final turmaInvalida = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '',
        turno: 'Manhã',
        anoLetivo: 2025,
      );

      // When & Then
      expect(
        () => service.cadastrarTurma(turmaInvalida),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Cenário: Não permite cadastrar turma com mesmo nome no mesmo ano',
        () async {
      // Given
      final turma1 = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );

      final turma2 = Turma(
        id: '2',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Tarde',
        anoLetivo: 2025,
      );

      // When
      await service.cadastrarTurma(turma1);

      // Then
      expect(
        () => service.cadastrarTurma(turma2),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Permite turmas com mesmo nome em anos diferentes', () async {
      // Given
      final turma2024 = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2024,
      );

      final turma2025 = Turma(
        id: '2',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );

      // When
      await service.cadastrarTurma(turma2024);
      await service.cadastrarTurma(turma2025);

      // Then
      final todasTurmas = await service.buscarTodasTurmas();
      expect(todasTurmas.length, 2);
    });
  });

  group('TurmaService - BDD: Gerenciar Alunos em Turma', () {
    late MockTurmaService service;

    setUp(() {
      service = MockTurmaService();
    });

    test('Cenário: Adicionar aluno a uma turma', () async {
      // Given
      final turma = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );
      await service.cadastrarTurma(turma);

      // When
      final adicionado = await service.adicionarAlunoTurma('1', 'aluno123');

      // Then
      expect(adicionado, true);
      final quantidade = await service.obterQuantidadeAlunos('1');
      expect(quantidade, 1);
    });

    test('Cenário: Não permite adicionar aluno duas vezes', () async {
      // Given
      final turma = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );
      await service.cadastrarTurma(turma);
      await service.adicionarAlunoTurma('1', 'aluno123');

      // When & Then
      expect(
        () => service.adicionarAlunoTurma('1', 'aluno123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Cenário: Remover aluno de turma', () async {
      // Given
      final turma = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );
      await service.cadastrarTurma(turma);
      await service.adicionarAlunoTurma('1', 'aluno123');

      // When
      await service.removerAlunoTurma('1', 'aluno123');

      // Then
      final quantidade = await service.obterQuantidadeAlunos('1');
      expect(quantidade, 0);
    });

    test('Cenário: Adicionar múltiplos alunos à turma', () async {
      // Given
      final turma = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );
      await service.cadastrarTurma(turma);

      // When
      await service.adicionarAlunoTurma('1', 'aluno1');
      await service.adicionarAlunoTurma('1', 'aluno2');
      await service.adicionarAlunoTurma('1', 'aluno3');

      // Then
      final quantidade = await service.obterQuantidadeAlunos('1');
      expect(quantidade, 3);
    });
  });

  group('TurmaService - BDD: Filtrar Turmas', () {
    late MockTurmaService service;

    setUp(() async {
      service = MockTurmaService();

      // Setup inicial com várias turmas
      await service.cadastrarTurma(Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      ));

      await service.cadastrarTurma(Turma(
        id: '2',
        nome: '1º Ano B',
        serie: '1º Ano',
        turno: 'Tarde',
        anoLetivo: 2025,
      ));

      await service.cadastrarTurma(Turma(
        id: '3',
        nome: '2º Ano A',
        serie: '2º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      ));
    });

    test('Cenário: Filtrar turmas ativas', () async {
      // When
      final turmasAtivas = await service.buscarTurmasAtivas();

      // Then
      expect(turmasAtivas.length, 3);
      expect(turmasAtivas.every((t) => t.ativa), true);
    });

    test('Cenário: Filtrar turmas por série', () async {
      // When
      final turmas1ano = await service.buscarTurmasPorSerie('1º Ano');

      // Then
      expect(turmas1ano.length, 2);
      expect(turmas1ano.every((t) => t.serie == '1º Ano'), true);
    });

    test('Cenário: Filtrar turmas por turno', () async {
      // When
      final turmasManha = await service.buscarTurmasPorTurno('Manhã');

      // Then
      expect(turmasManha.length, 2);
      expect(turmasManha.every((t) => t.turno == 'Manhã'), true);
    });

    test('Cenário: Turmas retornam em ordem alfabética', () async {
      // When
      final turmas = await service.buscarTurmasAtivas();

      // Then
      expect(turmas[0].nome, '1º Ano A');
      expect(turmas[1].nome, '1º Ano B');
      expect(turmas[2].nome, '2º Ano A');
    });
  });

  group('TurmaService - BDD: Atualizar e Deletar', () {
    late MockTurmaService service;

    setUp(() {
      service = MockTurmaService();
    });

    test('Cenário: Atualizar informações de turma', () async {
      // Given
      final turma = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );
      await service.cadastrarTurma(turma);

      // When
      final turmaAtualizada = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Tarde', // Mudou de turno
        anoLetivo: 2025,
      );
      await service.atualizarTurma('1', turmaAtualizada);

      // Then
      final turmaRecuperada = await service.buscarTurmaPorId('1');
      expect(turmaRecuperada?.turno, 'Tarde');
    });

    test('Cenário: Deletar turma', () async {
      // Given
      final turma = Turma(
        id: '1',
        nome: '1º Ano A',
        serie: '1º Ano',
        turno: 'Manhã',
        anoLetivo: 2025,
      );
      await service.cadastrarTurma(turma);

      // When
      await service.deletarTurma('1');

      // Then
      final turmaRecuperada = await service.buscarTurmaPorId('1');
      expect(turmaRecuperada, null);
    });

    test('Cenário: Não permite deletar turma inexistente', () async {
      // When & Then
      expect(
        () => service.deletarTurma('id_inexistente'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
