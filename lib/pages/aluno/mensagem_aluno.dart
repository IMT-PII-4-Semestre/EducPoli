import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import 'tela_chat.dart';

class MensagemAluno extends StatelessWidget {
  const MensagemAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Mensagens',
      corPrincipal: MenuConfig.corAluno,
      itensMenu: MenuConfig.menuAluno,
      itemSelecionadoId: 'mensagens',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Mensagens', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(
        child: Text('Erro: usuário não autenticado'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participantes', arrayContains: currentUserId)
          .orderBy('timestampUltimaMensagem', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar mensagens: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data?.docs ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma mensagem ainda',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aguarde que um professor inicie uma conversa',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chatDoc = chats[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final nomes = chatData['nomes'] as Map<String, dynamic>;

            // Pega o ID e Nome do OUTRO usuário (o Professor)
            final outroUsuarioId = (chatData['participantes'] as List)
                .firstWhere((id) => id != currentUserId, orElse: () => '');

            final nomeProfessor = nomes[outroUsuarioId] ?? 'Professor';
            final ultimaMsg = chatData['ultimaMensagem'] ?? '...';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  backgroundColor: MenuConfig.corAluno.withOpacity(0.1),
                  radius: 24,
                  child: Text(
                    nomeProfessor.isNotEmpty
                        ? nomeProfessor[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      color: MenuConfig.corAluno,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  nomeProfessor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    ultimaMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaChat(
                        chatRoomId: chatDoc.id,
                        destinatarioNome: nomeProfessor,
                        corPrincipal: MenuConfig.corAluno,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
