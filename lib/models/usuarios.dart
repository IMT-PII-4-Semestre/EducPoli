import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoUsuario { aluno, professor, diretor }

class Usuario {
  final String id;
  final String email;
  final String nome;
  final String ra;
  final TipoUsuario tipo;
  final DateTime criadoEm;
  final String? fotoUrl;
  final List<String> materias;

  Usuario({
    required this.id,
    required this.email,
    required this.nome,
    required this.ra,
    required this.tipo,
    required this.criadoEm,
    this.fotoUrl,
    this.materias = const [],
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    print('🔄 Convertendo map para Usuario: $map');

    // Parsing mais robusto do tipo
    TipoUsuario tipoUsuario;
    final tipoString = map['tipo']?.toString().toLowerCase() ?? 'aluno';

    print('📝 Tipo string do documento: "$tipoString"');

    switch (tipoString) {
      case 'diretor':
        tipoUsuario = TipoUsuario.diretor;
        break;
      case 'professor':
        tipoUsuario = TipoUsuario.professor;
        break;
      case 'aluno':
      default:
        tipoUsuario = TipoUsuario.aluno;
        break;
    }

    print('🎯 TipoUsuario definido: $tipoUsuario');

    return Usuario(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      nome: map['nome'] ?? '',
      ra: map['ra'] ?? '',
      tipo: tipoUsuario,
      criadoEm: map['criadoEm'] is Timestamp
          ? (map['criadoEm'] as Timestamp).toDate()
          : DateTime.parse(map['criadoEm']),
      fotoUrl: map['fotoUrl'],
      materias: List<String>.from(map['materias'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
      'ra': ra,
      'tipo': tipo.toString().split('.').last,
      'criadoEm': criadoEm.toIso8601String(),
      'fotoUrl': fotoUrl,
      'materias': materias,
    };
  }
}
