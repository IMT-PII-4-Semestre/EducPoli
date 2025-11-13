import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_chat.dart'; // Importa a tela de chat

// DESIGN ALUNO 
const double _kAppBarHeight = 80.0; 
const Color _primaryBlue = Color(0xFF7DD3FC);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class MensagemAluno extends StatefulWidget {
  const MensagemAluno({super.key});

  @override
  State<MensagemAluno> createState() => _MensagemAlunoState();
}

class _MensagemAlunoState extends State<MensagemAluno> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // MENU LATERAL
  final String _selectedNavItemId = 'messages'; 
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Matérias', 'icon': Icons.book, 'id': 'subjects'},
    {'title': 'Mensagem', 'icon': Icons.chat_bubble_outline, 'id': 'messages'},
    {'title': 'Notas', 'icon': Icons.assignment_outlined, 'id': 'notes'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: _primaryBlue,
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
        actions: [], // Aluno não inicia chat, apenas responde
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

  // CONTEÚDO PRINCIPAL: LISTA DE CONVERSAS 
  Widget _buildListaDeConversas() {
    final String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      // Busca por salas de chat onde o aluno logado é um participante
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
                Icon(Icons.message_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma conversa',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const Text(
                  'Aguarde um professor iniciar uma conversa.',
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
            
            // Pega o ID e Nome do OUTRO usuário (o Professor)
            final String outroUsuarioId = (chatData['participantes'] as List)
                .firstWhere((id) => id != currentUserId, orElse: () => '');
            
            final String nomeProfessor = nomes[outroUsuarioId] ?? 'Professor (Erro)';
            final String ultimaMsg = chatData['ultimaMensagem'] ?? '...';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: _primaryBlue.withOpacity(0.1),
                child: Text(nomeProfessor.isNotEmpty ? nomeProfessor[0].toUpperCase() : 'P',
                  style: const TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(nomeProfessor, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(ultimaMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaChat(
                      chatRoomId: chatDoc.id,
                      destinatarioNome: nomeProfessor,
                      corPrincipal: _primaryBlue, 
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

  // BARRA LATERAL (DINÂMICA) 
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 700; 

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: _primaryBlue,
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Aluno"; 

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Aluno";
                } else {
                   nomeExibicao = "Aluno";
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
                    child: const Icon(Icons.person, size: 32, color: Colors.white), 
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
                      if (item['id'] == 'subjects') {
                         if (_selectedNavItemId == 'subjects' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'subjects') Navigator.pushNamed(context, '/aluno/materias');
                      } else if (item['id'] == 'messages') {
                         if (_selectedNavItemId == 'messages' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'messages') Navigator.pushNamed(context, '/aluno/mensagem');
                      } else if (item['id'] == 'notes') {
                         if (_selectedNavItemId == 'notes' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'notes') Navigator.pushNamed(context, '/aluno/notas');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE1F0FF) : _menuItemBg,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: _primaryBlue.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? _primaryBlue : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _primaryBlue : Colors.black87,
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