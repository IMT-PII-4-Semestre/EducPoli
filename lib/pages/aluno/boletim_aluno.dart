import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notas_service.dart';

class BoletimAluno extends StatefulWidget {
  const BoletimAluno({super.key});

  @override
  State<BoletimAluno> createState() => _BoletimAlunoState();
}

class _BoletimAlunoState extends State<BoletimAluno> {
  final NotasService _notasService = NotasService();
  Map<String, dynamic>? _dadosAluno;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosAluno();
  }

  Future<void> _carregarDadosAluno() async {
    setState(() => _carregando = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          _dadosAluno = doc.data();
          _dadosAluno!['id'] = doc.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Boletim Escolar',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('notas').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> notas = {};
          if (snapshot.data!.exists) {
            notas = snapshot.data!.data() as Map<String, dynamic>;
          }

          if (notas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'Nenhuma nota lançada ainda',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderBoletim(isMobile),
                  const SizedBox(height: 32),
                  ...notas.entries.map((entry) {
                    if (entry.key.contains('media_') ||
                        entry.key == 'situacao') {
                      return const SizedBox.shrink();
                    }
                    return _buildTabelaMateriaBoletim(
                      entry.key,
                      entry.value as Map<String, dynamic>,
                      isMobile,
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBoletim(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOLETIM ESCOLAR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Período: 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (!isMobile)
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFFF9500),
                  child: Text(
                    _dadosAluno?['nome']?.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 16),
          _buildInfoAluno('Nome', _dadosAluno?['nome'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoAluno('RA', _dadosAluno?['ra'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoAluno('Turma', _dadosAluno?['turma'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoAluno(String label, String valor) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabelaMateriaBoletim(
    String materia,
    Map<String, dynamic> dados,
    bool isMobile,
  ) {
    final mediaFinal = dados['media_final'] ?? 0.0;
    final situacao = dados['situacao'] ?? 'Pendente';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header matéria
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getCorMateria(materia),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  materia,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mediaFinal.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getCorNota(mediaFinal),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabela de bimestres
          if (isMobile)
            _buildTabelaMobileBoletim(dados)
          else
            _buildTabelaDesktopBoletim(dados),

          // Footer com situação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Situação:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCorSituacao(situacao),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    situacao,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildTabelaDesktopBoletim(Map<String, dynamic> dados) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[200]!),
            verticalInside: BorderSide(color: Colors.grey[200]!),
          ),
          columnWidths: {
            0: const FixedColumnWidth(100),
            1: const FixedColumnWidth(80),
            2: const FixedColumnWidth(80),
            3: const FixedColumnWidth(80),
            4: const FixedColumnWidth(80),
            5: const FixedColumnWidth(80),
            6: const FixedColumnWidth(80),
          },
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                _buildCelulaHeader('Bimestre'),
                _buildCelulaHeader('Prova'),
                _buildCelulaHeader('Trabalho'),
                _buildCelulaHeader('Média'),
                _buildCelulaHeader('Prova'),
                _buildCelulaHeader('Trabalho'),
                _buildCelulaHeader('Média'),
              ],
            ),
            // Dados bimestres
            for (int i = 1; i <= 4; i++)
              _buildLinhaBoletim(
                '${i}º Bim',
                dados['bim$i'] as Map<String, dynamic>? ?? {},
              ),
          ],
        ),
      ),
    );
  }

  TableRow _buildLinhaBoletim(
    String label,
    Map<String, dynamic> bimData,
  ) {
    final prova = bimData['prova'];
    final trabalho = bimData['trabalho'];
    final media = bimData['media'];

    return TableRow(
      children: [
        _buildCelula(label, true),
        _buildCelula(prova?.toStringAsFixed(1) ?? '-', false),
        _buildCelula(trabalho?.toStringAsFixed(1) ?? '-', false),
        _buildCelula(media?.toStringAsFixed(1) ?? '-', false),
        _buildCelula(prova?.toStringAsFixed(1) ?? '-', false),
        _buildCelula(trabalho?.toStringAsFixed(1) ?? '-', false),
        _buildCelula(media?.toStringAsFixed(1) ?? '-', false),
      ],
    );
  }

  Widget _buildCelulaHeader(String texto) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildCelula(String texto, bool isHeader) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTabelaMobileBoletim(Map<String, dynamic> dados) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 1; i <= 4; i++)
            _buildCardBimestre(
                i, dados['bim$i'] as Map<String, dynamic>? ?? {}),
        ],
      ),
    );
  }

  Widget _buildCardBimestre(int numero, Map<String, dynamic> bimData) {
    final prova = bimData['prova'];
    final trabalho = bimData['trabalho'];
    final media = bimData['media'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${numero}º Bimestre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCorNota(media),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    media?.toStringAsFixed(1) ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildItemBimestre('Prova', prova?.toStringAsFixed(1) ?? '-'),
                _buildItemBimestre(
                    'Trabalho', trabalho?.toStringAsFixed(1) ?? '-'),
                _buildItemBimestre('Média', media?.toStringAsFixed(1) ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBimestre(String label, String valor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getCorNota(dynamic nota) {
    if (nota == null || nota == 0.0) return Colors.grey;
    final n = nota is num ? nota.toDouble() : 0.0;
    if (n >= 7.0) return Colors.green;
    if (n >= 5.0) return Colors.orange;
    return Colors.red;
  }

  Color _getCorMateria(String materia) {
    final cores = {
      'Matemática': const Color(0xFF3498DB),
      'Português': const Color(0xFFE74C3C),
      'História': const Color(0xFF9B59B6),
      'Geografia': const Color(0xFFE67E22),
      'Ciências': const Color(0xFF27AE60),
      'Inglês': const Color(0xFFF39C12),
      'Educação Física': const Color(0xFF1ABC9C),
      'Artes': const Color(0xFFE91E63),
      'Física': const Color(0xFF34495E),
      'Química': const Color(0xFF16A085),
      'Biologia': const Color(0xFF2ECC71),
      'Filosofia': const Color(0xFF8E44AD),
      'Sociologia': const Color(0xFFD35400),
    };
    return cores[materia] ?? const Color(0xFF95A5A6);
  }

  Color _getCorSituacao(String situacao) {
    if (situacao == 'Aprovado') return Colors.green;
    if (situacao == 'Recuperação') return Colors.orange;
    if (situacao == 'Reprovado') return Colors.red;
    return Colors.grey;
  }
}
