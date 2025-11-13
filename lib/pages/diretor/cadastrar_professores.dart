import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/materias_service.dart';

// DESIGN DIRETOR 
const double _kAppBarHeight = 80.0;
const Color _primaryRed = Color(0xFFE74C3C);
const Color _bgWhite = Colors.white;
const Color _menuItemBg = Color(0xFFF5F7FA);

class CadastrarProfessor extends StatefulWidget {
  const CadastrarProfessor({super.key});

  @override
  State<CadastrarProfessor> createState() => _CadastrarProfessorState();
}

class _CadastrarProfessorState extends State<CadastrarProfessor> {
  // LÓGICA ORIGINAL 
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  // Multi-select de matérias
  Set<String> _materiasSelecionadas = {};

  // MENU LATERAL 
  final String _selectedNavItemId = 'professores'; 
  final List<Map<String, dynamic>> _navItems = [
    {'title': 'Alunos', 'icon': Icons.person, 'id': 'alunos'},
    {'title': 'Professores', 'icon': Icons.person_3, 'id': 'professores'},
  ];

  // Validador de CPF 
  bool _validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = soma % 11;
    int dv1 = resto < 2 ? 0 : 11 - resto;
    if (int.parse(cpf[9]) != dv1) return false;
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    int dv2 = resto < 2 ? 0 : 11 - resto;
    if (int.parse(cpf[10]) != dv2) return false;
    return true;
  }

  // Formatar CPF 
  String _formatarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    if (cpf.length <= 9) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    }
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

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
          'Cadastrar Novo Professor',
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
                  child: _buildFormularioOriginal(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORMULÁRIO ORIGINAL 
  Widget _buildFormularioOriginal() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cadastrar novo professor',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Preencha os campos abaixo',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Nome
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: 'Nome Completo',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Insira o nome' : null,
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Insira o email';
              if (!v!.contains('@')) return 'Email inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // CPF
          TextFormField(
            controller: _cpfController,
            decoration: InputDecoration(
              labelText: 'CPF',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.badge),
              hintText: '000.000.000-00',
              helperText: 'Digite apenas números',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                final formatted = _formatarCPF(value);
                _cpfController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: formatted.length),
                  ),
                );
              }
            },
            validator: (v) {
              if (v?.isEmpty ?? true) {
                return 'Insira o CPF';
              }
              if (!_validarCPF(v!)) {
                return 'CPF inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Matérias (Multi-select)
          const Text(
            'Matérias que leciona *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: _materiasSelecionadas.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Selecione pelo menos uma matéria',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _materiasSelecionadas.map((materia) {
                        return Chip(
                          label: Text(materia),
                          onDeleted: () {
                            setState(
                              () => _materiasSelecionadas.remove(materia),
                            );
                          },
                          backgroundColor:
                              const Color(0xFFE74C3C).withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: Color(0xFFE74C3C),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: FutureBuilder<List<String>>(
              future: MateriasService.obterMateriasDisponiveis(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'Erro ao carregar matérias: ${snapshot.error}'),
                  );
                }

                final materias = snapshot.data ?? [];

                if (materias.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma matéria disponível'),
                  );
                }

                return ListView.builder(
                  itemCount: materias.length,
                  itemBuilder: (context, index) {
                    final materia = materias[index];
                    final selecionada =
                        _materiasSelecionadas.contains(materia);

                    return CheckboxListTile(
                      value: selecionada,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _materiasSelecionadas.add(materia);
                          } else {
                            _materiasSelecionadas.remove(materia);
                          }
                        });
                      },
                      title: Text(materia),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Senha
          TextFormField(
            controller: _senhaController,
            decoration: InputDecoration(
              labelText: 'Senha',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Insira a senha';
              if (v!.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Botões
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE74C3C)),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFFE74C3C)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 // BARRA LATERAL DINÂMICA 
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

  // LÓGICA DE CADASTRO 
  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_materiasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma matéria'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      // Criar usuário no Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // Salvar dados no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'id': userCredential.user!.uid,
        'email': _emailController.text.trim(),
        'nome': _nomeController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'materias': _materiasSelecionadas.toList(),
        'tipo': 'professor',
        'ativo': true,
        'criadoEm': DateTime.now().toIso8601String(),
        'turmas': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Professor cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao cadastrar';

      if (e.code == 'email-already-in-use') {
        mensagem = 'Este email já está cadastrado';
      } else if (e.code == 'weak-password') {
        mensagem = 'Senha muito fraca';
      } else if (e.code == 'invalid-email') {
        mensagem = 'Email inválido';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
        );
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

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}