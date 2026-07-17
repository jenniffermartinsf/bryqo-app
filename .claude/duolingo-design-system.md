# Duolingo Design System — Referência Completa

> Documento de referência para replicar o visual e a experiência do Duolingo.
> Fonte: https://design.duolingo.com + estudo aprofundado do produto

---

## 1. Filosofia de Design

### Princípios Centrais

| Princípio | Descrição |
|-----------|-----------|
| **Playful** | Divertido sem ser infantil. Cada interação deve trazer leveza e prazer. |
| **Global** | Funciona em qualquer cultura. Usa ícones universais, evita jargões regionais. |
| **Honest** | Transparente com o progresso real do usuário. Sem ilusões falsas. |
| **Educational** | Cada decisão de design serve ao aprendizado. UI apoia o conteúdo, nunca compete. |

### Personalidade da Marca
- **Encorajadora** — celebra pequenas vitórias, nunca envergonha erros
- **Bem-humorada** — usa humor suave, nunca sarcástico ou exclusivo
- **Motivadora** — cria urgência positiva (streaks, metas, progresso visual)
- **Acessível** — simples o suficiente para qualquer nível de habilidade tech

---

## 2. Cores

### Paleta Principal

| Nome | Hex | Uso |
|------|-----|-----|
| **Duolingo Green** | `#58CC02` | CTA primário, sucesso, ações positivas |
| **Green Dark** (sombra 3D) | `#58A700` | Borda inferior dos botões, sombra de cards verdes |
| **Macaw Blue** | `#1CB0F6` | Destaque secundário, links, informações |
| **Blue Dark** | `#0086C7` | Sombra/borda do azul |
| **Cardinal Red** | `#FF4B4B` | Erro, vidas (hearts), alertas |
| **Red Dark** | `#EA2B2B` | Sombra/borda do vermelho |
| **Sun Yellow / Gold** | `#FFC800` | XP, moedas, streaks, conquistas |
| **Yellow Dark** | `#E6AC00` | Sombra/borda do amarelo |
| **Bee Orange** | `#FF9600` | Notificações, destaques quentes |
| **Orange Dark** | `#E68600` | Sombra/borda do laranja |
| **Hummingbird Purple** | `#CE82FF` | Elementos premium, magia, especial |
| **Purple Dark** | `#9C52CE` | Sombra/borda do roxo |
| **Flamingo Pink** | `#FF86D0` | Diversidade, eventos especiais |
| **Pink Dark** | `#E668B3` | Sombra/borda do rosa |

### Escala de Neutros

| Nome | Hex | Uso |
|------|-----|-----|
| **Snow White** | `#FFFFFF` | Backgrounds, cards, botões secundários |
| **Polar** | `#F7F7F7` | Background de telas principais |
| **Feather** | `#E5E5E5` | Bordas, divisores, inputs inativos |
| **Swan** | `#AFAFAF` | Texto placeholder, ícones inativos |
| **Hare** | `#777777` | Texto secundário, labels |
| **Wolf** | `#4B4B4B` | Texto de corpo principal |
| **Raven** | `#3C3C3C` | Títulos, texto de alto contraste |
| **Night** | `#1F1F1F` | Máximo contraste, dark mode base |

### Backgrounds de Estado

| Estado | Background | Borda |
|--------|-----------|-------|
| Neutro/Não selecionado | `#FFFFFF` | `#E5E5E5` |
| Hover/Foco | `#F7F7F7` | `#AFAFAF` |
| Selecionado | tint 15% da cor principal | cor principal |
| Correto | `#D7FFB8` | `#58CC02` |
| Errado | `#FFDFE0` | `#FF4B4B` |

---

## 3. Tipografia

### Fontes

| Família | Uso | Equivalente disponível |
|---------|-----|------------------------|
| **Feather Bold** (custom) | Títulos, display, CTAs | `Nunito ExtraBold` / `Rounded Mplus 1c ExtraBold` |
| **DIN Round** | Corpo de texto, labels | `Nunito SemiBold` / `SF Rounded` |

