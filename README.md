# 📚 EducPoli

<div align="center">

**Sistema de Gerenciamento Escolar Multiplataforma**

[![Flutter](https://img.shields.io/badge/Flutter-3.5.0-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.5.0-0175C2?logo=dart)](https://dart.dev)

</div>

---

## 📖 Sobre o Projeto

Este projeto foi desenvolvido pelos alunos do **4º semestre** do curso de **Sistemas de Informação** do **Instituto Mauá de Tecnologia (IMT)**, como parte do **Projeto Interdisciplinar Integrador (PII)**.

O **EducPoli** é uma plataforma completa para gestão escolar, focada no **Sistema Poliedro**, que permite o compartilhamento de conteúdos, envio de mensagens individuais e divulgação segura de notas. A aplicação é **multiplataforma** (Web, Desktop e Mobile), com autenticação segura por RA e senha.

### 👥 Equipe de Desenvolvimento

- **Cauê de Oliveira Almiron** - RA: 24.01734-5
- **Carolina Mitsuoka Emoto** - RA: 22.00086-0
- **Fábio Tofanello** - RA: 24.01806-6
- **Giovanna Dias da Silva** - RA: 24.01797-3
- **Murilo Kaspar de Andrade** - RA: 24.01178-9
- **Raissa Mantovani Andrade Duarte** - RA: 24.00096-5

---

## ✨ Funcionalidades

### 👨‍🏫 Para Professores

- Gerenciamento de matérias e turmas
- Upload e compartilhamento de materiais didáticos
- Organização de conteúdo por seções/módulos
- Visualização de alunos por turma

### 👨‍💼 Para Diretores

- Cadastro e gerenciamento de alunos
- Criação e administração de turmas
- Gerenciamento de professores e suas atribuições
- Controle de matérias oferecidas

### 👨‍🎓 Para Alunos

- Acesso aos materiais das matérias
- Download de arquivos e documentos
- Visualização de conteúdos organizados por turma
- Interface intuitiva e responsiva

---

## 🛠️ Tecnologias Utilizadas

### Frontend

- **Flutter** - Framework multiplataforma para desenvolvimento de interfaces
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Google Fonts** - Tipografia customizada

### Backend & Serviços

- **Firebase Authentication** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Firebase Storage** - Armazenamento de arquivos

### Pacotes Principais

- `file_picker` - Seleção de arquivos
- `url_launcher` - Abertura de URLs e documentos
- `flutter_pdfview` - Visualização de PDFs
- `image_picker` - Seleção de imagens

### Testes

- `flutter_test` - Testes unitários e de widgets
- `mockito` - Mock de dependências
- `fake_cloud_firestore` - Mock do Firestore
- `firebase_auth_mocks` - Mock do Firebase Auth
- `integration_test` - Testes de integração

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.5.0 ou superior)
- [Dart SDK](https://dart.dev/get-dart) (versão 3.5.0 ou superior)
- [Git](https://git-scm.com/)
- Um editor de código ([VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio))

### Configuração do Ambiente

1. **Clone o repositório**

```bash
git clone https://github.com/seu-usuario/educpoli.git
cd educpoli/EducPoli
```

2. **Instale as dependências**

```bash
flutter pub get
```

3. **Configure o Firebase**

   - Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
   - Adicione os aplicativos (Android, iOS, Web)
   - Baixe os arquivos de configuração:
     - `google-services.json` (Android) → `android/app/`
     - `GoogleService-Info.plist` (iOS) → `ios/Runner/`
   - Configure o Firebase para Web (arquivo já incluído: `lib/firebase_options.dart`)

4. **Configure as regras do Firestore**
   - Acesse o Firestore no Firebase Console
   - Configure as regras de segurança conforme necessário

### Executando o Projeto

#### Mobile (Android/iOS)

```bash
# Verificar dispositivos conectados
flutter devices

# Executar em modo debug
flutter run

# Executar em dispositivo específico
flutter run -d <device_id>
```

#### Web

```bash
# Executar no navegador
flutter run -d chrome

# Ou especifique outro navegador
flutter run -d edge
```

#### Desktop (Windows/macOS/Linux)

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Build de Produção

#### Android (APK)

```bash
flutter build apk --release
```

#### Android (App Bundle)

```bash
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

#### Web

```bash
flutter build web --release
```

---

## 🧪 Executando Testes

### Testes Unitários

```bash
flutter test
```

### Testes de Integração

```bash
flutter test integration_test/
```

### Testes com Cobertura

```bash
flutter test --coverage
```

---

## 📁 Estrutura do Projeto

```
EducPoli/
├── lib/
│   ├── core/                 # Configurações e utilitários
│   │   └── config/          # Configurações do menu e cores
│   ├── models/              # Modelos de dados
│   ├── pages/               # Telas da aplicação
│   │   ├── aluno/          # Telas do aluno
│   │   ├── diretor/        # Telas do diretor
│   │   └── professor/      # Telas do professor
│   ├── services/            # Serviços e integrações
│   ├── widgets/             # Componentes reutilizáveis
│   ├── firebase_options.dart
│   └── main.dart           # Ponto de entrada
├── test/                    # Testes unitários
│   ├── unit/
│   ├── widget/
│   └── integration/
├── android/                 # Configurações Android
├── ios/                     # Configurações iOS
├── web/                     # Configurações Web
└── pubspec.yaml            # Dependências do projeto
```

---

## 🎯 Objetivos do Projeto

- ✅ Desenvolver uma plataforma multiplataforma acessível
- ✅ Implementar autenticação segura por RA e senha
- ✅ Permitir compartilhamento eficiente de conteúdos
- ✅ Garantir segurança e privacidade dos dados
- ✅ Criar interface intuitiva e responsiva
- ✅ Aplicar conhecimentos de desenvolvimento mobile e web

---

## 🤝 Colaboração

Este projeto é resultado da parceria entre:

<p align="center">
  <img src="https://raw.githubusercontent.com/IMT-PII-3-Semestre/chatbot-poliedro/main/images/logo-IMT.png" width="150" alt="Logo IMT">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/IMT-PII-3-Semestre/chatbot-poliedro/main/images/logo-poliedro-se.png" width="150" alt="Logo Poliedro SE">
</p>

---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos como parte do Projeto Interdisciplinar Integrador (PII) do Instituto Mauá de Tecnologia.

---

<div align="center">

**Desenvolvido com ❤️ por alunos do IMT**

</div>
