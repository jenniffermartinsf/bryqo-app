import Foundation
@testable import bryco_app

/// Small, self-contained builders so lesson-flow tests don't depend on the shipping
/// content in `BryqoContent` (which changes often). Everything here is deterministic.
enum LessonFixtures {
    static func option(_ id: String, _ text: String = "opção") -> ExerciseOption {
        ExerciseOption(id: id, text: text)
    }

    static func conceptStep(id: String = "concept") -> LessonStep {
        LessonStep(id: id, kind: .concept, title: "Conceito", body: "corpo", exercise: nil)
    }

    static func singleChoiceStep(
        id: String = "sc",
        correct: String,
        options: [ExerciseOption]
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .singleChoice,
            title: "Pergunta",
            body: "",
            exercise: Exercise(
                prompt: "Escolha a opção correta",
                options: options,
                correctOptionIds: [correct],
                explanation: "explicação"
            )
        )
    }

    static func orderingStep(
        id: String = "ord",
        options: [ExerciseOption],
        correctOrder: [String]
    ) -> LessonStep {
        LessonStep(
            id: id,
            kind: .ordering,
            title: "Ordene",
            body: "",
            exercise: Exercise(
                prompt: "Coloque em ordem",
                options: options,
                correctOptionIds: correctOrder,
                explanation: "explicação"
            )
        )
    }

    static func lesson(
        id: String = "fixture-lesson",
        xpReward: Int = 20,
        steps: [LessonStep]
    ) -> Lesson {
        Lesson(
            id: id,
            title: "Lição de teste",
            subtitle: "",
            estimatedMinutes: 4,
            xpReward: xpReward,
            materialReward: "Bússola",
            steps: steps
        )
    }

    /// A lesson shaped like a real one: concept → single-choice → single-choice.
    static func standardLesson() -> Lesson {
        lesson(steps: [
            conceptStep(id: "s0"),
            singleChoiceStep(id: "s1", correct: "b", options: [option("a"), option("b"), option("c")]),
            singleChoiceStep(id: "s2", correct: "x", options: [option("x"), option("y")])
        ])
    }
}
