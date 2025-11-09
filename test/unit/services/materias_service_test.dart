import 'package:flutter_test/flutter_test.dart';

/// Mock do MateriasService para testes
class MockMateriasService {
  final List<Map<String, dynamic>> _materias = [
    {'id': '1', 'nome': 'Matemática', 'ativa': true},
    {'id': '2', 'nome': 'Português', 'ativa': true},
    {'id': '3', 'nome': 'História', 'ativa': true},
    {'id': '4', 'nome': 'Geografia', 'ativa': true},
    {'id': '5', 'nome': 'Ciências', 'ativa': true},
    {'id': '6', 'nome': 'Inglês', 'ativa': true},
    {'id': '7', 'nome': 'Educação Física', 'ativa': true},
    {'id': '8', 'nome': 'Artes', 'ativa': true},
    {'id': '9', 'nome': 'Física', 'ativa': true},
    {'id': '10', 'nome': 'Química', 'ativa': true},
    {'id': '11', 'nome': 'Biologia', 'ativa': true},
    {'id': '12', 'nome': 'Filosofia', 'ativa': true},
    {'id': '13', 'nome': 'Sociologia', 'ativa': true},
  ];

  Future<void> inicializarMaterias() async {
    // Simula inicialização
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<List<String>> obterMateriasDisponiveis() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _materias
        .where((m) => m['ativa'] == true)
        .map((m) => m['nome'] as String)
        .toList()
      ..sort();
  }

  Future<List<String>> obterMateriasDoProf(String profId) async {
    // Mock: cada prof tem 3 materias aleatórias
    await Future.delayed(const Duration(milliseconds: 50));
    return ['Matemática', 'Física', 'Química'];
  }

