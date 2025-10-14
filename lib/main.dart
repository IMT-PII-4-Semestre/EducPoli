import 'package:educ_poli/pages/aluno/materias_alunos.dart';
import 'package:educ_poli/pages/diretor/cadastrar_alunos.dart';
import 'package:educ_poli/pages/diretor/cadastrar_professores.dart';
import 'package:educ_poli/pages/diretor/gerenciar_alunos.dart';
import 'package:educ_poli/pages/diretor/gerenciar_professor.dart';
import 'package:educ_poli/pages/professor/adicionar_alunos.dart';
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
import 'pages/aluno/arquivos_aluno.dart';
import 'pages/aluno/mensagem_aluno.dart';
import 'pages/aluno/notas_aluno.dart';
import 'pages/professor/materias_professor.dart';
import 'pages/professor/notas_professor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      routes: {
        '/login': (context) => const TelaLogin(),
        '/dashboard-aluno': (context) => const DashboardAluno(),
        '/dashboard-professor': (context) => const DashboardProfessor(),
        '/dashboard-diretor': (context) => const DashboardDiretor(),

        // Rotas do Aluno (apenas visualização)
        '/aluno/arquivos': (context) => const ArquivosAluno(),
        '/aluno/materias': (context) => const MateriasAluno(),
        '/aluno/mensagem': (context) => const MensagemAluno(),
        '/aluno/notas': (context) => const NotasAluno(),

        // Rotas do Professor (com permissões de edição)
        '/professor/adicionar': (context) => const AdicionarProfessor(),
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
}
