import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/arquivo_service.dart';

const Color primaryBlue = Color(0xFF7DD3FC);

// Adicionando nossa altura padrão
const double _kAppBarHeight = 80.0;

class DetalhesMateriaAluno extends StatelessWidget {
  final String materiaId;
  final String nomeMateria;

  const DetalhesMateriaAluno({
    super.key,
    required this.materiaId,
    required this.nomeMateria,
  });

  Future<void> _abrirMaterial(
      BuildContext context, String aulaId, String materialId) async {
    try {
      final materialDoc = await FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
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
  // --- FIM DA LÓGICA INTERNA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR ATUALIZADA ---
      appBar: AppBar(
        toolbarHeight: _kAppBarHeight, // 1. Altura padronizada
        automaticallyImplyLeading: false,
        backgroundColor: primaryBlue,
        elevation: 0,

        // 2. Ícones brancos
        iconTheme: const IconThemeData(color: Colors.white),

        // ÍCONE DE SETA PARA VOLTAR
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Cor herdada do iconTheme
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // 2. Título com fonte branca
        title: Text(
          nomeMateria,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white, // Cor da letra alterada
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,

        // 3. Ícone de pessoa removido
        actions: [],
      ),

      // O 'body' permanece exatamente igual, sem alteração na lógica
      body: _buildMateriaContent(context),
    );
  }

  Widget _buildMateriaContent(BuildContext context) {
    // StreamBuilder principal para ler as AULAS da matéria
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('aulas')
          .orderBy('ordem')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar aulas.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final aulas = snapshot.data?.docs ?? [];

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

          // StreamBuilder para ler os MATERIAIS de cada aula
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materias')
                .doc(materiaId)
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
    // Obter emoji apropriado para o tipo de arquivo
    final emoji = nomeArquivo != null
        ? ArquivoService.obterIconePorExtensao(nomeArquivo)
        : (type == 'pasta'
            ? '📁'
            : type == 'link'
                ? '🔗'
                : '📄');

    // Formatar tamanho do arquivo se disponível
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
                      'Pasta "$name": Funcionalidade de navegação interna não implementada.')),
            );
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Emoji do tipo de arquivo
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),

              // Nome e tamanho
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

              // Ícone de download/abrir
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
