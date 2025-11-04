import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuarios.dart';

class ServicoAutenticacao {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get usuarioAtual => _auth.currentUser;
  Stream<User?> get mudancasAuth => _auth.authStateChanges();

  Future<Usuario?> fazerLogin(String email, String senha) async {
    try {
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (resultado.user != null) {
        return await buscarDadosUsuario(resultado.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Erro no login: ${e.toString()}');
    }
  }

  Future<Usuario?> buscarDadosUsuario(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('usuarios').doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Usuario.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dados: ${e.toString()}');
    }
  }

  // Buscar dados do usuário atual logado
  Future<Map<String, dynamic>?> buscarDadosUsuarioAtual() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('usuarios').doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dados do usuário: ${e.toString()}');
    }
  }

  // Verificar se usuário está ativo
  Future<bool> verificarUsuarioAtivo() async {
    try {
      final dados = await buscarDadosUsuarioAtual();
      return dados?['ativo'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
  }
}
