# 🪢 Em Forca (Mobile - Flutter)

Projeto desenvolvido na faculdade de Ciência da Computação.
A ideia foi pegar um jogo que já tínhamos feito em Java e transformar em uma versão mobile usando Flutter.

---

## 📱 Sobre o projeto

Esse jogo começou como uma aplicação em Java com interface Swing e banco MySQL.
Depois resolvi refazer tudo em Flutter pra rodar direto no celular e não depender de servidor.

Nessa versão:

* O jogo funciona totalmente offline
* O banco agora é SQLite (local no app)
* Interface adaptada pra mobile
* Código mais organizado comparado à versão antiga

---

## 🎮 Como funciona

* Dá pra jogar sozinho ou em 2 jogadores
* Você escolhe uma categoria
* Vai tentando adivinhar a palavra letra por letra
* Tem um limite de 7 erros

Também tem duas ajudas:

* Dica da palavra
* Mostrar a categoria

Mas usar isso custa vida, então tem que pensar bem.

---

## 🗂️ Categorias

* Filmes e Séries
* Esportes
* Tecnologia
* Comidas e Bebidas
* Música

---

## 🛠️ Tecnologias

* Flutter
* Dart
* SQLite (sqflite)
* Google Fonts
* flutter_animate

---

## 📁 Organização do projeto

A estrutura ficou mais ou menos assim:

* `main.dart` → inicialização do app
* `models/` → estrutura das palavras
* `database/` → controle do banco SQLite
* `screens/` → telas do app
* `widgets/` → componentes reutilizáveis (tipo o boneco da forca)
* `theme/` → cores e estilos

---

## 🔄 Comparação com a versão antiga

Na versão antiga (Java):

* Usava MySQL
* Interface com Swing
* Código mais acoplado

Agora no Flutter:

* Banco local (SQLite)
* Interface mais moderna
* Melhor separação de responsabilidades

---

## ➕ Adicionar palavras

As palavras ficam dentro do arquivo:

`lib/database/database_helper.dart`

No método de inserção inicial.

Formato:

```dart
{'texto': 'PALAVRA', 'dica': 'Alguma dica', 'categoria': 'Categoria', 'dificuldade': 'medio'},
```

Depois de adicionar, precisa reinstalar o app pra recriar o banco.

---

## 🚀 Rodando o projeto

```bash
git clone https://github.com/SEU_USUARIO/jogo-forca-flutter.git
cd jogo-forca-flutter
flutter pub get
flutter run
```

---

## 📸 O que o jogo tem

* Sistema de vidas
* Dicas com custo
* Categorias
* Modo 2 jogadores
* Placar salvo
* Interface adaptada pra celular

---

## 👨‍💻 Autores

Projeto desenvolvido por:

* Carlos Joab
* Augusto
* Arthur Vinícius
* Michael

Como parte das atividades da faculdade de Ciência da Computação.

---

## 📄 Licença

Uso livre para estudo.
