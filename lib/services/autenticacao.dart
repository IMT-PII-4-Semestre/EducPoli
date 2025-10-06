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
      DocumentSnapshot doc = await _firestore
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        return Usuario.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dados: ${e.toString()}');
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
  }
}
