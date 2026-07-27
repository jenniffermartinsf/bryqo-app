import Foundation

enum BryqoContent {

    // All units in curriculum order
    static let allUnits: [LearningUnit] = [
        logicaUnit,
        algoritmosUnit,
        bigOUnit,
        recursaoUnit,
        estruturaDadosUnit,
        matematicaDiscretaUnit,
        arquiteturaUnit,
        sistemasOperacionaisUnit,
        internetUnit,
        redesUnit,
        bancosDadosUnit,
        engenhariaUnit
    ]

    // Backwards-compat aliases used in MainTabView / BackpackView
    static let sampleUnit     = internetUnit
    static let sampleCodeUnit = algoritmosUnit

    // MARK: - 1. Lógica de Programação

    static let logicaUnit = LearningUnit(
        id: "logica-programacao",
        title: "Lógica de Programação",
        subtitle: "O jeito de pensar que toda solução precisa.",
        lessons: [
            Lesson(id: "logica-instrucoes", title: "Instruções Precisas",
                   subtitle: "Computadores fazem exatamente o que você disse.", estimatedMinutes: 4, xpReward: 15, materialReward: "Compasso",
                   steps: [
                    story(id: "li-s", title: "O robô do sanduíche",
                          body: "Você pede para um robô fazer um sanduíche. Sem instruções exatas, ele coloca o pão em cima do tomate e chama de sanduíche. Computadores são assim."),
                    concept(id: "li-c", title: "Sem ambiguidade",
                            body: "Um computador executa exatamente o que você escreveu, não o que você quis dizer. Instruções precisam ser ordenadas, completas e sem duplo sentido."),
                    singleChoice(id: "li-e", title: "Identifique a instrução precisa",
                                 prompt: "Qual instrução um computador consegue seguir sem ambiguidade?",
                                 options: [option("a","Adicione sal a gosto"), option("b","Adicione 5 gramas de sal"), option("c","Tempere bem"), option("d","Coloque um pouco")],
                                 correctOptionIds: ["b"],
                                 explanation: "'5 gramas' é exato. As demais são subjetivas e ambíguas para uma máquina."),
                    summary(id: "li-sm", title: "Precisão é tudo",
                            body: "Programar é comunicar instruções sem ambiguidade. Toda ambiguidade vira bug.")
                   ]),

            Lesson(id: "logica-decisoes", title: "Decisões e Condições",
                   subtitle: "Quando o fluxo muda de direção.", estimatedMinutes: 4, xpReward: 15, materialReward: "Bússola",
                   steps: [
                    story(id: "ld-s", title: "Se chover, guarda-chuva",
                          body: "Toda manhã você toma decisões baseadas em condições. O código faz o mesmo com desvios condicionais."),
                    concept(id: "ld-c", title: "Verdadeiro ou Falso",
                            body: "Uma condição é uma pergunta com resposta verdadeira ou falsa. Quando verdadeira, um caminho é seguido; quando falsa, outro. Só um dos dois executa."),
                    trueFalse(id: "ld-e", title: "Verdadeiro ou falso",
                              prompt: "Uma condição sempre produz um resultado verdadeiro ou falso — nunca os dois ao mesmo tempo.",
                              correctAnswer: true,
                              explanation: "Correto. Condições são binárias: verdadeiro XOR falso."),
                    summary(id: "ld-sm", title: "Bifurcação construída",
                            body: "Decisões controlam o fluxo de qualquer algoritmo. São a base da lógica computacional.")
                   ]),

            Lesson(id: "logica-loops", title: "Repetição e Loops",
                   subtitle: "Faça o computador trabalhar por você.", estimatedMinutes: 4, xpReward: 20, materialReward: "Engrenagem",
                   steps: [
                    story(id: "ll-s", title: "1000 vezes em 1 instrução",
                          body: "Imagine precisar escrever 'Olá' mil vezes. Um loop faz isso em uma instrução — o computador é o operário, você é o arquiteto."),
                    concept(id: "ll-c", title: "Iteração",
                            body: "Um loop repete um bloco de instruções enquanto uma condição for verdadeira. Cada repetição se chama iteração. O loop para quando a condição se torna falsa."),
                    singleChoice(id: "ll-e", title: "Quantas iterações?",
                                 prompt: "Um loop começa com x = 0, executa enquanto x < 5 e incrementa x em 1 a cada vez. Quantas vezes o bloco executa?",
                                 options: [option("a","4"), option("b","5"), option("c","6"), option("d","infinito")],
                                 correctOptionIds: ["b"],
                                 explanation: "x passa por 0,1,2,3,4 — cinco valores onde x < 5 é verdadeiro."),
                    variableTrace(id: "ll-vt", title: "Rastreie o loop",
                                  exercise: VariableTraceExercise(
                                    intro: "Execute o código na sua cabeça, linha por linha, e diga o valor de `total` a cada passo.",
                                    codeLines: ["total = 0", "para cada n em [1, 2, 3]:", "    total = total + n"],
                                    language: .generic,
                                    steps: [
                                        VariableTraceStep(highlightedLine: 0, prompt: "Após a linha 1, quanto vale `total`?",
                                                          variable: "total", options: ["0", "1", "6"], correctAnswer: "0",
                                                          explanation: "`total` acabou de ser criado com 0."),
                                        VariableTraceStep(highlightedLine: 2, prompt: "1ª iteração (n = 1): quanto vale `total`?",
                                                          variable: "total", options: ["1", "2", "3"], correctAnswer: "1",
                                                          explanation: "0 + 1 = 1."),
                                        VariableTraceStep(highlightedLine: 2, prompt: "2ª iteração (n = 2): quanto vale `total`?",
                                                          variable: "total", options: ["2", "3", "5"], correctAnswer: "3",
                                                          explanation: "1 + 2 = 3."),
                                        VariableTraceStep(highlightedLine: 2, prompt: "3ª iteração (n = 3): quanto vale `total`?",
                                                          variable: "total", options: ["5", "6", "9"], correctAnswer: "6",
                                                          explanation: "3 + 3 = 6. O loop terminou — a soma é 6.")
                                    ])),
                    summary(id: "ll-sm", title: "Ciclo fechado",
                            body: "Loops eliminam repetição manual. São o motivo de computadores serem mais rápidos que humanos em tarefas repetitivas.")
                   ])
        ]
    )

    // MARK: - 2. Algoritmos

