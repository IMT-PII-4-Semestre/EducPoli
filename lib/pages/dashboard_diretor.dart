import 'package:flutter/material.dart';
import '../services/autenticacao.dart';

class DashboardDiretor extends StatelessWidget {
  const DashboardDiretor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header vermelho
          Container(
            height: 100,
            color: const Color(0xFFE74C3C),
            child: Row(
              children: [
                // Menu hamburguer
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),

                const Spacer(),

                // Título
                const Text(
                  'Área do Diretor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                // Ícone de usuário
                IconButton(
                  onPressed: () async {
                    await ServicoAutenticacao().sair();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  icon: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // Corpo principal
          Expanded(
            child: Row(
              children: [
                // Menu lateral esquerdo - CINZA PADRONIZADO
                Container(
                  width: 250,
                  color: Colors.grey[300],
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Menu items
                      _buildMenuItem(
                        context,
                        'alunos',
                        Icons.person,
                        '/diretor/alunos',
                      ),
                      _buildMenuItem(
                        context,
                        'professores',
                        Icons.person_3,
                        '/diretor/professores',
                      ),
                    ],
                  ),
                ),

                // Área principal
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMainCard(
                              context,
                              'alunos',
                              Icons.person,
                              Colors.grey[300]!,
                              '/diretor/alunos',
                            ),
                            const SizedBox(width: 40),
                            _buildMainCard(
                              context,
                              'professores',
                              Icons.person_3,
                              Colors.grey[300]!,
                              '/diretor/professores',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: () => Navigator.pushNamed(context, route),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
