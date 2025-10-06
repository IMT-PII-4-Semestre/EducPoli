// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educ_poli/main.dart';

void main() {
  testWidgets('Teste de tela de login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MeuApp());

    // Verificar se a tela de login carrega
    expect(find.text('Login'), findsOneWidget);

    // Verificar se os campos estão presentes
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Senha'), findsOneWidget);
  });
}
