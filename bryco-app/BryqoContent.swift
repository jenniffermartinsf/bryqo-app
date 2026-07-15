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

    private static func option(_ id: String, _ text: String) -> ExerciseOption {
        ExerciseOption(id: id, text: text)
    }
}
