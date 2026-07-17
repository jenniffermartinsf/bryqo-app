# Bryco App — Design Spec Completo

> App de aprendizado de programação/tech no estilo Duolingo.  
> Público: jovens adultos (teens-20s). Tom: moderno, vibrante, com humor.  
> Base de referência: `.claude/duolingo-design-system.md`

---

## 1. Identidade Visual Bryco

### Personalidade
- **Coding + Playful**: visual de tech (código, terminais) mas completamente gamificado
- **Hacker Friendly**: referências a programação sem ser entediante ou acadêmico
- **Mascote Brix**: a coruja do Duolingo → Brix, o mascote de código do Bryco
- Tom de voz: faz piadas de programação leves ("Ops! Esse bug fugiu de você 🐛")

### Taglines de Referência
```
"Aprenda a programar. Um commit de cada vez."
"Debug your skills, not your life."
"Você está on fire! 🔥 (e o servidor também)"
```

---

## 2. Paleta de Cores Bryco

Baseada no sistema Duolingo, com identidade própria de tech:

### Cores Primárias

| Nome | Hex | Uso |
|------|-----|-----|
| **Bryco Green** | `#58CC02` | CTA principal, correto, XP (= Duolingo Green) |
| **Green Shadow** | `#58A700` | Borda 3D dos botões verdes |
| **Code Blue** | `#1CB0F6` | Links, info, seções de código |
| **Blue Shadow** | `#0086C7` | Borda 3D dos botões azuis |
| **Bug Red** | `#FF4B4B` | Erro, vidas, bugs |
| **Red Shadow** | `#EA2B2B` | Borda 3D dos botões vermelhos |
| **XP Gold** | `#FFC800` | XP, conquistas, streaks |
| **Gold Shadow** | `#E6AC00` | Borda 3D dos botões dourados |
| **Terminal Purple** | `#CE82FF` | Seções especiais, desafios difíceis |
| **Purple Shadow** | `#9C52CE` | Borda 3D dos botões roxos |

### Neutros

| Nome | Hex | Uso |
|------|-----|-----|
| **White** | `#FFFFFF` | Cards, backgrounds, opções |
| **Off White** | `#F7F7F7` | Background de tela |
| **Border Light** | `#E5E5E5` | Bordas, divisores |
| **Gray Mid** | `#AFAFAF` | Placeholders, ícones inativos |
| **Gray Text** | `#777777` | Texto secundário |
| **Body Text** | `#4B4B4B` | Texto de corpo |
| **Title Text** | `#3C3C3C` | Títulos |

### Cor Especial: Code Blocks

| Nome | Hex | Uso |
|------|-----|-----|
| **Code BG** | `#1E1E2E` | Background de snippets de código |
| **Code Text** | `#CDD6F4` | Texto de código (style Catppuccin) |
| **Code Keyword** | `#CBA6F7` | Keywords (if, for, let) |
| **Code String** | `#A6E3A1` | Strings |
| **Code Number** | `#FAB387` | Números |
| **Code Comment** | `#6C7086` | Comentários |

---

## 3. Tipografia Bryco

### Fontes

| Família | Variação | Uso |
|---------|----------|-----|
| **Nunito** | ExtraBold 800 | Títulos, botões CTA, display |
| **Nunito** | Bold 700 | Subtítulos, labels |
| **Nunito** | SemiBold 600 | Corpo de texto, perguntas |
| **SF Mono / Menlo** | Regular / Medium | Code snippets apenas |

> No iOS usar `.rounded` design variant do SF Pro para ter o look Duolingo.
> Para código, sempre usar fonte monospace separada.

### Tamanhos

| Token | Size | Weight | Uso |
|-------|------|--------|-----|
| `display` | 44px | 800 | Telas de celebração |
| `titleXL` | 34px | 800 | Título principal de tela |
| `titleLG` | 28px | 700 | Seções |
| `titleMD` | 22px | 700 | Cards, modais |
| `titleSM` | 18px | 700 | Subtítulos |
| `bodyLG` | 19px | 600 | Perguntas de lição |
| `bodyMD` | 17px | 600 | Corpo padrão |
| `bodySM` | 15px | 400 | Descrições |
| `label` | 15px | 700 | Labels de botão |
| `caption` | 13px | 600 | Meta, timestamps |
| `code` | 15px | 400 | Code snippets (monospace) |

