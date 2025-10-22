import 'package:educ_poli/models/usuarios.dart';

class MockUsuarios {
  // Alunos mockados
  static final List<Usuario> alunos = [
    Usuario(
      id: 'aluno1',
      nome: 'João da Silva',
      email: 'joao.silva@email.com',
      ra: '2025001',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 15),
      materias: ['Matemática', 'Português', 'História'],
    ),
    Usuario(
      id: 'aluno2',
      nome: 'Maria Santos',
      email: 'maria.santos@email.com',
      ra: '2025002',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 16),
      materias: ['Matemática', 'Física', 'Química'],
    ),
    Usuario(
      id: 'aluno3',
      nome: 'Pedro Costa',
      email: 'pedro.costa@email.com',
      ra: '2025003',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 17),
      materias: ['Geografia', 'História', 'Português'],
    ),
    Usuario(
      id: 'aluno4',
      nome: 'Ana Souza',
      email: 'ana.souza@email.com',
      ra: '2025004',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 18),
      materias: ['Matemática', 'Biologia'],
    ),
    Usuario(
      id: 'aluno5',
      nome: 'Carlos Lima',
      email: 'carlos.lima@email.com',
      ra: '2025005',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 19),
      materias: ['Física', 'Química', 'Matemática'],
    ),
    Usuario(
      id: 'aluno6',
      nome: 'Fernanda Oliveira',
      email: 'fernanda.oliveira@email.com',
      ra: '2025006',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 20),
      materias: ['Português', 'Literatura', 'Redação'],
    ),
    Usuario(
      id: 'aluno7',
      nome: 'Lucas Pereira',
      email: 'lucas.pereira@email.com',
      ra: '2025007',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 21),
      materias: ['Matemática', 'Física'],
    ),
    Usuario(
      id: 'aluno8',
      nome: 'Juliana Mendes',
      email: 'juliana.mendes@email.com',
      ra: '2025008',
      tipo: TipoUsuario.aluno,
      criadoEm: DateTime(2025, 1, 22),
      materias: ['História', 'Geografia', 'Sociologia'],
    ),
  ];

  // Professores mockados
  static final List<Usuario> professores = [
    Usuario(
      id: 'prof1',
      nome: 'Prof. Roberto Alves',
      email: 'roberto.alves@educpoli.com',
      ra: 'PROF001',
      tipo: TipoUsuario.professor,
      criadoEm: DateTime(2024, 1, 1),
      materias: ['Matemática'],
    ),
    Usuario(
      id: 'prof2',
      nome: 'Profa. Fernanda Costa',
      email: 'fernanda.costa@educpoli.com',
      ra: 'PROF002',
      tipo: TipoUsuario.professor,
      criadoEm: DateTime(2024, 1, 1),
      materias: ['Português', 'Literatura', 'Redação'],
    ),
    Usuario(
      id: 'prof3',
      nome: 'Prof. Lucas Silva',
      email: 'lucas.silva@educpoli.com',
      ra: 'PROF003',
      tipo: TipoUsuario.professor,
      criadoEm: DateTime(2024, 1, 1),
      materias: ['Física'],
    ),
    Usuario(
      id: 'prof4',
      nome: 'Profa. Juliana Santos',
      email: 'juliana.santos@educpoli.com',
      ra: 'PROF004',
      tipo: TipoUsuario.professor,
      criadoEm: DateTime(2024, 1, 1),
      materias: ['Química'],
    ),
    Usuario(
      id: 'prof5',
      nome: 'Prof. Carlos Mendes',
      email: 'carlos.mendes@educpoli.com',
      ra: 'PROF005',
      tipo: TipoUsuario.professor,
      criadoEm: DateTime(2024, 1, 1),
      materias: ['História', 'Geografia'],
    ),
    Usuario(
      id: 'prof6',
      nome: 'Profa. Ana Paula',
      email: 'ana.paula@educpoli.com',
      ra: 'PROF006',
      tipo: TipoUsuario.professor,
      criadoEm: DateTime(2024, 1, 1),
      materias: ['Biologia'],
    ),
  ];

  // Diretores mockados
  static final List<Usuario> diretores = [
    Usuario(
      id: 'dir1',
      nome: 'Dr. Paulo Oliveira',
      email: 'diretor@educpoli.com',
      ra: 'DIR001',
      tipo: TipoUsuario.diretor,
      criadoEm: DateTime(2023, 1, 1),
      materias: [],
    ),
    Usuario(
      id: 'dir2',
      nome: 'Dra. Carla Rodrigues',
      email: 'carla.rodrigues@educpoli.com',
      ra: 'DIR002',
      tipo: TipoUsuario.diretor,
      criadoEm: DateTime(2023, 6, 1),
      materias: [],
    ),
  ];

  // Todos os usuários
  static List<Usuario> get todos => [...alunos, ...professores, ...diretores];

  // Buscar usuário por email
  static Usuario? buscarPorEmail(String email) {
    try {
      return todos.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  // Buscar usuário por RA
  static Usuario? buscarPorRA(String ra) {
    try {
      return todos.firstWhere((u) => u.ra == ra);
    } catch (e) {
      return null;
    }
  }

  // Buscar usuário por ID
  static Usuario? buscarPorId(String id) {
    try {
      return todos.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filtrar por tipo
  static List<Usuario> filtrarPorTipo(TipoUsuario tipo) {
    return todos.where((u) => u.tipo == tipo).toList();
  }

  // Filtrar por matéria
  static List<Usuario> filtrarPorMateria(String materia) {
    return todos.where((u) => u.materias.contains(materia)).toList();
  }

  // Buscar alunos de uma matéria específica
  static List<Usuario> alunosPorMateria(String materia) {
    return alunos.where((a) => a.materias.contains(materia)).toList();
  }

  // Buscar professores de uma matéria específica
  static List<Usuario> professoresPorMateria(String materia) {
    return professores.where((p) => p.materias.contains(materia)).toList();
  }

  // Obter todas as matérias únicas do sistema
  static List<String> get todasMaterias {
    final materiasSet = <String>{};
    for (var usuario in todos) {
      materiasSet.addAll(usuario.materias);
    }
    return materiasSet.toList()..sort();
  }

  // Contar usuários por tipo
  static Map<TipoUsuario, int> contarPorTipo() {
    return {
      TipoUsuario.aluno: alunos.length,
      TipoUsuario.professor: professores.length,
      TipoUsuario.diretor: diretores.length,
    };
  }

  // Usuário de teste padrão para cada tipo
  static Usuario get alunoTeste => alunos.first;
  static Usuario get professorTeste => professores.first;
  static Usuario get diretorTeste => diretores.first;

  // Credenciais de teste
  static const Map<String, String> credenciaisTeste = {
    'aluno@educpoli.com': 'Senha123',
    'professor@educpoli.com': 'Prof123',
    'diretor@educpoli.com': 'Dir123',
  };

  // Validar credenciais mockadas
  static bool validarCredenciais(String email, String senha) {
    return credenciaisTeste[email] == senha;
  }

  // Obter usuário mockado por credenciais
  static Usuario? loginMock(String email, String senha) {
    if (validarCredenciais(email, senha)) {
      return buscarPorEmail(email);
    }
    return null;
  }
}
