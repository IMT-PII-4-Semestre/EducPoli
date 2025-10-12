import 'package:flutter/material.dart';
import '../services/autenticacao.dart';

class DashboardProfessor extends StatelessWidget {
  const DashboardProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header amarelo
          Container(
            height: 100,
            color: const Color(0xFFFF9500),
            child: Row(
              children: [
                // Menu hamburguer
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                ),

                const Spacer(),

                // Título
                const Text(
                  'Área do Professor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                  icon: const Icon(Icons.person, color: Colors.black, size: 28),
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
                        'Adicionar',
                        Icons.person_add,
                        '/professor/adicionar',
                      ),
                      _buildMenuItem(
                        context,
                        'Matérias',
                        Icons.book,
                        '/professor/materias',
                      ),
                      _buildMenuItem(
                        context,
                        'Mensagem',
                        Icons.message,
                        '/professor/mensagem',
                      ),
                      _buildMenuItem(
                        context,
                        'Notas',
                        Icons.assignment,
                        '/professor/notas',
                      ),
                    ],
                  ),
                ),

                // Área principal
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Cards principais
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMainCard(
                                  context,
                                  'adicionar\nalunos',
                                  Icons.person_add,
                                  Colors.grey[300]!,
                                  '/professor/adicionar',
                                ),
                                _buildMainCard(
                                  context,
                                  'Matérias',
                                  Icons.book,
                                  Colors.grey[300]!,
                                  '/professor/materias',
                                ),
                                _buildMainCard(
                                  context,
                                  'Mensagem',
                                  Icons.message,
                                  Colors.grey[300]!,
                                  '/professor/mensagem',
                                ),
                                _buildMainCard(
                                  context,
                                  'Notas',
                                  Icons.assignment,
                                  Colors.grey[300]!,
                                  '/professor/notas',
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Elemento 3D decorativo
                        Container(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cubo laranja
                              Positioned(
                                bottom: 20,
                                left: 400,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              // Cubo rosa
                              Positioned(
                                bottom: 40,
                                right: 350,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.pink[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              // Cubo azul
                              Positioned(
                                top: 20,
                                right: 300,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
        width: 180,
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
