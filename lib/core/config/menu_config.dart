import 'package:flutter/material.dart';
import '../../widgets/menu_lateral.dart';

/// Configuração centralizada dos menus por tipo de usuário
class MenuConfig {
  /// Cor principal do Aluno
  static const Color corAluno = Color.fromARGB(255, 31, 181, 195);

  /// Cor principal do Professor
  static const Color corProfessor = Color.fromARGB(255, 250, 162, 31);

  /// Cor principal do Diretor
  static const Color corDiretor = Color(0xCCFF2828);

  /// Menu do Aluno
  static const List<ItemMenu> menuAluno = [
    ItemMenu(
      titulo: 'Início',
      icone: Icons.home_outlined,
      rota: '/aluno',
      id: 'home',
    ),
    ItemMenu(
      titulo: 'Matérias',
      icone: Icons.book_outlined,
      rota: '/aluno/materias',
      id: 'materias',
    ),
    ItemMenu(
      titulo: 'Mensagens',
      icone: Icons.chat_bubble_outline,
      rota: '/aluno/mensagem',
      id: 'mensagens',
    ),
    ItemMenu(
      titulo: 'Boletim',
      icone: Icons.description_outlined,
      rota: '/aluno/boletim',
      id: 'boletim',
    ),
  ];

  /// Menu do Professor
  static const List<ItemMenu> menuProfessor = [
    ItemMenu(
      titulo: 'Início',
      icone: Icons.home_outlined,
      rota: '/professor',
      id: 'home',
    ),
    ItemMenu(
      titulo: 'Matérias',
      icone: Icons.book_outlined,
      rota: '/professor/materias',
      id: 'materias',
    ),
    ItemMenu(
      titulo: 'Mensagens',
      icone: Icons.chat_bubble_outline,
      rota: '/professor/mensagem',
      id: 'mensagens',
    ),
    ItemMenu(
      titulo: 'Notas',
      icone: Icons.assignment_outlined,
      rota: '/professor/notas',
      id: 'notas',
    ),
  ];

  /// Menu do Diretor
  static const List<ItemMenu> menuDiretor = [
    ItemMenu(
      titulo: 'Início',
      icone: Icons.home_outlined,
      rota: '/diretor',
      id: 'home',
    ),
    ItemMenu(
      titulo: 'Alunos',
      icone: Icons.people_outline,
      rota: '/diretor/alunos',
      id: 'alunos',
    ),
    ItemMenu(
      titulo: 'Professores',
      icone: Icons.person_outline,
      rota: '/diretor/professores',
      id: 'professores',
    ),
  ];

  /// Retorna o menu baseado no tipo de usuário
  static List<ItemMenu> obterMenu(String tipoUsuario) {
    switch (tipoUsuario.toLowerCase()) {
      case 'aluno':
        return menuAluno;
      case 'professor':
        return menuProfessor;
      case 'diretor':
        return menuDiretor;
      default:
        return [];
    }
  }

  /// Retorna a cor baseada no tipo de usuário
  static Color obterCor(String tipoUsuario) {
    switch (tipoUsuario.toLowerCase()) {
      case 'aluno':
        return corAluno;
      case 'professor':
        return corProfessor;
      case 'diretor':
        return corDiretor;
      default:
        return Colors.grey;
    }
  }
}
