# 📝 Como Adicionar Palavras ao Banco de Dados

Este arquivo te ensina como popular o banco de dados do jogo com suas próprias palavras.

---

## 📍 Onde editar?

Abra o arquivo:
```
lib/database/database_helper.dart
```

Localize o método `_popularBancoDados()`. É lá que ficam todas as palavras.

---

## ✏️ Formato de uma palavra

```dart
{
  'texto': 'PALAVRA',        // A palavra (em MAIÚSCULAS)
  'dica': 'Dica da palavra', // Uma dica para o jogador
  'categoria': 'Categoria',  // A categoria (veja abaixo)
  'dificuldade': 'medio'     // 'facil', 'medio' ou 'dificil'
},
```

---

## 🗂️ Categorias disponíveis

Use exatamente como está escrito abaixo (com acentos):

- `'Filmes e Séries'`
- `'Esportes'`
- `'Tecnologia'`
- `'Comidas e Bebidas'`
- `'Música'`

---

## 📏 Regras de dificuldade

| Dificuldade | Quantidade de letras | Exemplo |
|-------------|---------------------|---------|
| `'facil'`   | Até 5 letras        | PIZZA, SAMBA |
| `'medio'`   | 6 a 8 letras        | FUTEBOL, GUITARRA |
| `'dificil'` | 9 letras ou mais    | ALGORITMO, CAIPIRINHA |

---

## 💡 Exemplo completo

```dart
// Adicione dentro do array palavras = [ ... ], antes do ];

// --- FILMES E SÉRIES ---
{'texto': 'TITANIC', 'dica': 'Filme sobre um navio que afundou', 'categoria': 'Filmes e Séries', 'dificuldade': 'medio'},
{'texto': 'HOMEM ARANHA', 'dica': 'Super-herói que atira teia', 'categoria': 'Filmes e Séries', 'dificuldade': 'dificil'},

// --- ESPORTES ---
{'texto': 'JUDÔ', 'dica': 'Arte marcial japonesa', 'categoria': 'Esportes', 'dificuldade': 'facil'},
{'texto': 'MARATONA', 'dica': 'Corrida de 42km', 'categoria': 'Esportes', 'dificuldade': 'medio'},

// --- TECNOLOGIA ---
{'texto': 'KOTLIN', 'dica': 'Linguagem oficial do Android', 'categoria': 'Tecnologia', 'dificuldade': 'facil'},
{'texto': 'BANCO DE DADOS', 'dica': 'Onde as informações são armazenadas', 'categoria': 'Tecnologia', 'dificuldade': 'dificil'},

// --- COMIDAS E BEBIDAS ---
{'texto': 'TAPIOCA', 'dica': 'Comida típica do Nordeste brasileiro', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'medio'},
{'texto': 'AÇAÍ', 'dica': 'Fruta roxa da Amazônia', 'categoria': 'Comidas e Bebidas', 'dificuldade': 'facil'},

// --- MÚSICA ---
{'texto': 'VIOLÃO', 'dica': 'Instrumento de cordas acústico', 'categoria': 'Música', 'dificuldade': 'facil'},
{'texto': 'AXÉMUSIC', 'dica': 'Ritmo musical da Bahia', 'categoria': 'Música', 'dificuldade': 'medio'},
```

---

## ⚠️ IMPORTANTE: Resetar o banco após adicionar palavras

O banco SQLite é criado **apenas na primeira vez** que o app é instalado.

Se você já rodou o app antes e quer adicionar novas palavras, você precisa:

**Opção 1 — Desinstalar e reinstalar (mais fácil):**
```bash
# No emulador ou celular, desinstale o app manualmente
# Depois rode novamente:
flutter run
```

**Opção 2 — Incrementar a versão do banco (correto para produção):**

No arquivo `database_helper.dart`, mude a versão de `1` para `2`:
```dart
return await openDatabase(
  path,
  version: 2,  // <- Mude aqui
  onCreate: _criarTabelas,
  onUpgrade: (db, oldVersion, newVersion) async {
    // Aqui você pode migrar dados ao atualizar o app
    await db.delete('palavras');
    await _popularBancoDados(db);
  },
);
```

---

## 🔤 Dica sobre acentos

As letras acentuadas (Ã, É, Ç, etc.) **não aparecem no teclado do jogo**.  
Por isso, se sua palavra tem acento, o jogo vai mostrar a letra sem acento no teclado.

✅ Recomendação: use palavras **sem acento** no campo `texto`:
```dart
// ✅ Correto
{'texto': 'PROGRAMACAO', 'dica': 'Ato de escrever código', ...}

// ⚠️ Cuidado — o Ç não tem no teclado!
{'texto': 'PROGRAMAÇÃO', ...}
```

---

Qualquer dúvida, volte aqui neste guia! 💪
