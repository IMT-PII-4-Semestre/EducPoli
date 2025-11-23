import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/autenticacao.dart';

/// Item de menu com ícone, título e rota
class ItemMenu {
  final String titulo;
  final IconData icone;
  final String rota;
  final String id;

  const ItemMenu({
    required this.titulo,
    required this.icone,
    required this.rota,
    required this.id,
  });
}

/// Menu Lateral Centralizado - Componente único para toda a aplicação
class MenuLateral extends StatelessWidget {
  final List<ItemMenu> itensMenu;
  final String itemSelecionadoId;
  final Color corPrincipal;

  const MenuLateral({
    super.key,
    required this.itensMenu,
    required this.itemSelecionadoId,
    required this.corPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER DO PERFIL
          _buildHeader(user, context),

          const SizedBox(height: 20),

          // ITENS DO MENU
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: itensMenu.length,
              itemBuilder: (context, index) {
                final item = itensMenu[index];
                final isSelected = item.id == itemSelecionadoId;
                return _buildMenuItem(context, item, isSelected);
              },
            ),
          ),

          // BOTÕES DE AÇÃO (INÍCIO E SAIR)
          _buildBotoesAcao(context),
        ],
      ),
    );
  }

  /// Header com informações do usuário
  Widget _buildHeader(User? user, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: user != null
          ? FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .get()
          : null,
      builder: (context, snapshot) {
        String nome = 'Usuário';
        String tipo = 'usuário';
        String email = user?.email ?? '';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          nome = data['nome'] ?? 'Usuário';
          tipo = data['tipo'] ?? 'usuário';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                corPrincipal,
                corPrincipal,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar circular
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    nome.isNotEmpty ? nome[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nome do usuário
              Text(
                nome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Badge do tipo de usuário
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  tipo.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Item individual do menu
  Widget _buildMenuItem(BuildContext context, ItemMenu item, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navega sem empilhar - substitui a rota atual
            Navigator.pushReplacementNamed(context, item.rota);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? corPrincipal.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? corPrincipal.withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icone,
                  color: isSelected ? corPrincipal : Colors.grey[600],
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.titulo,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? corPrincipal : Colors.grey[700],
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: corPrincipal,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Botão de ação: Sair
  Widget _buildBotoesAcao(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: _buildBotaoAcao(
        context: context,
        icone: Icons.logout,
        texto: 'Sair',
        cor: Colors.red,
        onTap: () async {
          await _sair(context);
        },
      ),
    );
  }

  /// Botão de ação genérico
  Widget _buildBotaoAcao({
    required BuildContext context,
    required IconData icone,
    required String texto,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: cor, size: 20),
              const SizedBox(width: 12),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Realiza logout
  Future<void> _sair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await ServicoAutenticacao().sair();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }
}

/// Drawer para Mobile
class MenuLateralDrawer extends StatelessWidget {
  final List<ItemMenu> itensMenu;
  final String itemSelecionadoId;
  final Color corPrincipal;

  const MenuLateralDrawer({
    super.key,
    required this.itensMenu,
    required this.itemSelecionadoId,
    required this.corPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MenuLateral(
        itensMenu: itensMenu,
        itemSelecionadoId: itemSelecionadoId,
        corPrincipal: corPrincipal,
      ),
    );
  }
}
