# 🪢 Jogo da Forca — Flutter

> Projeto acadêmico migrado de Java/MySQL para Flutter/SQLite.  
> Um jogo da forca mobile completo, com múltiplas categorias e modo 2 jogadores.

---

## 📱 Sobre o Projeto

Este app foi desenvolvido como projeto da faculdade de **Ciência da Computação**.  
A versão original foi criada em **Java com Swing** e banco de dados **MySQL**.  
Esta versão foi **migrada e expandida** para **Flutter**, tornando o jogo:

- ✅ Independente de servidor (sem precisar de MySQL instalado)
- ✅ Funcional em qualquer celular Android/iOS
- ✅ Com banco de dados SQLite embutido no app
- ✅ Portável para GitHub como portfólio

---

## 🎮 Como Jogar

1. Escolha **1 Jogador** ou **2 Jogadores**
2. Selecione uma **categoria**
3. Adivinhe a palavra clicando nas letras
4. Você tem **7 tentativas** antes do game over
5. Use os botões de **Dica** e **Categoria** (cada um custa 1 vida)

---

## 🗂️ Categorias Disponíveis

| Emoji | Categoria |
|-------|-----------|
| 🎬 | Filmes e Séries |
| ⚽ | Esportes |
| 💻 | Tecnologia / Programação |
| 🍕 | Comidas e Bebidas |
| 🎵 | Música |

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Função |
|------------|--------|
| **Flutter** | Framework mobile (Android/iOS) |
| **Dart** | Linguagem de programação |
| **SQLite** (sqflite) | Banco de dados local no celular |
| **Google Fonts** | Tipografia (Nunito) |
| **flutter_animate** | Animações suaves |

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada (equivalente ao main() do Java)
├── theme/
│   └── app_tema.dart            # Cores e estilos centralizados
├── models/
│   └── palavra.dart             # Modelo de dados (equivalente ao Palavra.java)
├── database/
│   └── database_helper.dart     # Banco SQLite (substitui ConexaoFactory + JogoDAO)
├── widgets/
│   └── boneco_forca.dart        # Desenho do boneco (equivalente ao desenharCenario())
└── screens/
    ├── tela_inicial.dart        # Menu principal
    ├── tela_categorias.dart     # Seleção de categoria
    ├── tela_jogo.dart           # Tela do jogo (equivalente ao JogoTela.java)
    └── tela_pontuacao.dart      # Placar dos jogadores
```

---

## 🔄 Comparação: Java → Flutter

| Java (Original) | Flutter (Novo) |
|-----------------|----------------|
| `Palavra.java` | `models/palavra.dart` |
| `ConexaoFactory.java` | `database/database_helper.dart` |
| `JogoDAO.java` | `database/database_helper.dart` |
| `JogoTela.java` | `screens/tela_jogo.dart` |
| `Graphics2D` / `paintComponent()` | `CustomPainter` / `BonecoForca` |
| `MySQL` (servidor externo) | `SQLite` (embutido no app) |
| `JOptionPane.showMessageDialog()` | `showDialog()` |
| `JButton` customizado | `GestureDetector` + `AnimatedContainer` |

---

## ➕ Como Adicionar Palavras

Abra o arquivo `lib/database/database_helper.dart` e localize o método `_popularBancoDados()`.

Adicione novas palavras seguindo o padrão:

```dart
{'texto': 'SUAPALAVRA', 'dica': 'Dica sobre a palavra', 'categoria': 'Categoria', 'dificuldade': 'medio'},
```

**Dificuldades:**
- `'facil'` → até 5 letras
- `'medio'` → 6 a 8 letras  
- `'dificil'` → 9 letras ou mais

**Categorias disponíveis:**
- `'Filmes e Séries'`
- `'Esportes'`
- `'Tecnologia'`
- `'Comidas e Bebidas'`
- `'Música'`

> ⚠️ **Atenção:** Após adicionar palavras, desinstale o app do celular/emulador e instale novamente. O banco de dados só é criado na primeira instalação.

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado
- Android Studio ou VS Code com extensão Flutter
- Emulador Android ou celular físico

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/SEU_USUARIO/jogo-forca-flutter.git

# 2. Entre na pasta
cd jogo-forca-flutter

# 3. Instale as dependências
flutter pub get

# 4. Rode o app
flutter run
```

---

## 📸 Funcionalidades

- 🎯 Palavra aleatória por categoria
- ❤️ Sistema de vidas (7 tentativas)
- 💡 Dicas reveladas com custo de vida
- 🏷️ Categoria revelada com custo de vida
- 👥 Modo 2 jogadores (vez a vez)
- 🏆 Placar salvo no banco SQLite
- 🎨 Interface inspirada no Duolingo
- 📱 Responsivo para qualquer tamanho de tela

---

## 👨‍💻 Autor

Desenvolvido como projeto acadêmico — Ciência da Computação.

---

## 📄 Licença

Este projeto é de uso educacional e livre para estudo.
