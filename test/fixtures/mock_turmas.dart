class Turma {
  final String id;
  final String nome;
  final String periodo;
  final int ano;
  final bool ativa;

  const Turma({
    required this.id,
    required this.nome,
    required this.periodo,
    required this.ano,
    required this.ativa,
  });
}

class MockTurmas {
  static final List<Turma> turmas = [
    const Turma(
      id: 'turma1',
      nome: 'A1',
      periodo: 'Manhã',
      ano: 2025,
      ativa: true,
    ),
    const Turma(
      id: 'turma2',
      nome: 'A2',
      periodo: 'Manhã',
      ano: 2025,
      ativa: true,
    ),
    const Turma(
      id: 'turma3',
      nome: 'B1',
      periodo: 'Tarde',
      ano: 2025,
      ativa: true,
    ),
    const Turma(
      id: 'turma4',
      nome: 'B2',
      periodo: 'Tarde',
      ano: 2025,
      ativa: true,
    ),
    const Turma(
      id: 'turma5',
      nome: 'C1',
      periodo: 'Noite',
      ano: 2025,
      ativa: true,
    ),
    const Turma(
      id: 'turma6',
      nome: 'C2',
      periodo: 'Noite',
      ano: 2025,
      ativa: false,
    ),
    const Turma(
      id: 'turma7',
      nome: 'C3',
      periodo: 'Noite',
      ano: 2025,
      ativa: true,
    ),
  ];

  // Buscar turma por nome
  static Turma? buscarPorNome(String nome) {
    try {
      return turmas.firstWhere((t) => t.nome == nome);
    } catch (e) {
      return null;
    }
  }

  // Filtrar por período
  static List<Turma> filtrarPorPeriodo(String periodo) {
    return turmas.where((t) => t.periodo == periodo).toList();
  }

  // Filtrar ativas
  static List<Turma> get ativas => turmas.where((t) => t.ativa).toList();

  // Filtrar inativas
  static List<Turma> get inativas => turmas.where((t) => !t.ativa).toList();

  // Nomes de turmas ativas
  static List<String> get nomesAtivas => ativas.map((t) => t.nome).toList();
}
