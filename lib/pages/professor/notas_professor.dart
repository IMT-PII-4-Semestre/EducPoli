import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notas_service.dart';
import '../../services/turma_service.dart';
import '../../models/turma.dart';

// DESIGN PROFESSOR 
const double _kAppBarHeight = 80.0;
const Color _primaryOrange = Color(0xFFFF9500);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

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

  // MENU LATERAL
  final String _selectedNavItemId = 'notas'; 
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Matérias', 'icon': Icons.book, 'id': 'materias'},
    {'title': 'Mensagem', 'icon': Icons.message, 'id': 'mensagem'},
    {'title': 'Notas', 'icon': Icons.assignment, 'id': 'notas'},
  ];

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
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (_carregandoMaterias) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Caso o professor não tenha matérias
    if (_materiasDisponiveis.isEmpty) {
      return Scaffold(
        backgroundColor: _bgWhite,
        appBar: AppBar(
          backgroundColor: _primaryOrange,
          toolbarHeight: _kAppBarHeight,
          title: const Text('Gerenciar Notas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: isDesktop ? null : _buildMobileDrawer(),
        body: Row(
          children: [
            if (isDesktop) SizedBox(width: 280, child: _buildSidebarContent()),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 64, color: Colors.orange[300]),
                    const SizedBox(height: 16),
                    const Text('Nenhuma matéria vinculada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Contacte o diretor para ser vinculado a uma matéria', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: _primaryOrange,
        elevation: 0,
        toolbarHeight: _kAppBarHeight,
        centerTitle: true,
        title: const Text(
          'Gerenciar Notas',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Inter',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      drawer: isDesktop ? null : _buildMobileDrawer(),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BARRA LATERAL
          if (isDesktop) 
            SizedBox(width: 280, child: _buildSidebarContent()),

          // CONTEÚDO PRINCIPAL
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SELETOR DE MATÉRIA E FILTROS
                  _buildFiltrosSuperiores(),
                  const SizedBox(height: 24),
                  
                  // TABELA DE ALUNOS
                  Expanded(
                    child: _buildTabelaAlunos(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETS DA BARRA LATERAL
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    // Verificação de desktop para a lógica de fechar o drawer ou navegar
    final isDesktop = MediaQuery.of(context).size.width > 800; 

    return Column(
      children: [
        // HEADER COM DADOS E ÍCONE PADRONIZADO
        Container(
          width: double.infinity,
          color: _primaryOrange,
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Professor"; 

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Professor";
                } else {
                   nomeExibicao = "Professor";
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ÁREA DA FOTO (COM ÍCONE DE FORMATURA PADRONIZADO)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school, size: 32, color: Colors.white), 
                  ),
                  const SizedBox(height: 12),
                  
                  // NOME COM SOMBRA
                  Text(
                    nomeExibicao,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // CARGO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cargoExibicao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // LISTA DE ITENS
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = item['id'] == _selectedNavItemId;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Lógica de navegação
                      if (item['id'] == 'materias') {
                         if (_selectedNavItemId == 'materias' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'materias') Navigator.pushNamed(context, '/professor/materias');
                      } else if (item['id'] == 'mensagem') {
                         if (_selectedNavItemId == 'mensagem' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'mensagem') Navigator.pushNamed(context, '/professor/mensagem');
                      } else if (item['id'] == 'notas') {
                         if (_selectedNavItemId == 'notas' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'notas') Navigator.pushNamed(context, '/professor/notas');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF3E0) : _menuItemBg,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: _primaryOrange.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? _primaryOrange : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _primaryOrange : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer() => Drawer(child: _buildSidebarContent());

  Widget _buildFiltrosSuperiores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seletor de Matéria
        const Text(
          'Selecione a matéria:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
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
              items: _materiasDisponiveis.map((materia) => DropdownMenuItem(
                value: materia,
                child: Text(materia),
              )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _materiaSelecionada = value);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Filtros de Busca e Turma
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _buscaController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou RA',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => setState(() => _termoBusca = value.toLowerCase()),
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
                    turmas.addAll(snapshot.data!.map((t) => t.nome));
                  }
                  return DropdownButtonFormField<String>(
                    value: _turmaFiltro,
                    decoration: InputDecoration(
                      labelText: 'Turma',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: turmas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
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
        if (snapshot.hasError) return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var alunos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nome = (data['nome'] ?? '').toString().toLowerCase();
          final ra = (data['ra'] ?? '').toString().toLowerCase();
          final turma = data['turma'] ?? '';

          if (_termoBusca.isNotEmpty && !nome.contains(_termoBusca) && !ra.contains(_termoBusca)) return false;
          if (_turmaFiltro != 'Selecione' && turma != _turmaFiltro) return false;

          return true;
        }).toList();

        if (alunos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Nenhum aluno encontrado', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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
              // Header da Tabela
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.grey[50],
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('RA', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Turma', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Ação', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: alunos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final alunoDoc = alunos[index];
                    final alunoData = alunoDoc.data() as Map<String, dynamic>;
                    final alunoId = alunoDoc.id;

                    return InkWell(
                      onTap: () => _abrirEditorNotas(alunoId, alunoData),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(alunoData['nome'] ?? '-')),
                            Expanded(child: Text(alunoData['ra'] ?? '-', style: TextStyle(color: Colors.grey[600]))),
                            Expanded(child: Text(alunoData['turma'] ?? '-', style: TextStyle(color: Colors.grey[600]))),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: OutlinedButton.icon(
                                  onPressed: () => _abrirEditorNotas(alunoId, alunoData),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Editar', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar notas: $e')));
      }
    }
  }

  void _preencherControllers(Map<String, dynamic> notas) {
    final notasMateria = notas[widget.materiaSelecionada] as Map<String, dynamic>? ?? {};
    for (int i = 1; i <= 4; i++) {
      final bimData = notasMateria['bim$i'] as Map<String, dynamic>? ?? {};
      controllers[i]!['prova']!.text = bimData['prova']?.toString() ?? '';
      controllers[i]!['trabalho']!.text = bimData['trabalho']?.toString() ?? '';
    }
  }

  Future<void> _salvarNotas() async {
    try {
      for (int i = 1; i <= 4; i++) {
        final provaText = controllers[i]!['prova']!.text.trim();
        final trabalhoText = controllers[i]!['trabalho']!.text.trim();
        final prova = provaText.isNotEmpty ? double.tryParse(provaText) : null;
        final trabalho = trabalhoText.isNotEmpty ? double.tryParse(trabalhoText) : null;

        if (prova != null && (prova < 0 || prova > 10)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prova do ${i}º bimestre deve estar entre 0 e 10')));
          return;
        }
        if (trabalho != null && (trabalho < 0 || trabalho > 10)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trabalho do ${i}º bimestre deve estar entre 0 e 10')));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notas salvas com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Editar Notas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(widget.alunoData['nome'] ?? '-', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              if (_carregando)
                const Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())
              else
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFE8F4F8), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFB3D9E8))),
                        child: Row(children: [const Icon(Icons.book, color: Color(0xFF3498DB), size: 16), const SizedBox(width: 8), Text('Matéria: ${widget.materiaSelecionada}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3498DB)))]),
                      ),
                      const SizedBox(height: 24),
                      Table(
                        border: TableBorder.all(color: Colors.grey[200]!),
                        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2)},
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[100]),
                            children: [
                              Padding(padding: const EdgeInsets.all(12), child: Text('Bimestre', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[700]))),
                              Padding(padding: const EdgeInsets.all(12), child: Text('Prova (0-10)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[700]))),
                              Padding(padding: const EdgeInsets.all(12), child: Text('Trabalho (0-10)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[700]))),
                            ],
                          ),
                          for (int i = 1; i <= 4; i++)
                            TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(12), child: Text('${i}º Bimestre', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                Padding(padding: const EdgeInsets.all(8), child: TextField(controller: controllers[i]!['prova'], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)))),
                                Padding(padding: const EdgeInsets.all(8), child: TextField(controller: controllers[i]!['trabalho'], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)))),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue[100]!)),
                        child: Row(children: [Icon(Icons.info, size: 16, color: Colors.blue[700]), const SizedBox(width: 8), Expanded(child: Text('Digite valores entre 0 e 10. A média será calculada automaticamente.', style: TextStyle(fontSize: 12, color: Colors.blue[700])))]),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(onPressed: _carregando ? null : _salvarNotas, icon: const Icon(Icons.save, size: 16), label: const Text('Salvar Notas'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3498DB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
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