import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import '../aluno/tela_chat.dart';

class MensagemProfessor extends StatelessWidget {
  const MensagemProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Mensagens',
      corPrincipal: MenuConfig.corProfessor,
      itensMenu: MenuConfig.menuProfessor,
      itemSelecionadoId: 'mensagens',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Mensagens', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    return Column(
      children: [
        // Botão nova mensagem no topo
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogNovaMensagem(context),
                icon: const Icon(Icons.add),
                label: const Text('Nova Mensagem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MenuConfig.corProfessor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        // Lista de conversas
        Expanded(child: _buildListaDeConversas(context)),
      ],
    );
  }

  Widget _buildListaDeConversas(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participantes', arrayContains: currentUserId)
          .orderBy('timestampUltimaMensagem', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar mensagens.'));
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
                Icon(Icons.message_outlined,
                    size: 100, color: Colors.grey[300]),
                const SizedBox(height: 20),
                const Text(
                  'Nenhuma conversa iniciada',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Clique em "Nova Mensagem" para começar',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chatDoc = chats[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final nomes = chatData['nomes'] as Map<String, dynamic>;

            final String outroUsuarioId = (chatData['participantes'] as List)
                .firstWhere((id) => id != currentUserId, orElse: () => '');

            final String nomeAluno = nomes[outroUsuarioId] ?? 'Aluno';
            final String ultimaMsg = chatData['ultimaMensagem'] ?? '...';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: MenuConfig.corProfessor.withOpacity(0.1),
                  child: Text(
                    nomeAluno.isNotEmpty ? nomeAluno[0].toUpperCase() : 'A',
                    style: TextStyle(
                      color: MenuConfig.corProfessor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  nomeAluno,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ultimaMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaChat(
                        chatRoomId: chatDoc.id,
                        destinatarioNome: nomeAluno,
                        corPrincipal: MenuConfig.corProfessor,
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

  void _mostrarDialogNovaMensagem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Iniciar Nova Conversa'),
          content: SizedBox(
            width: 400,
            height: 500,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('tipo', isEqualTo: 'aluno')
                  .orderBy('nome')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Erro ao carregar alunos',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'É necessário criar um índice no Firestore',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Verifique o terminal para o link do índice.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final alunos = snapshot.data?.docs ?? [];

                if (alunos.isEmpty) {
                  return const Center(child: Text('Nenhum aluno encontrado.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: alunos.length,
                  itemBuilder: (context, index) {
                    final aluno = alunos[index].data() as Map<String, dynamic>;
                    final alunoNome = aluno['nome'] ?? 'Aluno sem nome';
                    final alunoId = alunos[index].id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      title: Text(alunoNome),
                      subtitle: Text(aluno['email'] ?? ''),
                      onTap: () => _criarChat(context, alunoId, alunoNome),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _criarChat(
      BuildContext context, String alunoId, String alunoNome) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final String currentUserNome =
        FirebaseAuth.instance.currentUser?.displayName ?? "Professor";

    List<String> ids = [currentUserId, alunoId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
      'participantes': [currentUserId, alunoId],
      'nomes': {
        currentUserId: currentUserNome,
        alunoId: alunoNome,
      },
      'timestampUltimaMensagem': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (context.mounted) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaChat(
            chatRoomId: chatRoomId,
            destinatarioNome: alunoNome,
            corPrincipal: MenuConfig.corProfessor,
          ),
        ),
      );
    }
  }
}
