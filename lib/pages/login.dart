import 'package:flutter/material.dart';
import '../core/constants/cores.dart';
import '../widgets/botao_customizados.dart';
import '../widgets/campo_texto.dart';
import '../services/autenticacao.dart';
import '../models/usuarios.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _servicoAuth = ServicoAutenticacao();
  bool _ocultarSenha = true;
  bool _carregando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8860B), // Dourado
              Color(0xFFCD853F), // Sandy brown
              Color(0xFF8B4513), // Saddle brown
              Color(0xFF2F4F4F), // Dark slate gray
              Color(0xFF008B8B), // Dark cyan
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Detecta se é mobile (largura < 800px)
            final isMobile = constraints.maxWidth < 800;

            if (isMobile) {
              // Layout MOBILE - Tudo empilhado verticalmente
              return _buildMobileLayout();
            } else {
              // Layout WEB - Lado a lado
              return _buildWebLayout();
            }
          },
        ),
      ),
    );
  }

  // Layout para MOBILE
  Widget _buildMobileLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo compacta
              _buildLogo(size: 80),
              const SizedBox(height: 16),
              const Text(
                'EducPoli',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Card de login
              _buildLoginCard(maxWidth: double.infinity),
            ],
          ),
        ),
      ),
    );
  }

  // Layout para WEB
  Widget _buildWebLayout() {
    return Row(
      children: [
        // Lado esquerdo - Logo
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(size: 120),
                const SizedBox(height: 20),
                const Text(
                  'EducPoli',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lado direito - Formulário
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: _buildLoginCard(maxWidth: 400),
            ),
          ),
        ),
      ],
    );
  }

  // Widget do Logo (reutilizável)
  Widget _buildLogo({required double size}) {
    return Container(
      width: size * 1.5,
      height: size * 1.5,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          // Parte de trás do cubo
          Positioned(
            top: size * 0.125,
            left: size * 0.125,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Parte da frente do cubo
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.school,
                size: size * 0.5,
                color: const Color(0xFF8B4513),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card de Login (reutilizável)
  Widget _buildLoginCard({required double maxWidth}) {
    return Card(
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: maxWidth,
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 32),

              // Campo email/login
              CampoTexto(
                controller: _emailController,
                label: 'Login',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu login';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo senha
              CampoTexto(
                controller: _senhaController,
                label: 'Senha',
                obscureText: _ocultarSenha,
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _ocultarSenha = !_ocultarSenha;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Esqueceu senha
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: Color(0xFF3498DB), fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão login
              SizedBox(
                width: double.infinity,
                child: BotaoCustomizado(
                  texto: 'Entrar',
                  onPressed: _carregando ? null : _fazerLogin,
                  carregando: _carregando,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      try {
        final usuario = await _servicoAuth.fazerLogin(
          _emailController.text.trim(),
          _senhaController.text.trim(),
        );

        if (usuario != null && mounted) {
          // Navegar baseado no tipo de usuário
          switch (usuario.tipo) {
            case TipoUsuario.diretor:
              Navigator.pushReplacementNamed(context, '/dashboard-diretor');
              break;
            case TipoUsuario.professor:
              Navigator.pushReplacementNamed(context, '/dashboard-professor');
              break;
            case TipoUsuario.aluno:
              Navigator.pushReplacementNamed(context, '/dashboard-aluno');
              break;
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro no login: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
