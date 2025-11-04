import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notas_service.dart';
import '../../services/turma_service.dart';
import '../../models/turma.dart';

class NotasProfessor extends StatefulWidget {
  const NotasProfessor({super.key});

  @override
  State<NotasProfessor> createState() => _NotasProfessorState();
}

class _NotasProfessorState extends State<NotasProfessor> {
  final TextEditingController _buscaController = TextEditingController();
  final NotasService _notasService = NotasService();
  final TurmaService _turmaService = TurmaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _turmaFiltro = 'Selecione';
  String _termoBusca = '';
  List<String> _materiasDisponiveis = [];
  String _materiaSelecionada = '';
  bool _carregandoMaterias = true;

  @override
  void initState() {
    super.initState();
    _carregarMateriasProfessor();
  }

  Future<void> _carregarMateriasProfessor() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final materias = List<String>.from(data['materias'] ?? []);
        setState(() {
          _materiasDisponiveis = materias;
          if (materias.isNotEmpty) {
            _materiaSelecionada = materias.first;
          }
          _carregandoMaterias = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar matérias: $e');
      setState(() => _carregandoMaterias = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoMaterias) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_materiasDisponiveis.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.orange[300]),
              const SizedBox(height: 16),
              const Text(
                'Nenhuma matéria vinculada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Contacte o diretor para ser vinculado a uma matéria',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PAGE HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(40, 24, 40, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Dashboard',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('/', style: TextStyle(color: Colors.grey)),
                    ),
                    const Text(
                      'Gerenciar Notas',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Título
                const Text(
                  'Gerenciar Notas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Edite as notas dos alunos por matéria',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // SELETOR DE MATÉRIA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecione a matéria:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _materiaSelecionada,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: _materiasDisponiveis
                        .map((materia) => DropdownMenuItem(
                              value: materia,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12,
                                ),
                                child: Text(materia),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _materiaSelecionada = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Badge da matéria selecionada
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFB3D9E8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.book,
                        color: Color(0xFF3498DB),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Matéria: $_materiaSelecionada',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // FILTROS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                // Busca
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou RA',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _termoBusca = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),

                // Turma
                Expanded(
                  flex: 2,
                  child: StreamBuilder<List<Turma>>(
                    stream: _turmaService.buscarTurmasAtivas(),
                    builder: (context, snapshot) {
                      List<String> turmas = ['Selecione'];
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        turmas.addAll(snapshot.data!.map((t) => t.nome));
                      }

                      return DropdownButtonFormField<String>(
                        value: _turmaFiltro,
                        decoration: InputDecoration(
                          labelText: 'Turma',
                          labelStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: turmas
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _turmaFiltro = v!),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // TABELA DE ALUNOS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .where('tipo', isEqualTo: 'aluno')
                    .where('ativo', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var alunos = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nome = (data['nome'] ?? '').toString().toLowerCase();
                    final ra = (data['ra'] ?? '').toString().toLowerCase();
                    final turma = data['turma'] ?? '';

                    if (_termoBusca.isNotEmpty &&
                        !nome.contains(_termoBusca) &&
                        !ra.contains(_termoBusca)) return false;

                    if (_turmaFiltro != 'Selecione' && turma != _turmaFiltro) {
                      return false;
                    }

                    return true;
                  }).toList();

                  if (alunos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum aluno encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        // Header da tabela
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Nome',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'RA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Turma',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Ação',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Linhas da tabela
                        Expanded(
                          child: ListView.builder(
                            itemCount: alunos.length,
                            itemBuilder: (context, index) {
                              final alunoDoc = alunos[index];
                              final alunoData =
                                  alunoDoc.data() as Map<String, dynamic>;
                              final alunoId = alunoDoc.id;

                              return InkWell(
                                onTap: () => _abrirEditorNotas(
                                  alunoId,
                                  alunoData,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[100]!,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          alunoData['nome'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          alunoData['ra'] ?? '-',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          alunoData['turma'] ?? '-',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _abrirEditorNotas(
                                            alunoId,
                                            alunoData,
                                          ),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Editar',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFE8F4F8),
                                            foregroundColor:
                                                const Color(0xFF3498DB),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _abrirEditorNotas(
    String alunoId,
    Map<String, dynamic> alunoData,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EditorNotasAluno(
        alunoId: alunoId,
        alunoData: alunoData,
        materiaSelecionada: _materiaSelecionada,
        notasService: _notasService,
      ),
    );
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }
}

class _EditorNotasAluno extends StatefulWidget {
  final String alunoId;
  final Map<String, dynamic> alunoData;
  final String materiaSelecionada;
  final NotasService notasService;

  const _EditorNotasAluno({
    required this.alunoId,
    required this.alunoData,
    required this.materiaSelecionada,
    required this.notasService,
  });

  @override
  State<_EditorNotasAluno> createState() => _EditorNotasAlunoState();
}

class _EditorNotasAlunoState extends State<_EditorNotasAluno> {
  late Map<int, Map<String, TextEditingController>> controllers;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
    _carregarNotas();
  }

  void _inicializarControllers() {
    controllers = {};
    for (int i = 1; i <= 4; i++) {
      controllers[i] = {
        'prova': TextEditingController(),
        'trabalho': TextEditingController(),
      };
    }
  }

  Future<void> _carregarNotas() async {
    try {
      final notas = await widget.notasService.buscarNotasAluno(
        widget.alunoId,
      );

      setState(() {
        _preencherControllers(notas);
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar notas: $e')),
        );
      }
    }
  }

  void _preencherControllers(Map<String, dynamic> notas) {
    final notasMateria =
        notas[widget.materiaSelecionada] as Map<String, dynamic>? ?? {};

    for (int i = 1; i <= 4; i++) {
      final bimData = notasMateria['bim$i'] as Map<String, dynamic>? ?? {};
      final prova = bimData['prova'];
      final trabalho = bimData['trabalho'];

      controllers[i]!['prova']!.text = prova?.toString() ?? '';
      controllers[i]!['trabalho']!.text = trabalho?.toString() ?? '';
    }
  }

  Future<void> _salvarNotas() async {
    try {
      for (int i = 1; i <= 4; i++) {
        final provaText = controllers[i]!['prova']!.text.trim();
        final trabalhoText = controllers[i]!['trabalho']!.text.trim();

        final prova = provaText.isNotEmpty ? double.tryParse(provaText) : null;
        final trabalho =
            trabalhoText.isNotEmpty ? double.tryParse(trabalhoText) : null;

        if (prova != null && (prova < 0 || prova > 10)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Prova do ${i}º bimestre deve estar entre 0 e 10',
              ),
            ),
          );
          return;
        }

        if (trabalho != null && (trabalho < 0 || trabalho > 10)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Trabalho do ${i}º bimestre deve estar entre 0 e 10',
              ),
            ),
          );
          return;
        }

        if (prova != null || trabalho != null) {
          await widget.notasService.salvarNotasDetalhadas(
            alunoId: widget.alunoId,
            materia: widget.materiaSelecionada,
            bimestre: i,
            prova: prova,
            trabalho: trabalho,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notas salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editar Notas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.alunoData['nome'] ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Conteúdo
              if (_carregando)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Info da matéria
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4F8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFB3D9E8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.book,
                              color: Color(0xFF3498DB),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Matéria: ${widget.materiaSelecionada}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3498DB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tabela de notas
                      Table(
                        border: TableBorder.all(color: Colors.grey[200]!),
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          // Header
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Bimestre',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Prova (0-10)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Trabalho (0-10)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Linhas
                          for (int i = 1; i <= 4; i++)
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    '${i}º Bimestre',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextField(
                                    controller: controllers[i]!['prova'],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextField(
                                    controller: controllers[i]!['trabalho'],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Observação
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Digite valores entre 0 e 10. A média será calculada automaticamente.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Footer (Botões)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _carregando ? null : _salvarNotas,
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('Salvar Notas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
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
    );
  }

  @override
  void dispose() {
    for (final bim in controllers.values) {
      for (final controller in bim.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
