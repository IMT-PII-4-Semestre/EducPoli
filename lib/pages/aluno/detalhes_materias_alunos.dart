import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/arquivo_service.dart';

const Color primaryBlue = Color(0xFF7DD3FC);
const double _kAppBarHeight = 80.0;

class DetalhesMateriaAluno extends StatefulWidget {
  final String materiaId;
  final String nomeMateria;

  const DetalhesMateriaAluno({
    super.key,
    required this.materiaId,
    required this.nomeMateria,
  });

  @override
  State<DetalhesMateriaAluno> createState() => _DetalhesMateriaAlunoState();
}

class _DetalhesMateriaAlunoState extends State<DetalhesMateriaAluno> {
  String? _turmaAluno;
  bool _carregandoTurma = true;

  @override
  void initState() {
    super.initState();
    _carregarTurmaAluno();
  }

  Future<void> _carregarTurmaAluno() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _turmaAluno = data['turma'];
          _carregandoTurma = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar turma: $e');
      setState(() => _carregandoTurma = false);
    }
  }

  Future<void> _abrirMaterial(
      BuildContext context, String aulaId, String materialId) async {
    try {
      final materialDoc = await FirebaseFirestore.instance
          .collection('materias')
          .doc(widget.materiaId)
          .collection('aulas')
          .doc(aulaId)
          .collection('materiais')
          .doc(materialId)
          .get();

      final url = materialDoc.data()?['url'];
      final nome = materialDoc.data()?['nome'] ?? 'Material';

      if (url == null || url.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '"$nome": Este material não possui um link para abrir.')),
          );
        }
        return;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          throw 'Não foi possível abrir o link: $url.';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir material: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _kAppBarHeight,
        automaticallyImplyLeading: false,
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.nomeMateria,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: _buildMateriaContent(context),
    );
  }

  Widget _buildMateriaContent(BuildContext context) {
    if (_carregandoTurma) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_turmaAluno == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_outlined, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Você não está vinculado a uma turma',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('materias')
          .doc(widget.materiaId)
          .collection('aulas')
          .where('turma', isEqualTo: _turmaAluno)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Erro no StreamBuilder: ${snapshot.error}');
          return const Center(child: Text('Erro ao carregar aulas.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var aulas = snapshot.data?.docs ?? [];
        // Ordenar manualmente por ordem
        aulas.sort((a, b) {
          final ordemA = (a.data() as Map<String, dynamic>)['ordem'] ?? 0;
          final ordemB = (b.data() as Map<String, dynamic>)['ordem'] ?? 0;
          return ordemA.compareTo(ordemB);
        });

        if (aulas.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhuma seção disponível para sua turma',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...aulas.map((aulaDoc) {
                final aulaData = aulaDoc.data() as Map<String, dynamic>;
                final aulaId = aulaDoc.id;
                final titulo = aulaData['titulo'] ?? 'Aula Sem Título';

                return _buildAulaSection(context, titulo, aulaId);
              }).toList(),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAulaSection(BuildContext context, String title, String aulaId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materias')
                .doc(widget.materiaId)
                .collection('aulas')
                .doc(aulaId)
                .collection('materiais')
                .orderBy('nome')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Erro ao carregar materiais.');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              final materiais = snapshot.data?.docs ?? [];

              if (materiais.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Nenhum material adicionado nesta seção.'),
                );
              }

              return Column(
                children: materiais.map((materialDoc) {
                  final material = materialDoc.data() as Map<String, dynamic>;
                  final nomeArquivo = material['nomeArquivo'] as String?;
                  final tamanhoArquivo = material['tamanhoArquivo'] as int?;

                  return _buildMaterialRow(
                    context,
                    material['nome'] ?? 'Item sem nome',
                    material['tipo'] ?? 'documento',
                    aulaId,
                    materialDoc.id,
                    nomeArquivo: nomeArquivo,
                    tamanhoArquivo: tamanhoArquivo,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(
    BuildContext context,
    String name,
    String type,
    String aulaId,
    String materialId, {
    String? nomeArquivo,
    int? tamanhoArquivo,
  }) {
    final emoji = nomeArquivo != null
        ? ArquivoService.obterIconePorExtensao(nomeArquivo)
        : (type == 'pasta'
            ? ''
            : type == 'link'
                ? ''
                : '');

    final tamanhoFormatado = tamanhoArquivo != null
        ? ArquivoService.formatarTamanho(tamanhoArquivo)
        : '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (type != 'pasta') {
            _abrirMaterial(context, aulaId, materialId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Pasta "$name": Funcionalidade de navegacao interna nao implementada.')),
            );
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tamanhoFormatado.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tamanhoFormatado,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (type != 'pasta')
                Icon(
                  Icons.download,
                  color: primaryBlue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