---

## 4. Fluxo de Lição — Spec Completa

### 4.1 Estrutura da Tela de Lição

```
┌──────────────────────────────────────────────┐
│  [X]   [████████████░░░░░░]   ❤️ ❤️ ❤️        │  ← TopBar
├──────────────────────────────────────────────┤
│                                              │
│   Qual é o output deste código?              │  ← Pergunta (bodyLG, bold)
│                                              │
│   ┌──────────────────────────────────┐       │
│   │  print("Hello, World!")          │       │  ← Code snippet
│   └──────────────────────────────────┘       │
│                                              │
│   ○ Hello, World!                            │  ← Opções
│   ○ hello, world!                            │
│   ○ "Hello, World!"                          │
│   ○ Erro de compilação                       │
│                                              │
├──────────────────────────────────────────────┤
│              [VERIFICAR]                     │  ← CTA primário 3D
└──────────────────────────────────────────────┘
```

### 4.2 Top Bar da Lição

```swift
// Componentes:
// - Botão X (fechar) — leva a confirmação de saída
// - ProgressView — width proporcional ao progresso (0.0-1.0)
// - HeartsView — 3 corações, vermelhos se cheios, cinza se perdidos
```

**Specs:**
- Background: `.white` / `.systemBackground`
- Altura: 52pt
- Progress bar: `height: 10pt`, `radius: 999`, cor `#58CC02`
- X button: 24×24pt, cor `#AFAFAF`
- Hearts: espaçamento 4pt entre eles, 20×20pt cada

### 4.3 Tipos de Questão

#### Tipo 1: Multiple Choice (Múltipla Escolha)
```
Pergunta em texto ou com code snippet
↓
4 opções em cards verticais
Opções podem conter: texto, código inline, ícone
```

**Estado das opções:**
| Estado | BG | Border | Text |
|--------|-----|--------|------|
| Default | `#FFFFFF` | `2pt #E5E5E5` | `#4B4B4B` |
| Selected | `#EDFBCB` | `2pt #58CC02` | `#3C3C3C` |
| Correct | `#D7FFB8` | `2pt #58CC02` | `#3C3C3C` |
| Wrong | `#FFDFE0` | `2pt #FF4B4B` | `#3C3C3C` |

**Animações:**
- Tap: scale 0.97 → 1.0, `150ms spring`
- Wrong: shake horizontal (±8pt, 3 ciclos), `400ms`
- Correct: scale 1.0 → 1.03 → 1.0, `200ms spring`

#### Tipo 2: Code Completion (Preencher o Código)
```
def saudacao(nome):
    return "Olá, " + ___
```
Opções em chips horizontais: `[nome]  [None]  ["nome"]  [str]`

**Chip specs:**
- Padding: `8pt 16pt`
- Radius: `8pt`
- Default: `#FFFFFF`, borda `#E5E5E5`
- Selected: `#1CB0F6` bg, texto branco

#### Tipo 3: Code Order (Ordenar Código)
```
Arraste para montar o código:
[linha 3]  [linha 1]  [linha 4]  [linha 2]
     ↓
┌─────────────────────┐
│ 1. [linha 1]   [×]  │
│ 2. ___________      │  ← drop zone
│ 3. ___________      │
└─────────────────────┘
```

#### Tipo 4: True/False
```
O código abaixo gera um erro?

def f():
    x = 5
    return x + "1"

[✓ Verdadeiro]   [✗ Falso]
```

**Botão True/False:**
- Verde para Verdadeiro: `#58CC02` + sombra `#58A700`
- Vermelho para Falso: `#FF4B4B` + sombra `#EA2B2B`
- Lado a lado, cada um 50% da largura

### 4.4 Tela de Feedback (Bottom Banner)

