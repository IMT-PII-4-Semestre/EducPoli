import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import '../../services/mensagens_service.dart';
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
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar mensagens.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var chats = snapshot.data?.docs ?? [];

        // Ordenar por timestampUltimaMensagem no cliente
        chats.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['timestampUltimaMensagem'] as Timestamp?;
          final bTime = bData['timestampUltimaMensagem'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime);
        });

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
    String tipoSelecionado = 'aluno';
    Set<String> usuariosSelecionados = {};
    Map<String, String> mapaUsuarios = {};

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                usuariosSelecionados.isEmpty
                    ? 'Iniciar Nova Conversa'
                    : 'Selecionados: ${usuariosSelecionados.length}',
              ),
              content: SizedBox(
                width: 500,
                height: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de tipo
                    const Text(
                      'Enviar mensagem para:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'aluno',
                          label: Text('Alunos'),
                          icon: Icon(Icons.people),
                        ),
                        ButtonSegment(
                          value: 'professor',
                          label: Text('Professores'),
                          icon: Icon(Icons.school),
                        ),
                      ],
                      selected: {tipoSelecionado},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          tipoSelecionado = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Lista de usuários
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: MensagensService.buscarUsuariosPorTipo(
                            tipoSelecionado),
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
                                      'Erro ao carregar usuários',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'É necessário criar um índice no Firestore',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final usuarios = snapshot.data?.docs ?? [];
                          final currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;

                          // Filtrar o próprio usuário
                          final usuariosFiltrados = usuarios
                              .where((doc) => doc.id != currentUserId)
                              .toList();

                          // Ordenar por nome alfabeticamente
                          usuariosFiltrados.sort((a, b) {
                            final nomeA =
                                (a.data() as Map<String, dynamic>)['nome'] ??
                                    '';
                            final nomeB =
                                (b.data() as Map<String, dynamic>)['nome'] ??
                                    '';
                            return nomeA.compareTo(nomeB);
                          });

                          if (usuariosFiltrados.isEmpty) {
                            return Center(
                              child: Text(
                                'Nenhum ${tipoSelecionado} encontrado',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: usuariosFiltrados.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final usuario = usuariosFiltrados[index].data()
                                  as Map<String, dynamic>;
                              final usuarioNome = usuario['nome'] ?? 'Sem nome';
                              final usuarioId = usuariosFiltrados[index].id;
                              final usuarioEmail = usuario['email'] ?? '';

                              // Armazenar no mapa
                              mapaUsuarios[usuarioId] = usuarioNome;

                              final isSelected =
                                  usuariosSelecionados.contains(usuarioId);

                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      usuariosSelecionados.add(usuarioId);
                                    } else {
                                      usuariosSelecionados.remove(usuarioId);
                                    }
                                  });
                                },
                                secondary: CircleAvatar(
                                  backgroundColor:
                                      MenuConfig.corProfessor.withOpacity(0.1),
                                  child: Text(
                                    usuarioNome.isNotEmpty
                                        ? usuarioNome[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      color: MenuConfig.corProfessor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  usuarioNome,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  usuarioEmail,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                activeColor: MenuConfig.corProfessor,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: usuariosSelecionados.isEmpty
                      ? null
                      : () => _iniciarConversasMultiplas(
                            context,
                            usuariosSelecionados,
                            mapaUsuarios,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MenuConfig.corProfessor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Iniciar ${usuariosSelecionados.length > 1 ? "Conversas" : "Conversa"}',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _iniciarConversasMultiplas(
    BuildContext context,
    Set<String> usuariosIds,
    Map<String, String> mapaUsuarios,
  ) async {
    final currentUserNome =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Professor';

    try {
      String? ultimoChatRoomId;
      String? ultimoNome;

      for (String usuarioId in usuariosIds) {
        final nome = mapaUsuarios[usuarioId] ?? 'Usuário';

        ultimoChatRoomId = await MensagensService.criarOuRecuperarChat(
          destinatarioId: usuarioId,
          destinatarioNome: nome,
          currentUserNome: currentUserNome,
        );
        ultimoNome = nome;
      }

      if (context.mounted) {
        Navigator.pop(context);

        // Se selecionou apenas 1, abre o chat diretamente
        if (usuariosIds.length == 1 && ultimoChatRoomId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaChat(
                chatRoomId: ultimoChatRoomId!,
                destinatarioNome: ultimoNome!,
                corPrincipal: MenuConfig.corProfessor,
              ),
            ),
          );
        } else {
          // Se selecionou múltiplos, mostra mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${usuariosIds.length} conversas iniciadas com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar conversas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
