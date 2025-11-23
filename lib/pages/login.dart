import 'package:flutter/material.dart';
import '../widgets/campo_texto.dart';
import '../services/autenticacao.dart';
import '../models/usuarios.dart';
import 'dart:math' as math; // <-- adicionado

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
        decoration: BoxDecoration(
          gradient: SweepGradient(
            colors: const [
              Color(0xCCFAA41F), // Amarelo/Ouro
              Color(0xCCFF2828), // Borgonha/Magenta
              Color(0xCC1FB4C3), // Ciano/Verde Água
              Color(0xCCFAA41F), // volta ao amarelo para fechar o círculo
            ],
            startAngle: 0.0,
            endAngle: 2 * math.pi,
            center: const Alignment(-0.05, -0.05),
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
              _buildLogo(size: 60),
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(size: 80),
            const SizedBox(height: 48),
            _buildLoginCard(maxWidth: 400),
          ],
        ),
      ),
    );
  }

  // Widget do Logo (reutilizável)
  Widget _buildLogo({required double size}) {
    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sombra traseira (parte de trás do cubo 3D)
          Positioned(
            top: size * 0.3,
            left: size * 0.3,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-0.3)
                ..rotateY(0.3),
              alignment: Alignment.center,
              child: Container(
                width: size * 1.5,
                height: size * 1.5,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(size * 0.15),
                ),
              ),
            ),
          ),
          // Cubo principal
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-0.2)
              ..rotateY(0.2),
            alignment: Alignment.center,
            child: Container(
              width: size * 1.5,
              height: size * 1.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size * 0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(8, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.school_rounded,
                  size: size * 0.9,
                  color: const Color(0xCCFF2828),
                ),
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
      color: Colors.transparent,
      child: Container(
        width: maxWidth,
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
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
                  color: Color.fromARGB(204, 0, 0, 0),
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
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
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
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
                    backgroundColor: const Color(0xFFFF2828),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFFF2828).withOpacity(0.6),
                    elevation: 4,
                    shadowColor: const Color(0xFFFF2828).withOpacity(0.5),
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
