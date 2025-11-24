import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import '../../services/materias_service.dart';

class CadastrarProfessor extends StatefulWidget {
  const CadastrarProfessor({super.key});

  @override
  State<CadastrarProfessor> createState() => _CadastrarProfessorState();
}

class _CadastrarProfessorState extends State<CadastrarProfessor> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  Set<String> _materiasSelecionadas = {};
  Set<String> _turmasSelecionadas = {};

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
    return LayoutBase(
      titulo: 'Cadastrar Professor',
      corPrincipal: MenuConfig.corDiretor,
      itensMenu: MenuConfig.menuDiretor,
      itemSelecionadoId: 'professores',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Professores'),
        Breadcrumb(texto: 'Novo Professor', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32.0),
          child: _buildFormulario(),
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Cadastrar novo professor',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha os dados do professor',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

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
              if (v?.isEmpty ?? true) return 'Insira o CPF';
              if (!_validarCPF(v!)) return 'CPF inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Matérias
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
                            setState(() {
                              _materiasSelecionadas.remove(materia);
                            });
                          },
                          backgroundColor:
                              MenuConfig.corDiretor.withOpacity(0.1),
                          deleteIconColor: MenuConfig.corDiretor,
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
                  return Center(child: Text('Erro: ${snapshot.error}'));
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
                    final selecionado = _materiasSelecionadas.contains(materia);
                    return CheckboxListTile(
                      title: Text(materia),
                      value: selecionado,
                      onChanged: (valor) {
                        setState(() {
                          if (valor == true) {
                            _materiasSelecionadas.add(materia);
                          } else {
                            _materiasSelecionadas.remove(materia);
                          }
                        });
                      },
                      activeColor: MenuConfig.corDiretor,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Turmas
          const Text(
            'Turmas em que leciona *',
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
            child: _turmasSelecionadas.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Selecione pelo menos uma turma',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _turmasSelecionadas.map((turma) {
                        return Chip(
                          label: Text(turma),
                          onDeleted: () {
                            setState(() {
                              _turmasSelecionadas.remove(turma);
                            });
                          },
                          backgroundColor:
                              MenuConfig.corDiretor.withOpacity(0.1),
                          deleteIconColor: MenuConfig.corDiretor,
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('turmas')
                  .where('ativa', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final turmas = snapshot.data?.docs ?? [];

                if (turmas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma turma disponível'),
                  );
                }

                return ListView.builder(
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turmaData =
                        turmas[index].data() as Map<String, dynamic>;
                    final turmaNome = turmaData['nome'] ?? '';
                    final selecionado = _turmasSelecionadas.contains(turmaNome);
                    return CheckboxListTile(
                      title: Text(turmaNome),
                      value: selecionado,
                      onChanged: (valor) {
                        setState(() {
                          if (valor == true) {
                            _turmasSelecionadas.add(turmaNome);
                          } else {
                            _turmasSelecionadas.remove(turmaNome);
                          }
                        });
                      },
                      activeColor: MenuConfig.corDiretor,
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
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, '/diretor/professores'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: MenuConfig.corDiretor),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: MenuConfig.corDiretor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MenuConfig.corDiretor,
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

    if (_turmasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma turma'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'id': userCredential.user!.uid,
        'email': _emailController.text.trim(),
        'nome': _nomeController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'materias': _materiasSelecionadas.toList(),
        'turmas': _turmasSelecionadas.toList(),
        'tipo': 'professor',
        'ativo': true,
        'criadoEm': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Professor cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/diretor/professores');
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
