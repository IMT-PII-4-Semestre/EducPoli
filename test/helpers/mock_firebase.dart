import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../fixtures/mock_usuarios.dart';
import '../fixtures/mock_notas.dart';

class MockFirebase {
  static FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  static MockFirebaseAuth auth = MockFirebaseAuth();

  // Inicializar Firestore com dados mockados
  static Future<void> inicializarFirestore() async {
    // Adicionar usuários
    for (var usuario in MockUsuarios.todos) {
      await firestore
          .collection('usuarios')
          .doc(usuario.id)
          .set(usuario.toMap());
    }

    // Adicionar notas
    for (var nota in MockNotas.notas) {
      await firestore.collection('notas').doc(nota.id).set(nota.toMap());
    }
  }

  // Criar usuário de teste no Auth
  static Future<void> criarUsuarioAuth(String email, String senha) async {
    final user = MockUser(
      isAnonymous: false,
      uid: 'mockUid',
      email: email,
      displayName: email.split('@')[0],
    );

    auth = MockFirebaseAuth(mockUser: user, signedIn: true);
  }

  // Limpar dados
  static Future<void> limpar() async {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
  }

  // Reset para estado inicial
  static Future<void> reset() async {
    await limpar();
    await inicializarFirestore();
  }
}
