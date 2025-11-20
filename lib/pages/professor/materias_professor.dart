import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import 'detalhes_materia_professor.dart';

class MateriasProfessor extends StatefulWidget {
  const MateriasProfessor({super.key});

  @override
  State<MateriasProfessor> createState() => _MateriasProfessorState();
}

class _MateriasProfessorState extends State<MateriasProfessor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _minhasMaterias = [];
  bool _carregandoPerfil = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfilProfessor();
  }

  Future<void> _carregarPerfilProfessor() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final listaDoPerfil = List<String>.from(data['materias'] ?? []);

        if (mounted) {
          setState(() {
            _minhasMaterias = listaDoPerfil;
            _carregandoPerfil = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      if (mounted) setState(() => _carregandoPerfil = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Gerenciar Matérias',
      corPrincipal: MenuConfig.corProfessor,
      itensMenu: MenuConfig.menuProfessor,
      itemSelecionadoId: 'materias',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Matérias', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    if (_carregandoPerfil) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: _buildListaMaterias(),
    );
  }

  Widget _buildListaMaterias() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('materias').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar matérias'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final todasMaterias = snapshot.data?.docs ?? [];

        final materiasFiltradas = todasMaterias.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nomeMateria = data['nome'] ?? '';
          return _minhasMaterias.contains(nomeMateria);
        }).toList();

        if (materiasFiltradas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 20),
                const Text(
                  'Você não possui matérias vinculadas',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adicione uma nova ou peça ao diretor',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        if (isMobile) {
          return ListView.separated(
            itemCount: materiasFiltradas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final materiaDoc = materiasFiltradas[index];
              final materia = materiaDoc.data() as Map<String, dynamic>;
              return _buildMateriaCardMobile(materiaDoc.id, materia);
            },
          );
        } else {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              childAspectRatio: 1.5,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: materiasFiltradas.length,
            itemBuilder: (context, index) {
              final materiaDoc = materiasFiltradas[index];
              final materia = materiaDoc.data() as Map<String, dynamic>;
              return _buildMateriaCard(materiaDoc.id, materia);
            },
          );
        }
      },
    );
  }

  Widget _buildMateriaCard(String id, Map<String, dynamic> materia) {
    final materiaNome = materia['nome'] ?? 'Sem nome';
    final descricao = materia['descricao'] ?? 'Sem descrição';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesMateriaProfessor(
                materiaId: id,
                nomeMateria: materiaNome,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MenuConfig.corProfessor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book,
                  color: MenuConfig.corProfessor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                materiaNome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMateriaCardMobile(String id, Map<String, dynamic> materia) {
    final materiaNome = materia['nome'] ?? 'Sem nome';
    final descricao = materia['descricao'] ?? 'Sem descrição';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: MenuConfig.corProfessor.withOpacity(0.1),
          child: Icon(Icons.book, color: MenuConfig.corProfessor),
        ),
        title: Text(materiaNome,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesMateriaProfessor(
                materiaId: id,
                nomeMateria: materiaNome,
              ),
            ),
          );
        },
      ),
    );
  }
}
