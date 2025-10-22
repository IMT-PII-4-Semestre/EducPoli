import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educ_poli/pages/dashboard_diretor.dart';

void main() {
  group('Dashboard Diretor - Widget Tests', () {
    testWidgets('Deve exibir título "Área do Diretor"', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      expect(find.text('Área do Diretor'), findsOneWidget);
    });

    testWidgets('Deve exibir opção "alunos"', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      expect(find.text('alunos'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Deve exibir opção "professores"', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      expect(find.text('professores'), findsOneWidget);
      expect(find.byIcon(Icons.person_3), findsOneWidget);
    });

    testWidgets('Deve ter botão de logout', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('Deve ter cor vermelha no header', (tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      final Container header = tester.widget(find.byType(Container).first);
      expect(header.color, const Color(0xFFE74C3C));
    });

    testWidgets('Mobile: Deve ter menu hambúrguer', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      expect(find.byType(Drawer), findsOneWidget);

      // Cleanup
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Desktop: Deve ter menu lateral fixo', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      expect(find.byType(Row), findsWidgets);

      // Cleanup
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Deve navegar para gerenciar alunos ao clicar', (tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: const DashboardDiretor(),
        routes: {
          '/diretor/alunos': (context) =>
              const Scaffold(body: Text('Gerenciar Alunos')),
        },
      ));

      // Act
      await tester.tap(find.text('alunos'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Gerenciar Alunos'), findsOneWidget);
    });

    testWidgets('Deve exibir cards em grid no mobile', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(const MaterialApp(home: DashboardDiretor()));

      // Assert
      expect(find.byType(GridView), findsOneWidget);

      // Cleanup
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
