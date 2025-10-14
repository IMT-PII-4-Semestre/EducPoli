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

                        // Figura 3D isométrica CORRIGIDA
                        _buildIsometricCube(),
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

  Widget _buildIsometricCube() {
    return Container(
      height: 200,
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(painter: IsometricCubePainter()),
        ),
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

// Custom Painter para criar o cubo isométrico correto
class IsometricCubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Dimensões do cubo
    final double cubeSize = 60;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Face superior (azul claro)
    paint.color = const Color(0xFF7DD3FC);
    final topPath = Path();
    topPath.moveTo(centerX - cubeSize, centerY - cubeSize / 2);
    topPath.lineTo(centerX, centerY - cubeSize);
    topPath.lineTo(centerX + cubeSize, centerY - cubeSize / 2);
    topPath.lineTo(centerX, centerY);
    topPath.close();
    canvas.drawPath(topPath, paint);

    // Face direita (rosa)
    paint.color = const Color(0xFFFF9EC7);
    final rightPath = Path();
    rightPath.moveTo(centerX, centerY);
    rightPath.lineTo(centerX + cubeSize, centerY - cubeSize / 2);
    rightPath.lineTo(centerX + cubeSize, centerY + cubeSize / 2);
    rightPath.lineTo(centerX, centerY + cubeSize);
    rightPath.close();
    canvas.drawPath(rightPath, paint);

    // Face esquerda (laranja)
    paint.color = const Color(0xFFFFB366);
    final leftPath = Path();
    leftPath.moveTo(centerX - cubeSize, centerY - cubeSize / 2);
    leftPath.lineTo(centerX, centerY);
    leftPath.lineTo(centerX, centerY + cubeSize);
    leftPath.lineTo(centerX - cubeSize, centerY + cubeSize / 2);
    leftPath.close();
    canvas.drawPath(leftPath, paint);

    // Linhas de contorno (opcional)
    paint.color = Colors.black26;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawPath(topPath, paint);
    canvas.drawPath(rightPath, paint);
    canvas.drawPath(leftPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
