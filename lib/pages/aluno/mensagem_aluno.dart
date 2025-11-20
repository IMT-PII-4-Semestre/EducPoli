import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import '../../services/mensagens_service.dart';
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
                  backgroundColor: MenuConfig.corAluno,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        // Lista de conversas
        Expanded(child: _buildListaConversas(context, currentUserId)),
      ],
    );
  }

  Widget _buildListaConversas(BuildContext context, String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participantes', arrayContains: currentUserId)
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

  void _mostrarDialogNovaMensagem(BuildContext context) {
    String tipoSelecionado = 'professor';
    Set<String> usuariosSelecionados = {};
    Map<String, String> mapaUsuarios = {}; // Para armazenar ID -> Nome

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
                          value: 'professor',
                          label: Text('Professores'),
                          icon: Icon(Icons.school),
                        ),
                        ButtonSegment(
                          value: 'aluno',
                          label: Text('Alunos'),
                          icon: Icon(Icons.people),
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
                            return const Center(
                              child: Text('Erro ao carregar usuários'),
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
                                      MenuConfig.corAluno.withOpacity(0.1),
                                  child: Text(
                                    usuarioNome.isNotEmpty
                                        ? usuarioNome[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      color: MenuConfig.corAluno,
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
                                activeColor: MenuConfig.corAluno,
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
                    backgroundColor: MenuConfig.corAluno,
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
        FirebaseAuth.instance.currentUser?.displayName ?? 'Aluno';

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
                corPrincipal: MenuConfig.corAluno,
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
