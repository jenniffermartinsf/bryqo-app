import Foundation

enum BryqoContent {
    static let sampleUnit = LearningUnit(
        id: "internet-page-delivery",
        title: "Como a internet entrega uma pagina",
        subtitle: "Entenda o caminho entre tocar em um link e ver uma pagina aparecer.",
        lessons: [
            Lesson(
                id: "client-server",
                title: "Cliente e servidor",
                subtitle: "Quem pede e quem responde.",
                estimatedMinutes: 4,
                xpReward: 20,
                materialReward: "Madeira",
                steps: [
                    story(
                        id: "client-server-story",
                        title: "Voce toca em Entrar",
                        body: "O app precisa buscar seus dados. Ele faz um pedido para outro computador preparado para responder."
                    ),
                    concept(
                        id: "client-server-concept",
                        title: "Dois papeis",
                        body: "Cliente e quem inicia o pedido. Servidor e quem recebe, processa e devolve uma resposta."
                    ),
                    singleChoice(
                        id: "client-server-exercise",
                        title: "Identifique o papel",
                        prompt: "Quando o navegador pede uma pagina, qual papel ele exerce?",
                        options: [
                            option("a", "Cliente"),
                            option("b", "Servidor"),
                            option("c", "Banco de dados")
                        ],
                        correctOptionIds: ["a"],
                        explanation: "O navegador inicia a requisicao, entao atua como cliente."
                    ),
                    summary(
                        id: "client-server-summary",
                        title: "Bloco colocado",
                        body: "Cliente pede. Servidor responde. Esse par aparece em apps, sites e APIs."
                    )
                ]
            ),
            Lesson(
                id: "ip-address",
                title: "Endereco IP",
                subtitle: "Como encontrar um dispositivo na rede.",
                estimatedMinutes: 4,
                xpReward: 20,
                materialReward: "Pedra",
                steps: [
                    story(
                        id: "ip-story",
                        title: "A ponte precisa de destino",
                        body: "Antes de enviar uma mensagem, a rede precisa saber para onde ela deve ir."
                    ),
                    concept(
                        id: "ip-concept",
                        title: "Um endereco na rede",
                        body: "Um endereco IP identifica um dispositivo ou ponto de rede para que pacotes encontrem o caminho correto."
                    ),
                    trueFalse(
                        id: "ip-exercise",
                        title: "Verdadeiro ou falso",
                        prompt: "Um endereco IP ajuda a rede a encaminhar dados ate um destino.",
                        correctAnswer: true,
                        explanation: "Sim. O IP funciona como uma referencia de destino para os pacotes."
                    ),
                    summary(
                        id: "ip-summary",
                        title: "Destino definido",
                        body: "Sem endereco, a rede nao sabe para onde levar os pacotes."
                    )
                ]
            ),
            Lesson(
                id: "dns",
                title: "DNS",
                subtitle: "Como nomes viram enderecos.",
                estimatedMinutes: 5,
                xpReward: 25,
                materialReward: "Galhos",
                steps: [
                    story(
                        id: "dns-story",
                        title: "Voce lembra nomes, a rede usa numeros",
                        body: "E mais facil digitar um dominio do que memorizar um endereco numerico."
                    ),
                    concept(
                        id: "dns-concept",
                        title: "A agenda da internet",
                        body: "DNS traduz nomes de dominio, como exemplo.com, para enderecos que a rede consegue usar."
                    ),
                    ordering(
                        id: "dns-exercise",
                        title: "Monte a sequencia",
                        prompt: "Ordene o que acontece quando voce acessa um dominio.",
                        options: [
                            option("type", "Voce digita o dominio"),
                            option("ask", "O sistema consulta o DNS"),
                            option("ip", "O DNS retorna um endereco IP"),
                            option("connect", "O cliente usa o IP para se conectar")
                        ],
                        correctOptionIds: ["type", "ask", "ip", "connect"],
                        explanation: "Primeiro vem o nome, depois a consulta, o endereco e a conexao."
                    ),
                    summary(
                        id: "dns-summary",
                        title: "Nome encontrado",
                        body: "DNS conecta nomes amigaveis aos enderecos usados pela rede."
                    )
                ]
            ),
            Lesson(
                id: "request-response",
                title: "Requisicao e resposta",
                subtitle: "O ciclo basico da web.",
                estimatedMinutes: 5,
                xpReward: 25,
                materialReward: "Blocos",
                steps: [
                    story(
                        id: "request-response-story",
                        title: "Um pedido atravessa o rio",
                        body: "O cliente envia uma requisicao. O servidor avalia o pedido e devolve uma resposta."
                    ),
                    concept(
                        id: "request-response-concept",
                        title: "Causa e efeito",
                        body: "A requisicao descreve o que o cliente quer. A resposta carrega o resultado, como uma pagina, dados ou erro."
                    ),
                    singleChoice(
                        id: "request-response-exercise",
                        title: "Escolha a melhor explicacao",
                        prompt: "Qual frase descreve melhor uma resposta?",
                        options: [
                            option("a", "Um pedido iniciado pelo cliente"),
                            option("b", "O retorno enviado pelo servidor"),
                            option("c", "O nome publico de um site")
                        ],
                        correctOptionIds: ["b"],
                        explanation: "A resposta e o retorno do servidor para uma requisicao."
                    ),
                    summary(
                        id: "request-response-summary",
                        title: "Fluxo completo",
                        body: "A web funciona por muitos ciclos de pedido e retorno."
                    )
                ]
            ),
            Lesson(
                id: "http-https",
                title: "HTTP e HTTPS",
                subtitle: "As regras da conversa na web.",
                estimatedMinutes: 5,
                xpReward: 30,
                materialReward: "Engrenagem",
                steps: [
                    story(
                        id: "http-story",
                        title: "A conversa precisa de regras",
                        body: "Cliente e servidor precisam combinar o formato do pedido e da resposta."
                    ),
                    concept(
                        id: "http-concept",
                        title: "Protocolo da web",
                        body: "HTTP define como mensagens da web sao estruturadas. HTTPS usa protecao criptografada nessa comunicacao."
                    ),
                    trueFalse(
                        id: "http-exercise",
                        title: "Seguranca",
                        prompt: "HTTPS e uma versao protegida da comunicacao HTTP.",
                        correctAnswer: true,
                        explanation: "HTTPS adiciona uma camada de protecao para reduzir exposicao e adulteracao dos dados em transito."
                    ),
                    summary(
                        id: "http-summary",
                        title: "Barragem reforcada",
                        body: "HTTP organiza a conversa. HTTPS protege essa conversa durante o caminho."
                    )
                ]
            )
        ]
    )

