# 🎨 Nova Estrutura de Menu Lateral - EducPoli

## 📋 O que mudou?

### ✅ ANTES (Problema)

- ❌ Cada tela tinha seu próprio menu lateral
- ❌ Menu inconsistente entre páginas
- ❌ Botão voltar aparecia no canto superior esquerdo
- ❌ Navegação funcionava como pilha
- ❌ Código duplicado em várias telas

### ✅ AGORA (Solução)

- ✅ **Menu lateral centralizado e único**
- ✅ **Componente reutilizável** (`MenuLateral`)
- ✅ **Layout base padronizado** (`LayoutBase`)
- ✅ **Configuração centralizada** (`MenuConfig`)
- ✅ **Navegação sem empilhamento** (pushReplacement)
- ✅ **Sem setas de voltar** - navegação por breadcrumbs e menu
- ✅ **Botões de ação centralizados** (Início e Sair)

---

## 🏗️ Arquitetura

```
lib/
├── core/
│   └── config/
│       └── menu_config.dart          # ⚙️ Configuração de menus por perfil
├── widgets/
│   ├── menu_lateral.dart             # 📱 Componente do menu lateral
│   └── layout_base.dart              # 🎨 Layout base para todas as páginas
└── pages/
    ├── aluno/
    │   ├── materias_alunos.dart      # ✅ Exemplo atualizado
    │   ├── mensagem_aluno.dart
    │   ├── notas_aluno.dart
    │   └── boletim_aluno.dart
    ├── professor/
    │   ├── materias_professor.dart
    │   ├── mensagens_professor.dart
    │   └── notas_professor.dart
    └── diretor/
        ├── gerenciar_alunos.dart
        ├── gerenciar_professor.dart
        ├── cadastrar_alunos.dart
        └── cadastrar_professores.dart
```

---

## 🎯 Como Usar

### 1. **MenuConfig** - Configuração Centralizada

```dart
// lib/core/config/menu_config.dart

class MenuConfig {
  // Cores por perfil
  static const Color corAluno = Color(0xFF7DD3FC);
  static const Color corProfessor = Color(0xFFFF9500);
  static const Color corDiretor = Color(0xFFE74C3C);

  // Menus por perfil
  static const List<ItemMenu> menuAluno = [
    ItemMenu(
      titulo: 'Matérias',
      icone: Icons.book_outlined,
      rota: '/aluno/materias',
      id: 'materias',
    ),
    // ... outros itens
  ];

  // Métodos auxiliares
  static List<ItemMenu> obterMenu(String tipoUsuario) { ... }
  static Color obterCor(String tipoUsuario) { ... }
}
```

### 2. **LayoutBase** - Layout Padronizado

```dart
// lib/widgets/layout_base.dart

class LayoutBase extends StatelessWidget {
  final String titulo;
  final Widget conteudo;
  final List<ItemMenu> itensMenu;
  final String itemSelecionadoId;
  final Color corPrincipal;
  final List<Widget>? breadcrumbs;

  // Renderiza:
  // - AppBar sem botão voltar
  // - Menu lateral (desktop fixo, mobile drawer)
  // - Conteúdo da página
}
```

### 3. **MenuLateral** - Componente do Menu

```dart
// lib/widgets/menu_lateral.dart

class MenuLateral extends StatelessWidget {
  // Renderiza:
  // - Header com perfil do usuário
  // - Lista de itens do menu
  // - Botões de ação (Início e Sair)

  // Navegação: pushReplacementNamed (sem empilhamento)
}
```

---

## 📝 Exemplo de Página Atualizada

```dart
import 'package:flutter/material.dart';
import '../../widgets/layout_base.dart';
import '../../core/config/menu_config.dart';

class MinhaTelaAluno extends StatelessWidget {
  const MinhaTelaAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBase(
      titulo: 'Minha Tela',
      corPrincipal: MenuConfig.corAluno,
      itensMenu: MenuConfig.menuAluno,
      itemSelecionadoId: 'materias', // ID do item ativo
      breadcrumbs: const [
        Breadcrumb(texto: 'Início'),
        Breadcrumb(texto: 'Minha Tela', isAtivo: true),
      ],
      conteudo: _buildConteudo(context),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    return Center(
      child: Text('Seu conteúdo aqui'),
    );
  }
}
```

---

## 🎨 Características do Menu Lateral

### 📱 Header do Perfil

- Avatar circular com inicial do nome
- Nome completo do usuário
- Email do usuário
- Badge com tipo (ALUNO/PROFESSOR/DIRETOR)
- Gradiente com cor do perfil

### 📋 Itens do Menu

- Ícone + Título
- Indicador visual do item ativo
- Navegação sem empilhamento
- Hover e feedback visual

### 🔘 Botões de Ação

- **Voltar ao Início**: Navega para o dashboard apropriado
- **Sair**: Confirmação antes de logout

---

## 🚀 Próximos Passos

### Páginas a Atualizar:

#### Aluno (4/4)

- [x] `materias_alunos.dart` ✅
- [ ] `mensagem_aluno.dart`
- [ ] `notas_aluno.dart`
- [ ] `boletim_aluno.dart`

#### Professor (0/3)

- [ ] `materias_professor.dart`
- [ ] `mensagens_professor.dart`
- [ ] `notas_professor.dart`

#### Diretor (0/4)

- [ ] `gerenciar_alunos.dart`
- [ ] `gerenciar_professor.dart`
- [ ] `cadastrar_alunos.dart`
- [ ] `cadastrar_professores.dart`

---

## 💡 Benefícios

1. **Consistência**: Mesmo menu em todas as telas
2. **Manutenção**: Mudanças em um só lugar
3. **Performance**: Menos re-renders
4. **UX**: Navegação clara e intuitiva
5. **Código Limpo**: DRY (Don't Repeat Yourself)

---

## 🔧 Personalização

### Alterar cores do menu:

```dart
// lib/core/config/menu_config.dart
static const Color corAluno = Color(0xFF7DD3FC); // Sua cor aqui
```

### Adicionar item ao menu:

```dart
static const List<ItemMenu> menuAluno = [
  // ... itens existentes
  ItemMenu(
    titulo: 'Novo Item',
    icone: Icons.star,
    rota: '/aluno/novo',
    id: 'novo',
  ),
];
```

### Alterar comportamento de navegação:

```dart
// lib/widgets/menu_lateral.dart
onTap: () {
  // pushReplacementNamed = sem empilhamento
  Navigator.pushReplacementNamed(context, item.rota);

  // OU push = com empilhamento (não recomendado)
  // Navigator.pushNamed(context, item.rota);
}
```

---

## ✅ Checklist de Migração

Para migrar uma página antiga:

1. [ ] Importar `LayoutBase` e `MenuConfig`
2. [ ] Remover `Scaffold`, `AppBar` e menu lateral custom
3. [ ] Envolver conteúdo em `LayoutBase`
4. [ ] Definir `titulo`, `corPrincipal`, `itensMenu`, `itemSelecionadoId`
5. [ ] Adicionar `breadcrumbs` se necessário
6. [ ] Testar navegação entre páginas
7. [ ] Verificar responsividade (desktop/mobile)

---

🎉 **Menu Lateral Centralizado Implementado com Sucesso!**
