import Foundation

// MARK: - DTO → domain (with validation)

extension ContentCatalogDTO {
    /// Valid units only. A lesson with a broken step is dropped; a unit left with no lessons
    /// is dropped. One bad lesson on the server never takes the whole app down.
    func toDomain() -> [LearningUnit] {
        units.compactMap { $0.toDomain() }
    }
}

extension UnitDTO {
    func toDomain() -> LearningUnit? {
        let lessons = lessons.compactMap { $0.toDomain() }
        guard !lessons.isEmpty else { return nil }
        return LearningUnit(id: id, title: title, subtitle: subtitle, lessons: lessons)
    }
}

extension LessonDTO {
    func toDomain() -> Lesson? {
        let mapped = steps.map { $0.toDomain() }
        // Every step must be valid: skipping one silently could leave a lesson that no
        // longer makes sense, so the whole lesson is dropped instead.
        guard !mapped.isEmpty, !mapped.contains(where: { $0 == nil }) else { return nil }
        return Lesson(
            id: id, title: title, subtitle: subtitle,
            estimatedMinutes: estimatedMinutes, xpReward: xpReward,
            materialReward: materialReward, steps: mapped.compactMap { $0 }
        )
    }
}

extension StepDTO {
    func toDomain() -> LessonStep? {
        guard let kind = LessonStepKind(wireValue: kind) else { return nil }
        let exercise = exercise?.toDomain()
        let trace = variableTrace?.toDomain()
        let search = binarySearch?.toDomain()

        switch kind {
        case .singleChoice, .trueFalse, .ordering, .codeCompletion:
            guard exercise != nil else { return nil }
        case .variableTrace:
            guard trace != nil else { return nil }
        case .binarySearch:
            guard search != nil else { return nil }
        case .story, .concept, .summary:
            break
        }
        return LessonStep(id: id, kind: kind, title: title, body: body,
                          exercise: exercise, variableTrace: trace, binarySearch: search)
    }
}

extension ExerciseDTO {
    func toDomain() -> Exercise? {
        let optionIds = Set(options.map(\.id))
        guard !options.isEmpty, !correctOptionIds.isEmpty,
              Set(correctOptionIds).isSubset(of: optionIds) else { return nil }
        return Exercise(
            prompt: prompt,
            options: options.map { ExerciseOption(id: $0.id, text: $0.text) },
            correctOptionIds: correctOptionIds,
            explanation: explanation,
            codeSnippet: codeSnippet.map { CodeSnippet(code: $0.code, language: CodeLanguage(wireValue: $0.language)) }
        )
    }
}

extension VariableTraceDTO {
    func toDomain() -> VariableTraceExercise? {
        let valid = !steps.isEmpty && steps.allSatisfy {
            codeLines.indices.contains($0.highlightedLine) && $0.options.contains($0.correctAnswer)
        }
        guard valid else { return nil }
        return VariableTraceExercise(
            intro: intro, codeLines: codeLines, language: CodeLanguage(wireValue: language),
            steps: steps.map {
                VariableTraceStep(highlightedLine: $0.highlightedLine, prompt: $0.prompt, variable: $0.variable,
                                  options: $0.options, correctAnswer: $0.correctAnswer, explanation: $0.explanation)
            }
        )
    }
}

extension BinarySearchDTO {
    func toDomain() -> BinarySearchExercise? {
        guard !array.isEmpty, array == array.sorted() else { return nil }
        return BinarySearchExercise(intro: intro, array: array, target: target)
    }
}

// MARK: - Wire values

extension LessonStepKind {
    nonisolated init?(wireValue: String) {
        switch wireValue {
        case "story": self = .story
        case "concept": self = .concept
        case "singleChoice": self = .singleChoice
        case "trueFalse": self = .trueFalse
        case "ordering": self = .ordering
        case "codeCompletion": self = .codeCompletion
        case "variableTrace": self = .variableTrace
        case "binarySearch": self = .binarySearch
        case "summary": self = .summary
        default: return nil
        }
    }

    nonisolated var wireValue: String {
        switch self {
        case .story: "story"
        case .concept: "concept"
        case .singleChoice: "singleChoice"
        case .trueFalse: "trueFalse"
        case .ordering: "ordering"
        case .codeCompletion: "codeCompletion"
        case .variableTrace: "variableTrace"
        case .binarySearch: "binarySearch"
        case .summary: "summary"
        }
    }
}

extension CodeLanguage {
    /// Unknown languages fall back to the generic label instead of failing.
    nonisolated init(wireValue: String) {
        self = CodeLanguage(rawValue: wireValue) ?? .generic
    }
}

// MARK: - Domain → DTO (used to publish the catalog from the bundled content)

extension ContentCatalogDTO {
    init(version: Int, content units: [LearningUnit]) {
        self.init(version: version, units: units.map { unit in
            UnitDTO(id: unit.id, title: unit.title, subtitle: unit.subtitle, lessons: unit.lessons.map { lesson in
                LessonDTO(
                    id: lesson.id, title: lesson.title, subtitle: lesson.subtitle,
                    estimatedMinutes: lesson.estimatedMinutes, xpReward: lesson.xpReward,
                    materialReward: lesson.materialReward,
                    steps: lesson.steps.map { step in
                        StepDTO(
                            id: step.id, kind: step.kind.wireValue, title: step.title, body: step.body,
                            exercise: step.exercise.map { e in
                                ExerciseDTO(prompt: e.prompt,
                                            options: e.options.map { OptionDTO(id: $0.id, text: $0.text) },
                                            correctOptionIds: e.correctOptionIds, explanation: e.explanation,
                                            codeSnippet: e.codeSnippet.map { CodeSnippetDTO(code: $0.code, language: $0.language.rawValue) })
                            },
                            variableTrace: step.variableTrace.map { t in
                                VariableTraceDTO(intro: t.intro, codeLines: t.codeLines, language: t.language.rawValue,
                                                 steps: t.steps.map {
                                                     VariableTraceStepDTO(highlightedLine: $0.highlightedLine, prompt: $0.prompt,
                                                                          variable: $0.variable, options: $0.options,
                                                                          correctAnswer: $0.correctAnswer, explanation: $0.explanation)
                                                 })
                            },
                            binarySearch: step.binarySearch.map { BinarySearchDTO(intro: $0.intro, array: $0.array, target: $0.target) }
                        )
                    }
                )
            })
        })
    }
}
