import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educ_poli/pages/login.dart';
import '../setup_firebase_mocks.dart';

void main() {
  // Inicializar Firebase Mock antes de TODOS os testes
  setUpAll(() async {
    await setupFirebaseCoreMocks();
  });

  group('Tela de Login - Widget Tests', () {
    testWidgets('Deve renderizar todos os elementos da tela',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EducPoli'), findsOneWidget);
      expect(find.text('Login'), findsAtLeastNWidgets(1));
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueceu a senha?'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('Deve validar campos obrigatórios',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // Tentar fazer login sem preencher nada
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira seu login'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('Deve preencher campos de login e senha',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      final loginField = find.widgetWithText(TextFormField, 'Login');
      final senhaField = find.widgetWithText(TextFormField, 'Senha');

      expect(loginField, findsOneWidget);
      expect(senhaField, findsOneWidget);

      await tester.enterText(loginField, 'teste@email.com');
      await tester.enterText(senhaField, '123456');

      expect(find.text('teste@email.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('Deve alternar visibilidade da senha',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar se o ícone de visibilidade existe
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Clicar no ícone
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Verificar se mudou para visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Clicar novamente
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Verificar se voltou para visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Deve exibir link "Esqueceu a senha?"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Esqueceu a senha?'), findsOneWidget);
    });

    testWidgets('Deve ter gradiente de fundo', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      final containers = find.descendant(
        of: scaffold,
        matching: find.byType(Container),
      );

      expect(containers, findsWidgets);

      // Verificar se pelo menos um container tem decoração
      bool hasDecoration = false;
      for (final container in tester.widgetList<Container>(containers)) {
        if (container.decoration != null) {
          hasDecoration = true;
          break;
        }
      }
      expect(hasDecoration, true);
    });

    testWidgets('Deve ter logo da escola', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.school), findsOneWidget);
    });
  });

  group('Tela de Login - Validações de Campo', () {
    testWidgets('Deve validar campo de login vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // Preencher apenas senha
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira seu login'), findsOneWidget);
    });

    testWidgets('Deve validar campo de senha vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // Preencher apenas login
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'usuario@email.com',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('Deve aceitar entrada de texto nos campos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      final loginField = find.widgetWithText(TextFormField, 'Login');
      final senhaField = find.widgetWithText(TextFormField, 'Senha');

      await tester.enterText(loginField, 'teste@example.com');
      await tester.enterText(senhaField, 'senha123');

      expect(find.text('teste@example.com'), findsOneWidget);
      expect(find.text('senha123'), findsOneWidget);
    });
  });

  group('Tela de Login - Responsividade', () {
    testWidgets('Deve ter layout mobile em tela pequena',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar se a tela foi renderizada
      expect(find.byType(TelaLogin), findsOneWidget);
      expect(find.text('EducPoli'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Deve ter layout desktop em tela grande',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar se a tela foi renderizada
      expect(find.byType(TelaLogin), findsOneWidget);
      expect(find.text('EducPoli'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });

  group('Tela de Login - Interações', () {
    testWidgets('Botão Entrar deve estar visível e clicável',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      final botaoEntrar = find.text('Entrar');
      expect(botaoEntrar, findsOneWidget);

      // Verificar se o botão é interativo
      await tester.tap(botaoEntrar);
      await tester.pump();
    });

    testWidgets('Link "Esqueceu a senha?" deve estar clicável',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TelaLogin(),
        ),
      );
      await tester.pumpAndSettle();

      final link = find.text('Esqueceu a senha?');
      expect(link, findsOneWidget);

      await tester.tap(link);
      await tester.pump();
    });
  });
}
