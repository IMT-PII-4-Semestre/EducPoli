import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';
import '../../services/turma_service.dart';
import '../../models/turma.dart';

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

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Cadastrar Aluno',
      corPrincipal: MenuConfig.corDiretor,
      itensMenu: MenuConfig.menuDiretor,
      itemSelecionadoId: 'alunos',
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Alunos'),
        Breadcrumb(texto: 'Novo Aluno', isAtivo: true),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Cadastrar novo aluno',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados do aluno',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Nome
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

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Insira o email' : null,
                ),
                const SizedBox(height: 16),

                // RA
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

                // Turma
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
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _turmaSelecionada = v ?? 'Selecione'),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 32),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, '/diretor/alunos'),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

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
        'id': _raController.text.trim(),
        'email': _emailController.text.trim(),
        'nome': _nomeController.text.trim(),
        'ra': _raController.text.trim(),
        'tipo': 'aluno',
        'turma': _turmaSelecionada == 'Selecione' ? null : _turmaSelecionada,
        'ativo': true,
        'criadoEm': DateTime.now().toIso8601String(),
        'materias': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/diretor/alunos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
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
    _raController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
