import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../aluno/tela_chat.dart'; 

// DESIGN PROFESSOR
const double _kAppBarHeight = 80.0;
const Color _primaryOrange = Color(0xFFFF9500);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class MensagemProfessor extends StatefulWidget {
  const MensagemProfessor({super.key});

  @override
  State<MensagemProfessor> createState() => _MensagemProfessorState();
}

class _MensagemProfessorState extends State<MensagemProfessor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // MENU LATERAL 
  final String _selectedNavItemId = 'mensagem'; 
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Matérias', 'icon': Icons.book, 'id': 'materias'},
    {'title': 'Mensagem', 'icon': Icons.message, 'id': 'mensagem'},
    {'title': 'Notas', 'icon': Icons.assignment, 'id': 'notas'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: _primaryOrange,
        elevation: 0,
        toolbarHeight: _kAppBarHeight,
        centerTitle: true,
        title: const Text(
          'Mensagens',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Inter',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botão para iniciar nova conversa
          IconButton(
            onPressed: () => _mostrarDialogNovaMensagem(context),
            icon: const Icon(Icons.add_circle_outline, size: 30),
            tooltip: 'Nova Mensagem',
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      drawer: isDesktop ? null : _buildMobileDrawer(),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BARRA LATERAL
          if (isDesktop) 
            SizedBox(width: 280, child: _buildSidebarContent()),

          // CONTEÚDO (Lista de Conversas)
          Expanded(
            child: _buildListaDeConversas(),
          ),
        ],
      ),
    );
  }

  // --- CONTEÚDO PRINCIPAL: LISTA DE CONVERSAS ---
  Widget _buildListaDeConversas() {
    final String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      // Busca por salas de chat onde o professor logado é um participante
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participantes', arrayContains: currentUserId)
          .orderBy('timestampUltimaMensagem', descending: true) // Mostra mais recentes primeiro
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
                Icon(Icons.message_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma conversa iniciada',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const Text(
                  'Clique no "+" para enviar uma mensagem a um aluno.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chatDoc = chats[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final nomes = chatData['nomes'] as Map<String, dynamic>;
            
            // Pega o ID e Nome do OUTRO usuário (o Aluno)
            final String outroUsuarioId = (chatData['participantes'] as List)
                .firstWhere((id) => id != currentUserId, orElse: () => '');
            
            final String nomeAluno = nomes[outroUsuarioId] ?? 'Aluno (Erro)';
            final String ultimaMsg = chatData['ultimaMensagem'] ?? '...';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: _primaryOrange.withOpacity(0.1),
                child: Text(nomeAluno.isNotEmpty ? nomeAluno[0].toUpperCase() : 'A',
                  style: const TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(nomeAluno, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(ultimaMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaChat(
                      chatRoomId: chatDoc.id,
                      destinatarioNome: nomeAluno,
                      corPrincipal: _primaryOrange, // Passa a cor do Professor
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- DIÁLOGO PARA INICIAR NOVA MENSAGEM ---
  // --- DIÁLOGO CORRIGIDO (SEM ERRO DE LAYOUT) ---
  void _mostrarDialogNovaMensagem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Iniciar Nova Conversa'),
          // DEFINIMOS UM TAMANHO FIXO PARA O CONTEÚDO
          content: SizedBox(
            width: 400, // Largura fixa
            height: 500, // Altura fixa (Isso resolve o erro do ListView infinito)
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('tipo', isEqualTo: 'aluno')
                  .orderBy('nome')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SingleChildScrollView( // Scroll para ver o erro inteiro
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          const Text('Erro no Firebase:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(fontSize: 12, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text('Verifique o terminal para o link do índice.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
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
                
                // LISTVIEW AGORA TEM ESPAÇO DEFINIDO PELO SIZEDBOX ACIMA
                return ListView.builder(
                  shrinkWrap: true, // Importante para diálogos
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

  // --- LÓGICA DE BACKEND: CRIAR CHAT ---
  Future<void> _criarChat(BuildContext context, String alunoId, String alunoNome) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserNome = _auth.currentUser?.displayName ?? "Professor"; // Você pode buscar o nome do 'usuarios' se preferir

    // Gera um ID de sala único e consistente (ordenando os UIDs)
    List<String> ids = [currentUserId, alunoId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Cria/Define os dados da sala de chat
    await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
      'participantes': [currentUserId, alunoId],
      'nomes': {
        currentUserId: currentUserNome,
        alunoId: alunoNome,
      },
      'timestampUltimaMensagem': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Merge:true não sobrescreve se já existir

    if (context.mounted) {
      Navigator.pop(context); // Fecha o diálogo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaChat(
            chatRoomId: chatRoomId,
            destinatarioNome: alunoNome,
            corPrincipal: _primaryOrange,
          ),
        ),
      );
    }
  }


  // --- BARRA LATERAL (DINÂMICA) ---
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 800; 

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: _primaryOrange,
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Professor"; 

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Professor";
                } else {
                   nomeExibicao = "Professor";
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school, size: 32, color: Colors.white), 
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    nomeExibicao,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cargoExibicao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // LISTA DE ITENS
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = item['id'] == _selectedNavItemId;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (item['id'] == 'materias') {
                         if (_selectedNavItemId == 'materias' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'materias') Navigator.pushNamed(context, '/professor/materias');
                      } else if (item['id'] == 'mensagem') {
                         if (_selectedNavItemId == 'mensagem' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'mensagem') Navigator.pushNamed(context, '/professor/mensagem');
                      } else if (item['id'] == 'notas') {
                         if (_selectedNavItemId == 'notas' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'notas') Navigator.pushNamed(context, '/professor/notas');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF3E0) : _menuItemBg,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: _primaryOrange.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? _primaryOrange : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _primaryOrange : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer() => Drawer(child: _buildSidebarContent());
}