  Future<bool> atribuirMateriaProf(String profId, List<String> materias) async {
    if (materias.isEmpty) {
      throw ArgumentError('Deve atribuir pelo menos uma matéria');
    }

    // Verifica se todas as matérias são válidas
    final materiasDisponiveis = await obterMateriasDisponiveis();
    for (String materia in materias) {
      if (!materiasDisponiveis.contains(materia)) {
        throw Exception('Matéria "$materia" não existe');
      }
    }

    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Future<void> adicionarMateria(String nome, String descricao) async {
    if (nome.isEmpty) {
      throw ArgumentError('Nome da matéria não pode ser vazio');
    }

    // Verifica se já existe
    final existe =
        _materias.any((m) => m['nome'].toLowerCase() == nome.toLowerCase());
    if (existe) {
      throw Exception('Matéria "$nome" já existe');
    }

    final novoId = (_materias.length + 1).toString();
    _materias.add({
      'id': novoId,
      'nome': nome,
      'descricao': descricao,
      'ativa': true,
    });

    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> inativarMateria(String nome) async {
    final materia = _materias.firstWhere(
      (m) => m['nome'] == nome,
      orElse: () => throw Exception('Matéria "$nome" não encontrada'),
    );

    materia['ativa'] = false;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  int obterQuantidadeMaterias() {
    return _materias.where((m) => m['ativa'] == true).length;
  }
}

void main() {
  group('MateriasService - Inicialização (Caixa Branca)', () {
    late MockMateriasService service;

    setUp(() {
      service = MockMateriasService();
    });

    test('Deve inicializar materias sem erro', () async {
      expect(() => service.inicializarMaterias(), returnsNormally);
    });

    test('Deve ter 13 materias padrão disponíveis', () async {
      await service.inicializarMaterias();
      final materias = await service.obterMateriasDisponiveis();

      expect(materias.length, 13);
    });

    test('Deve conter todas as materias esperadas', () async {
      final materias = await service.obterMateriasDisponiveis();

      expect(materias, contains('Matemática'));
      expect(materias, contains('Português'));
      expect(materias, contains('Física'));
      expect(materias, contains('Química'));
      expect(materias, contains('Biologia'));
    });
  });

  group('MateriasService - Obter Materias (Caixa Branca)', () {
    late MockMateriasService service;

    setUp(() {
      service = MockMateriasService();
    });

    test('Deve retornar materias em ordem alfabética', () async {
      final materias = await service.obterMateriasDisponiveis();

      expect(materias, isA<List<String>>());
      expect(materias, equals(List.from(materias)..sort()));
    });

    test('Deve retornar materias não vazio', () async {
      final materias = await service.obterMateriasDisponiveis();

      expect(materias, isNotEmpty);
    });

    test('Deve retornar apenas materias ativas', () async {
      // Inativar uma matéria
      await service.inativarMateria('Artes');

      final materias = await service.obterMateriasDisponiveis();

      expect(materias, isNot(contains('Artes')));
      expect(materias.length, 12);
    });
  });

  group('MateriasService - Atribuição a Professor (Caixa Branca)', () {
    late MockMateriasService service;

    setUp(() {
      service = MockMateriasService();
    });

    test('Deve atribuir materias válidas ao professor', () async {
      final resultado = await service.atribuirMateriaProf(
        'prof123',
        ['Matemática', 'Física'],
      );

      expect(resultado, true);
    });

    test('Não deve atribuir lista vazia de materias', () async {
      expect(
        () => service.atribuirMateriaProf('prof123', []),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Não deve atribuir matéria inexistente', () async {
      expect(
        () => service.atribuirMateriaProf('prof123', ['Matéria Fake']),
        throwsA(isA<Exception>()),
      );
    });

    test('Não deve atribuir mistura de válidas e inválidas', () async {
      expect(
        () => service.atribuirMateriaProf(
          'prof123',
          ['Matemática', 'Matéria Fake'],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve atribuir múltiplas materias ao mesmo professor', () async {
      final resultado = await service.atribuirMateriaProf(
        'prof123',
        ['Matemática', 'Física', 'Química', 'Biologia'],
      );

      expect(resultado, true);
    });
  });

  group('MateriasService - Adicionar Materia (Caixa Branca)', () {
    late MockMateriasService service;

    setUp(() {
      service = MockMateriasService();
    });

    test('Deve adicionar nova matéria com sucesso', () async {
      await service.adicionarMateria('Astronomia', 'Estudo do universo');

      final materias = await service.obterMateriasDisponiveis();
      expect(materias, contains('Astronomia'));
      expect(materias.length, 14);
    });

    test('Não deve adicionar matéria com nome vazio', () async {
      expect(
        () => service.adicionarMateria('', 'Descrição'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Não deve adicionar matéria duplicada', () async {
      expect(
        () => service.adicionarMateria('Matemática', 'Já existe'),
        throwsA(isA<Exception>()),
      );
    });

    test('Não deve adicionar matéria com mesmo nome (case-insensitive)',
        () async {
      expect(
        () => service.adicionarMateria('MATEMÁTICA', 'Descrição'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MateriasService - Inativar Materia (Caixa Branca)', () {
    late MockMateriasService service;

    setUp(() {
      service = MockMateriasService();
    });

    test('Deve inativar matéria existente', () async {
      await service.inativarMateria('Artes');

      final materias = await service.obterMateriasDisponiveis();
      expect(materias, isNot(contains('Artes')));
    });

    test('Não deve inativar matéria inexistente', () async {
      expect(
        () => service.inativarMateria('Matéria Inexistente'),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve refletir no contador de materias ativas', () async {
      expect(service.obterQuantidadeMaterias(), 13);

      await service.inativarMateria('Artes');
      expect(service.obterQuantidadeMaterias(), 12);

      await service.inativarMateria('Filosofia');
      expect(service.obterQuantidadeMaterias(), 11);
    });
  });

  group('MateriasService - Fluxo Completo (Caixa Preta)', () {
    late MockMateriasService service;

    setUp(() {
      service = MockMateriasService();
    });

    test('Fluxo completo: inicializar, obter, atribuir', () async {
      // 1. Inicializar
      await service.inicializarMaterias();

      // 2. Obter materias
      final materias = await service.obterMateriasDisponiveis();
      expect(materias, isNotEmpty);

      // 3. Atribuir ao professor
      final resultado = await service.atribuirMateriaProf(
        'prof123',
        [materias[0], materias[1]],
      );
      expect(resultado, true);

      // 4. Verificar materias do professor
      final materiasProf = await service.obterMateriasDoProf('prof123');
      expect(materiasProf, isNotEmpty);
    });

    test('Fluxo completo: adicionar e inativar matéria', () async {
      // 1. Adicionar nova matéria
      await service.adicionarMateria('Geologia', 'Estudo das rochas');

      // 2. Verificar quantidade
      expect(service.obterQuantidadeMaterias(), 14);

      // 3. Inativar nova matéria
      await service.inativarMateria('Geologia');

      // 4. Verificar que foi inativada
      final materias = await service.obterMateriasDisponiveis();
      expect(materias, isNot(contains('Geologia')));
      expect(service.obterQuantidadeMaterias(), 13);
    });

    test('Deve manter consistência após múltiplas operações', () async {
      final materiasInicial = await service.obterMateriasDisponiveis();
      final quantidadeInicial = materiasInicial.length;

      // Múltiplas operações
      await service.adicionarMateria('Astronomia', 'Desc');
      await service.inativarMateria('Artes');
      await service.adicionarMateria('Geologia', 'Desc');
      await service.inativarMateria('Geologia');

      final materiasGinal = await service.obterMateriasDisponiveis();
      final quantidadeFinal = materiasGinal.length;

      // Quantidade deve ser igual ao final (adicionou 2, inativou 2)
      expect(quantidadeFinal, quantidadeInicial - 1); // Apenas Artes inativada
    });
  });

  group('MateriasService - Casos Extremos (Caixa Preta)', () {
    late MockMateriasService service;

    setUp(() {
      service = MockMateriasService();
    });

    test('Deve lidar com nomes de matéria muito longos', () async {
      final nomeLongo = 'A' * 500;
      await service.adicionarMateria(nomeLongo, 'Descrição');

      final materias = await service.obterMateriasDisponiveis();
      expect(materias, contains(nomeLongo));
    });

    test('Deve lidar com caracteres especiais em matéria', () async {
      await service.adicionarMateria(
        'Educação Física II',
        'Descrição com ç, ã, é',
      );

      final materias = await service.obterMateriasDisponiveis();
      expect(materias, contains('Educação Física II'));
    });

    test('Deve permitir atribuir todas as materias ao professor', () async {
      final todasMaterias = await service.obterMateriasDisponiveis();

      final resultado = await service.atribuirMateriaProf(
        'prof123',
        todasMaterias,
      );

      expect(resultado, true);
    });

    test('Deve manter lista sincronizada após inativar', () async {
      final antes = await service.obterMateriasDisponiveis();

      await service.inativarMateria(antes[0]);

      final depois = await service.obterMateriasDisponiveis();

      expect(depois.length, antes.length - 1);
      expect(depois, isNot(contains(antes[0])));
    });
  });
}
