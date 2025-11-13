import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaChat extends StatefulWidget {
  final String chatRoomId;
  final String destinatarioNome;
  final Color corPrincipal; // Cor (Laranja ou Azul) para a AppBar

  const TelaChat({
    super.key,
    required this.chatRoomId,
    required this.destinatarioNome,
    required this.corPrincipal,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final TextEditingController _mensagemController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _mensagemController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensagem() async {
    final String texto = _mensagemController.text.trim();
    if (texto.isEmpty) {
      return; // Não envia mensagens vazias
    }

    final String currentUserId = _auth.currentUser!.uid;
    _mensagemController.clear();

    // Adiciona a mensagem na subcoleção 'mensagens'
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('mensagens')
        .add({
      'remetenteId': currentUserId,
      'texto': texto,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Atualiza a 'ultimaMensagem' no documento principal do chat (para a lista)
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .update({
      'ultimaMensagem': texto,
      'timestampUltimaMensagem': FieldValue.serverTimestamp(),
    });

    // Anima para o final da lista
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.corPrincipal, // Usa a cor do perfil (Laranja/Azul)
        toolbarHeight: 80.0,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.destinatarioNome,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Lista de Mensagens
          Expanded(
            child: _buildListaMensagens(),
          ),
          // 2. Campo de Input
          _buildInputMensagem(),
        ],
      ),
    );
  }

  Widget _buildListaMensagens() {
    final String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      // Busca as mensagens da sala de chat, ordenadas pela mais recente
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatRoomId)
          .collection('mensagens')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final mensagens = snapshot.data?.docs ?? [];

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // Começa de baixo para cima
          padding: const EdgeInsets.all(16.0),
          itemCount: mensagens.length,
          itemBuilder: (context, index) {
            final msg = mensagens[index].data() as Map<String, dynamic>;
            final bool ehMinha = msg['remetenteId'] == currentUserId;
            
            return _buildBubbleMensagem(ehMinha, msg['texto'] ?? '');
          },
        );
      },
    );
  }

  // Desenha a "bolha" de chat
  Widget _buildBubbleMensagem(bool ehMinha, String texto) {
    return Row(
      // Alinha à direita (end) se for minha, à esquerda (start) se for do outro
      mainAxisAlignment: ehMinha ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // Max 70% da tela
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: ehMinha ? widget.corPrincipal.withOpacity(0.9) : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: ehMinha ? const Radius.circular(16) : const Radius.circular(0),
              bottomRight: ehMinha ? const Radius.circular(0) : const Radius.circular(16),
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(
              color: ehMinha ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Desenha o campo de input
  Widget _buildInputMensagem() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mensagemController,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _enviarMensagem(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _enviarMensagem,
            backgroundColor: widget.corPrincipal,
            elevation: 0,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}