#### Resposta Correta
```
┌─────────────────────────────────────────────────┐
│  ✅  Correto!                          +10 XP   │
│  Arrays começam no índice 0 em Python.          │
│                              [CONTINUAR] →      │
└─────────────────────────────────────────────────┘
```

**Specs:**
- Background: `#D7FFB8`
- Border top: `2pt #58CC02`
- Ícone check: 32×32pt, cor `#58CC02`
- "+10 XP": badge dourado, `#FFC800`, `Bold 700`
- Título: `#58CC02`, `Bold 700`, 19pt
- Subtexto: `#4B4B4B`, 15pt, max 2 linhas
- Botão: verde 3D (padrão)
- Animação entrada: slide-up 300ms spring (stiffness 300, damping 25)

#### Resposta Errada
```
┌─────────────────────────────────────────────────┐
│  🐛  Bug encontrado!               ❤️ → 🖤      │
│  Resposta correta: "Hello, World!"              │
│                              [CONTINUAR] →      │
└─────────────────────────────────────────────────┘
```

**Specs:**
- Background: `#FFDFE0`
- Border top: `2pt #FF4B4B`
- Ícone bug: 32×32pt (usar o mascote Brix triste)
- Título: `#FF4B4B`, `Bold 700`, 19pt  
- Resposta correta: `#4B4B4B`, 15pt
- Animação coração perdido: coração voa para o contador e desaparece

### 4.5 Tela de Conclusão de Lição

```
┌──────────────────────────────────────┐
│                                      │
│     🎉  [Brix comemorando]           │
│                                      │
│      Lição Concluída!                │
│                                      │
│  ┌──────────┬──────────┬──────────┐  │
│  │  XP      │ Acertos  │ Streak   │  │
│  │ +50 🪙   │  8/10    │ 🔥 5     │  │
│  └──────────┴──────────┴──────────┘  │
│                                      │
│         [CONTINUAR]                  │
│                                      │
└──────────────────────────────────────┘
```

**Specs:**
- Background: gradiente suave de `#FFFFFF` → `#F0FFF4`
- Confetti: 40 partículas (verde, amarelo, azul, roxo)
- Mascote Brix: animação bounce na entrada
- Cards de stats: `#FFFFFF`, sombra suave, radius `16pt`
- XP counter: animação de contagem (0 → valor final), `800ms ease-out`
- Botão continuar: verde 3D, largura total

---

## 5. Code Snippet Component

Componente para exibir código nas questões:

```
┌──────────────────────────────────────────────┐
│ python                              ← label   │
│─────────────────────────────────────────────│
│  def saudacao(nome):                         │
│      return "Olá, " + nome                   │
└──────────────────────────────────────────────┘
```

**Specs:**
- Background: `#1E1E2E` (dark sempre, mesmo em light mode)
- Label de linguagem: top-left, `#6C7086`, `caption` size, capsule background
- Padding: `16pt`
- Radius: `12pt`
- Fonte: `SF Mono` ou `Menlo`, 14-15pt
- Syntax highlighting: keywords roxo, strings verde, números laranja
- Scroll horizontal se linha muito longa

---

## 6. Gamificação — Implementação

### XP System
- Cada questão certa: `+10 XP`
- Streak bonus (7 dias): `+50 XP` ao completar lição
- Perfeit (100% acertos): `+20 XP` bonus

### Hearts System
- 3 corações por padrão
- -1 coração por erro
- 0 corações → "Você ficou sem vidas!" modal com opções:
  - Assistir anúncio → +1 coração
  - Praticar lição anterior → recuperar
  - Esperar (temporizador de recarga)

### Streak
- Incrementa ao completar pelo menos 1 lição por dia
- Exibido proeminentemente na Home
- Notificação de risco quando não completou (fim do dia)

### Level / Progress Path
- Cada unidade = 5-10 lições
- Lição bloqueada até completar anterior
- "Boss" no fim de cada unidade = revisão completa com timer

---

## 7. Animações em SwiftUI

