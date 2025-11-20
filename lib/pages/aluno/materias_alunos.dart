import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalhes_materias_alunos.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';

class MateriasAluno extends StatelessWidget {
  const MateriasAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Matérias',
      corPrincipal: MenuConfig.corAluno,
      itensMenu: MenuConfig.menuAluno,
      itemSelecionadoId: 'materias',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Matérias', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('materias').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar matérias: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final materias = snapshot.data?.docs ?? [];

          if (materias.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma matéria cadastrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final isDesktop = MediaQuery.of(context).size.width > 800;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isDesktop ? 1.2 : 3.5,
            ),
            itemCount: materias.length,
            itemBuilder: (context, index) {
              final materia = materias[index];
              final dados = materia.data() as Map<String, dynamic>;
              return _buildMateriaCard(
                context,
                materia.id,
                dados['nome'] ?? 'Sem nome',
                dados['descricao'] ?? 'Sem descrição',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMateriaCard(
    BuildContext context,
    String id,
    String nome,
    String descricao,
  ) {
    final cores = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];

    final cor = cores[id.hashCode % cores.length];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesMateriaAluno(
                materiaId: id,
                nomeMateria: nome,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cor.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone da matéria
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book_outlined,
                  color: cor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),

              // Nome da matéria
              Text(
                nome,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Descrição
              Expanded(
                child: Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),

              // Botão de acessar
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Acessar',
                        style: TextStyle(
                          color: cor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: cor,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