> **Regra de ouro**: Duolingo usa SEMPRE fontes arredondadas (sem serifas retas). A percepção de "amigável" vem do arredondamento das letras.

### Escala de Tamanhos

| Token | Tamanho | Peso | Uso |
|-------|---------|------|-----|
| `display` | 44px | ExtraBold 800 | Telas de celebração, hero |
| `title-xl` | 36px | ExtraBold 800 | Títulos de tela principais |
| `title-lg` | 28px | Bold 700 | Seções, modais |
| `title-md` | 24px | Bold 700 | Cards de destaque |
| `title-sm` | 20px | Bold 700 | Subtítulos, labels de seção |
| `body-lg` | 19px | SemiBold 600 | Texto de perguntas/lições |
| `body-md` | 17px | SemiBold 600 | Corpo de texto padrão |
| `body-sm` | 16px | Regular 400 | Descrições secundárias |
| `label-lg` | 15px | Bold 700 | Labels de botão |
| `label-md` | 14px | SemiBold 600 | Tags, chips, metadata |
| `label-sm` | 12px | SemiBold 600 | Captions, footnotes |

### Regras Tipográficas
- **Line height**: 1.3× para títulos, 1.5× para corpo
- **Letter spacing**: `-0.3px` para títulos grandes, `0` para corpo
- **Nunca** usar peso Regular (400) para elementos interativos
- Texto de botão sempre `Bold 700` ou maior

---

## 4. Espaçamento & Grid

### Sistema de Espaçamento (base 4px)

| Token | Valor | Uso |
|-------|-------|-----|
| `space-1` | 4px | Micro-espaços entre ícone e texto |
| `space-2` | 8px | Padding interno de chips/tags |
| `space-3` | 12px | Gap entre elementos em linha |
| `space-4` | 16px | Padding padrão de cards |
| `space-5` | 20px | Padding horizontal de telas |
| `space-6` | 24px | Separação entre seções menores |
| `space-8` | 32px | Separação entre seções |
| `space-10` | 40px | Padding vertical de headers |
| `space-12` | 48px | Espaço acima de CTAs principais |
| `space-16` | 64px | Margens maiores, separações de bloco |

### Border Radius

| Token | Valor | Uso |
|-------|-------|-----|
| `radius-sm` | 8px | Chips pequenos, badges |
| `radius-md` | 12px | Cards, inputs |
| `radius-lg` | 16px | Cards de destaque, botões médios |
| `radius-xl` | 20px | Modais, banners |
| `radius-pill` | 999px | Botões CTA, tags pills |

---

## 5. Componentes-Chave

### 5.1 Botão Primário (o mais icônico do Duolingo)

O botão 3D é a assinatura visual do Duolingo. Ele simula um botão físico:

```
┌─────────────────────────────┐  ← face do botão (cor principal)
│         CONTINUAR           │
└─────────────────────────────┘
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ← sombra (cor escura, ~4px)
```

**Especificações:**
- Background: `#58CC02` (verde) ou cor da ação
- Borda inferior: `4px solid #58A700` (sombra 3D)
- Sem box-shadow convencional
- Border radius: `12-16px` ou `999px` (pill)
- Padding: `16px 24px`
- Texto: Branco, `Bold 700`, `15-17px`
- Estado pressionado: move `2px` para baixo, borda inferior reduz para `2px`
- Transição: `100ms ease`

**Variantes:**
| Variante | Background | Borda Inferior | Texto |
|----------|-----------|----------------|-------|
| Primary (verde) | `#58CC02` | `#58A700` | `#FFFFFF` |
| Secondary (branco) | `#FFFFFF` | `#E5E5E5` | `#4B4B4B` |
| Danger (vermelho) | `#FF4B4B` | `#EA2B2B` | `#FFFFFF` |
| Locked (cinza) | `#E5E5E5` | `#AFAFAF` | `#AFAFAF` |

### 5.2 Opções de Questão (Multiple Choice)

