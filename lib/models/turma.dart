class Turma {
  final String id;
  final String nome;
  final String serie;
  final String turno;
  final int anoLetivo;
  final bool ativa;

  Turma({
    required this.id,
    required this.nome,
    required this.serie,
    required this.turno,
    required this.anoLetivo,
    this.ativa = true,
  });

  factory Turma.fromMap(Map<String, dynamic> map, String id) {
    return Turma(
      id: id,
      nome: map['nome'] ?? '',
      serie: map['serie'] ?? '',
      turno: map['turno'] ?? '',
      anoLetivo: map['anoLetivo'] ?? DateTime.now().year,
      ativa: map['ativa'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'serie': serie,
      'turno': turno,
      'anoLetivo': anoLetivo,
      'ativa': ativa,
    };
  }
}
