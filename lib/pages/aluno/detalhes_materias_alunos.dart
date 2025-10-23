
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 

const Color primaryBlue = Color(0xFF7DD3FC); 
const Color contentRowColor = Color(0xFFF0F0F0); 

class DetalhesMateriaAluno extends StatelessWidget {
  final String materiaId;
  final String nomeMateria;

  const DetalhesMateriaAluno({
    super.key,
    required this.materiaId,
    required this.nomeMateria,
  });

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'pasta':
        return Icons.folder;
      case 'documento':
      case 'arquivo': 
        return Icons.description;
      case 'link':
        return Icons.insert_drive_file;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  // Função de Abertura de Link 
  Future<void> _abrirMaterial(BuildContext context, String aulaId, String materialId) async {
    try {
      final materialDoc = await FirebaseFirestore.instance
          .collection('materias').doc(materiaId)
          .collection('aulas').doc(aulaId)
          .collection('materiais').doc(materialId).get();

      final url = materialDoc.data()?['url'];
      final nome = materialDoc.data()?['nome'] ?? 'Material';

      if (url == null || url.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$nome": Este material não possui um link para abrir.')),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: primaryBlue,
          foregroundColor: Colors.black,
          
          // ÍCONE DE SETA PARA VOLTAR
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); 
            },
          ),
          
          title: Text(
            nomeMateria,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.account_circle, size: 32),
            ),
          ],
        ),
      ),
      
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
                  return _buildMaterialRow(
                    context, 
                    material['nome'] ?? 'Item sem nome', 
                    material['tipo'] ?? 'documento',
                    aulaId,
                    materialDoc.id, 
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
    String materialId,
  ) {
    return InkWell( 
      onTap: () {
        if (type != 'pasta') {
          _abrirMaterial(context, aulaId, materialId);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pasta "$name": Funcionalidade de navegação interna não implementada.')),
          );
        }
      },
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: contentRowColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(_getIconForType(type), size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(color: Colors.grey.shade800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8), 
          ],
        ),
      ),
    );
  }
}