```
┌─────────────────────────────────┐
│  🇧🇷  A frase em português        │  ← borda 2px, radius 12px
└─────────────────────────────────┘
```

- Estado padrão: `background #FFFFFF`, `border 2px #E5E5E5`
- Estado hover: `background #F7F7F7`, `border 2px #AFAFAF`
- Estado selecionado: `background tint 15%`, `border 2px cor`
- Estado correto: `background #D7FFB8`, `border 2px #58CC02`
- Estado errado: `background #FFDFE0`, `border 2px #FF4B4B`
- Animação de shake quando errado: `translateX` ±8px, 3 ciclos, 400ms

### 5.3 Barra de Progresso

```
[██████████████░░░░░░░░░░░░░░░░]  60%
```

- Background: `#E5E5E5`
- Fill: `#58CC02` (verde) ou cor do contexto
- Height: `8-12px`
- Border radius: `999px`
- Transição: `600ms ease-in-out` com spring leve

### 5.4 Progress Path (Mapa de Lições)

O elemento mais reconhecível do Duolingo: uma trilha em zig-zag com nós circulares.

```
        ●  ← Completed (verde sólido + checkmark)
       /
      ●    ← Current (pulsando, cor principal)
       \
        ●  ← Locked (cinza, cadeado)
       /
      ●
```

- Nó completado: circle preenchido verde, ícone branco de check
- Nó atual: circle maior, animação de pulse, cor principal
- Nó bloqueado: circle cinza, ícone de cadeado
- Linha conectora: `2-4px`, mesmo gradiente da trilha
- Cada nó: `56-64px` de diâmetro

### 5.5 Cards de Conquista / Badge

```
┌──────────────────────────────┐
│       🏆                      │
│   Semana Perfeita!           │  ← radius 16px, padding 16px
│   Completou 7 dias seguidos  │  ← sombra suave
└──────────────────────────────┘
```

- Background: `#FFFFFF`
- Box shadow: `0 2px 8px rgba(0,0,0,0.1)`, `0 0 0 2px #E5E5E5`
- Border radius: `16px`
- Ícone: 48-64px, ilustração colorida

### 5.6 Streak Counter

```
🔥 7
```

- Ícone de chama: amarelo-laranja (`#FF9600`)
- Número: `Bold 700`, `17-19px`, `#FF9600`
- Quando streak ativo: brilho/glow sutil ao redor da chama

### 5.7 Hearts (Vidas)

```
❤️ ❤️ ❤️ 🖤 🖤
```

- Heart cheio: vermelho `#FF4B4B`
- Heart vazio: cinza `#E5E5E5`
- Animação ao perder: quebra e cai (bounce down + fade)

### 5.8 XP / Moedas (Gems)

```
💎 1,250 XP
```

- Ícone: cristal azul ou moeda dourada
- Valor: `Bold 700`, cor correspondente

---

## 6. Feedback Visual (Estados de Resposta)

### Resposta Correta
```
┌─────────────────────────────────────────┐
│  ✅  Correto!                            │  ← banner verde na base
│  "A resposta certa era..."              │
│                         [CONTINUAR]     │
└─────────────────────────────────────────┘
```
- Background: `#D7FFB8`
- Ícone: checkmark `#58CC02`
- Título: "Ótimo trabalho!", "Correto!", "Incrível!"
- Botão: verde primário

### Resposta Errada
```
┌─────────────────────────────────────────┐
│  ❌  Ops! Tente de novo.                 │  ← banner vermelho na base
│  Resposta correta: "..."               │
│                         [CONTINUAR]     │
└─────────────────────────────────────────┘
```
- Background: `#FFDFE0`
- Ícone: X vermelho `#FF4B4B`
- Título: "Ops!", "Quase lá!", "Não desta vez."
- Linguagem: NUNCA envergonhante, sempre encorajadora
- Botão: vermelho primário

---

## 7. Animações e Motion

