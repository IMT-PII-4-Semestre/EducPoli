import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educ_poli/pages/login.dart';

void main() {
  group('Feature: Login de Usuários', () {
    testWidgets('Cenário: Login bem-sucedido como Aluno',
        (WidgetTester tester) async {
      // GIVEN: O aplicativo está aberto na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);

      // AND: Estou na tela de login
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      // WHEN: Eu preencho as credenciais do aluno
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'aluno@educpoli.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha123',
      );

      // AND: Eu clico em Entrar
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // THEN: Devo ser redirecionado para o dashboard do aluno
      // (Aqui você pode verificar a navegação ou mensagens)
    });

    testWidgets('Cenário: Login bem-sucedido como Professor',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu faço login como professor
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'professor@educpoli.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Prof123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // THEN: Devo ver o dashboard do professor
    });

    testWidgets('Cenário: Login bem-sucedido como Diretor',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu faço login como diretor
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'diretor@educpoli.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Dir123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // THEN: Devo ver o dashboard do diretor
    });

    testWidgets('Cenário: Login com credenciais inválidas',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu preencho credenciais inválidas
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'invalido@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha_errada',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // THEN: Devo ver mensagem de erro
      expect(
        find.textContaining('Erro').evaluate().isNotEmpty ||
            find.textContaining('inválid').evaluate().isNotEmpty ||
            find.textContaining('incorret').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Cenário: Tentativa de login com campos vazios',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu clico em Entrar sem preencher os campos
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // THEN: Devo ver mensagens de validação
      expect(find.text('Por favor, insira seu login'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('Cenário: Validar campo de login obrigatório',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu deixo o login vazio e preencho apenas a senha
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // THEN: Devo ver erro no campo de login
      expect(find.text('Por favor, insira seu login'), findsOneWidget);
    });

    testWidgets('Cenário: Validar campo de senha obrigatório',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu preencho apenas o login
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'usuario@email.com',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // THEN: Devo ver erro no campo de senha
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('Cenário: Alternar visibilidade da senha',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu preencho a senha
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'minhasenha',
      );

      // THEN: A senha deve estar oculta por padrão
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // WHEN: Eu clico no ícone de visualizar
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // THEN: A senha deve ficar visível
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // WHEN: Eu clico novamente
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // THEN: A senha volta a ficar oculta
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Cenário: Verificar link "Esqueceu a senha?"',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: Devo ver o link de recuperação de senha
      expect(find.text('Esqueceu a senha?'), findsOneWidget);

      // WHEN: Eu clico no link
      await tester.tap(find.text('Esqueceu a senha?'));
      await tester.pump();

      // THEN: Algo deve acontecer (atualmente não faz nada no código)
    });

    testWidgets('Cenário: Verificar elementos visuais da tela',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: Devo ver todos os elementos principais
      expect(find.text('EducPoli'), findsOneWidget);
      expect(find.text('Login'), findsAtLeastNWidgets(1)); // Título + label
      expect(find.byIcon(Icons.school), findsOneWidget); // Logo
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueceu a senha?'), findsOneWidget);
    });

    testWidgets('Cenário: Verificar gradiente de fundo',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: O container deve ter gradiente
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Scaffold),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets(
        'Cenário: Botão Entrar deve estar desabilitado durante carregamento',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de login
      await tester.pumpWidget(
        MaterialApp(
          home: const TelaLogin(),
          routes: {
            '/dashboard-aluno': (context) =>
                const Scaffold(body: Text('Dashboard Aluno')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: Eu preencho credenciais válidas
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'teste@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha123',
      );

      // AND: Eu clico em Entrar
      await tester.tap(find.text('Entrar'));
      await tester.pump(); // Apenas um pump para iniciar o loading

      // THEN: O botão deve mostrar indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Cenário: Layout responsivo - Mobile',
        (WidgetTester tester) async {
      // GIVEN: Tela com largura de celular (< 800px)
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: Deve usar layout mobile (Column)
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsNothing);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Cenário: Layout responsivo - Web',
        (WidgetTester tester) async {
      // GIVEN: Tela com largura de desktop (>= 800px)
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: Deve usar layout web (Row)
      expect(find.byType(Row), findsWidgets);

      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });
}