    static let algoritmosUnit = LearningUnit(
        id: "algoritmos",
        title: "Algoritmos",
        subtitle: "Sequências que resolvem problemas de forma sistemática.",
        lessons: [
            Lesson(id: "alg-conceito", title: "O que é um Algoritmo?",
                   subtitle: "A receita antes do código.", estimatedMinutes: 4, xpReward: 20, materialReward: "Planta",
                   steps: [
                    story(id: "ac-s", title: "A receita de bolo",
                          body: "Uma receita de bolo é um algoritmo: tem início, passos ordenados e um resultado esperado. Todo programa é um conjunto de algoritmos."),
                    concept(id: "ac-c", title: "Definição",
                            body: "Um algoritmo é uma sequência finita de passos bem definidos para resolver um problema. Deve ter entrada, saída, ser preciso e terminar."),
                    singleChoice(id: "ac-e", title: "Característica obrigatória",
                                 prompt: "Qual característica NÃO é obrigatória em um algoritmo?",
                                 options: [option("a","Ter um fim"), option("b","Ser executado por um computador"), option("c","Ter passos definidos"), option("d","Produzir um resultado")],
                                 correctOptionIds: ["b"],
                                 explanation: "Algoritmos existem antes do computador — uma receita executada à mão também é um algoritmo."),
                    summary(id: "ac-sm", title: "Algoritmo primeiro",
                            body: "Você cria o algoritmo antes de escrever código. A linguagem é apenas a tradução.")
                   ]),

            Lesson(id: "alg-busca-linear", title: "Busca Linear",
                   subtitle: "A estratégia mais simples de busca.", estimatedMinutes: 4, xpReward: 20, materialReward: "Lupa",
                   steps: [
                    story(id: "abl-s", title: "Chaves perdidas",
                          body: "Você perdeu as chaves. A estratégia mais simples: olhar cada lugar um por um, até encontrar ou confirmar que não estão."),
                    concept(id: "abl-c", title: "Percorrer tudo",
                            body: "Busca linear examina cada elemento da lista em ordem. No melhor caso encontra no primeiro elemento. No pior caso, examina todos os n elementos."),
                    trueFalse(id: "abl-e", title: "Verdadeiro ou falso",
                              prompt: "Na busca linear, o pior caso ocorre quando o elemento procurado é o primeiro da lista.",
                              correctAnswer: false,
                              explanation: "O pior caso é quando o elemento é o último — ou não existe na lista."),
                    summary(id: "abl-sm", title: "Simples mas custoso",
                            body: "Busca linear funciona sempre, mas é lenta em listas grandes. É O(n) — proporcional ao tamanho.")
                   ]),

            Lesson(id: "alg-busca-binaria", title: "Busca Binária",
                   subtitle: "Descarte metade a cada passo.", estimatedMinutes: 5, xpReward: 25, materialReward: "Divisor",
                   steps: [
                    story(id: "abb-s", title: "O dicionário",
                          body: "Ao buscar uma palavra no dicionário, você não lê da página 1. Abre no meio, descarta metade e repete. Isso é busca binária."),
                    concept(id: "abb-c", title: "Divisão e conquista",
                            body: "Busca binária só funciona em listas ordenadas. A cada passo, compara com o elemento do meio e descarta metade. Com 1.000.000 de itens, precisa de no máximo 20 comparações."),
                    ordering(id: "abb-e", title: "Monte a sequência",
                             prompt: "Ordene os passos da busca binária:",
                             options: [option("a","Veja o elemento do meio"), option("b","Compare com o alvo"), option("c","Descarte a metade errada"), option("d","Repita com a metade restante")],
                             correctOptionIds: ["a","b","c","d"],
                             explanation: "Cada passo elimina metade do problema até encontrar ou confirmar ausência."),
                    binarySearch(id: "abb-bs", title: "Busque você mesmo",
                                 exercise: BinarySearchExercise(
                                    intro: "Guie a busca: a cada passo, diga se o alvo é menor, igual ou maior que o meio. Veja metade da lista desaparecer.",
                                    array: [3, 7, 11, 18, 25, 34, 42, 58, 65],
                                    target: 58)),
                    summary(id: "abb-sm", title: "Logarítmica",
                            body: "Busca binária é O(log n) — exponencialmente mais rápida que linear em listas grandes.")
                   ]),

            Lesson(id: "alg-ordenacao", title: "Algoritmos de Ordenação",
                   subtitle: "Transformar caos em estrutura.", estimatedMinutes: 5, xpReward: 25, materialReward: "Sequência",
                   steps: [
                    story(id: "ao-s", title: "Organizando o baralho",
                          body: "Para organizar cartas, você encontra a menor, coloca na frente, e repete com o restante. Isso é Selection Sort — intuitivo mas não o mais eficiente."),
                    concept(id: "ao-c", title: "Trade-offs de ordenação",
                            body: "Bubble Sort é simples mas O(n²). Merge Sort divide e conquista, chegando a O(n log n). Quick Sort é O(n log n) na média. Escolher o algoritmo certo importa em listas grandes."),
                    singleChoice(id: "ao-e", title: "Qual é mais eficiente?",
                                 prompt: "Para ordenar 1 milhão de elementos, qual algoritmo você escolheria?",
                                 options: [option("a","Bubble Sort — O(n²)"), option("b","Selection Sort — O(n²)"), option("c","Merge Sort — O(n log n)"), option("d","Todos são iguais em performance")],
                                 correctOptionIds: ["c"],
                                 explanation: "O(n log n) é dramaticamente melhor que O(n²) em escala. 1M² = 1 trilhão de operações vs ~20M."),
                    summary(id: "ao-sm", title: "Ordem importa",
                            body: "Dados ordenados habilitam busca binária, joins eficientes em BD e muito mais.")
                   ])
        ]
    )

    // MARK: - 3. Big O Notation

    static let bigOUnit = LearningUnit(
        id: "big-o-notation",
        title: "Big O Notation",
        subtitle: "A linguagem para medir e comparar eficiência.",
        lessons: [
            Lesson(id: "bigo-intro", title: "O que é Big O?",
                   subtitle: "Medindo crescimento, não segundos.", estimatedMinutes: 4, xpReward: 20, materialReward: "Medidor",
                   steps: [
                    story(id: "bi-s", title: "Dois algoritmos, mesmo problema",
                          body: "Dois algoritmos resolvem o mesmo problema. Como saber qual é melhor sem executá-los? Big O responde isso."),
                    concept(id: "bi-c", title: "Crescimento da entrada",
                            body: "Big O descreve como o tempo de execução cresce conforme o tamanho da entrada (n) aumenta. Não mede segundos — mede padrão de crescimento. O(1) é constante. O(n) cresce linearmente."),
                    singleChoice(id: "bi-e", title: "Identifique a complexidade",
                                 prompt: "Um algoritmo que visita cada elemento da lista exatamente uma vez tem complexidade:",
                                 options: [option("a","O(1)"), option("b","O(n)"), option("c","O(n²)"), option("d","O(log n)")],
                                 correctOptionIds: ["b"],
                                 explanation: "Visitar cada um dos n elementos = O(n). O tempo cresce proporcionalmente ao tamanho."),
                    summary(id: "bi-sm", title: "Linguagem universal",
                            body: "Big O é como devs comunicam eficiência. É independente de hardware ou linguagem.")
                   ]),

            Lesson(id: "bigo-eficiente", title: "O(1) e O(log n)",
                   subtitle: "As complexidades mais desejáveis.", estimatedMinutes: 4, xpReward: 20, materialReward: "Raio",
                   steps: [
                    story(id: "be-s", title: "Gaveta numerada",
                          body: "Acessar uma gaveta pelo número é O(1) — não importa quantas gavetas existam. Busca binária é O(log n) — dobrar a entrada adiciona apenas 1 passo."),
                    concept(id: "be-c", title: "Crescimento lento",
                            body: "O(1) é constante: a entrada não afeta o tempo. O(log n) cresce tão devagar que com 1 bilhão de itens faz apenas ~30 operações. São as complexidades mais desejáveis."),
                    trueFalse(id: "be-e", title: "Verdadeiro ou falso",
                              prompt: "Um algoritmo O(log n) com 1.000.000 de entradas precisa de aproximadamente 20 passos.",
                              correctAnswer: true,
                              explanation: "log₂(1.000.000) ≈ 20. É por isso que busca binária é tão poderosa."),
                    summary(id: "be-sm", title: "Escala ideal",
                            body: "O(1) e O(log n) funcionam bem mesmo com bilhões de entradas.")
                   ]),

            Lesson(id: "bigo-ruim", title: "O(n²) e O(2ⁿ)",
                   subtitle: "Quando o crescimento se torna problema.", estimatedMinutes: 5, xpReward: 25, materialReward: "Gráfico",
                   steps: [
                    story(id: "br-s", title: "Pares em uma festa",
                          body: "Com 10 pessoas, são 100 possíveis cumprimentos. Com 1000, são 1 milhão. O número de pares cresce ao quadrado."),
                    concept(id: "br-c", title: "Quadrático e Exponencial",
                            body: "O(n²) surge em loops aninhados — funciona para n pequeno, trava para n grande. O(2ⁿ) dobra a cada incremento — torna-se impraticável rapidamente. Evite ambos em problemas de escala."),
                    ordering(id: "br-e", title: "Ordene do mais ao menos eficiente",
                             prompt: "Organize as complexidades do mais eficiente ao menos eficiente:",
                             options: [option("a","O(1)"), option("b","O(log n)"), option("c","O(n)"), option("d","O(n²)")],
                             correctOptionIds: ["a","b","c","d"],
                             explanation: "Constante → Logarítmica → Linear → Quadrática. Cada nível é drasticamente pior em escala."),
                    summary(id: "br-sm", title: "Big O na prática",
                            body: "Código que funciona no dev com 100 itens pode travar em produção com 1 milhão. Big O prevê isso.")
                   ])
        ]
    )