### Spring Padrão para Interações
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
```

### Spring para Celebrações
```swift
.animation(.spring(response: 0.4, dampingFraction: 0.5), value: showResult)
```

### Shake (resposta errada)
```swift
// Implementar via keyframes ou phase animator
.keyframeAnimator(initialValue: 0.0, trigger: shakeCount) { view, value in
    view.offset(x: value)
} keyframes: { _ in
    CubicKeyframe(8, duration: 0.07)
    CubicKeyframe(-8, duration: 0.07)
    CubicKeyframe(6, duration: 0.07)
    CubicKeyframe(-6, duration: 0.07)
    CubicKeyframe(4, duration: 0.07)
    CubicKeyframe(0, duration: 0.07)
}
```

### Scale Pop (item correto)
```swift
.scaleEffect(isCorrect ? 1.05 : 1.0)
.animation(.spring(response: 0.25, dampingFraction: 0.6), value: isCorrect)
```

### Slide Up (feedback banner)
```swift
.transition(.move(edge: .bottom).combined(with: .opacity))
.animation(.spring(response: 0.35, dampingFraction: 0.75), value: showFeedback)
```

---

## 8. Componente: Botão 3D (Assinatura Duolingo/Bryco)

```swift
struct BrycoButton: View {
    let title: String
    let color: Color       // ex: Color(hex: "#58CC02")
    let shadowColor: Color // ex: Color(hex: "#58A700")
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(shadowColor, lineWidth: 0)
                )
                .offset(y: isPressed ? 3 : 0)
        }
        // A "sombra 3D" é feita com um segundo retângulo atrás,
        // deslocado 4pt para baixo com a shadowColor
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(shadowColor)
                .offset(y: isPressed ? 1 : 4)
        )
        .buttonStyle(.plain)
        ._onButtonGesture(pressing: { pressing in
            withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: action)
    }
}
```

---

## 9. Voz e Micro-copy para App de Código

### Celebração (correto)
```
"Correto! Você debugou! 🐛✓"
"Perfeito! Esse código vai longe. 🚀"
"Show de bola! +10 XP"
"Compilou sem erros! 🎉"
"Você é um(a) dev nato(a)!"
```

### Erro (errado)
```
"Bug encontrado! Mas você vai corrigir. 🐛"
"Ops! Todo dev erra. O segredo é aprender."
"Resposta correta: [X] — guarda essa pra próxima!"
"Quase! Revisa a sintaxe."
```

### Progresso
```
"Você está em chamas! 🔥 [N] dias seguidos."
"[N] lições completas! Continue assim."
"Desbloqueou: [Conquista] 🏆"
"Novo recorde pessoal! ⚡"
```

### Vazio / Início
```
"Seu primeiro commit começa aqui."
"Todo sênior um dia foi júnior."
"Comece pequeno. Escale rápido."
```

---

## 10. Plano de Implementação — Fluxo de Lição

### Fase 1: Estrutura Base
- [ ] `LessonViewModel` — gerencia questões, respostas, XP, corações
- [ ] `Question` model com tipos: `.multipleChoice`, `.codeCompletion`, `.trueOrFalse`
- [ ] `LessonProgressBar` — barra de progresso animada no topo
- [ ] `HeartsView` — 3 corações com animação de perda

### Fase 2: Questão Multiple Choice
- [ ] `MultipleChoiceQuestion` view
- [ ] `OptionCard` com estados: default, selected, correct, wrong
- [ ] Animação de shake nos erros
- [ ] Code snippet integrado quando questão tem código

### Fase 3: Feedback Banner
- [ ] `LessonFeedbackBanner` — slide-up com correto/errado
- [ ] Animação de XP flutuante (+10)
- [ ] Animação de coração perdido

### Fase 4: Conclusão
- [ ] `LessonCompletionView` — tela de celebração
- [ ] Confetti animation
- [ ] Stats cards (XP, acertos, streak)
- [ ] Integração com progress path

### Fase 5: Code Questions
- [ ] `CodeSnippetView` com syntax highlighting
- [ ] `CodeCompletionQuestion` com chips selecionáveis
- [ ] `TrueOrFalseQuestion`

---

*Documento criado em 2026-07-16. Projeto: Bryco App — app de aprendizado de programação.*
