import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MensagensService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cria ou recupera um chat entre dois usuários
  static Future<String> criarOuRecuperarChat({
    required String destinatarioId,
    required String destinatarioNome,
    required String currentUserNome,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;

    // Ordenar IDs para garantir que sempre gere o mesmo chatRoomId
    List<String> ids = [currentUserId, destinatarioId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Criar ou atualizar documento do chat
    await _firestore.collection('chats').doc(chatRoomId).set({
      'participantes': [currentUserId, destinatarioId],
      'nomes': {
        currentUserId: currentUserNome,
        destinatarioId: destinatarioNome,
      },
      'timestampUltimaMensagem': FieldValue.serverTimestamp(),
      'ultimaMensagem': '',
    }, SetOptions(merge: true));

    return chatRoomId;
  }

  /// Envia uma mensagem no chat
  static Future<void> enviarMensagem({
    required String chatRoomId,
    required String mensagem,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserNome = _auth.currentUser?.displayName ?? 'Usuário';

    // Adicionar mensagem à subcoleção
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('mensagens')
        .add({
      'texto': mensagem,
      'remetenteId': currentUserId,
      'remetenteNome': currentUserNome,
      'timestamp': FieldValue.serverTimestamp(),
      'lida': false,
    });

    // Atualizar última mensagem no chat
    await _firestore.collection('chats').doc(chatRoomId).update({
      'ultimaMensagem': mensagem,
      'timestampUltimaMensagem': FieldValue.serverTimestamp(),
    });
  }

  /// Busca usuários (alunos ou professores) para iniciar conversa
  static Stream<QuerySnapshot> buscarUsuariosPorTipo(String tipo) {
    return _firestore
        .collection('usuarios')
        .where('tipo', isEqualTo: tipo)
        .snapshots();
  }

  /// Busca todos os usuários exceto o atual
  static Stream<QuerySnapshot> buscarTodosUsuarios() {
    final currentUserId = _auth.currentUser?.uid;

    return _firestore
        .collection('usuarios')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .orderBy(FieldPath.documentId)
        .snapshots();
  }

  /// Busca conversas do usuário atual
  static Stream<QuerySnapshot> buscarConversas() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('chats')
        .where('participantes', arrayContains: currentUserId)
        .orderBy('timestampUltimaMensagem', descending: true)
        .snapshots();
  }

  /// Busca mensagens de um chat específico
  static Stream<QuerySnapshot> buscarMensagens(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('mensagens')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Marca mensagens como lidas
  static Future<void> marcarMensagensComoLidas(String chatRoomId) async {
    final String currentUserId = _auth.currentUser!.uid;

    final mensagensNaoLidas = await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('mensagens')
        .where('remetenteId', isNotEqualTo: currentUserId)
        .where('lida', isEqualTo: false)
        .get();

    for (var doc in mensagensNaoLidas.docs) {
      await doc.reference.update({'lida': true});
    }
  }

  /// Conta mensagens não lidas
  static Stream<int> contarMensagensNaoLidas() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('chats')
        .where('participantes', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((chatsSnapshot) async {
      int totalNaoLidas = 0;

      for (var chatDoc in chatsSnapshot.docs) {
        final mensagensNaoLidas = await chatDoc.reference
            .collection('mensagens')
            .where('remetenteId', isNotEqualTo: currentUserId)
            .where('lida', isEqualTo: false)
            .get();

        totalNaoLidas += mensagensNaoLidas.docs.length;
      }

      return totalNaoLidas;
    });
  }

  /// Obtém informações do destinatário em um chat
  static Future<Map<String, dynamic>?> obterInfoDestinatario(
      String chatRoomId) async {
    final String currentUserId = _auth.currentUser!.uid;

    final chatDoc = await _firestore.collection('chats').doc(chatRoomId).get();

    if (!chatDoc.exists) return null;

    final chatData = chatDoc.data() as Map<String, dynamic>;
    final participantes = chatData['participantes'] as List;
    final nomes = chatData['nomes'] as Map<String, dynamic>;

    final destinatarioId = participantes.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (destinatarioId.isEmpty) return null;

    return {
      'id': destinatarioId,
      'nome': nomes[destinatarioId] ?? 'Usuário',
    };
  }
}