    // MARK: - 4. Recursão

    static let recursaoUnit = LearningUnit(
        id: "recursao",
        title: "Recursão",
        subtitle: "Resolver o grande resolvendo o pequeno.",
        lessons: [
            Lesson(id: "rec-conceito", title: "Uma Função que se Chama",
                   subtitle: "O problema dentro do problema.", estimatedMinutes: 4, xpReward: 20, materialReward: "Espelho",
                   steps: [
                    story(id: "rc-s", title: "Fatorial de 5",
                          body: "Para calcular 5!, você precisa de 4!. Para 4!, precisa de 3!. E assim até 1! = 1. A solução do grande depende da solução do menor."),
                    concept(id: "rc-c", title: "Auto-referência controlada",
                            body: "Recursão é quando uma função se chama dentro de si mesma com uma entrada menor. Cada chamada reduz o problema até chegar ao caso base, que retorna diretamente."),
                    trueFalse(id: "rc-e", title: "Verdadeiro ou falso",
                              prompt: "Uma função recursiva sem caso base executa para sempre (ou até estourar a memória).",
                              correctAnswer: true,
                              explanation: "Sem caso base, a função nunca para de se chamar — causando stack overflow."),
                    summary(id: "rc-sm", title: "Quebrar para conquistar",
                            body: "Recursão transforma problemas grandes em versões menores do mesmo problema.")
                   ]),

            Lesson(id: "rec-caso-base", title: "Caso Base e Caso Recursivo",
                   subtitle: "A condição de parada é tudo.", estimatedMinutes: 4, xpReward: 20, materialReward: "Âncora",
                   steps: [
                    story(id: "rcb-s", title: "A menor matrioska",
                          body: "Bonecas russas: cada uma abre e tem outra dentro — até chegar na menor, que não abre mais. Essa é o caso base."),
                    concept(id: "rcb-c", title: "Dois casos obrigatórios",
                            body: "Caso base: condição de parada — retorna um valor diretamente sem nova chamada. Caso recursivo: reduz o problema e se chama novamente. Sem caso base, recursão infinita. Sem caso recursivo, apenas uma chamada."),
                    singleChoice(id: "rcb-e", title: "Identifique o caso base",
                                 prompt: "Numa função que calcula fatorial(n), qual é o caso base?",
                                 options: [option("a","n > 1"), option("b","n * fatorial(n-1)"), option("c","n = 0 ou n = 1, retorna 1"), option("d","fatorial(n-1)")],
                                 correctOptionIds: ["c"],
                                 explanation: "fatorial(0) = fatorial(1) = 1. São os valores que param a recursão."),
                    summary(id: "rcb-sm", title: "Sem base, sem fim",
                            body: "O caso base é a fundação. Sem ele: stack overflow. Com ele: elegância.")
                   ]),

            Lesson(id: "rec-uso", title: "Quando Usar Recursão",
                   subtitle: "Hierarquia pede recursão.", estimatedMinutes: 5, xpReward: 25, materialReward: "Árvore",
                   steps: [
                    story(id: "ru-s", title: "Pasta dentro de pasta",
                          body: "Percorrer todos os arquivos de um computador — pastas dentro de pastas indefinidamente — com um loop iterativo seria complexo. Com recursão, são 5 linhas."),
                    concept(id: "ru-c", title: "Casos ideais",
                            body: "Recursão brilha em estruturas hierárquicas (árvores, grafos) e divisão-e-conquista. Para listas simples, loops iterativos são mais eficientes por não acumular chamadas na stack de memória."),
                    singleChoice(id: "ru-e", title: "Qual se beneficia mais?",
                                 prompt: "Qual problema se beneficia MAIS de recursão?",
                                 options: [option("a","Somar 100 números em uma lista"), option("b","Percorrer todos os arquivos de uma pasta e suas subpastas"), option("c","Buscar o maior número em um array"), option("d","Imprimir números de 1 a 10")],
                                 correctOptionIds: ["b"],
                                 explanation: "Estruturas hierárquicas são naturalmente recursivas. Loops iterativos precisariam de uma pilha manual."),
                    summary(id: "ru-sm", title: "Ferramenta certa",
                            body: "Use recursão quando o problema é naturalmente hierárquico ou se divide em versões menores de si mesmo.")
                   ])
        ]
    )

    // MARK: - 5. Estrutura de Dados

    static let estruturaDadosUnit = LearningUnit(
        id: "estrutura-de-dados",
        title: "Estrutura de Dados",
        subtitle: "Como organizamos informação determina o que conseguimos fazer com ela.",
        lessons: [
            Lesson(id: "ed-arrays", title: "Arrays e Listas",
                   subtitle: "Memória contígua e acesso por índice.", estimatedMinutes: 4, xpReward: 20, materialReward: "Grade",
                   steps: [
                    story(id: "ea-s", title: "Cadeiras numeradas",
                          body: "10 cadeiras numeradas em fila. Você sabe exatamente onde está a cadeira 7 sem precisar procurar. Arrays funcionam assim."),
                    concept(id: "ea-c", title: "Índice direto",
                            body: "Um array armazena elementos em posições consecutivas de memória. Acesso por índice é O(1) — instantâneo. Inserir ou remover do meio exige mover elementos: O(n)."),
                    singleChoice(id: "ea-e", title: "Qual operação é O(1)?",
                                 prompt: "Qual operação em um array tem tempo constante O(1)?",
                                 options: [option("a","Buscar um valor sem saber o índice"), option("b","Acessar um elemento pelo índice"), option("c","Inserir no meio"), option("d","Remover do início")],
                                 correctOptionIds: ["b"],
                                 explanation: "O índice é o endereço direto na memória. Sem busca — acesso imediato."),
                    summary(id: "ea-sm", title: "Velocidade com limitações",
                            body: "Arrays trocam flexibilidade por velocidade de acesso. Perfeitos quando o tamanho e os índices são conhecidos.")
                   ]),

            Lesson(id: "ed-pilha-fila", title: "Pilhas e Filas",
                   subtitle: "LIFO e FIFO — a ordem de acesso muda tudo.", estimatedMinutes: 4, xpReward: 20, materialReward: "Pilha",
                   steps: [
                    story(id: "epf-s", title: "Pratos e banco",
                          body: "Pilha de pratos: o último colocado é o primeiro retirado (LIFO). Fila de banco: o primeiro que chegou é o primeiro atendido (FIFO)."),
                    concept(id: "epf-c", title: "LIFO vs FIFO",
                            body: "Stack (pilha) segue LIFO: Last In, First Out — usado em recursão, histórico de ações, desfazer. Queue (fila) segue FIFO: First In, First Out — usado em filas de impressão, mensagens assíncronas."),
                    trueFalse(id: "epf-e", title: "Verdadeiro ou falso",
                              prompt: "Em uma pilha (Stack), o primeiro elemento inserido é o primeiro a ser removido.",
                              correctAnswer: false,
                              explanation: "Pilha é LIFO: o ÚLTIMO a entrar é o PRIMEIRO a sair. Pense em pratos empilhados."),
                    summary(id: "epf-sm", title: "Ordem define uso",
                            body: "Pilhas controlam execução e histórico. Filas controlam processamento em ordem.")
                   ]),

            Lesson(id: "ed-hash", title: "Hash Tables",
                   subtitle: "Busca em tempo constante.", estimatedMinutes: 5, xpReward: 25, materialReward: "Chave",
                   steps: [
                    story(id: "eh-s", title: "Agenda telefônica",
                          body: "Para achar o número da Ana, você vai direto ao 'A' — sem varrer toda a lista. Hash tables fazem isso com código."),
                    concept(id: "eh-c", title: "Chave → Posição",
                            body: "Uma hash table usa uma função de hash para mapear chaves a posições de memória. Busca, inserção e remoção são O(1) na média. Dicionários em Python, objetos em JS e Maps em Java são hash tables."),
                    singleChoice(id: "eh-e", title: "Melhor estrutura para busca por chave",
                                 prompt: "Qual estrutura é mais eficiente para buscar um usuário pelo email (chave única)?",
                                 options: [option("a","Array — percorre todos"), option("b","Lista encadeada — O(n)"), option("c","Hash Table — O(1)"), option("d","Pilha — LIFO")],
                                 correctOptionIds: ["c"],
                                 explanation: "Hash table mapeia o email diretamente a uma posição. Sem varrer — acesso quase instantâneo."),
                    summary(id: "eh-sm", title: "Espaço por velocidade",
                            body: "Hash tables trocam memória por velocidade. São uma das estruturas mais usadas no mundo real.")
                   ]),

            Lesson(id: "ed-arvores", title: "Árvores",
                   subtitle: "Hierarquia que permite busca eficiente.", estimatedMinutes: 5, xpReward: 25, materialReward: "Galho",
                   steps: [
                    story(id: "ear-s", title: "Sistema de arquivos",
                          body: "Uma pasta raiz com subpastas dentro de subpastas. Isso é uma árvore — a estrutura de dados por trás do sistema de arquivos do seu computador."),
                    concept(id: "ear-c", title: "Nós e filhos",
                            body: "Uma árvore tem um nó raiz e nós filhos. Em uma Árvore Binária de Busca (BST), o filho esquerdo é sempre menor e o direito maior. Busca, inserção e remoção são O(log n) em árvores balanceadas."),
                    trueFalse(id: "ear-e", title: "Verdadeiro ou falso",
                              prompt: "Em uma Árvore Binária de Busca balanceada, todos os valores à esquerda de um nó são menores que ele.",
                              correctAnswer: true,
                              explanation: "Essa é a propriedade fundamental da BST — o que permite descarte de metade a cada passo, igual à busca binária."),
                    summary(id: "ear-sm", title: "Hierarquia eficiente",
                            body: "Árvores organizam dados hierarquicamente. Bancos de dados usam B-trees (variação) para índices.")
                   ])
        ]
    )

