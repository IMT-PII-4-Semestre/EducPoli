import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'boletim_aluno.dart'; 

// DESIGN 
const double _kAppBarHeight = 80.0; 
const Color _primaryBlue = Color(0xFF7DD3FC);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class NotasAluno extends StatefulWidget {
  const NotasAluno({super.key});

  @override
  State<NotasAluno> createState() => _NotasAlunoState();
}

class _NotasAlunoState extends State<NotasAluno> {
  Map<String, dynamic>? _dadosAluno;
  bool _carregando = true;

  final String _selectedNavItemId = 'notes'; 

  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Matérias', 'icon': Icons.book, 'id': 'subjects'},
    {'title': 'Mensagem', 'icon': Icons.chat_bubble_outline, 'id': 'messages'},
    {'title': 'Notas', 'icon': Icons.assignment_outlined, 'id': 'notes'}, 
  ];


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
    final isDesktop = MediaQuery.of(context).size.width > 700;

    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        toolbarHeight: _kAppBarHeight,
        centerTitle: true,
        title: const Text(
          'Notas',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Inter',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [], 
      ),
      
      // DRAWER
      drawer: isDesktop ? null : _buildMobileDrawer(),

      // CORPO
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BARRA LATERAL
          if (isDesktop) 
            SizedBox(
              width: 280, 
              child: _buildSidebarContent(),
            ),

          // CONTEÚDO CENTRALIZADO
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(32.0), 
              child: const BoletimAlunoDesignNeutro(),
            ),
          ),
        ],
      ),
    );
  }

  // BARRA LATERAL DINÂMICA DO ALUNO (CONECTADA)
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 700; 

    return Column(
      children: [
        // HEADER AZUL COM DADOS DO FIREBASE
        Container(
          width: double.infinity,
          color: _primaryBlue, // Azul do Aluno
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            // Busca os dados do usuário logado
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Aluno"; 

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Aluno";
                } else {
                   nomeExibicao = "Aluno";
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FOTO / ÍCONE (COM SOMBRA)
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
                    // Ícone de Pessoa (Padrão do Dashboard do Aluno)
                    child: const Icon(Icons.person, size: 32, color: Colors.white), 
                  ),
                  const SizedBox(height: 12),
                  
                  // NOME DO ALUNO (DINÂMICO)
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
                  
                  // CARGO (TAG)
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

        // LISTA DE ITENS DO MENU
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
                      // Lógica de Navegação do Aluno
                      if (item['id'] == 'subjects') {
                         if (_selectedNavItemId == 'subjects' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'subjects') Navigator.pushNamed(context, '/aluno/materias');
                      } else if (item['id'] == 'messages') {
                         if (_selectedNavItemId == 'messages' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'messages') Navigator.pushNamed(context, '/aluno/mensagem');
                      } else if (item['id'] == 'notes') {
                         if (_selectedNavItemId == 'notes' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'notes') Navigator.pushNamed(context, '/aluno/notas');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        // Se selecionado: fundo azul bem clarinho e borda azul
                        color: isSelected ? const Color(0xFFE1F0FF) : _menuItemBg,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: _primaryBlue.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? _primaryBlue : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _primaryBlue : Colors.black87,
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

  Widget _buildMobileDrawer() {
    return Drawer(
      child: _buildSidebarContent(),
    );
  }
}

// BOLETIM 
class BoletimAlunoDesignNeutro extends StatelessWidget {
  const BoletimAlunoDesignNeutro({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('notas').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        Map<String, dynamic> notas = {};
        if (snapshot.data!.exists) {
          notas = snapshot.data!.data() as Map<String, dynamic>;
        }

        if (notas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 20),
                Text('Nenhuma nota lançada ainda', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...notas.entries.map((entry) {
                if (entry.key.contains('media_') || entry.key == 'situacao') {
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
        );
      },
    );
  }

  Widget _buildTabelaMateriaBoletim(String materia, Map<String, dynamic> dados, bool isMobile) {
    final mediaFinal = dados['media_final'] ?? 0.0;
    final situacao = dados['situacao'] ?? 'Pendente';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER - NOME DA MATÉRIA EM NEGRITO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  materia, // APENAS A MATÉRIA EM NEGRITO
                  style: const TextStyle(
                    color: Colors.black87, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCorNota(mediaFinal).withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getCorNota(mediaFinal).withOpacity(0.3)),
                  ),
                  child: Text(
                    mediaFinal.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // A média final no badge em negrito para destaque
                      color: _getCorNota(mediaFinal), 
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isMobile)
            _buildTabelaMobileBoletim(dados)
          else
            _buildTabelaDesktopBoletim(dados),

          // FOOTER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50], 
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Situação Final:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCorSituacao(situacao),
                    borderRadius: BorderRadius.circular(20),
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
        padding: const EdgeInsets.all(20),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[100]!),
            verticalInside: BorderSide.none,
          ),
          columnWidths: const {
            0: FixedColumnWidth(120), 
            1: FixedColumnWidth(80),
            2: FixedColumnWidth(80),
            3: FixedColumnWidth(90), 
            4: FixedColumnWidth(80),
            5: FixedColumnWidth(80),
            6: FixedColumnWidth(90),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[50]),
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

  TableRow _buildLinhaBoletim(String label, Map<String, dynamic> bimData) {
    final prova = bimData['prova'];
    final trabalho = bimData['trabalho'];
    final media = bimData['media'];

    return TableRow(
      children: [
        _buildCelula(label), // 1º Bimestre: Normal
        _buildCelula(prova?.toStringAsFixed(1) ?? '-'), // Prova: Normal
        _buildCelula(trabalho?.toStringAsFixed(1) ?? '-'), // Trabalho: Normal
        _buildCelulaMedia(media?.toStringAsFixed(1) ?? '-', media), // Média: Sombreada, sem negrito
        _buildCelula(prova?.toStringAsFixed(1) ?? '-'), // Prova: Normal
        _buildCelula(trabalho?.toStringAsFixed(1) ?? '-'), // Trabalho: Normal
        _buildCelulaMedia(media?.toStringAsFixed(1) ?? '-', media), // Média: Sombreada, sem negrito
      ],
    );
  }

  Widget _buildCelulaHeader(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
      ),
    );
  }

  Widget _buildCelula(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.normal, 
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  // CÉLULA DA MÉDIA
  Widget _buildCelulaMedia(String texto, dynamic valorNumerico) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100], 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.normal, 
          fontSize: 13,
          color: _getCorNota(valorNumerico), 
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
            _buildCardBimestre(i, dados['bim$i'] as Map<String, dynamic>? ?? {}),
        ],
      ),
    );
  }

  Widget _buildCardBimestre(int numero, Map<String, dynamic> bimData) {
    final prova = bimData['prova'];
    final trabalho = bimData['trabalho'];
    final media = bimData['media'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${numero}º Bimestre', style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13)), // NORMAL
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                   color: Colors.grey[200], // Sombreado no mobile
                   borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  media?.toStringAsFixed(1) ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.normal, // NORMAL NO MOBILE
                    color: _getCorNota(media),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItemBimestre('Prova', prova?.toStringAsFixed(1) ?? '-'),
              _buildItemBimestre('Trabalho', trabalho?.toStringAsFixed(1) ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemBimestre(String label, String valor) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13)), // NORMAL
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

  Color _getCorSituacao(String situacao) {
    if (situacao == 'Aprovado') return Colors.green;
    if (situacao == 'Recuperação') return Colors.orange;
    if (situacao == 'Reprovado') return Colors.red;
    return Colors.grey;
  }
}
