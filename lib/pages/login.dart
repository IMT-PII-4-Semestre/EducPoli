import 'package:flutter/material.dart';
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
              Color(0xFF1E90FF), // Azul mais vibrante
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
      width: size * 1.8,
      height: size * 1.8,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cubo 3D com efeito de profundidade
          Positioned(
            top: size * 0.15,
            left: size * 0.15,
            child: Container(
              width: size * 1.3,
              height: size * 1.3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Parte central do cubo
          Positioned(
            top: size * 0.075,
            left: size * 0.075,
            child: Container(
              width: size * 1.3,
              height: size * 1.3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Parte frontal do cubo
          Container(
            width: size * 1.3,
            height: size * 1.3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.school,
                size: size * 0.7,
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
      elevation: 24,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: maxWidth,
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.85),
            ],
          ),
        ),
        padding: const EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),

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
              const SizedBox(height: 20),

              // Campo senha
              CampoTexto(
                controller: _senhaController,
                label: 'Senha',
                obscureText: _ocultarSenha,
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarSenha ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF666666),
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
              const SizedBox(height: 12),

              // Esqueceu senha
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _mostrarDialogRecuperarSenha,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: Color(0xFF1E90FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botão login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFE91E63).withOpacity(0.6),
                    elevation: 4,
                    shadowColor: const Color(0xFFE91E63).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
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
          _mostrarDialogMensagem(
            titulo: 'Erro no Login',
            mensagem:
                'Email ou senha incorretos. Por favor, verifique seus dados e tente novamente.',
            icone: Icons.error_outline,
            cor: Colors.red,
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

  void _mostrarDialogMensagem({
    required String titulo,
    required String mensagem,
    required IconData icone,
    required Color cor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icone,
                size: 64,
                color: cor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              mensagem,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: cor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogRecuperarSenha() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: const Color(0xFF1E90FF)),
            const SizedBox(width: 12),
            const Text('Recuperar Senha'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digite seu email para receber o link de recuperação de senha:',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();

              if (email.isEmpty) {
                Navigator.pop(context);
                _mostrarDialogMensagem(
                  titulo: 'Atenção',
                  mensagem:
                      'Por favor, insira seu email para recuperar a senha.',
                  icone: Icons.warning_amber_rounded,
                  cor: Colors.orange,
                );
                return;
              }

              try {
                await _servicoAuth.enviarEmailRecuperacaoSenha(email);

                if (context.mounted) {
                  Navigator.pop(context);
                  _mostrarDialogMensagem(
                    titulo: 'Email Enviado!',
                    mensagem:
                        'Um link de recuperação foi enviado para $email. Verifique sua caixa de entrada e spam.',
                    icone: Icons.check_circle_outline,
                    cor: Colors.green,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _mostrarDialogMensagem(
                    titulo: 'Erro',
                    mensagem:
                        'Não foi possível enviar o email. Verifique se o endereço está correto e tente novamente.',
                    icone: Icons.error_outline,
                    cor: Colors.red,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
            ),
            child: const Text('Enviar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