    // MARK: - 6. Matemática Discreta

    static let matematicaDiscretaUnit = LearningUnit(
        id: "matematica-discreta",
        title: "Matemática Discreta",
        subtitle: "A matemática da computação: conjuntos, lógica e grafos.",
        lessons: [
            Lesson(id: "md-logica-bool", title: "Lógica Booleana",
                   subtitle: "A linguagem do hardware.", estimatedMinutes: 4, xpReward: 20, materialReward: "Circuito",
                   steps: [
                    story(id: "mlb-s", title: "O chip que decide",
                          body: "Todo transistor do seu processador executa operações booleanas bilhões de vezes por segundo. AND, OR, NOT são a linguagem do silício."),
                    concept(id: "mlb-c", title: "AND, OR, NOT",
                            body: "AND: ambos verdadeiros → verdadeiro. OR: basta um verdadeiro → verdadeiro. NOT: inverte. Todo if/else em código é lógica booleana. Tabelas verdade descrevem todas as combinações possíveis."),
                    singleChoice(id: "mlb-e", title: "Resultado da operação",
                                 prompt: "true AND false resulta em:",
                                 options: [option("a","true"), option("b","false"), option("c","null"), option("d","depende da linguagem")],
                                 correctOptionIds: ["b"],
                                 explanation: "AND exige que ambos sejam verdadeiros. Como false está presente, o resultado é false."),
                    summary(id: "mlb-sm", title: "Fundação do hardware",
                            body: "Toda decisão em código se reduz a operações booleanas no nível do hardware.")
                   ]),

            Lesson(id: "md-conjuntos", title: "Conjuntos",
                   subtitle: "A base do modelo relacional.", estimatedMinutes: 4, xpReward: 20, materialReward: "Diagrama",
                   steps: [
                    story(id: "mc-s", title: "SQL é teoria dos conjuntos",
                          body: "UNION (união), INTERSECT (interseção), EXCEPT (diferença) — operações SQL são direto da teoria dos conjuntos. Entender conjuntos é entender bancos de dados."),
                    concept(id: "mc-c", title: "União, Interseção, Diferença",
                            body: "Um conjunto é uma coleção sem repetição. União: todos os elementos de ambos. Interseção: apenas os comuns. Diferença: elementos do primeiro que não estão no segundo."),
                    trueFalse(id: "mc-e", title: "Verdadeiro ou falso",
                              prompt: "A interseção de {1, 2, 3} e {2, 3, 4} é {2, 3}.",
                              correctAnswer: true,
                              explanation: "Interseção são os elementos presentes em AMBOS os conjuntos. 2 e 3 estão nos dois."),
                    summary(id: "mc-sm", title: "Conjuntos em todo lugar",
                            body: "Conjuntos são a base de SQL, álgebra relacional e teoria dos grafos.")
                   ]),

            Lesson(id: "md-grafos", title: "Grafos",
                   subtitle: "Modelando relacionamentos do mundo real.", estimatedMinutes: 5, xpReward: 25, materialReward: "Rede",
                   steps: [
                    story(id: "mg-s", title: "Amizades, rotas, dependências",
                          body: "Amigos no LinkedIn, rotas de GPS, dependências de pacotes npm, páginas linkadas na web — todos são grafos. São a estrutura mais universal da computação."),
                    concept(id: "mg-c", title: "Vértices e Arestas",
                            body: "Um grafo tem vértices (nós) e arestas (conexões). Dirigido: conexão tem sentido (A → B). Não-dirigido: bidirecional. Árvores são um tipo especial de grafo acíclico e conectado."),
                    singleChoice(id: "mg-e", title: "Tipo de grafo",
                                 prompt: "Uma rede social onde A segue B mas B não segue A é um grafo:",
                                 options: [option("a","Não dirigido"), option("b","Dirigido"), option("c","Árvore"), option("d","Acíclico")],
                                 correctOptionIds: ["b"],
                                 explanation: "A relação de 'seguir' tem direção. A → B não implica B → A. Isso é um grafo dirigido."),
                    summary(id: "mg-sm", title: "Grafos modelam tudo",
                            body: "Grafos modelam qualquer relação entre entidades. BFS e DFS são os algoritmos para percorrê-los.")
                   ])
        ]
    )

    // MARK: - 7. Arquitetura de Computadores

