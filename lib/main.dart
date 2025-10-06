import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/constants/cores.dart';
import 'pages/login.dart';
import 'pages/dashboard_aluno.dart';
import 'pages/dashboard_professor.dart';
import 'pages/dashboard_diretor.dart';

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
      },
    );
  }
}
