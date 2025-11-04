import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notas_service.dart';
import 'boletim_aluno.dart';

class NotasAluno extends StatefulWidget {
  const NotasAluno({super.key});

  @override
  State<NotasAluno> createState() => _NotasAlunoState();
}

class _NotasAlunoState extends State<NotasAluno>
    with SingleTickerProviderStateMixin {
  final NotasService _notasService = NotasService();
  Map<String, dynamic>? _dadosAluno;
  bool _carregando = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'Minhas Notas',
          style: TextStyle(color: Colors.black87),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3498DB),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF3498DB),
          tabs: const [
            Tab(
              icon: Icon(Icons.assessment, size: 20),
              text: 'Notas',
            ),
            Tab(
              icon: Icon(Icons.assignment, size: 20),
              text: 'Boletim',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAbaNotes(isMobile),
          const BoletimAluno(),
        ],
      ),
    );
  }

  Widget _buildAbaNotes(bool isMobile) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
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
                _buildHeaderNotas(isMobile),
                const SizedBox(height: 32),
                _buildResumoGeral(uid ?? '', isMobile),
                const SizedBox(height: 32),
                const Text(
                  'Notas por Matéria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...notas.entries.map((entry) {
                  if (entry.key.startsWith('_')) return const SizedBox.shrink();
                  return _buildCardMateria(
                    entry.key,
                    entry.value as Map<String, dynamic>? ?? {},
                    isMobile,
                  );
                }).toList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderNotas(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minhas Notas',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              _dadosAluno?['nome'] ?? '-',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(width: 24),
            Icon(Icons.badge, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'RA: ${_dadosAluno?['ra'] ?? '-'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(width: 24),
            Icon(Icons.class_, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Turma: ${_dadosAluno?['turma'] ?? '-'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumoGeral(String uid, bool isMobile) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _notasService.buscarEstatisticasAluno(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final mediaGeral = stats['media_geral'] ?? 0.0;
        final totalMaterias = stats['total_materias'] ?? 0;
        final aprovado = stats['aprovado_em'] ?? 0;
        final recuperacao = stats['recuperacao_em'] ?? 0;

        if (isMobile) {
          return Column(
            children: [
              _buildCardEstatistica(
                'Média Geral',
                mediaGeral.toStringAsFixed(2),
                Icons.school,
                _getCorNota(mediaGeral),
                isMobile,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCardEstatistica(
                      'Aprovado',
                      '$aprovado',
                      Icons.check_circle,
                      Colors.green,
                      isMobile,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCardEstatistica(
                      'Recuperação',
                      '$recuperacao',
                      Icons.warning,
                      Colors.orange,
                      isMobile,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCardEstatistica(
                'Total de Matérias',
                totalMaterias.toString(),
                Icons.book,
                Colors.blue,
                isMobile,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildCardEstatistica(
                'Média Geral',
                mediaGeral.toStringAsFixed(2),
                Icons.school,
                _getCorNota(mediaGeral),
                isMobile,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardEstatistica(
                'Aprovado em',
                '$aprovado matérias',
                Icons.check_circle,
                Colors.green,
                isMobile,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardEstatistica(
                'Recuperação em',
                '$recuperacao matérias',
                Icons.warning,
                Colors.orange,
                isMobile,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardEstatistica(
                'Total de Matérias',
                totalMaterias.toString(),
                Icons.book,
                Colors.blue,
                isMobile,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardEstatistica(
    String label,
    String valor,
    IconData icone,
    Color cor,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icone, color: cor, size: 24),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMateria(
    String materia,
    Map<String, dynamic> notas,
    bool isMobile,
  ) {
    final bim1 = notas['bim1'];
    final bim2 = notas['bim2'];
    final bim3 = notas['bim3'];
    final bim4 = notas['bim4'];
    final media = notas['media_final'] ?? notas['media'];
    final situacao = notas['situacao'] ?? 'Pendente';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getCorMateria(materia),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIconeMateria(materia),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      materia,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        media?.toStringAsFixed(2) ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Média',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: isMobile
                ? Column(
                    children: [
                      _buildNotaBimestre('1º Bimestre', bim1, isMobile),
                      const SizedBox(height: 12),
                      _buildNotaBimestre('2º Bimestre', bim2, isMobile),
                      const SizedBox(height: 12),
                      _buildNotaBimestre('3º Bimestre', bim3, isMobile),
                      const SizedBox(height: 12),
                      _buildNotaBimestre('4º Bimestre', bim4, isMobile),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNotaBimestre('1º Bim', bim1, isMobile),
                      _buildNotaBimestre('2º Bim', bim2, isMobile),
                      _buildNotaBimestre('3º Bim', bim3, isMobile),
                      _buildNotaBimestre('4º Bim', bim4, isMobile),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconeSituacao(situacao),
                  size: 18,
                  color: _getCorSituacao(situacao),
                ),
                const SizedBox(width: 8),
                Text(
                  'Situação: $situacao',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getCorSituacao(situacao),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotaBimestre(String label, dynamic nota, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nota?.toStringAsFixed(2) ?? '-',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _getCorNota(nota),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCorNota(dynamic nota) {
    if (nota == null) return Colors.grey;
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

  IconData _getIconeMateria(String materia) {
    final icones = {
      'Matemática': Icons.calculate,
      'Português': Icons.menu_book,
      'História': Icons.history_edu,
      'Geografia': Icons.public,
      'Ciências': Icons.science,
      'Inglês': Icons.language,
      'Educação Física': Icons.sports_soccer,
      'Artes': Icons.palette,
      'Física': Icons.waves,
      'Química': Icons.biotech,
      'Biologia': Icons.eco,
      'Filosofia': Icons.psychology,
      'Sociologia': Icons.groups,
    };
    return icones[materia] ?? Icons.book;
  }

  Color _getCorSituacao(String situacao) {
    if (situacao == 'Aprovado') return Colors.green;
    if (situacao == 'Recuperação') return Colors.orange;
    if (situacao == 'Reprovado') return Colors.red;
    return Colors.grey;
  }

  IconData _getIconeSituacao(String situacao) {
    if (situacao == 'Aprovado') return Icons.check_circle;
    if (situacao == 'Recuperação') return Icons.warning;
    if (situacao == 'Reprovado') return Icons.cancel;
    return Icons.help;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