    static let arquiteturaUnit = LearningUnit(
        id: "arquitetura-computadores",
        title: "Arquitetura de Computadores",
        subtitle: "Como a máquina pensa e executa.",
        lessons: [
            Lesson(id: "arq-cpu", title: "CPU e Memória",
                   subtitle: "O processador e onde os dados vivem.", estimatedMinutes: 4, xpReward: 20, materialReward: "Chip",
                   steps: [
                    story(id: "ac-s2", title: "A bancada de trabalho",
                          body: "A CPU é o trabalhador. A RAM é a bancada — rápida mas temporária. O disco é o armário — lento mas permanente. A eficiência depende de mover coisas da forma certa entre eles."),
                    concept(id: "ac-c2", title: "Hierarquia de memória",
                            body: "Registradores (ns) → Cache L1/L2 (ns) → RAM (µs) → SSD (ms) → HD (ms). Quanto mais longe da CPU, mais lento e maior. Programas eficientes mantêm dados quentes próximos da CPU."),
                    ordering(id: "ac-e2", title: "Ordene da mais rápida à mais lenta",
                             prompt: "Organize as memórias da mais rápida à mais lenta:",
                             options: [option("a","Registradores da CPU"), option("b","Cache L1"), option("c","RAM"), option("d","SSD")],
                             correctOptionIds: ["a","b","c","d"],
                             explanation: "Registradores são parte da CPU — nanossegundos. SSD acessa em milissegundos. A diferença é de milhões de vezes."),
                    summary(id: "ac-sm2", title: "Localidade importa",
                            body: "Cache hits vs misses explicam por que o mesmo algoritmo pode ser 10x mais lento dependendo do acesso à memória.")
                   ]),

            Lesson(id: "arq-bits", title: "Bits e Bytes",
                   subtitle: "Tudo é 0 e 1.", estimatedMinutes: 4, xpReward: 20, materialReward: "Binário",
                   steps: [
                    story(id: "ab-s", title: "Texto, imagem, código — tudo igual",
                          body: "Uma foto, um texto e um executável são todos armazenados como 0s e 1s. O que muda é como esses bits são interpretados."),
                    concept(id: "ab-c", title: "Unidades e representação",
                            body: "1 bit é 0 ou 1. 8 bits = 1 byte = 256 valores possíveis (2⁸). Texto usa Unicode (UTF-8). Números inteiros usam complemento de dois. Cores RGB usam 3 bytes. Entender isso explica limites de tipos e overflow."),
                    trueFalse(id: "ab-e", title: "Verdadeiro ou falso",
                              prompt: "Um byte pode representar exatamente 256 valores diferentes.",
                              correctAnswer: true,
                              explanation: "2⁸ = 256. Por isso inteiros de 8 bits vão de 0 a 255 (sem sinal) ou -128 a 127 (com sinal)."),
                    summary(id: "ab-sm", title: "A linguagem da máquina",
                            body: "Entender bits e bytes explica overflow, formatos de arquivo e limites de tipos em qualquer linguagem.")
                   ]),

            Lesson(id: "arq-execucao", title: "Como um Programa Executa",
                   subtitle: "Do código à instrução de máquina.", estimatedMinutes: 5, xpReward: 25, materialReward: "Processador",
                   steps: [
                    story(id: "ape-s", title: "O caminho do código",
                          body: "Você escreve código em alto nível. Mas a CPU só entende 0s e 1s. O que acontece no meio?"),
                    concept(id: "ape-c", title: "Compilação e execução",
                            body: "Código fonte → Compilador/Interpretador → Código de máquina → CPU executa. O SO carrega o programa na RAM. A CPU aplica o ciclo: Fetch (busca) → Decode (decodifica) → Execute (executa) para cada instrução."),
                    singleChoice(id: "ape-e", title: "O que um compilador faz?",
                                 prompt: "A função principal de um compilador é:",
                                 options: [option("a","Executar o código diretamente"), option("b","Traduzir código fonte para código de máquina"), option("c","Verificar erros de lógica"), option("d","Gerenciar a memória em tempo de execução")],
                                 correctOptionIds: ["b"],
                                 explanation: "Compilador traduz. Não executa nem detecta bugs lógicos — apenas transforma a representação."),
                    summary(id: "ape-sm", title: "Abstração em camadas",
                            body: "Entender o caminho do código à CPU explica performance, erros de segmentação e comportamento inesperado.")
                   ])
        ]
    )

    // MARK: - 8. Sistemas Operacionais

    static let sistemasOperacionaisUnit = LearningUnit(
        id: "sistemas-operacionais",
        title: "Sistemas Operacionais",
        subtitle: "O maestro que orquestra hardware e software.",
        lessons: [
            Lesson(id: "so-intro", title: "O que é um SO?",
                   subtitle: "O intermediário entre código e hardware.", estimatedMinutes: 4, xpReward: 20, materialReward: "Chave-inglesa",
                   steps: [
                    story(id: "si-s", title: "O governo do computador",
                          body: "Sem o SO, cada app precisaria saber acessar disco, gerenciar rede e controlar memória diretamente. O SO abstrai o hardware e distribui recursos com regras."),
                    concept(id: "si-c", title: "Abstração e gerenciamento",
                            body: "O SO gerencia processos, memória, sistema de arquivos e dispositivos. Expõe APIs (chamadas de sistema) para que apps não acessem hardware diretamente. Linux, macOS e Windows fazem isso de formas diferentes mas com objetivos similares."),
                    trueFalse(id: "si-e", title: "Verdadeiro ou falso",
                              prompt: "O sistema operacional permite que múltiplos programas compartilhem o hardware sem conflito.",
                              correctAnswer: true,
                              explanation: "Isso é exatamente o papel do SO — arbitrar o acesso ao hardware entre múltiplos processos."),
                    summary(id: "si-sm", title: "Fundação invisível",
                            body: "Todo app que você usa roda sobre um SO. Entendê-lo explica performance, segurança e comportamento de sistemas.")
                   ]),

            Lesson(id: "so-processos", title: "Processos e Threads",
                   subtitle: "Paralelismo e isolamento.", estimatedMinutes: 5, xpReward: 25, materialReward: "Paralelismo",
                   steps: [
                    story(id: "sp-s", title: "Música, download e browser ao mesmo tempo",
                          body: "Você ouve música, baixa um arquivo e navega simultaneamente. Cada um é gerenciado pelo SO como processo ou thread."),
                    concept(id: "sp-c", title: "Processo vs Thread",
                            body: "Processo: programa em execução com memória própria e isolada. Thread: unidade de execução dentro de um processo, compartilhando memória. Threads são mais eficientes mas exigem sincronização para evitar condições de corrida."),
                    singleChoice(id: "sp-e", title: "A diferença principal",
                                 prompt: "A principal diferença entre processo e thread é:",
                                 options: [option("a","Processos são sempre mais rápidos"), option("b","Threads dentro de um processo compartilham memória"), option("c","Threads têm memória própria e isolada"), option("d","Processos não podem ser pausados pelo SO")],
                                 correctOptionIds: ["b"],
                                 explanation: "Threads compartilham o espaço de memória do processo pai — mais eficiente mas exige cuidado com acesso concorrente."),
                    summary(id: "sp-sm", title: "Threads para performance",
                            body: "Threads permitem paralelismo dentro de um programa. Processos garantem isolamento entre programas.")
                   ]),

            Lesson(id: "so-memoria", title: "Gerenciamento de Memória",
                   subtitle: "Stack, Heap e o que pode dar errado.", estimatedMinutes: 5, xpReward: 25, materialReward: "Memória",
                   steps: [
                    story(id: "sm-s", title: "Quem controla a memória?",
                          body: "Se cada app pedisse memória sem limite, o sistema travaria em minutos. O SO é o árbitro — define o que cada processo pode usar."),
                    concept(id: "sm-c", title: "Stack e Heap",
                            body: "Stack: variáveis locais e chamadas de função — rápida, tamanho limitado, gerenciada automaticamente. Heap: alocação dinâmica — maior, mais flexível, requer gerenciamento. Linguagens modernas usam garbage collection na heap."),
                    trueFalse(id: "sm-e", title: "Verdadeiro ou falso",
                              prompt: "Stack overflow ocorre quando a pilha de chamadas de função excede o limite de memória disponível.",
                              correctAnswer: true,
                              explanation: "Recursão infinita ou funções muito profundas enchhem a stack até estourar — daí o nome 'stack overflow'."),
                    summary(id: "sm-sm", title: "Memória é recurso finito",
                            body: "Entender stack e heap explica memory leaks, crashes e por que recursão sem fim mata programas.")
                   ])
        ]
    )

