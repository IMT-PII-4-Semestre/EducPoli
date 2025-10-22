import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  // Esperar por loading spinner desaparecer
  static Future<void> esperarCarregamento(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Esperar até que o CircularProgressIndicator suma
    while (tester.any(find.byType(CircularProgressIndicator))) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // Fazer login helper
  static Future<void> fazerLogin(
    WidgetTester tester,
    String email,
    String senha,
  ) async {
    await tester.enterText(find.byKey(const Key('campo_email')), email);
    await tester.enterText(find.byKey(const Key('campo_senha')), senha);
    await tester.tap(find.text('Entrar'));
    await esperarCarregamento(tester);
  }

  // Fazer logout helper
  static Future<void> fazerLogout(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
  }

  // Scroll até encontrar widget
  static Future<void> scrollAteEncontrar(
    WidgetTester tester,
    Finder scrollable,
    Finder item,
  ) async {
    int attempts = 0;
    while (attempts < 10) {
      if (tester.any(item)) {
        break;
      }
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
      attempts++;
    }
  }

  // Verificar se está na rota
  static bool estaEmRota(WidgetTester tester, String rota) {
    final context = tester.element(find.byType(MaterialApp));
    final route = ModalRoute.of(context);
    return route?.settings.name == rota;
  }

  // Preencher formulário de cadastro de aluno
  static Future<void> preencherFormularioAluno(
    WidgetTester tester, {
    required String nome,
    required String cpf,
    required String email,
    required String senha,
    required String turma,
  }) async {
    await tester.enterText(find.byKey(const Key('campo_nome')), nome);
    await tester.enterText(find.byKey(const Key('campo_cpf')), cpf);
    await tester.enterText(find.byKey(const Key('campo_email')), email);
    await tester.enterText(find.byKey(const Key('campo_senha')), senha);
    await tester.enterText(find.byKey(const Key('campo_turma')), turma);
  }

  // Limpar campos de texto
  static Future<void> limparCampo(WidgetTester tester, Key key) async {
    await tester.enterText(find.byKey(key), '');
    await tester.pump();
  }

  // Verificar se snackbar apareceu
  static bool snackbarApareceu(WidgetTester tester, String mensagem) {
    return tester.any(find.text(mensagem)) && tester.any(find.byType(SnackBar));
  }

  // Fechar snackbar
  static Future<void> fecharSnackbar(WidgetTester tester) async {
    await tester.tap(find.byType(SnackBarAction).first);
    await tester.pumpAndSettle();
  }

  // Abrir menu hambúrguer (mobile)
  static Future<void> abrirMenuMobile(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
  }

  // Selecionar item de dropdown
  static Future<void> selecionarDropdown(
    WidgetTester tester,
    Key dropdownKey,
    String valor,
  ) async {
    await tester.tap(find.byKey(dropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text(valor).last);
    await tester.pumpAndSettle();
  }

  // Verificar se dialog está aberto
  static bool dialogAberto(WidgetTester tester) {
    return tester.any(find.byType(AlertDialog)) ||
        tester.any(find.byType(Dialog));
  }

  // Fechar dialog
  static Future<void> fecharDialog(WidgetTester tester) async {
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
  }

  // Confirmar dialog
  static Future<void> confirmarDialog(WidgetTester tester) async {
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
  }

  // Capturar screenshot (útil para evidências)
  static Future<void> capturarScreenshot(
    WidgetTester tester,
    String nomeArquivo,
  ) async {
    await tester.pumpAndSettle();
    // Implementar captura de screenshot se necessário
  }

  // Simular delay de rede
  static Future<void> simularDelayRede() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  // Verificar se elemento está visível na tela
  static bool elementoVisivel(WidgetTester tester, Finder finder) {
    try {
      final element = tester.firstRenderObject(finder);
      return element.attached && element.paintBounds.size > Size.zero;
    } catch (e) {
      return false;
    }
  }

  // Dar tap múltiplo (para casos de duplo clique)
  static Future<void> tapMultiplo(
    WidgetTester tester,
    Finder finder,
    int vezes,
  ) async {
    for (int i = 0; i < vezes; i++) {
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // Verificar se campo está habilitado
  static bool campoHabilitado(WidgetTester tester, Key key) {
    final TextField field = tester.widget(find.byKey(key));
    return field.enabled ?? true;
  }

  // Verificar cor de fundo de um widget
  static Color? corDeFundo(WidgetTester tester, Finder finder) {
    final Container container = tester.widget(finder);
    return container.color;
  }

  // Contar quantidade de widgets
  static int contarWidgets(WidgetTester tester, Type tipo) {
    return tester.widgetList(find.byType(tipo)).length;
  }
}