    static let sampleCodeUnit = LearningUnit(
        id: "python-basics",
        title: "Python: Primeiros Passos",
        subtitle: "Escreva suas primeiras linhas de código real.",
        lessons: [
            Lesson(
                id: "python-print",
                title: "A função print()",
                subtitle: "Seu primeiro código funcionando.",
                estimatedMinutes: 4,
                xpReward: 20,
                materialReward: "Código",
                steps: [
                    story(
                        id: "print-story",
                        title: "Seu primeiro output",
                        body: "Todo programador começa pelo mesmo lugar: fazendo o computador exibir uma mensagem. Em Python, você usa print()."
                    ),
                    concept(
                        id: "print-concept",
                        title: "print() exibe na tela",
                        body: "Tudo que você colocar entre os parênteses aparece na tela. Texto precisa de aspas. Números não precisam."
                    ),
                    singleChoiceWithCode(
                        id: "print-output-1",
                        title: "Qual é o output?",
                        prompt: "O que esse código vai imprimir?",
                        code: "print(\"Hello, World!\")",
                        language: .python,
                        options: [
                            option("a", "Hello, World!"),
                            option("b", "\"Hello, World!\""),
                            option("c", "hello, world!"),
                            option("d", "SyntaxError")
                        ],
                        correctOptionIds: ["a"],
                        explanation: "print() exibe o texto sem as aspas. As aspas só delimitam a string no código."
                    ),
                    singleChoiceWithCode(
                        id: "print-output-2",
                        title: "E esse aqui?",
                        prompt: "Quantas linhas esse código imprime?",
                        code: "print(\"Linha 1\")\nprint(\"Linha 2\")\nprint(\"Linha 3\")",
                        language: .python,
                        options: [
                            option("a", "1"),
                            option("b", "2"),
                            option("c", "3"),
                            option("d", "0 — gera erro")
                        ],
                        correctOptionIds: ["c"],
                        explanation: "Cada print() imprime uma linha separada. Três chamadas = três linhas."
                    ),
                    summary(
                        id: "print-summary",
                        title: "Primeiro bloco colocado",
                        body: "print() é a porta de entrada do Python. Use para ver o que seu código está fazendo."
                    )
                ]
            ),
            Lesson(
                id: "python-variables",
                title: "Variáveis",
                subtitle: "Guardando valores para usar depois.",
                estimatedMinutes: 4,
                xpReward: 20,
                materialReward: "Caixa",
                steps: [
                    story(
                        id: "var-story",
                        title: "Uma caixa com nome",
                        body: "Variáveis são como caixas etiquetadas. Você guarda algo dentro e acessa pelo nome quando precisar."
                    ),
                    concept(
                        id: "var-concept",
                        title: "nome = valor",
                        body: "Em Python, você cria uma variável só escrevendo o nome, o sinal de igual e o valor. Sem nenhuma palavra especial antes."
                    ),
                    singleChoiceWithCode(
                        id: "var-output",
                        title: "O que aparece?",
                        prompt: "O que esse código imprime?",
                        code: "nome = \"Ana\"\nidade = 25\nprint(nome)",
                        language: .python,
                        options: [
                            option("a", "Ana"),
                            option("b", "nome"),
                            option("c", "\"Ana\""),
                            option("d", "25")
                        ],
                        correctOptionIds: ["a"],
                        explanation: "print(nome) imprime o valor guardado na variável nome, que é \"Ana\" sem as aspas."
                    ),
                    singleChoiceWithCode(
                        id: "var-update",
                        title: "Variável atualizada",
                        prompt: "Qual é o output?",
                        code: "x = 10\nx = x + 5\nprint(x)",
                        language: .python,
                        options: [
                            option("a", "10"),
                            option("b", "5"),
                            option("c", "15"),
                            option("d", "x + 5")
                        ],
                        correctOptionIds: ["c"],
                        explanation: "x começa em 10. Na segunda linha, x recebe 10 + 5 = 15. print(x) exibe 15."
                    ),
                    summary(
                        id: "var-summary",
                        title: "Caixa guardada",
                        body: "Variáveis guardam dados. Você pode ler, sobrescrever e usar o valor quantas vezes quiser."
                    )
                ]
            ),
            Lesson(
                id: "python-conditionals",
                title: "Condicionais",
                subtitle: "Tomando decisões no código.",
                estimatedMinutes: 5,
                xpReward: 25,
                materialReward: "Bifurcação",
                steps: [
                    story(
                        id: "if-story",
                        title: "O código decide",
                        body: "Às vezes o código precisa tomar um caminho ou outro dependendo de uma condição. É aí que entra o if."
                    ),
                    concept(
                        id: "if-concept",
                        title: "if / else",
                        body: "Se a condição for verdadeira, o bloco do if executa. Caso contrário, o bloco do else executa. Só um dos dois roda."
                    ),
                    singleChoiceWithCode(
                        id: "if-output",
                        title: "Qual caminho?",
                        prompt: "O que esse código imprime?",
                        code: "x = 10\nif x > 5:\n    print(\"maior\")\nelse:\n    print(\"menor\")",
                        language: .python,
                        options: [
                            option("a", "maior"),
                            option("b", "menor"),
                            option("c", "10"),
                            option("d", "maior e menor")
                        ],
                        correctOptionIds: ["a"],
                        explanation: "x é 10, e 10 > 5 é True. O bloco do if executa e imprime \"maior\"."
                    ),
                    singleChoiceWithCode(
                        id: "if-elif",
                        title: "Três caminhos",
                        prompt: "Com nota = 7, o que é impresso?",
                        code: "nota = 7\nif nota >= 9:\n    print(\"A\")\nelif nota >= 6:\n    print(\"B\")\nelse:\n    print(\"C\")",
                        language: .python,
                        options: [
                            option("a", "A"),
                            option("b", "B"),
                            option("c", "C"),
                            option("d", "A e B")
                        ],
                        correctOptionIds: ["b"],
                        explanation: "7 não é >= 9, mas é >= 6. O elif captura esse caso e imprime \"B\"."
                    ),
                    summary(
                        id: "if-summary",
                        title: "Desvio construído",
                        body: "if/elif/else criam bifurcações. Apenas o primeiro bloco verdadeiro é executado."
                    )
                ]
            ),
            Lesson(
                id: "python-functions",
                title: "Funções",
                subtitle: "Empacotando código para reutilizar.",
                estimatedMinutes: 5,
                xpReward: 30,
                materialReward: "Função",
                steps: [
                    story(
                        id: "func-story",
                        title: "Código que você usa várias vezes",
                        body: "Em vez de copiar o mesmo bloco toda vez, você embrulha ele em uma função e chama pelo nome quando precisar."
                    ),
                    concept(
                        id: "func-concept",
                        title: "def nome(): ...",
                        body: "Funções são definidas com def, seguido do nome e parênteses. Parâmetros entram nos parênteses. Use return para devolver um valor."
                    ),
                    codeCompletion(
                        id: "func-define",
                        title: "Complete a função",
                        prompt: "Complete para definir uma função chamada saudacao:",
                        code: "___ saudacao():\n    print(\"Olá!\")",
                        language: .python,
                        options: [
                            option("a", "def"),
                            option("b", "fun"),
                            option("c", "function"),
                            option("d", "func")
                        ],
                        correctOptionId: "a",
                        explanation: "Em Python, funções são criadas com def. Outras linguagens usam function ou fun, mas não Python."
                    ),
                    trueFalseWithCode(
                        id: "func-return",
                        title: "Verdadeiro ou falso",
                        prompt: "Essa função retorna a soma de dois números?",
                        code: "def somar(a, b):\n    return a + b",
                        language: .python,
                        correctAnswer: true,
                        explanation: "Sim! return a + b devolve o resultado da soma para quem chamou a função."
                    ),
                    summary(
                        id: "func-summary",
                        title: "Função criada",
                        body: "def cria a função, parâmetros permitem entrada, return devolve o resultado. Reutilize sem copiar."
                    )
                ]
            ),
            Lesson(
                id: "python-loops",
                title: "Loops com for",
                subtitle: "Repetindo sem copiar e colar.",
                estimatedMinutes: 5,
                xpReward: 25,
                materialReward: "Ciclo",
                steps: [
                    story(
                        id: "loop-story",
                        title: "Repetir é trabalho da máquina",
                        body: "Em vez de escrever print() dez vezes, você usa um loop. O computador repete o bloco quantas vezes você mandar."
                    ),
                    concept(
                        id: "loop-concept",
                        title: "for item in coleção",
                        body: "O for pega cada item de uma coleção e executa o bloco uma vez para cada um. range(n) gera os números de 0 até n-1."
                    ),
                    singleChoiceWithCode(
                        id: "loop-output",
                        title: "Quantas vezes?",
                        prompt: "Quantas linhas esse código imprime?",
                        code: "for i in range(5):\n    print(i)",
                        language: .python,
                        options: [
                            option("a", "4"),
                            option("b", "5"),
                            option("c", "6"),
                            option("d", "Nenhuma — gera erro")
                        ],
                        correctOptionIds: ["b"],
                        explanation: "range(5) gera [0, 1, 2, 3, 4] — cinco números. O loop imprime cada um, totalizando 5 linhas."
                    ),
                    singleChoiceWithCode(
                        id: "loop-sum",
                        title: "Acumulando",
                        prompt: "Qual é o valor de total no final?",
                        code: "total = 0\nfor n in [1, 2, 3, 4]:\n    total = total + n\nprint(total)",
                        language: .python,
                        options: [
                            option("a", "4"),
                            option("b", "8"),
                            option("c", "10"),
                            option("d", "0")
                        ],
                        correctOptionIds: ["c"],
                        explanation: "total acumula 0+1+2+3+4 = 10. O padrão de acumular em uma variável fora do loop é muito comum."
                    ),
                    summary(
                        id: "loop-summary",
                        title: "Ciclo fechado",
                        body: "Loops eliminam repetição. for percorre qualquer coleção e range() gera sequências numéricas."
                    )
                ]
            )
        ]
    )