    // MARK: - 9. Como a Internet Funciona (existing unit, kept intact)

    static let internetUnit = LearningUnit(
        id: "internet-page-delivery",
        title: "Como a Internet Funciona",
        subtitle: "Do clique ao conteúdo — o caminho invisível.",
        lessons: [
            Lesson(id: "client-server", title: "Cliente e Servidor",
                   subtitle: "Quem pede e quem responde.", estimatedMinutes: 4, xpReward: 20, materialReward: "Madeira",
                   steps: [
                    story(id: "client-server-story", title: "Voce toca em Entrar",
                          body: "O app precisa buscar seus dados. Ele faz um pedido para outro computador preparado para responder."),
                    concept(id: "client-server-concept", title: "Dois papeis",
                            body: "Cliente e quem inicia o pedido. Servidor e quem recebe, processa e devolve uma resposta."),
                    singleChoice(id: "client-server-exercise", title: "Identifique o papel",
                                 prompt: "Quando o navegador pede uma pagina, qual papel ele exerce?",
                                 options: [option("a","Cliente"), option("b","Servidor"), option("c","Banco de dados")],
                                 correctOptionIds: ["a"],
                                 explanation: "O navegador inicia a requisicao, entao atua como cliente."),
                    summary(id: "client-server-summary", title: "Bloco colocado",
                            body: "Cliente pede. Servidor responde. Esse par aparece em apps, sites e APIs.")
                   ]),

            Lesson(id: "ip-address", title: "Endereco IP",
                   subtitle: "Como encontrar um dispositivo na rede.", estimatedMinutes: 4, xpReward: 20, materialReward: "Pedra",
                   steps: [
                    story(id: "ip-story", title: "A ponte precisa de destino",
                          body: "Antes de enviar uma mensagem, a rede precisa saber para onde ela deve ir."),
                    concept(id: "ip-concept", title: "Um endereco na rede",
                            body: "Um endereco IP identifica um dispositivo ou ponto de rede para que pacotes encontrem o caminho correto."),
                    trueFalse(id: "ip-exercise", title: "Verdadeiro ou falso",
                              prompt: "Um endereco IP ajuda a rede a encaminhar dados ate um destino.",
                              correctAnswer: true,
                              explanation: "Sim. O IP funciona como uma referencia de destino para os pacotes."),
                    summary(id: "ip-summary", title: "Destino definido",
                            body: "Sem endereco, a rede nao sabe para onde levar os pacotes.")
                   ]),

            Lesson(id: "dns", title: "DNS",
                   subtitle: "Como nomes viram enderecos.", estimatedMinutes: 5, xpReward: 25, materialReward: "Galhos",
                   steps: [
                    story(id: "dns-story", title: "Voce lembra nomes, a rede usa numeros",
                          body: "E mais facil digitar um dominio do que memorizar um endereco numerico."),
                    concept(id: "dns-concept", title: "A agenda da internet",
                            body: "DNS traduz nomes de dominio, como exemplo.com, para enderecos que a rede consegue usar."),
                    ordering(id: "dns-exercise", title: "Monte a sequencia",
                             prompt: "Ordene o que acontece quando voce acessa um dominio.",
                             options: [option("type","Voce digita o dominio"), option("ask","O sistema consulta o DNS"), option("ip","O DNS retorna um endereco IP"), option("connect","O cliente usa o IP para se conectar")],
                             correctOptionIds: ["type","ask","ip","connect"],
                             explanation: "Primeiro vem o nome, depois a consulta, o endereco e a conexao."),
                    summary(id: "dns-summary", title: "Nome encontrado",
                            body: "DNS conecta nomes amigaveis aos enderecos usados pela rede.")
                   ]),

            Lesson(id: "request-response", title: "Requisicao e Resposta",
                   subtitle: "O ciclo basico da web.", estimatedMinutes: 5, xpReward: 25, materialReward: "Blocos",
                   steps: [
                    story(id: "request-response-story", title: "Um pedido atravessa o rio",
                          body: "O cliente envia uma requisicao. O servidor avalia o pedido e devolve uma resposta."),
                    concept(id: "request-response-concept", title: "Causa e efeito",
                            body: "A requisicao descreve o que o cliente quer. A resposta carrega o resultado, como uma pagina, dados ou erro."),
                    singleChoice(id: "request-response-exercise", title: "Escolha a melhor explicacao",
                                 prompt: "Qual frase descreve melhor uma resposta?",
                                 options: [option("a","Um pedido iniciado pelo cliente"), option("b","O retorno enviado pelo servidor"), option("c","O nome publico de um site")],
                                 correctOptionIds: ["b"],
                                 explanation: "A resposta e o retorno do servidor para uma requisicao."),
                    summary(id: "request-response-summary", title: "Fluxo completo",
                            body: "A web funciona por muitos ciclos de pedido e retorno.")
                   ]),

            Lesson(id: "http-https", title: "HTTP e HTTPS",
                   subtitle: "As regras da conversa na web.", estimatedMinutes: 5, xpReward: 30, materialReward: "Cadeado",
                   steps: [
                    story(id: "http-story", title: "A conversa precisa de regras",
                          body: "Cliente e servidor precisam combinar o formato do pedido e da resposta."),
                    concept(id: "http-concept", title: "Protocolo da web",
                            body: "HTTP define como mensagens da web sao estruturadas. HTTPS usa protecao criptografada nessa comunicacao."),
                    trueFalse(id: "http-exercise", title: "Seguranca",
                              prompt: "HTTPS e uma versao protegida da comunicacao HTTP.",
                              correctAnswer: true,
                              explanation: "HTTPS adiciona uma camada de protecao para reduzir exposicao e adulteracao dos dados em transito."),
                    summary(id: "http-summary", title: "Barragem reforcada",
                            body: "HTTP organiza a conversa. HTTPS protege essa conversa durante o caminho.")
                   ])
        ]
    )

    // MARK: - 10. Redes e Internet (aprofundamento)

