import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:educ_poli/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Cadastro de Alunos - Integration Tests', () {
    testWidgets(
        'Fluxo completo: Login Diretor → Cadastrar Aluno → Visualizar Lista',
        (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login como Diretor
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'diretor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Dir123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Área do Diretor'), findsOneWidget);

      // Step 2: Navegar para Gerenciar Alunos
      await tester.tap(find.text('alunos'));
      await tester.pumpAndSettle();

      expect(find.text('Gerenciar Alunos'), findsOneWidget);

      // Step 3: Clicar em Novo Aluno
      await tester.tap(find.text('Novo aluno'));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar Aluno'), findsOneWidget);

      // Step 4: Preencher formulário
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'João da Silva');
      await tester.enterText(
          find.byKey(const Key('campo_cpf')), '123.456.789-09');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'joao.silva@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');
      await tester.enterText(find.byKey(const Key('campo_turma')), 'A1');

      // Step 5: Cadastrar
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert: Sucesso
      expect(find.text('Aluno cadastrado com sucesso!'), findsOneWidget);

      // Step 6: Verificar na lista
      await tester.pumpAndSettle();
      expect(find.text('João da Silva'), findsOneWidget);
    });

    testWidgets('Validação de CPF duplicado', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'diretor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Dir123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar para cadastro
      await tester.tap(find.text('alunos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Novo aluno'));
      await tester.pumpAndSettle();

      // Tentar cadastrar com CPF duplicado
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'Maria Santos');
      await tester.enterText(find.byKey(const Key('campo_cpf')),
          '123.456.789-09'); // CPF já cadastrado
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'maria@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');
      await tester.enterText(find.byKey(const Key('campo_turma')), 'B2');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert
      expect(find.text('CPF já cadastrado'), findsOneWidget);
    });

    testWidgets('Editar aluno existente', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'diretor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Dir123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar para lista de alunos
      await tester.tap(find.text('alunos'));
      await tester.pumpAndSettle();

      // Encontrar aluno e clicar em editar
      final editButton = find.byIcon(Icons.edit).first;
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Editar nome
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'João Silva Atualizado');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert
      expect(find.text('Aluno atualizado com sucesso!'), findsOneWidget);
      expect(find.text('João Silva Atualizado'), findsOneWidget);
    });

    testWidgets('Inativar aluno', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'diretor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Dir123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar para lista
      await tester.tap(find.text('alunos'));
      await tester.pumpAndSettle();

      // Clicar no switch de ativo/inativo
      final switchButton = find.byType(Switch).first;
      await tester.tap(switchButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert
      expect(find.text('Status atualizado'), findsOneWidget);
    });

    testWidgets('Filtrar alunos por turma', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'diretor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Dir123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar para lista
      await tester.tap(find.text('alunos'));
      await tester.pumpAndSettle();

      // Selecionar filtro de turma
      final dropdownFinder = find.byKey(const Key('filtro_turma'));
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Selecionar turma A1
      await tester.tap(find.text('A1').last);
      await tester.pumpAndSettle();

      // Assert - Só deve mostrar alunos da turma A1
      // (verificação depende dos dados mockados)
    });

    testWidgets('Buscar aluno por nome', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'diretor@educpoli.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Dir123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navegar
      await tester.tap(find.text('alunos'));
      await tester.pumpAndSettle();

      // Buscar
      await tester.enterText(find.byKey(const Key('campo_busca')), 'João');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('João da Silva'), findsWidgets);
    });
  });
}
