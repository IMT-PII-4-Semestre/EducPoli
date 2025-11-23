import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';

class BoletimAluno extends StatelessWidget {
  const BoletimAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Boletim',
      corPrincipal: MenuConfig.corAluno,
      itensMenu: MenuConfig.menuAluno,
      itemSelecionadoId: 'boletim',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Boletim', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text('Erro: usuário não autenticado'),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('notas').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar boletim: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
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
                const Text(
                  'Nenhuma nota lançada ainda',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Boletim Completo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Desempenho detalhado por matéria',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              ...notas.entries.map((entry) {
                if (entry.key.contains('media_') || entry.key == 'situacao') {
                  return const SizedBox.shrink();
                }
                return _buildMateriaCard(
                  entry.key,
                  entry.value as Map<String, dynamic>,
                  isMobile,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMateriaCard(
    String materia,
    Map<String, dynamic> dados,
    bool isMobile,
  ) {
    final mediaFinal = dados['media_final'] ?? 0.0;
    final situacao = dados['situacao'] ?? 'Pendente';

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Builder(
        builder: (context) => InkWell(
          onTap: isMobile
              ? () => _mostrarDetalhesModal(context, materia, dados)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da matéria
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getCorMateria(materia).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getCorMateria(materia),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            materia,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Média Final: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                mediaFinal.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getCorNota(mediaFinal),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getCorSituacao(situacao).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getCorSituacao(situacao),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        situacao,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _getCorSituacao(situacao),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabela de notas detalhada
              Padding(
                padding: const EdgeInsets.all(20),
                child: isMobile
                    ? _buildTabelaMobile(dados)
                    : _buildTabelaDesktop(dados),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesModal(
      BuildContext context, String materia, Map<String, dynamic> dados) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCorMateria(materia),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.book_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      materia,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Notas Detalhadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Detalhes de cada bimestre
              for (int i = 1; i <= 4; i++)
                if (dados.containsKey('bimestre_$i'))
                  _buildBimestreDetalhado(
                      i, dados['bimestre_$i'] as Map<String, dynamic>),

              const Divider(height: 32),

              // Resumo final
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getCorNota(dados['media_final']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCorNota(dados['media_final']),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Média Final',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dados['media_final']?.toStringAsFixed(1) ?? '-',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getCorNota(dados['media_final']),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _getCorSituacao(dados['situacao'] ?? 'Pendente')
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCorSituacao(dados['situacao'] ?? 'Pendente'),
                    width: 2,
                  ),
                ),
                child: Text(
                  dados['situacao'] ?? 'Pendente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getCorSituacao(dados['situacao'] ?? 'Pendente'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBimestreDetalhado(int numero, Map<String, dynamic> bimData) {
    final prova = bimData['prova'];
    final trabalho = bimData['trabalho'];
    final media = bimData['media'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${numero}º Bimestre',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNotaItem(
                    'Prova', prova?.toStringAsFixed(1) ?? '-', prova),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNotaItem(
                    'Trabalho', trabalho?.toStringAsFixed(1) ?? '-', trabalho),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNotaItem(
                    'Média', media?.toStringAsFixed(1) ?? '-', media),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotaItem(String label, String valor, dynamic nota) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getCorNota(nota),
          ),
        ),
      ],
    );
  }

  Widget _buildTabelaDesktop(Map<String, dynamic> dados) {
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.5),
        5: FlexColumnWidth(1.5),
        6: FlexColumnWidth(1.5),
      },
      children: [
        // Header principal
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            _buildCelulaHeader(''),
            _buildCelulaHeader('1º Bimestre'),
            _buildCelulaHeader('2º Bimestre'),
            _buildCelulaHeader('3º Bimestre'),
            _buildCelulaHeader('4º Bimestre'),
            _buildCelulaHeader('Média Final'),
            _buildCelulaHeader('Situação'),
          ],
        ),
        // Linha Prova
        _buildLinhaDetalhada(
          'Prova',
          dados,
          (bim) => bim['prova'],
        ),
        // Linha Trabalho
        _buildLinhaDetalhada(
          'Trabalho',
          dados,
          (bim) => bim['trabalho'],
        ),
        // Linha Média
        _buildLinhaDetalhada(
          'Média',
          dados,
          (bim) => bim['media'],
        ),
      ],
    );
  }

  TableRow _buildLinhaDetalhada(
    String label,
    Map<String, dynamic> dados,
    dynamic Function(Map<String, dynamic>) getValue,
  ) {
    return TableRow(
      children: [
        _buildCelula(label, true),
        for (int i = 1; i <= 4; i++)
          _buildCelula(
            dados.containsKey('bimestre_$i')
                ? (getValue(dados['bimestre_$i'])?.toStringAsFixed(1) ?? '-')
                : '-',
            false,
          ),
        label == 'Média'
            ? _buildCelulaMedia(
                dados['media_final']?.toStringAsFixed(1) ?? '-',
                dados['media_final'],
              )
            : _buildCelula('-', false),
        label == 'Média'
            ? _buildCelulaSituacao(dados['situacao'] ?? 'Pendente')
            : _buildCelula('-', false),
      ],
    );
  }

  Widget _buildCelulaHeader(String texto) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCelula(String texto, bool isBold) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCelulaMedia(String texto, dynamic valorNumerico) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getCorNota(valorNumerico).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: _getCorNota(valorNumerico),
        ),
      ),
    );
  }

  Widget _buildCelulaSituacao(String situacao) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getCorSituacao(situacao).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getCorSituacao(situacao),
          width: 1.5,
        ),
      ),
      child: Text(
        situacao,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: _getCorSituacao(situacao),
        ),
      ),
    );
  }

  Widget _buildTabelaMobile(Map<String, dynamic> dados) {
    return Column(
      children: [
        for (int i = 1; i <= 4; i++)
          if (dados.containsKey('bimestre_$i'))
            _buildCardBimestre(i, dados['bimestre_$i'] as Map<String, dynamic>),

        // Card de resumo final
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Média Final',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dados['media_final']?.toStringAsFixed(1) ?? '-',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getCorNota(dados['media_final']),
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  const Text(
                    'Situação',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCorSituacao(dados['situacao'] ?? 'Pendente')
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCorSituacao(dados['situacao'] ?? 'Pendente'),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      dados['situacao'] ?? 'Pendente',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getCorSituacao(dados['situacao'] ?? 'Pendente'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardBimestre(int numero, Map<String, dynamic> bimData) {
    final prova = bimData['prova'];
    final trabalho = bimData['trabalho'];
    final media = bimData['media'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$numeroº Bimestre',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItemBimestre(
                  'Prova', prova?.toStringAsFixed(1) ?? '-', prova),
              _buildItemBimestre(
                  'Trabalho', trabalho?.toStringAsFixed(1) ?? '-', trabalho),
              _buildItemBimestre(
                  'Média', media?.toStringAsFixed(1) ?? '-', media),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemBimestre(String label, String valor, dynamic nota) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _getCorNota(nota),
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
