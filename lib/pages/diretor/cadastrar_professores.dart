import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastrarProfessor extends StatefulWidget {
  const CadastrarProfessor({super.key});

  @override
  State<CadastrarProfessor> createState() => _CadastrarProfessorState();
}

class _CadastrarProfessorState extends State<CadastrarProfessor> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _raController = TextEditingController();
  final _senhaController = TextEditingController();
  final _materiasController = TextEditingController();
  bool _carregando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Novo Professor'),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _raController,
                decoration: const InputDecoration(
                  labelText: 'RA (Registro Acadêmico)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o RA';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _materiasController,
                decoration: const InputDecoration(
                  labelText: 'Matérias (separadas por vírgula)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                  hintText: 'Ex: Matemática, Física, Química',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha Inicial',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrarProfessor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                  ),
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Cadastrar Professor',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cadastrarProfessor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      try {
        // Processar matérias
        List<String> materias = [];
        if (_materiasController.text.isNotEmpty) {
          materias = _materiasController.text
              .split(',')
              .map((materia) => materia.trim())
              .where((materia) => materia.isNotEmpty)
              .toList();
        }

        // Criar usuário no Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text.trim(),
            );

        // Criar documento no Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
              'id': _raController.text.trim(),
              'email': _emailController.text.trim(),
              'nome': _nomeController.text.trim(),
              'ra': _raController.text.trim(),
              'tipo': 'professor',
              'criadoEm': DateTime.now().toIso8601String(),
              'materias': materias,
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _carregando = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _raController.dispose();
    _senhaController.dispose();
    _materiasController.dispose();
    super.dispose();
  }
}
