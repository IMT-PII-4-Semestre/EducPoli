import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:educ_poli/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Autenticação - Integration Tests', () {
    testWidgets('Fluxo completo: Login → Dashboard → Logout', (tester) async {
      // Arrange - Iniciar app
      app.main();
      await tester.pumpAndSettle();

      // Act - Fazer login
      final emailField = find.byKey(const Key('campo_email'));
      final senhaField = find.byKey(const Key('campo_senha'));
      final botaoEntrar = find.text('Entrar');

      await tester.enterText(emailField, 'aluno@educpoli.com');
      await tester.enterText(senhaField, 'Senha123');
      await tester.tap(botaoEntrar);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Verificar dashboard
      expect(find.text('Área do Aluno'), findsOneWidget);

      // Act - Fazer logout
      final botaoLogout = find.byIcon(Icons.logout);
      await tester.tap(botaoLogout);
      await tester.pumpAndSettle();

      // Assert - Verificar volta para login
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Login com credenciais inválidas deve mostrar erro',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'invalido@email.com');
      await tester.enterText(
          find.byKey(const Key('campo_senha')), 'senha_errada');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert
      expect(find.text('Erro no login'), findsOneWidget);
    });

    testWidgets('Login como diferentes tipos de usuário', (tester) async {
      // Teste para Aluno
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('campo_email')), 'aluno@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Área do Aluno'), findsOneWidget);

      // Logout
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Teste para Professor
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'professor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Prof123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Área do Professor'), findsOneWidget);

      // Logout
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Teste para Diretor
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'diretor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Dir123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Área do Diretor'), findsOneWidget);
    });

    testWidgets('Persistência de sessão após fechar e reabrir app',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'aluno@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Simular fechamento e reabertura
      await tester.pumpWidget(Container());
      app.main();
      await tester.pumpAndSettle();

      // Deve continuar logado
      expect(find.text('Área do Aluno'), findsOneWidget);
    });
  });
}
