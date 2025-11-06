import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGuard {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifica se o usuário está autenticado
  static bool estaAutenticado() {
    return _auth.currentUser != null;
  }

  /// Retorna o tipo de usuário logado (aluno, professor, diretor)
  static Future<String?> obterTipoUsuario() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['tipo'] as String?;
      }
      return null;
    } catch (e) {
      print('Erro ao obter tipo de usuário: $e');
      return null;
    }
  }

  /// Valida se o usuário tem permissão para acessar uma rota específica
  static Future<bool> temPermissao(String rota) async {
    try {
      // Se não está autenticado, nega acesso
      if (!estaAutenticado()) {
        return false;
      }

      final tipoUsuario = await obterTipoUsuario();
      if (tipoUsuario == null) {
        return false;
      }

      // Define quais rotas cada tipo de usuário pode acessar
      final rotasAluno = [
        '/dashboard-aluno',
        '/aluno/materias',
        '/aluno/mensagem',
        '/aluno/notas',
        '/aluno/boletim',
      ];

      final rotasProfessor = [
        '/dashboard-professor',
        '/professor/materias',
        '/professor/mensagem',
        '/professor/notas',
      ];

      final rotasDiretor = [
        '/dashboard-diretor',
        '/diretor/alunos',
        '/diretor/professores',
        '/diretor/cadastrar-aluno',
        '/diretor/cadastrar-professor',
      ];

      // Verifica permissão baseado no tipo de usuário
      if (tipoUsuario == 'aluno') {
        return rotasAluno.contains(rota);
      } else if (tipoUsuario == 'professor') {
        return rotasProfessor.contains(rota);
      } else if (tipoUsuario == 'diretor') {
        return rotasDiretor.contains(rota);
      }

      return false;
    } catch (e) {
      print('Erro ao validar permissão: $e');
      return false;
    }
  }

  /// Retorna a rota padrão baseada no tipo de usuário
  static Future<String> obterRotaPadrao() async {
    try {
      final tipoUsuario = await obterTipoUsuario();

      switch (tipoUsuario) {
        case 'aluno':
          return '/dashboard-aluno';
        case 'professor':
          return '/dashboard-professor';
        case 'diretor':
          return '/dashboard-diretor';
        default:
          return '/login';
      }
    } catch (e) {
      print('Erro ao obter rota padrão: $e');
      return '/login';
    }
  }
}
