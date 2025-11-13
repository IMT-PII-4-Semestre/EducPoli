import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/turma_service.dart';
import '../../models/turma.dart';

// DESIGN 
const double _kAppBarHeight = 80.0;
const Color _primaryRed = Color(0xFFE74C3C);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class CadastrarAluno extends StatefulWidget {
  const CadastrarAluno({super.key});

  @override
  State<CadastrarAluno> createState() => _CadastrarAlunoState();
}

class _CadastrarAlunoState extends State<CadastrarAluno> {
  
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _raController = TextEditingController();
  final _senhaController = TextEditingController();
  final TurmaService _turmaService = TurmaService();
  String _turmaSelecionada = 'Selecione';
  bool _carregando = false;

  // MENU LATERAL 
  final String _selectedNavItemId = 'alunos'; 
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Alunos', 'icon': Icons.person, 'id': 'alunos'},
    {'title': 'Professores', 'icon': Icons.person_3, 'id': 'professores'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: _bgWhite,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: _primaryRed,
        elevation: 0,
        toolbarHeight: _kAppBarHeight,
        centerTitle: true,
        title: const Text(
          'Cadastrar Novo Aluno',
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

          // CONTEÚDO DO FORMULÁRIO 
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => v?.isEmpty ?? true ? 'Insira o nome' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (v) => v?.isEmpty ?? true ? 'Insira o email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _raController,
                          decoration: const InputDecoration(
                            labelText: 'RA',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (v) => v?.isEmpty ?? true ? 'Insira o RA' : null,
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Turma>>(
                          stream: _turmaService.buscarTurmasAtivas(),
                          builder: (context, snapshot) {
                            List<String> turmas = ['Selecione'];
                            if (snapshot.hasData) {
                              turmas.addAll(snapshot.data!.map((t) => t.nome));
                            }
                            return DropdownButtonFormField<String>(
                              value: _turmaSelecionada,
                              decoration: const InputDecoration(
                                labelText: 'Turma',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.class_),
                              ),
                              items: turmas
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _turmaSelecionada = v ?? 'Selecione'),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _senhaController,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _cadastrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryRed, // Cor Vermelha
                            ),
                            child: _carregando
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Cadastrar',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FUNÇÃO DE CADASTRO 
  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
            'id': _raController.text.trim(),
            'email': _emailController.text.trim(),
            'nome': _nomeController.text.trim(),
            'ra': _raController.text.trim(),
            'tipo': 'aluno',
            'turma': _turmaSelecionada == 'Selecione'
                ? null
                : _turmaSelecionada,
            'ativo': true,
            'criadoEm': DateTime.now().toIso8601String(),
            'materias': [],
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno cadastrado!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // --- BARRA LATERAL DINÂMICA (DIRETOR) ---
  Widget _buildSidebarContent() {
    final user = FirebaseAuth.instance.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        // HEADER VERMELHO COM DADOS DO FIREBASE
        Container(
          width: double.infinity,
          color: const Color(0xFFE74C3C), // Vermelho do Diretor
          padding: const EdgeInsets.only(top: 10, bottom: 25, left: 24, right: 16),
          child: FutureBuilder<DocumentSnapshot>(
            future: user != null 
                ? FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get() 
                : null,
            builder: (context, snapshot) {
              String nomeExibicao = "Carregando...";
              String cargoExibicao = "Diretor";

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nomeExibicao = data['nome'] ?? "Diretor";
                } else {
                   nomeExibicao = "Diretor";
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ÍCONE DO DIRETOR (PADRÃO DASHBOARD)
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
                    // O ÍCONE PADRÃO DO DASHBOARD DO DIRETOR
                    child: const Icon(Icons.admin_panel_settings, size: 32, color: Colors.white), 
                  ),
                  const SizedBox(height: 12),
                  
                  // NOME DINÂMICO
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
                       if (item['id'] == 'alunos') {
                         if (_selectedNavItemId == 'alunos' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'alunos') Navigator.pushNamed(context, '/diretor/alunos');
                       } else if (item['id'] == 'professores') {
                         if (_selectedNavItemId == 'professores' && !isDesktop) Navigator.pop(context);
                         else if (_selectedNavItemId != 'professores') Navigator.pushNamed(context, '/diretor/professores');
                       }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF5F5) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? const Color(0xFFE74C3C) : Colors.black87,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? const Color(0xFFE74C3C) : Colors.black87,
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

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _raController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}