class Nota {
  final String id;
  final String alunoId;
  final String professorId;
  final String materia;
  final double valor;
  final String bimestre;
  final DateTime data;

  const Nota({
    required this.id,
    required this.alunoId,
    required this.professorId,
    required this.materia,
    required this.valor,
    required this.bimestre,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'alunoId': alunoId,
      'professorId': professorId,
      'materia': materia,
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
      materia: map['materia'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      bimestre: map['bimestre'] ?? '',
      data: DateTime.parse(map['data']),
    );
  }
}

class MockNotas {
  static final List<Nota> notas = [
    // Notas do aluno1 (João da Silva) - 1º Bimestre
    Nota(
      id: 'nota1',
      alunoId: 'aluno1',
      professorId: 'prof1',
      materia: 'Matemática',
      valor: 8.5,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 15),
    ),
    Nota(
      id: 'nota2',
      alunoId: 'aluno1',
      professorId: 'prof2',
      materia: 'Português',
      valor: 9.0,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 20),
    ),
    Nota(
      id: 'nota3',
      alunoId: 'aluno1',
      professorId: 'prof5',
      materia: 'História',
      valor: 7.5,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 25),
    ),

    // Notas do aluno2 (Maria Santos) - 1º Bimestre
    Nota(
      id: 'nota4',
      alunoId: 'aluno2',
      professorId: 'prof1',
      materia: 'Matemática',
      valor: 9.5,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 15),
    ),
    Nota(
      id: 'nota5',
      alunoId: 'aluno2',
      professorId: 'prof3',
      materia: 'Física',
      valor: 8.0,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 20),
    ),
    Nota(
      id: 'nota6',
      alunoId: 'aluno2',
      professorId: 'prof4',
      materia: 'Química',
      valor: 10.0,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 25),
    ),

    // Notas do aluno3 (Pedro Costa) - 1º Bimestre
    Nota(
      id: 'nota7',
      alunoId: 'aluno3',
      professorId: 'prof5',
      materia: 'Geografia',
      valor: 6.5,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 15),
    ),
    Nota(
      id: 'nota8',
      alunoId: 'aluno3',
      professorId: 'prof5',
      materia: 'História',
      valor: 7.0,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 20),
    ),
    Nota(
      id: 'nota9',
      alunoId: 'aluno3',
      professorId: 'prof2',
      materia: 'Português',
      valor: 7.5,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 22),
    ),

    // Notas do aluno4 (Ana Souza) - 1º Bimestre
    Nota(
      id: 'nota10',
      alunoId: 'aluno4',
      professorId: 'prof1',
      materia: 'Matemática',
      valor: 5.0,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 15),
    ),
    Nota(
      id: 'nota11',
      alunoId: 'aluno4',
      professorId: 'prof6',
      materia: 'Biologia',
      valor: 8.5,
      bimestre: '1º Bimestre',
      data: DateTime(2025, 3, 18),
    ),

    // Notas de recuperação
    Nota(
      id: 'nota12',
      alunoId: 'aluno4',
      professorId: 'prof1',
      materia: 'Matemática',
      valor: 7.5,
      bimestre: '1º Bimestre - Recuperação',
      data: DateTime(2025, 4, 10),
    ),

    // Notas do 2º Bimestre
    Nota(
      id: 'nota13',
      alunoId: 'aluno1',
      professorId: 'prof1',
      materia: 'Matemática',
      valor: 9.0,
      bimestre: '2º Bimestre',
      data: DateTime(2025, 6, 15),
    ),
    Nota(
      id: 'nota14',
      alunoId: 'aluno2',
      professorId: 'prof1',
      materia: 'Matemática',
      valor: 8.5,
      bimestre: '2º Bimestre',
      data: DateTime(2025, 6, 15),
    ),
    Nota(
      id: 'nota15',
      alunoId: 'aluno5',
      professorId: 'prof3',
      materia: 'Física',
      valor: 9.5,
      bimestre: '2º Bimestre',
      data: DateTime(2025, 6, 20),
    ),
  ];

  // Buscar notas por aluno
  static List<Nota> buscarPorAluno(String alunoId) {
    return notas.where((n) => n.alunoId == alunoId).toList();
  }

  // Buscar notas por matéria
  static List<Nota> buscarPorMateria(String materia) {
    return notas.where((n) => n.materia == materia).toList();
  }

  // Buscar notas por bimestre
  static List<Nota> buscarPorBimestre(String bimestre) {
    return notas.where((n) => n.bimestre == bimestre).toList();
  }

  // Buscar notas por professor
  static List<Nota> buscarPorProfessor(String professorId) {
    return notas.where((n) => n.professorId == professorId).toList();
  }

  // Buscar notas de um aluno em uma matéria
  static List<Nota> buscarPorAlunoEMateria(String alunoId, String materia) {
    return notas
        .where((n) => n.alunoId == alunoId && n.materia == materia)
        .toList();
  }

  // Calcular média de um aluno
  static double calcularMediaAluno(String alunoId) {
    final notasAluno = buscarPorAluno(alunoId);
    if (notasAluno.isEmpty) return 0.0;
    final soma = notasAluno.fold(0.0, (sum, nota) => sum + nota.valor);
    return double.parse((soma / notasAluno.length).toStringAsFixed(2));
  }

  // Calcular média de um aluno em uma matéria
  static double calcularMediaAlunoMateria(String alunoId, String materia) {
    final notasFiltradas = buscarPorAlunoEMateria(alunoId, materia);
    if (notasFiltradas.isEmpty) return 0.0;
    final soma = notasFiltradas.fold(0.0, (sum, nota) => sum + nota.valor);
    return double.parse((soma / notasFiltradas.length).toStringAsFixed(2));
  }

  // Calcular média de uma matéria
  static double calcularMediaMateria(String materia) {
    final notasFiltradas = buscarPorMateria(materia);
    if (notasFiltradas.isEmpty) return 0.0;
    final soma = notasFiltradas.fold(0.0, (sum, nota) => sum + nota.valor);
    return double.parse((soma / notasFiltradas.length).toStringAsFixed(2));
  }

  // Alunos sem nota em uma matéria
  static List<String> alunosSemNota(
      String materia, List<String> todosAlunoIds) {
    final idsComNota =
        notas.where((n) => n.materia == materia).map((n) => n.alunoId).toSet();
    return todosAlunoIds.where((id) => !idsComNota.contains(id)).toList();
  }

  // Nota mais alta
  static Nota? notaMaisAlta() {
    if (notas.isEmpty) return null;
    return notas.reduce((a, b) => a.valor > b.valor ? a : b);
  }

  // Nota mais baixa
  static Nota? notaMaisBaixa() {
    if (notas.isEmpty) return null;
    return notas.reduce((a, b) => a.valor < b.valor ? a : b);
  }

  // Estatísticas por matéria
  static Map<String, dynamic> estatisticasMateria(String materia) {
    final notasMateria = buscarPorMateria(materia);
    if (notasMateria.isEmpty) {
      return {
        'media': 0.0,
        'maior': 0.0,
        'menor': 0.0,
        'total': 0,
      };
    }

    final valores = notasMateria.map((n) => n.valor).toList();
    return {
      'media': calcularMediaMateria(materia),
      'maior': valores.reduce((a, b) => a > b ? a : b),
      'menor': valores.reduce((a, b) => a < b ? a : b),
      'total': notasMateria.length,
    };
  }

  // Alunos aprovados em uma matéria (média >= 7.0)
  static List<String> alunosAprovados(String materia) {
    final alunosComNota =
        notas.where((n) => n.materia == materia).map((n) => n.alunoId).toSet();

    return alunosComNota
        .where((alunoId) => calcularMediaAlunoMateria(alunoId, materia) >= 7.0)
        .toList();
  }

  // Alunos em recuperação (média < 7.0)
  static List<String> alunosEmRecuperacao(String materia) {
    final alunosComNota =
        notas.where((n) => n.materia == materia).map((n) => n.alunoId).toSet();

    return alunosComNota
        .where((alunoId) => calcularMediaAlunoMateria(alunoId, materia) < 7.0)
        .toList();
  }
}