    private static func singleChoiceWithCode(
        id: String,
        title: String,
        prompt: String,
        code: String,
        language: CodeLanguage = .python,
        options: [ExerciseOption],
        correctOptionIds: [String],
        explanation: String
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .singleChoice,
            title: title,
            body: "",
            exercise: Exercise(
                prompt: prompt,
                options: options,
                correctOptionIds: correctOptionIds,
                explanation: explanation,
                codeSnippet: CodeSnippet(code: code, language: language)
            )
        )
    }

    private static func story(id: String, title: String, body: String) -> LessonStep {
        LessonStep(id: id, kind: .story, title: title, body: body, exercise: nil)
    }

    private static func concept(id: String, title: String, body: String) -> LessonStep {
        LessonStep(id: id, kind: .concept, title: title, body: body, exercise: nil)
    }

    private static func summary(id: String, title: String, body: String) -> LessonStep {
        LessonStep(id: id, kind: .summary, title: title, body: body, exercise: nil)
    }

    private static func singleChoice(
        id: String,
        title: String,
        prompt: String,
        options: [ExerciseOption],
        correctOptionIds: [String],
        explanation: String
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .singleChoice,
            title: title,
            body: "",
            exercise: Exercise(
                prompt: prompt,
                options: options,
                correctOptionIds: correctOptionIds,
                explanation: explanation
            )
        )
    }

    private static func trueFalse(
        id: String,
        title: String,
        prompt: String,
        correctAnswer: Bool,
        explanation: String
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .trueFalse,
            title: title,
            body: "",
            exercise: Exercise(
                prompt: prompt,
                options: [
                    option("true", "Verdadeiro"),
                    option("false", "Falso")
                ],
                correctOptionIds: [correctAnswer ? "true" : "false"],
                explanation: explanation
            )
        )
    }

    private static func ordering(
        id: String,
        title: String,
        prompt: String,
        options: [ExerciseOption],
        correctOptionIds: [String],
        explanation: String
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .ordering,
            title: title,
            body: "Toque nas opcoes na ordem correta.",
            exercise: Exercise(
                prompt: prompt,
                options: options,
                correctOptionIds: correctOptionIds,
                explanation: explanation
            )
        )
    }

    private static func trueFalseWithCode(
        id: String,
        title: String,
        prompt: String,
        code: String,
        language: CodeLanguage = .python,
        correctAnswer: Bool,
        explanation: String
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .trueFalse,
            title: title,
            body: "",
            exercise: Exercise(
                prompt: prompt,
                options: [
                    option("true", "Verdadeiro"),
                    option("false", "Falso")
                ],
                correctOptionIds: [correctAnswer ? "true" : "false"],
                explanation: explanation,
                codeSnippet: CodeSnippet(code: code, language: language)
            )
        )
    }

    private static func codeCompletion(
        id: String,
        title: String,
        prompt: String,
        code: String,
        language: CodeLanguage = .python,
        options: [ExerciseOption],
        correctOptionId: String,
        explanation: String
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .codeCompletion,
            title: title,
            body: "",
            exercise: Exercise(
                prompt: prompt,
                options: options,
                correctOptionIds: [correctOptionId],
                explanation: explanation,
                codeSnippet: CodeSnippet(code: code, language: language)
            )
        )
    }

    private static func option(_ id: String, _ text: String) -> ExerciseOption {
        ExerciseOption(id: id, text: text)
    }
}
