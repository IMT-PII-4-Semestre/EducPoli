import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:educ_poli/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Gerenciamento de Notas - Integration Tests', () {
    testWidgets('Fluxo completo: Login Professor → Lançar Nota → Visualizar',
        (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login como Professor
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'professor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Prof123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Área do Professor'), findsOneWidget);

      // Step 2: Navegar para Notas
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();

      expect(find.text('Gerenciar Notas'), findsOneWidget);

      // Step 3: Selecionar turma
      await tester.tap(find.byKey(const Key('dropdown_turma')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A1').last);
      await tester.pumpAndSettle();

      // Step 4: Selecionar disciplina
      await tester.tap(find.byKey(const Key('dropdown_disciplina')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Matemática').last);
      await tester.pumpAndSettle();

      // Step 5: Selecionar aluno
      await tester.tap(find.text('Maria Santos').first);
      await tester.pumpAndSettle();

      // Step 6: Lançar nota
      await tester.enterText(find.byKey(const Key('campo_nota')), '8.5');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert
      expect(find.text('Nota lançada com sucesso'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);
    });

    testWidgets('Editar nota existente', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'professor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Prof123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();

      // Selecionar turma e disciplina
      await tester.tap(find.byKey(const Key('dropdown_turma')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A1').last);
      await tester.pumpAndSettle();

      // Clicar em nota existente
      final notaFinder = find.text('8.5').first;
      await tester.tap(notaFinder);
      await tester.pumpAndSettle();

      // Editar
      await tester.enterText(find.byKey(const Key('campo_nota')), '9.0');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert
      expect(find.text('Nota atualizada'), findsOneWidget);
      expect(find.text('9.0'), findsOneWidget);
    });

    testWidgets('Tentar lançar nota inválida (maior que 10)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login e navegação
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'professor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Prof123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();

      // Tentar lançar nota 15.0
      await tester.enterText(find.byKey(const Key('campo_nota')), '15.0');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nota deve estar entre 0 e 10'), findsOneWidget);
    });

    testWidgets('Visualizar média da turma', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'professor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Prof123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();

      // Selecionar turma
      await tester.tap(find.byKey(const Key('dropdown_turma')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A1').last);
      await tester.pumpAndSettle();

      // Assert - Deve mostrar média
      expect(find.textContaining('Média da turma:'), findsOneWidget);
    });

    testWidgets('Excluir nota lançada', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'professor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Prof123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();

      // Clicar no botão de excluir
      final deleteButton = find.byIcon(Icons.delete).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Confirmar exclusão
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert
      expect(find.text('Nota excluída com sucesso'), findsOneWidget);
    });
  });
}
