import 'package:educ_poli/pages/aluno/boletim_aluno.dart';
import 'package:educ_poli/pages/aluno/materias_alunos.dart';
import 'package:educ_poli/pages/diretor/cadastrar_alunos.dart';
import 'package:educ_poli/pages/diretor/cadastrar_professores.dart';
import 'package:educ_poli/pages/diretor/gerenciar_alunos.dart';
import 'package:educ_poli/pages/diretor/gerenciar_professor.dart';
import 'package:educ_poli/pages/professor/mensagens_professor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/constants/cores.dart';
import 'pages/login.dart';
import 'pages/dashboard_aluno.dart';
import 'pages/dashboard_professor.dart';
import 'pages/dashboard_diretor.dart';
import 'pages/aluno/mensagem_aluno.dart';
import 'pages/aluno/notas_aluno.dart';
import 'pages/professor/materias_professor.dart';
import 'pages/professor/notas_professor.dart';
import 'services/auth_guard.dart';
import 'services/rota_observer.dart';
import 'services/materias_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Inicializa matérias no Firestore
  await MateriasService.inicializarMaterias();
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EducPoli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Cores.principal),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const TelaLogin(),
      navigatorObservers: [RotaObserver()],
      onGenerateRoute: (settings) {
        return _gerarRota(settings);
      },
      routes: {
        '/login': (context) => const TelaLogin(),
        '/dashboard-aluno': (context) => const DashboardAluno(),
        '/dashboard-professor': (context) => const DashboardProfessor(),
        '/dashboard-diretor': (context) => const DashboardDiretor(),

        // Rotas do Aluno (apenas visualização)
        '/aluno/materias': (context) => const MateriasAluno(),
        '/aluno/mensagem': (context) => const MensagemAluno(),
        '/aluno/notas': (context) => const NotasAluno(),
        '/aluno/boletim': (context) => const BoletimAluno(),

        // Rotas do Professor (com permissões de edição)
        '/professor/materias': (context) => const MateriasProfessor(),
        '/professor/mensagem': (context) => const MensagemProfessor(),
        '/professor/notas': (context) => const NotasProfessor(),

        // Rotas do Diretor
        '/diretor/alunos': (context) => const AlunosDiretor(),
        '/diretor/professores': (context) => const ProfessoresDiretor(),
        '/diretor/cadastrar-aluno': (context) => const CadastrarAluno(),
        '/diretor/cadastrar-professor': (context) => const CadastrarProfessor(),
      },
    );
  }

  /// Gera rotas com validação de permissão
  Route<dynamic>? _gerarRota(RouteSettings settings) {
    // Permite acesso livre ao login
    if (settings.name == '/login') {
      return MaterialPageRoute(
        builder: (context) => const TelaLogin(),
        settings: settings,
      );
    }

    // Para outras rotas, cria um proxy que valida permissão
    return MaterialPageRoute(
      builder: (context) => _RotaProtegida(
        routeName: settings.name ?? '',
      ),
      settings: settings,
    );
  }
}

/// Widget que valida permissão antes de navegar
class _RotaProtegida extends StatefulWidget {
  final String routeName;

  const _RotaProtegida({required this.routeName});

  @override
  State<_RotaProtegida> createState() => _RotaProtegidaState();
}

class _RotaProtegidaState extends State<_RotaProtegida> {
  @override
  void initState() {
    super.initState();
    _validarAcesso();
  }

  void _validarAcesso() async {
    // Aguarda um frame para garantir que o build foi concluído
    await Future.delayed(const Duration(milliseconds: 100));

    final temPermissao = await AuthGuard.temPermissao(widget.routeName);

    if (!mounted) return;

    if (!temPermissao) {
      // Se não tem permissão, redireciona para a rota padrão
      final rotaPadrao = await AuthGuard.obterRotaPadrao();
      if (mounted) {
        Navigator.pushReplacementNamed(context, rotaPadrao);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Validando acesso a ${widget.routeName}...'),
          ],
        ),
      ),
    );
  }
}