    static let redesUnit = LearningUnit(
        id: "redes-internet",
        title: "Redes e Internet",
        subtitle: "Protocolos, modelos e segurança da comunicação em rede.",
        lessons: [
            Lesson(id: "redes-modelos", title: "Modelos de Rede",
                   subtitle: "Camadas que separam responsabilidades.", estimatedMinutes: 5, xpReward: 25, materialReward: "Camadas",
                   steps: [
                    story(id: "rm-s", title: "Uma carta em muitas mãos",
                          body: "Uma carta passa por mãos diferentes até chegar ao destino — cada uma com uma responsabilidade específica. Redes funcionam em camadas pelo mesmo motivo."),
                    concept(id: "rm-c", title: "TCP/IP em 4 camadas",
                            body: "Aplicação (HTTP, SMTP, DNS) → Transporte (TCP, UDP) → Rede (IP, roteamento) → Enlace (Ethernet, Wi-Fi). Cada camada encapsula a de baixo. HTTP não precisa saber como bits são transmitidos fisicamente."),
                    ordering(id: "rm-e", title: "Ordene as camadas",
                             prompt: "Ordene as camadas TCP/IP da mais alta (aplicação) à mais baixa (física):",
                             options: [option("a","Aplicação"), option("b","Transporte"), option("c","Rede"), option("d","Enlace")],
                             correctOptionIds: ["a","b","c","d"],
                             explanation: "Cada camada adiciona um cabeçalho (encapsulamento) ao pacote antes de passar para a camada abaixo."),
                    summary(id: "rm-sm", title: "Separação de responsabilidades",
                            body: "Camadas permitem que HTTP evolua sem mudar Ethernet, e que Wi-Fi substitua cabo sem mudar TCP.")
                   ]),

            Lesson(id: "redes-tcp-udp", title: "TCP vs UDP",
                   subtitle: "Confiabilidade ou velocidade — escolha sua batalha.", estimatedMinutes: 5, xpReward: 25, materialReward: "Protocolo",
                   steps: [
                    story(id: "rtu-s", title: "Email vs videochamada",
                          body: "Email precisa chegar completo e em ordem — cada byte importa. Videochamada prefere velocidade a perfeição — perder 1 frame é ok."),
                    concept(id: "rtu-c", title: "Garantia vs velocidade",
                            body: "TCP: cria conexão, confirma cada pacote, reordena se necessário, retransmite perdas. Confiável mas com overhead. UDP: dispara pacotes sem confirmação. Mais rápido, sem garantias. HTTP/SSH usam TCP. Streaming e games preferem UDP."),
                    singleChoice(id: "rtu-e", title: "Protocolo ideal",
                                 prompt: "Um jogo online em tempo real onde latência importa mais que perfeição deveria usar:",
                                 options: [option("a","TCP — garante que tudo chegue em ordem"), option("b","UDP — prioriza velocidade, tolera perdas"), option("c","HTTP — protocolo da web"), option("d","DNS — resolve nomes")],
                                 correctOptionIds: ["b"],
                                 explanation: "Em jogos, um pacote atrasado é pior que um pacote perdido. UDP elimina o overhead do TCP."),
                    summary(id: "rtu-sm", title: "Escolha informada",
                            body: "TCP é correio registrado. UDP é panfleto. A escolha depende do que o sistema prioriza.")
                   ]),

            Lesson(id: "redes-seguranca", title: "Segurança: TLS e Criptografia",
                   subtitle: "Por que o cadeado no browser importa.", estimatedMinutes: 5, xpReward: 30, materialReward: "Criptografia",
                   steps: [
                    story(id: "rs-s", title: "Senha em texto puro",
                          body: "Sem criptografia, qualquer roteador entre você e o servidor leria sua senha como texto puro. Com TLS, apenas o destino consegue decifrar."),
                    concept(id: "rs-c", title: "Criptografia assimétrica",
                            body: "TLS usa par de chaves: pública (qualquer um pode usar para criptografar) e privada (só o servidor decifra). HTTPS = HTTP + TLS. O cadeado no browser confirma que a conexão é criptografada e autenticada."),
                    trueFalse(id: "rs-e", title: "Verdadeiro ou falso",
                              prompt: "TLS garante que apenas o servidor destino correto consegue decifrar os dados transmitidos.",
                              correctAnswer: true,
                              explanation: "A chave privada fica apenas no servidor. Sem ela, os dados interceptados são ilegíveis."),
                    summary(id: "rs-sm", title: "HTTPS é obrigatório",
                            body: "Criptografia assimétrica resolve o problema de combinar uma chave secreta em um canal público — a base de toda segurança web.")
                   ])
        ]
    )

    // MARK: - 11. Bancos de Dados

    static let bancosDadosUnit = LearningUnit(
        id: "bancos-de-dados",
        title: "Bancos de Dados",
        subtitle: "Armazenamento, consulta e relacionamentos de dados persistentes.",
        lessons: [
            Lesson(id: "bd-intro", title: "Por que Banco de Dados?",
                   subtitle: "Além de arquivos e planilhas.", estimatedMinutes: 4, xpReward: 20, materialReward: "Tabela",
                   steps: [
                    story(id: "bdi-s", title: "A planilha que não escala",
                          body: "Uma planilha com 1 milhão de clientes e 50 milhões de pedidos. Como buscar todos os pedidos de SP feitos em março? Banco de dados resolve isso."),
                    concept(id: "bdi-c", title: "SQL e NoSQL",
                            body: "SQL (relacional): dados em tabelas com esquema fixo e relacionamentos. Ideal para consistência. NoSQL: flexível para dados não estruturados, escala horizontal. MongoDB, Redis, Cassandra são NoSQL. Escolha depende do problema."),
                    singleChoice(id: "bdi-e", title: "Vantagem do SQL",
                                 prompt: "Qual é a principal vantagem de um banco SQL sobre armazenar dados em arquivos?",
                                 options: [option("a","Ocupa menos espaço em disco"), option("b","Permite consultas complexas e relacionamentos eficientes"), option("c","É mais rápido para leitura sequencial de todos os dados"), option("d","Não precisa de servidor")],
                                 correctOptionIds: ["b"],
                                 explanation: "SQL foi projetado para consultas ad-hoc complexas com JOINs, filtros e agregações que seriam impraticáveis com arquivos."),
                    summary(id: "bdi-sm", title: "Dados como sistema",
                            body: "Bancos de dados transformam dados brutos em informação consultável, consistente e confiável.")
                   ]),

            Lesson(id: "bd-tabelas", title: "Tabelas e Chaves",
                   subtitle: "A estrutura do modelo relacional.", estimatedMinutes: 5, xpReward: 25, materialReward: "Chave-BD",
                   steps: [
                    story(id: "bdt-s", title: "Relacionando tabelas",
                          body: "Uma tabela Pedidos com coluna cliente_id que aponta para a tabela Clientes. Isso é um relacionamento — a base do modelo relacional."),
                    concept(id: "bdt-c", title: "PK e FK",
                            body: "Chave primária (PK): identifica cada linha de forma única. Chave estrangeira (FK): referência a uma PK em outra tabela — cria relacionamentos. Normalização elimina redundância dividindo dados em tabelas relacionadas."),
                    trueFalse(id: "bdt-e", title: "Verdadeiro ou falso",
                              prompt: "Uma chave primária pode ter o mesmo valor em duas linhas da mesma tabela.",
                              correctAnswer: false,
                              explanation: "A PK é única por definição. Duplicidade viola a integridade da entidade."),
                    summary(id: "bdt-sm", title: "Relacionamentos sem redundância",
                            body: "Tabelas + chaves = base do modelo relacional. A normalização evita inconsistências quando dados mudam.")
                   ]),

            Lesson(id: "bd-indices", title: "Índices e Performance",
                   subtitle: "O atalho que transforma segundos em milissegundos.", estimatedMinutes: 5, xpReward: 30, materialReward: "Índice",
                   steps: [
                    story(id: "bdind-s", title: "10 milhões de clientes",
                          body: "Buscar por email em 10 milhões de clientes sem índice: lê todas as linhas. Com índice: vai direto. A diferença pode ser de minutos para milissegundos."),
                    concept(id: "bdind-c", title: "B-tree por baixo",
                            body: "Um índice é uma estrutura auxiliar (geralmente B-tree) que acelera buscas numa coluna. Melhora leitura drasticamente mas tem custo em escrita (índice precisa ser atualizado). Colunas em WHERE e JOIN são candidatas."),
                    singleChoice(id: "bdind-e", title: "Trade-off do índice",
                                 prompt: "Adicionar um índice a uma coluna muito consultada vai:",
                                 options: [option("a","Acelerar leituras e escritas igualmente"), option("b","Acelerar leituras, com pequeno custo adicional em escritas"), option("c","Reduzir o espaço em disco"), option("d","Substituir a necessidade de chave primária")],
                                 correctOptionIds: ["b"],
                                 explanation: "Índices precisam ser atualizados em INSERT/UPDATE/DELETE — esse é o custo. Para leituras frequentes, o ganho compensa amplamente."),
                    summary(id: "bdind-sm", title: "Índice com critério",
                            body: "Índices são o atalho do banco. Usados com critério, transformam consultas lentas em instantâneas.")
                   ])
        ]
    )

    // MARK: - 12. Engenharia de Software

