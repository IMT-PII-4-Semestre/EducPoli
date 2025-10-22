import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:educ_poli/pages/professor/notas_professor.dart';

void main() {
  group('Gerenciamento de Notas pelo Professor', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('Deve lançar nota válida para um aluno',
        (WidgetTester tester) async {
      // ARRANGE: Criar dados de teste
      await fakeFirestore.collection('usuarios').add({
        'nome': 'Maria Santos',
        'tipo': 'aluno',
        'turma': 'A1',
      });

      // ACT: Renderizar tela
      await tester.pumpWidget(
        MaterialApp(
          home: NotasProfessor(),
        ),
      );

      // Selecionar turma
      await tester.tap(find.text('A1'));
      await tester.pumpAndSettle();

      // Selecionar disciplina
      await tester.tap(find.text('Matemática'));
      await tester.pumpAndSettle();

      // Selecionar aluno
      await tester.tap(find.text('Maria Santos'));
      await tester.pumpAndSettle();

      // Preencher nota
      await tester.enterText(find.byKey(Key('campo_nota')), '8.5');
      await tester.pumpAndSettle();

      // Salvar
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Nota lançada com sucesso'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);
    });

    testWidgets('Deve editar nota existente', (WidgetTester tester) async {
      // ARRANGE
      await fakeFirestore.collection('notas').add({
        'aluno': 'João Silva',
        'disciplina': 'Matemática',
        'valor': 7.0,
      });

      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      // ACT: Clicar na nota existente
      await tester.tap(find.text('7.0'));
      await tester.pumpAndSettle();

      // Alterar valor
      await tester.enterText(find.byKey(Key('campo_nota')), '8.0');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Nota atualizada'), findsOneWidget);
      expect(find.text('8.0'), findsOneWidget);
    });

    testWidgets('Não deve permitir nota maior que 10',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      // ACT
      await tester.enterText(find.byKey(Key('campo_nota')), '15.0');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Nota deve estar entre 0 e 10'), findsOneWidget);
    });

    testWidgets('Não deve permitir nota negativa', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.enterText(find.byKey(Key('campo_nota')), '-2.0');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Nota deve estar entre 0 e 10'), findsOneWidget);
    });

    testWidgets('Deve aceitar notas com casas decimais',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.enterText(find.byKey(Key('campo_nota')), '8.75');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('8.75'), findsOneWidget);
    });

    testWidgets('Deve aceitar nota zero como válida',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.enterText(find.byKey(Key('campo_nota')), '0.0');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Nota lançada com sucesso'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('Deve aceitar nota máxima (10.0)', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.enterText(find.byKey(Key('campo_nota')), '10.0');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Nota lançada com sucesso'), findsOneWidget);
      expect(find.text('10.0'), findsOneWidget);
    });

    testWidgets('Deve validar seleção de aluno obrigatória',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.tap(find.text('B2')); // Turma
      await tester.tap(find.text('Física')); // Disciplina
      await tester.enterText(find.byKey(Key('campo_nota')), '7.5');
      await tester.tap(find.text('Salvar')); // SEM selecionar aluno
      await tester.pumpAndSettle();

      expect(find.text('Por favor, selecione um aluno'), findsOneWidget);
    });

    testWidgets('Deve validar seleção de disciplina obrigatória',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.tap(find.text('C1')); // Turma
      await tester.tap(find.text('Lucas Pereira')); // Aluno
      await tester.enterText(find.byKey(Key('campo_nota')), '8.0');
      await tester.tap(find.text('Salvar')); // SEM disciplina
      await tester.pumpAndSettle();

      expect(find.text('Por favor, selecione uma disciplina'), findsOneWidget);
    });

    testWidgets('Deve validar preenchimento de nota obrigatório',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.tap(find.text('A1'));
      await tester.tap(find.text('Matemática'));
      await tester.tap(find.text('João Silva'));
      await tester.tap(find.text('Salvar')); // SEM nota
      await tester.pumpAndSettle();

      expect(find.text('Por favor, informe a nota'), findsOneWidget);
    });

    testWidgets('Deve excluir nota existente', (WidgetTester tester) async {
      await fakeFirestore.collection('notas').add({
        'aluno': 'Roberto Lima',
        'disciplina': 'História',
        'valor': 6.5,
      });

      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Nota excluída com sucesso'), findsOneWidget);
      expect(find.text('6.5'), findsNothing);
    });

    testWidgets('Deve cancelar exclusão de nota', (WidgetTester tester) async {
      await fakeFirestore.collection('notas').add({
        'aluno': 'Carla Souza',
        'disciplina': 'Português',
        'valor': 9.0,
      });

      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('9.0'), findsOneWidget);
    });

    testWidgets('Deve filtrar notas por disciplina',
        (WidgetTester tester) async {
      await fakeFirestore.collection('notas').add({
        'disciplina': 'Matemática',
        'valor': 8.0,
      });
      await fakeFirestore.collection('notas').add({
        'disciplina': 'História',
        'valor': 7.0,
      });

      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.tap(find.text('Matemática'));
      await tester.pumpAndSettle();

      expect(find.text('8.0'), findsOneWidget);
      expect(find.text('7.0'), findsNothing);
    });

    testWidgets('Deve calcular média da turma', (WidgetTester tester) async {
      await fakeFirestore.collection('notas').add(
        {'turma': 'A1', 'disciplina': 'Matemática', 'valor': 8.0},
      );
      await fakeFirestore.collection('notas').add(
        {'turma': 'A1', 'disciplina': 'Matemática', 'valor': 7.0},
      );
      await fakeFirestore.collection('notas').add(
        {'turma': 'A1', 'disciplina': 'Matemática', 'valor': 9.0},
      );

      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.tap(find.text('A1'));
      await tester.pumpAndSettle();

      expect(find.text('Média: 8.0'), findsOneWidget);
    });

    testWidgets('Deve arredondar nota com múltiplas casas decimais',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.enterText(find.byKey(Key('campo_nota')), '8.333333');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('8.33'), findsOneWidget);
    });

    testWidgets('Deve buscar aluno por nome', (WidgetTester tester) async {
      await fakeFirestore.collection('usuarios').add(
        {'nome': 'Maria Silva', 'tipo': 'aluno'},
      );
      await fakeFirestore.collection('usuarios').add(
        {'nome': 'João Costa', 'tipo': 'aluno'},
      );
      await fakeFirestore.collection('usuarios').add(
        {'nome': 'Maria Santos', 'tipo': 'aluno'},
      );

      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      await tester.enterText(find.byKey(Key('busca')), 'Maria');
      await tester.pumpAndSettle();

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('João Costa'), findsNothing);
    });

    testWidgets('Professor só deve ver suas próprias disciplinas',
        (WidgetTester tester) async {
      await fakeFirestore.collection('usuarios').add({
        'tipo': 'professor',
        'disciplinas': ['Matemática'],
      });

      await tester.pumpWidget(MaterialApp(home: NotasProfessor()));

      expect(find.text('Matemática'), findsOneWidget);
      expect(find.text('História'), findsNothing);
      expect(find.text('Química'), findsNothing);
    });
  });
}