### Princípios de Motion
1. **Springy** — usa física de mola, não curvas lineares
2. **Significativo** — cada animação tem propósito (feedback, transição, celebração)
3. **Rápido** — micro-interações abaixo de 300ms
4. **Delightful** — celebrações são generosas e satisfatórias

### Valores de Spring Recomendados

| Contexto | Stiffness | Damping | Uso |
|----------|-----------|---------|-----|
| Botão press | 400 | 25 | Feedback tátil |
| Card entrada | 300 | 20 | Aparecer de baixo |
| Modal | 280 | 22 | Slide up |
| Celebração | 200 | 15 | Bounce exagerado |
| Progresso | 250 | 30 | Smooth, não oscila |

### Durações

| Tipo | Duração | Easing |
|------|---------|--------|
| Micro-feedback (tap) | 100-150ms | ease-out |
| Transição de estado | 200-300ms | spring |
| Transição de tela | 300-400ms | ease-in-out |
| Entrada de elemento | 250-350ms | spring |
| Celebração | 600-1200ms | spring + bounce |
| Progress fill | 600-800ms | ease-in-out |

### Padrões de Animação Chave

**Shake (resposta errada):**
```
keyframes: 0%→8px → -8px → 6px → -6px → 4px → -4px → 0
duration: 400ms
```

**Scale Pop (item coletado, conquista):**
```
0.8 → 1.15 → 0.95 → 1.0
duration: 300ms, spring
```

**Slide Up (banners de feedback):**
```
translateY(100%) → translateY(0)
duration: 300ms, spring (stiffness 300, damping 25)
```

**Confetti / Partículas (conclusão de lição):**
- 30-50 partículas coloridas
- Cores: verde, amarelo, azul, roxo, rosa
- Disparam do centro para fora com física de gravidade
- Duration total: 1.5-2s

---

## 8. Iconografia e Ilustrações

### Estilo de Ícones
- **Bold e preenchidos** — não outline fino
- **Arredondados** — cantos suaves, sem ângulos retos
- **Coloridos** — ícones de navegação ganham cor quando ativos
- **Tamanhos padrão**: 20px, 24px, 32px, 48px

### Estilo de Ilustrações
- **Flat design** com gradientes sutis
- **Outline bold** nos personagens (2-4px de espessura)
- **Expressivo** — personagens têm emoções claras e exageradas
- **Diversidade** — representação de múltiplas etnias, culturas
- **Paleta limitada** — cada personagem tem 3-5 cores principais

### Personagens (Duolingo)
- Duo (coruja verde) — mascote principal, motivador
- Lily — sarcástica, cabelo roxo
- Bea — animada, cabelo loiro
- Eddy — relaxado, cabelo escuro
- Zari — estudiosa, usa hijab
- Lin — curiosa, asiática

> Para apps próprios: criar 1-3 personagens com personalidade clara e usar consistentemente como guia emocional do usuário.

---

## 9. Navegação

### Tab Bar Inferior

| Aba | Ícone inativo | Ícone ativo | Label |
|-----|--------------|------------|-------|
| Home/Learn | outline | preenchido verde | "Aprender" |
| Practice | outline | preenchido azul | "Praticar" |
| Leaderboard | outline | preenchido amarelo | "Liga" |
| Profile | outline | preenchido roxo | "Perfil" |

- Background: `#FFFFFF` com border-top `1px #E5E5E5`
- Safe area para iPhone: padding bottom para home indicator
- Transição ativa: scale 1.0 → 1.15 → 1.0, `200ms spring`

### Top Bar de Lição

```
[← Voltar]  [████████░░░░░░]  [❤️ 3]
```

- X para sair (com confirmação modal)
- Barra de progresso central
- Hearts / vidas à direita

---

## 10. Gamificação — Padrões de UI

### Streak (Sequência Diária)
- Exibido proeminentemente no topo da home
- Número grande + ícone de chama
- Quando em risco: chama apagada/cinza com urgência

### XP & Progresso
- Barra de XP diário visível
- Animação de +XP ao completar (número flutua e desaparece)
- Marcos celebrados com animação