    static let engenhariaUnit = LearningUnit(
        id: "engenharia-software",
        title: "Engenharia de Software",
        subtitle: "Como construir software real, sustentável e em equipe.",
        lessons: [
            Lesson(id: "eng-paradigmas", title: "Paradigmas de Programação",
                   subtitle: "OO e Funcional — duas formas de pensar.", estimatedMinutes: 5, xpReward: 25, materialReward: "Paradigma",
                   steps: [
                    story(id: "ep-s", title: "Duas escolas de pensamento",
                          body: "Orientação a Objetos organiza código como entidades que interagem. Programação Funcional compõe funções puras como peças de Lego. Nenhum é superior — cada problema tem seu paradigma ideal."),
                    concept(id: "ep-c", title: "OO vs Funcional",
                            body: "OO: encapsula dados e comportamento em classes (herança, polimorfismo, encapsulamento). FP: funções puras, sem estado mutável, imutabilidade. Linguagens modernas como Kotlin, Swift e Python combinam os dois."),
                    trueFalse(id: "ep-e", title: "Verdadeiro ou falso",
                              prompt: "Em programação funcional, uma função pura sempre retorna o mesmo resultado para os mesmos argumentos de entrada.",
                              correctAnswer: true,
                              explanation: "Sem estado externo, sem efeitos colaterais — mesma entrada sempre produz mesma saída. Isso torna funções puras previsíveis e testáveis."),
                    summary(id: "ep-sm", title: "Ferramenta certa para o problema",
                            body: "Entender paradigmas é entender como decompor problemas. A maioria dos sistemas modernos usa os dois.")
                   ]),

            Lesson(id: "eng-patterns", title: "Design Patterns",
                   subtitle: "Soluções que já foram testadas pelo mundo.", estimatedMinutes: 5, xpReward: 25, materialReward: "Padrão",
                   steps: [
                    story(id: "epa-s", title: "Não reinvente a roda",
                          body: "A Gang of Four documentou 23 padrões de design em 1994. Décadas depois, são ainda a linguagem comum de arquitetura de software."),
                    concept(id: "epa-c", title: "Padrões recorrentes",
                            body: "Singleton: uma única instância global. Observer: notifica múltiplos objetos quando algo muda. Factory: desacopla criação de uso. SOLID: 5 princípios para código limpo e extensível. Padrões são vocabulário — dizendo o nome, todos entendem a solução."),
                    singleChoice(id: "epa-e", title: "Observer Pattern",
                                 prompt: "O padrão Observer é ideal quando:",
                                 options: [option("a","Você quer garantir uma única instância de uma classe"), option("b","Múltiplos componentes precisam reagir a mudanças em um objeto"), option("c","Você quer criar objetos sem especificar a classe exata"), option("d","Você quer adicionar comportamento sem herança")],
                                 correctOptionIds: ["b"],
                                 explanation: "Observer implementa o padrão publish/subscribe. Um subject notifica todos os observers registrados quando seu estado muda."),
                    summary(id: "epa-sm", title: "Vocabulário arquitetural",
                            body: "Patterns são atalhos de comunicação. Dominá-los acelera design de sistemas e revisões de código.")
                   ]),

            Lesson(id: "eng-git", title: "Controle de Versão com Git",
                   subtitle: "O fundamento do trabalho colaborativo.", estimatedMinutes: 5, xpReward: 25, materialReward: "Commit",
                   steps: [
                    story(id: "eg-s", title: "Sem Git, não tem volta",
                          body: "Você alterou código que funcionava. Sem Git, não dá para recuperar. Com Git, um comando restaura qualquer estado anterior da história do projeto."),
                    concept(id: "eg-c", title: "Commits, branches e merges",
                            body: "Git rastreia cada mudança como um snapshot (commit). Branches isolam trabalho em paralelo sem afetar o código principal. Merge integra branches. O histórico completo permite reverter, comparar e colaborar sem sobrescrever o trabalho alheio."),
                    ordering(id: "eg-e", title: "Fluxo básico do Git",
                             prompt: "Ordene o fluxo básico para salvar e compartilhar uma mudança:",
                             options: [option("a","Modifique arquivos"), option("b","git add — stage das mudanças"), option("c","git commit — cria o snapshot"), option("d","git push — envia ao servidor remoto")],
                             correctOptionIds: ["a","b","c","d"],
                             explanation: "Modificar → Staged → Committed → Pushed. Cada etapa tem um propósito: trabalhar, selecionar, salvar, compartilhar."),
                    summary(id: "eg-sm", title: "Obrigatório em qualquer time",
                            body: "Git é a base do desenvolvimento colaborativo. Commits, branches e merges são habilidades inegociáveis.")
                   ]),

            Lesson(id: "eng-testes", title: "Testes Automatizados",
                   subtitle: "A rede de segurança do código.", estimatedMinutes: 5, xpReward: 30, materialReward: "Verificação",
                   steps: [
                    story(id: "et-s", title: "Centenas de deploys por dia",
                          body: "Netflix deploya código centenas de vezes ao dia sem cair. Testes automatizados são a razão — cada deploy passa por milhares de verificações automáticas em segundos."),
                    concept(id: "et-c", title: "Tipos de teste",
                            body: "Unitário: testa funções isoladas. Integração: testa componentes juntos. E2E: testa fluxos completos. TDD (Test-Driven Development): escreve o teste antes do código — o teste define o comportamento esperado. Cobertura mede o percentual do código testado."),
                    trueFalse(id: "et-e", title: "Verdadeiro ou falso",
                              prompt: "Em TDD, você primeiro escreve o teste (que falha), e só depois escreve o código que o faz passar.",
                              correctAnswer: true,
                              explanation: "Red → Green → Refactor. Teste falho primeiro força você a definir o comportamento antes da implementação."),
                    summary(id: "et-sm", title: "Testes são investimento",
                            body: "Testes não documentam bugs passados — são garantia de que mudanças futuras não quebram o que já funciona.")
                   ])
        ]
    )

    // MARK: - Step helpers

    private static func story(id: String, title: String, body: String) -> LessonStep {
        LessonStep(id: id, kind: .story, title: title, body: body, exercise: nil)
    }

    private static func concept(id: String, title: String, body: String) -> LessonStep {
        LessonStep(id: id, kind: .concept, title: title, body: body, exercise: nil)
    }

    private static func summary(id: String, title: String, body: String) -> LessonStep {
        LessonStep(id: id, kind: .summary, title: title, body: body, exercise: nil)
    }

    private static func singleChoice(id: String, title: String, prompt: String,
                                     options: [ExerciseOption], correctOptionIds: [String],
                                     explanation: String) -> LessonStep {
        LessonStep(id: id, kind: .singleChoice, title: title, body: "",
                   exercise: Exercise(prompt: prompt, options: options,
                                      correctOptionIds: correctOptionIds, explanation: explanation))
    }

    private static func trueFalse(id: String, title: String, prompt: String,
                                  correctAnswer: Bool, explanation: String) -> LessonStep {
        LessonStep(id: id, kind: .trueFalse, title: title, body: "",
                   exercise: Exercise(prompt: prompt,
                                      options: [option("true","Verdadeiro"), option("false","Falso")],
                                      correctOptionIds: [correctAnswer ? "true" : "false"],
                                      explanation: explanation))
    }

    private static func ordering(id: String, title: String, prompt: String,
                                 options: [ExerciseOption], correctOptionIds: [String],
                                 explanation: String) -> LessonStep {
        LessonStep(id: id, kind: .ordering, title: title, body: "Toque nas opcoes na ordem correta.",
                   exercise: Exercise(prompt: prompt, options: options,
                                      correctOptionIds: correctOptionIds, explanation: explanation))
    }

    private static func variableTrace(id: String, title: String, exercise: VariableTraceExercise) -> LessonStep {
        LessonStep(id: id, kind: .variableTrace, title: title, body: "", variableTrace: exercise)
    }

    private static func binarySearch(id: String, title: String, exercise: BinarySearchExercise) -> LessonStep {
        LessonStep(id: id, kind: .binarySearch, title: title, body: "", binarySearch: exercise)
    }

    private static func option(_ id: String, _ text: String) -> ExerciseOption {
        ExerciseOption(id: id, text: text)
    }
}
