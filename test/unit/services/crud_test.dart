import 'package:flutter_test/flutter_test.dart';

// Mock simples do CRUD
class ServicoCRUD<T> {
  final Map<String, Map<String, dynamic>> _database = {};
  final String colecao;

  ServicoCRUD(this.colecao);

  Future<String> adicionar(Map<String, dynamic> dados) async {
    if (dados.isEmpty) {
      throw ArgumentError('Dados não podem ser vazios');
    }

    final id = 'id_${DateTime.now().millisecondsSinceEpoch}';
    _database[id] = dados;

    await Future.delayed(const Duration(milliseconds: 50));
    return id;
  }

  Future<Map<String, dynamic>?> buscarPorId(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }

    await Future.delayed(const Duration(milliseconds: 50));
    return _database[id];
  }

  Future<void> atualizar(String id, Map<String, dynamic> dados) async {
    if (id.isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }
    if (dados.isEmpty) {
      throw ArgumentError('Dados não podem ser vazios');
    }
    if (!_database.containsKey(id)) {
      throw Exception('Documento não encontrado');
    }

    _database[id] = {..._database[id]!, ...dados};
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> deletar(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }
    if (!_database.containsKey(id)) {
      throw Exception('Documento não encontrado');
    }

    _database.remove(id);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<List<Map<String, dynamic>>> buscarTodos() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _database.values.toList();
  }

  Future<List<Map<String, dynamic>>> buscarPorCampo(
      String campo, dynamic valor) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _database.values.where((doc) => doc[campo] == valor).toList();
  }
}

void main() {
  late ServicoCRUD<Map<String, dynamic>> servicoCRUD;

  setUp(() {
    servicoCRUD = ServicoCRUD('usuarios');
  });

  group('ServicoCRUD - Operações CRUD (Caixa Branca)', () {
    test('Deve adicionar um documento com sucesso', () async {
      // Arrange
      final dados = {
        'nome': 'Novo Usuario',
        'email': 'novo@email.com',
        'tipo': 'aluno',
      };

      // Act
      final id = await servicoCRUD.adicionar(dados);

      // Assert
      expect(id, isNotNull);
      expect(id, startsWith('id_'));
    });

    test('Deve buscar documento por ID', () async {
      // Arrange
      final dados = {
        'nome': 'Teste',
        'email': 'teste@email.com',
        'tipo': 'aluno',
      };
      final id = await servicoCRUD.adicionar(dados);

      // Act
      final resultado = await servicoCRUD.buscarPorId(id);

      // Assert
      expect(resultado, isNotNull);
      expect(resultado?['nome'], 'Teste');
      expect(resultado?['email'], 'teste@email.com');
    });

    test('Deve atualizar documento existente', () async {
      // Arrange
      final dados = {'nome': 'Nome Original'};
      final id = await servicoCRUD.adicionar(dados);

      // Act
      await servicoCRUD.atualizar(id, {'nome': 'Nome Atualizado'});
      final resultado = await servicoCRUD.buscarPorId(id);

      // Assert
      expect(resultado?['nome'], 'Nome Atualizado');
    });

    test('Deve deletar documento', () async {
      // Arrange
      final dados = {'nome': 'Para Deletar'};
      final id = await servicoCRUD.adicionar(dados);

      // Act
      await servicoCRUD.deletar(id);
      final resultado = await servicoCRUD.buscarPorId(id);

      // Assert
      expect(resultado, null);
    });

    test('Deve buscar todos os documentos', () async {
      // Arrange
      await servicoCRUD.adicionar({'nome': 'Usuario 1'});
      await servicoCRUD.adicionar({'nome': 'Usuario 2'});
      await servicoCRUD.adicionar({'nome': 'Usuario 3'});

      // Act
      final todos = await servicoCRUD.buscarTodos();

      // Assert
      expect(todos.length, greaterThanOrEqualTo(3));
    });

    test('Deve buscar por campo específico', () async {
      // Arrange
      await servicoCRUD.adicionar({'nome': 'João', 'tipo': 'aluno'});
      await servicoCRUD.adicionar({'nome': 'Maria', 'tipo': 'professor'});
      await servicoCRUD.adicionar({'nome': 'Pedro', 'tipo': 'aluno'});

      // Act
      final alunos = await servicoCRUD.buscarPorCampo('tipo', 'aluno');

      // Assert
      expect(alunos.length, 2);
      expect(alunos.every((doc) => doc['tipo'] == 'aluno'), true);
    });
  });

  group('ServicoCRUD - Validações (Caixa Preta)', () {
    test('Não deve aceitar ID vazio ao buscar', () {
      expect(
        () => servicoCRUD.buscarPorId(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Não deve aceitar dados vazios ao adicionar', () {
      expect(
        () => servicoCRUD.adicionar({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Deve retornar null ao buscar documento inexistente', () async {
      // Act
      final resultado = await servicoCRUD.buscarPorId('id_inexistente');

      // Assert
      expect(resultado, null);
    });

    test('Não deve atualizar documento inexistente', () async {
      expect(
        () => servicoCRUD.atualizar('id_inexistente', {'nome': 'Teste'}),
        throwsA(isA<Exception>()),
      );
    });

    test('Não deve deletar documento inexistente', () async {
      expect(
        () => servicoCRUD.deletar('id_inexistente'),
        throwsA(isA<Exception>()),
      );
    });

    test('Não deve aceitar dados vazios ao atualizar', () async {
      // Arrange
      final id = await servicoCRUD.adicionar({'nome': 'Teste'});

      // Act & Assert
      expect(
        () => servicoCRUD.atualizar(id, {}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('ServicoCRUD - Operações Complexas', () {
    test('Deve manter dados originais ao atualizar parcialmente', () async {
      // Arrange
      final dados = {
        'nome': 'João',
        'email': 'joao@email.com',
        'tipo': 'aluno'
      };
      final id = await servicoCRUD.adicionar(dados);

      // Act
      await servicoCRUD.atualizar(id, {'nome': 'João Silva'});
      final resultado = await servicoCRUD.buscarPorId(id);

      // Assert
      expect(resultado?['nome'], 'João Silva');
      expect(resultado?['email'], 'joao@email.com');
      expect(resultado?['tipo'], 'aluno');
    });

    test('Deve adicionar múltiplos documentos sequencialmente', () async {
      // Act
      final id1 = await servicoCRUD.adicionar({'ordem': 1});
      final id2 = await servicoCRUD.adicionar({'ordem': 2});
      final id3 = await servicoCRUD.adicionar({'ordem': 3});

      // Assert
      expect(id1, isNot(id2));
      expect(id2, isNot(id3));
      expect(id1, isNot(id3));
    });

    test('Deve retornar lista vazia quando não há documentos com o filtro',
        () async {
      // Act
      final resultado = await servicoCRUD.buscarPorCampo('tipo', 'inexistente');

      // Assert
      expect(resultado, isEmpty);
    });
  });
}
