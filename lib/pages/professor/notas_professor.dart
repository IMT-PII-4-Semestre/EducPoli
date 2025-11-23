import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
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
      return LayoutBase(
        titulo: 'Gerenciar Notas',
        corPrincipal: MenuConfig.corProfessor,
        itensMenu: MenuConfig.menuProfessor,
        itemSelecionadoId: 'notas',
        breadcrumbs: const [
          Breadcrumb(texto: 'Início'),
          Breadcrumb(texto: 'Notas', isAtivo: true),
        ],
        conteudo: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 100, color: Colors.grey[300]),
              const SizedBox(height: 20),
              const Text(
                'Você não possui matérias vinculadas',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Adicione matérias na seção "Matérias"',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBase(
      titulo: 'Gerenciar Notas',
      corPrincipal: MenuConfig.corProfessor,
      itensMenu: MenuConfig.menuProfessor,
      itemSelecionadoId: 'notas',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Notas', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltrosSuperiores(),
          const SizedBox(height: 24),
          Expanded(child: _buildTabelaAlunos()),
        ],
      ),
    );
  }

  Widget _buildFiltrosSuperiores() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seletor de Matéria
        const Text(
          'Selecione a matéria:',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _materiaSelecionada,
              isExpanded: true,
              items: _materiasDisponiveis
                  .map((materia) => DropdownMenuItem(
                        value: materia,
                        child: Text(materia),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _materiaSelecionada = value);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Filtros de Busca e Turma
        if (isMobile) ...[
          TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou RA',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) =>
                setState(() => _termoBusca = value.toLowerCase()),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Turma>>(
            stream: _turmaService.buscarTurmasAtivas(),
            builder: (context, snapshot) {
              List<String> turmas = ['Selecione'];
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                turmas.addAll(snapshot.data!.map((t) => t.nome).toList());
              }
              return DropdownButtonFormField<String>(
                value: _turmaFiltro,
                decoration: InputDecoration(
                  labelText: 'Turma',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: turmas
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _turmaFiltro = v!),
              );
            },
          ),
        ] else
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou RA',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) =>
                      setState(() => _termoBusca = value.toLowerCase()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: StreamBuilder<List<Turma>>(
                  stream: _turmaService.buscarTurmasAtivas(),
                  builder: (context, snapshot) {
                    List<String> turmas = ['Selecione'];
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      turmas.addAll(snapshot.data!.map((t) => t.nome).toList());
                    }
                    return DropdownButtonFormField<String>(
                      value: _turmaFiltro,
                      decoration: InputDecoration(
                        labelText: 'Turma',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: turmas
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _turmaFiltro = v!),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTabelaAlunos() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('tipo', isEqualTo: 'aluno')
          .where('ativo', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
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
              !ra.contains(_termoBusca)) {
            return false;
          }
          if (_turmaFiltro != 'Selecione' && turma != _turmaFiltro)
            return false;

          return true;
        }).toList();

        if (alunos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum aluno encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        if (isMobile) {
          return ListView.separated(
            itemCount: alunos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alunoDoc = alunos[index];
              final alunoData = alunoDoc.data() as Map<String, dynamic>;
              return _buildAlunoCardMobile(alunoDoc.id, alunoData);
            },
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
              // Header da Tabela
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('Nome',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('RA',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Turma',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(
                        width: 120,
                        child: Text('Ação',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: alunos.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final alunoDoc = alunos[index];
                    final alunoData = alunoDoc.data() as Map<String, dynamic>;
                    return _buildAlunoRow(alunoDoc.id, alunoData);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlunoRow(String alunoId, Map<String, dynamic> alunoData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(alunoData['nome'] ?? '-')),
          Expanded(child: Text(alunoData['ra'] ?? '-')),
          Expanded(child: Text(alunoData['turma'] ?? 'Sem turma')),
          SizedBox(
            width: 120,
            child: ElevatedButton.icon(
              onPressed: () => _abrirEditorNotas(alunoId, alunoData),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MenuConfig.corProfessor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlunoCardMobile(String alunoId, Map<String, dynamic> alunoData) {
    return Card(
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
            Text(
              alunoData['nome'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('RA: ',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(alunoData['ra'] ?? '-',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                const Text('Turma: ',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(alunoData['turma'] ?? 'Sem turma',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirEditorNotas(alunoId, alunoData),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar Notas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MenuConfig.corProfessor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirEditorNotas(String alunoId, Map<String, dynamic> alunoData) {
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

// CLASSE DO EDITOR DE NOTAS
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
      final notas = await widget.notasService.buscarNotasAluno(widget.alunoId);
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
      final bimData =
          notasMateria['bimestre_$i'] as Map<String, dynamic>? ?? {};
      controllers[i]!['prova']!.text = bimData['prova']?.toString() ?? '';
      controllers[i]!['trabalho']!.text = bimData['trabalho']?.toString() ?? '';
    }
  }

  Future<void> _salvarNotas() async {
    try {
      // Primeiro validar todos os valores
      for (int i = 1; i <= 4; i++) {
        final provaText = controllers[i]!['prova']!.text.trim();
        final trabalhoText = controllers[i]!['trabalho']!.text.trim();
        final prova = provaText.isNotEmpty ? double.tryParse(provaText) : null;
        final trabalho =
            trabalhoText.isNotEmpty ? double.tryParse(trabalhoText) : null;

        if (prova != null && (prova < 0 || prova > 10)) {
          _mostrarModalErro('Prova do ${i}º bimestre deve estar entre 0 e 10');
          return;
        }
        if (trabalho != null && (trabalho < 0 || trabalho > 10)) {
          _mostrarModalErro(
              'Trabalho do ${i}º bimestre deve estar entre 0 e 10');
          return;
        }
      }

      // Se passou nas validações, salva
      for (int i = 1; i <= 4; i++) {
        final provaText = controllers[i]!['prova']!.text.trim();
        final trabalhoText = controllers[i]!['trabalho']!.text.trim();
        final prova = provaText.isNotEmpty ? double.tryParse(provaText) : null;
        final trabalho =
            trabalhoText.isNotEmpty ? double.tryParse(trabalhoText) : null;

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
        _mostrarModalSucesso();
      }
    } catch (e) {
      if (mounted) {
        _mostrarModalErro('Erro ao salvar: $e');
      }
    }
  }

  void _mostrarModalErro(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Atenção!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarModalSucesso() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sucesso!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notas salvas com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o modal de sucesso
                    Navigator.pop(context); // Fecha o editor de notas
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MenuConfig.corProfessor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Editar Notas',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.alunoData['nome']} - ${widget.materiaSelecionada}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              if (_carregando)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      for (int i = 1; i <= 4; i++) ...[
                        Text(
                          '${i}º Bimestre',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controllers[i]!['prova'],
                                decoration: const InputDecoration(
                                  labelText: 'Prova (0-10)',
                                  border: OutlineInputBorder(),
                                  helperText: 'Digite apenas números de 0 a 10',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,2}\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: controllers[i]!['trabalho'],
                                decoration: const InputDecoration(
                                  labelText: 'Trabalho (0-10)',
                                  border: OutlineInputBorder(),
                                  helperText: 'Digite apenas números de 0 a 10',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,2}\.?\d{0,2}')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (i < 4) const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
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
                    ElevatedButton(
                      onPressed: _salvarNotas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MenuConfig.corProfessor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Salvar Notas'),
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
