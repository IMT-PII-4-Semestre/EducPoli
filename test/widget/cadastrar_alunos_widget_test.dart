import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educ_poli/pages/diretor/cadastrar_alunos.dart';

void main() {
  group('Cadastrar Alunos - Widget Tests', () {
    testWidgets('Deve exibir formulário de cadastro', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Assert
      expect(find.text('Cadastrar Aluno'), findsOneWidget);
      expect(find.byKey(const Key('campo_nome')), findsOneWidget);
      expect(find.byKey(const Key('campo_cpf')), findsOneWidget);
      expect(find.byKey(const Key('campo_email')), findsOneWidget);
      expect(find.byKey(const Key('campo_senha')), findsOneWidget);
      expect(find.byKey(const Key('campo_turma')), findsOneWidget);
    });

    testWidgets('Deve ter botão Cadastrar', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Assert
      expect(find.text('Cadastrar'), findsOneWidget);
    });

    testWidgets('Deve ter botão Cancelar', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Assert
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('Deve validar campos obrigatórios', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Act - Tentar cadastrar sem preencher
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      // Assert
      expect(find.text('Nome é obrigatório'), findsOneWidget);
      expect(find.text('CPF é obrigatório'), findsOneWidget);
      expect(find.text('Email é obrigatório'), findsOneWidget);
      expect(find.text('Senha é obrigatória'), findsOneWidget);
      expect(find.text('Turma é obrigatória'), findsOneWidget);
    });

    testWidgets('Deve permitir preenchimento de todos os campos',
        (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Act
      await tester.enterText(find.byKey(const Key('campo_nome')), 'João Silva');
      await tester.enterText(
          find.byKey(const Key('campo_cpf')), '123.456.789-00');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'joao@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'senha123');
      await tester.enterText(find.byKey(const Key('campo_turma')), 'A1');
      await tester.pump();

      // Assert
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('123.456.789-00'), findsOneWidget);
      expect(find.text('joao@email.com'), findsOneWidget);
      expect(find.text('A1'), findsOneWidget);
    });

    testWidgets('Deve formatar CPF automaticamente', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Act
      await tester.enterText(find.byKey(const Key('campo_cpf')), '12345678900');
      await tester.pump();

      // Assert - CPF formatado
      final TextField cpfField =
          tester.widget(find.byKey(const Key('campo_cpf')));
      expect(cpfField.controller?.text, '123.456.789-00');
    });

    testWidgets('Deve mostrar indicador de carregamento ao cadastrar',
        (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Act - Preencher e cadastrar
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'Maria Santos');
      await tester.enterText(
          find.byKey(const Key('campo_cpf')), '987.654.321-00');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'maria@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'senha123');
      await tester.enterText(find.byKey(const Key('campo_turma')), 'B2');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Deve voltar ao clicar em Cancelar', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: const CadastrarAluno(),
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
                builder: (context) =>
                    const Scaffold(body: Text('Tela Anterior')));
          }
          return null;
        },
      ));

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tela Anterior'), findsOneWidget);
    });
  });

  group('Cadastrar Alunos - Responsividade', () {
    testWidgets('Mobile: Campos devem ocupar largura total', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Cleanup
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
