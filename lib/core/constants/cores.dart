import 'package:flutter/material.dart';

class Cores {
  static const Color principal = Color(0xFF7DD3FC);
  static const Color secundaria = Color(0xFF10B981);
  static const Color laranja = Color(0xFFF59E0B);
  static const Color fundo = Color(0xFFF9FAFB);
  static const Color superficie = Colors.white;
  static const Color erro = Color(0xFFEF4444);
  static const Color textoPrincipal = Color(0xFF111827);
  static const Color textoSecundario = Color(0xFF6B7280);
  
  // Gradientes das telas
  static const LinearGradient gradientePrincipal = LinearGradient(
    colors: [Color(0xFF7DD3FC), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradienteLaranja = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}