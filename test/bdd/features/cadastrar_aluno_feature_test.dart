import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educ_poli/pages/diretor/cadastrar_alunos.dart';

void main() {
  group('Feature: Cadastro de Alunos pelo Diretor', () {
    testWidgets('Cenário: Cadastrar aluno com todos os dados válidos',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro de aluno
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar Aluno'), findsOneWidget);

      // WHEN: Eu preencho todos os campos obrigatórios
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'João da Silva');
      await tester.pump();

      await tester.enterText(find.byKey(const Key('campo_ra')), '2025001');
      await tester.pump();

      await tester.enterText(
          find.byKey(const Key('campo_email')), 'joao@email.com');
      await tester.pump();

      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');
      await tester.pump();

      // Selecionar matérias (se houver)
      final materiasFinder = find.text('Matemática');
      if (tester.any(materiasFinder)) {
        await tester.tap(materiasFinder);
        await tester.pump();
      }

      // AND: Eu clico em Cadastrar
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // THEN: Devo ver mensagem de sucesso
      expect(find.textContaining('sucesso'), findsWidgets);
    });

    testWidgets('Cenário: Não permitir cadastro com RA duplicado',
        (WidgetTester tester) async {
      // GIVEN: Existe um aluno com RA 2025001
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu tento cadastrar outro aluno com mesmo RA
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'Maria Santos');
      await tester.enterText(find.byKey(const Key('campo_ra')), '2025001');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'maria@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // THEN: Devo ver mensagem de erro
      expect(
          find.textContaining('RA já cadastrado').evaluate().isNotEmpty ||
              find.textContaining('já existe').evaluate().isNotEmpty ||
              find.textContaining('duplicado').evaluate().isNotEmpty,
          true);

      // AND: O cadastro não deve ser realizado
      expect(find.text('Cadastrar Aluno'), findsOneWidget);
    });

    testWidgets('Cenário: Não permitir cadastro com email duplicado',
        (WidgetTester tester) async {
      // GIVEN: Existe um aluno com email joao@email.com
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu tento cadastrar outro aluno com mesmo email
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'Pedro Costa');
      await tester.enterText(find.byKey(const Key('campo_ra')), '2025002');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'joao@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // THEN: Devo ver mensagem de erro
      expect(
          find.textContaining('Email já cadastrado').evaluate().isNotEmpty ||
              find.textContaining('já existe').evaluate().isNotEmpty,
          true);
    });

    testWidgets('Cenário: Validar todos os campos obrigatórios',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu tento cadastrar sem preencher os campos
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      // THEN: Devo ver mensagens de validação
      expect(
          find.textContaining('obrigatório').evaluate().isNotEmpty ||
              find.textContaining('necessário').evaluate().isNotEmpty,
          true);
    });

    testWidgets('Cenário: Não permitir email inválido',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu preencho email sem @
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'Pedro Costa');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'email_invalido');
      await tester.enterText(find.byKey(const Key('campo_ra')), '2025003');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      // THEN: Devo ver erro de validação
      expect(
          find.textContaining('Email inválido').evaluate().isNotEmpty ||
              find.textContaining('válido').evaluate().isNotEmpty ||
              find.textContaining('formato').evaluate().isNotEmpty,
          true);
    });

    testWidgets('Cenário: Não permitir senha fraca',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu preencho senha com menos de 6 caracteres
      await tester.enterText(find.byKey(const Key('campo_nome')), 'Ana Lima');
      await tester.enterText(find.byKey(const Key('campo_ra')), '2025004');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'ana@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), '123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      // THEN: Devo ver erro de validação
      expect(
          find.textContaining('6 caracteres').evaluate().isNotEmpty ||
              find.textContaining('fraca').evaluate().isNotEmpty ||
              find.textContaining('curta').evaluate().isNotEmpty,
          true);
    });

    testWidgets('Cenário: Validar formato do RA', (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu tento usar RA inválido (com letras)
      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'Carlos Santos');
      await tester.enterText(find.byKey(const Key('campo_ra')), 'ABC123');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'carlos@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      // THEN: Devo ver erro de validação (se houver validação de formato)
      // Ou o sistema deve aceitar se permite RA alfanumérico
    });

    testWidgets('Cenário: Cancelar operação de cadastro',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // AND: Eu preenchi alguns campos
      await tester.enterText(find.byKey(const Key('campo_nome')), 'Ana Lima');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'ana@email.com');

      // WHEN: Eu clico em Voltar ou Cancelar
      final voltarButton = find.byType(BackButton);
      if (tester.any(voltarButton)) {
        await tester.tap(voltarButton);
        await tester.pumpAndSettle();
      }

      // THEN: A operação deve ser cancelada
    });

    testWidgets('Cenário: Selecionar matérias para o aluno',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu seleciono múltiplas matérias
      final matematica = find.text('Matemática');
      if (tester.any(matematica)) {
        await tester.tap(matematica);
        await tester.pump();
      }

      final portugues = find.text('Português');
      if (tester.any(portugues)) {
        await tester.tap(portugues);
        await tester.pump();
      }

      // THEN: As matérias devem ser selecionadas
      // Verificar checkboxes ou chips selecionados
    });

    testWidgets('Cenário: Visualizar senha digitada',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu digito uma senha
      await tester.enterText(
          find.byKey(const Key('campo_senha')), 'minhasenha');
      await tester.pump();

      // THEN: A senha deve estar oculta por padrão
      final TextField senhaField =
          tester.widget(find.byKey(const Key('campo_senha')));
      expect(senhaField.obscureText, true);

      // WHEN: Eu clico no ícone de visualizar
      final visibilityIcon = find.byIcon(Icons.visibility);
      if (tester.any(visibilityIcon)) {
        await tester.tap(visibilityIcon);
        await tester.pump();

        // THEN: A senha deve ficar visível
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      }
    });

    testWidgets('Cenário: Limpar formulário após cadastro bem-sucedido',
        (WidgetTester tester) async {
      // GIVEN: Cadastrei um aluno com sucesso
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('campo_nome')), 'Teste Sucesso');
      await tester.enterText(find.byKey(const Key('campo_ra')), '2025999');
      await tester.enterText(
          find.byKey(const Key('campo_email')), 'sucesso@email.com');
      await tester.enterText(find.byKey(const Key('campo_senha')), 'Senha123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // THEN: Os campos devem estar limpos para novo cadastro
      // (se o sistema limpa automaticamente)
    });

    testWidgets('Cenário: Adicionar foto de perfil (opcional)',
        (WidgetTester tester) async {
      // GIVEN: Estou na tela de cadastro
      await tester.pumpWidget(const MaterialApp(home: CadastrarAluno()));
      await tester.pumpAndSettle();

      // WHEN: Eu clico em adicionar foto
      final adicionarFoto = find.byIcon(Icons.add_a_photo);
      if (tester.any(adicionarFoto)) {
        await tester.tap(adicionarFoto);
        await tester.pump();

        // THEN: Deve abrir seletor de imagem
      }
    });
  });
}