### Ligas / Leaderboard
- Ranking semanal com avatares
- Top 3 destacados com ouro/prata/bronze
- Promoção/rebaixamento visualizados

### Achievements / Badges
- Grid de badges, desbloqueados vs. bloqueados
- Bloqueados: grayscale ou silhueta
- Ao desbloquear: animação de brilho + pop

### Skill Tree / Path
- Nós na trilha representam lições
- Seções agrupam temas (unidades)
- Boss fight no final de cada unidade
- Revisão/reforço integrada à trilha

---

## 11. Micro-copy e Voz

### Tom de Voz
- **Curto** — frases de 1-2 linhas máximo
- **Ativo** — verbos de ação ("Comece", "Complete", "Ganhe")
- **Encorajador** — celebra qualquer progresso
- **Sem jargões** — acessível para todos os níveis

### Frases de Celebração (exemplos)
```
"Incrível! 🎉"
"Você arrasou!"
"Perfeito! Continue assim."
"Uau! Nota máxima!"
"Você está em chamas! 🔥"
```

### Frases de Erro (exemplos)
```
"Ops! Quase lá."
"Não desta vez. Você consegue!"
"Resposta correta: [X]"
"Continue tentando!"
```

### Frases de Vazio / Onboarding
```
"Sua jornada começa aqui."
"Todo especialista já foi um iniciante."
"Um dia de cada vez."
```

---

## 12. Dark Mode

### Mapeamento de Cores

| Light | Dark |
|-------|------|
| `#FFFFFF` (bg principal) | `#131f24` |
| `#F7F7F7` (bg secundário) | `#1a2a33` |
| `#E5E5E5` (bordas) | `#2b3d47` |
| `#4B4B4B` (texto) | `#EFEFEF` |
| `#3C3C3C` (título) | `#FFFFFF` |
| `#58CC02` (verde) | `#58CC02` (mantém) |

> No dark mode, as cores de ação (verde, azul, vermelho) permanecem as mesmas. Só os neutros se invertem.

---

## 13. Onboarding

### Fluxo Típico
1. **Splash** — mascote + animação de boas-vindas
2. **Proposta de valor** — "Aprenda X em Y minutos por dia"
3. **Personalização** — qual seu objetivo? Qual seu nível?
4. **Comprometimento** — metas diárias (5 / 10 / 15 / 20 min)
5. **Notificações** — permissão com contexto de valor
6. **Primeira lição** — começa imediatamente, sem bloqueios

### Princípios de Onboarding Duolingo
- **Nunca peça login antes de valor** — mostra o produto primeiro
- **Lição demo** — usuário experimenta antes de criar conta
- **Progresso imediato** — barra aparece desde o início
- **Escolhas simples** — máximo 4 opções por tela

---

## 14. Acessibilidade

- Contraste mínimo: **4.5:1** para texto, **3:1** para UI
- Targets de toque: **44×44pt** mínimo
- VoiceOver / TalkBack: todos os elementos com labels
- Sem animações essenciais: respeitam `prefers-reduced-motion`
- Cores não são o único diferenciador de estados (sempre acompanhadas de ícone ou texto)

---

## 15. Do's and Don'ts

### DO ✅
- Usar bordas 3D em botões principais
- Celebrar cada ação com micro-animação
- Manter linguagem sempre positiva e encorajadora
- Usar cores vibrantes com confiança
- Mostrar progresso constantemente
- Usar personagens para criar conexão emocional
- Feedback imediato em toda ação do usuário

### DON'T ❌
- Nunca usar fontes sem arredondamento (serifas, condensed, thin)
- Nunca envergonhar o usuário por erros
- Nunca esconder o progresso
- Nunca usar cinza sem propósito (UI parece morta)
- Nunca telas sem hierarquia visual clara
- Nunca transições abruptas (sempre animar)
- Nunca mais de 1 CTA primário por tela

---

*Documento compilado em 2026-07-16 para uso como referência de design no projeto Bryco App.*
