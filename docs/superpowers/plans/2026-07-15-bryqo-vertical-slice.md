# Bryqo Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first local-first Bryqo iOS vertical slice with onboarding, tab navigation, a five-lesson learning unit, exercises, XP, streak/progress, review, and valley progress.

**Architecture:** Replace the SwiftData template UI with a lightweight SwiftUI feature structure. Keep content in local Swift seed data and keep progress in an observable in-memory app state for this prototype. Views consume explicit domain models and update progress through a single `BryqoAppState` object.

**Tech Stack:** Swift, SwiftUI, Observation, Swift Testing, SF Symbols.

## Global Constraints

- The first unit is **Como a internet entrega uma página**.
- Lessons are: Cliente e servidor, Endereço IP, DNS, Requisição e resposta, HTTP e HTTPS.
- No account creation, Sign in with Apple, backend sync, real analytics, StoreKit, real local notifications, AI, remote content loading, or full mascot illustration.
- The current template `Item` list must not remain visible in the app experience.
- UI copy should be Brazilian Portuguese, warm, clear, and non-punitive.
- Exercise feedback must not rely only on color.
- The app must build successfully.

---

### Task 1: Domain Models And Progress Rules

**Files:**
- Create: `bryco-app/BryqoModels.swift`
- Create: `bryco-app/BryqoAppState.swift`
- Modify: `bryco-appTests/bryco_appTests.swift`

**Interfaces:**
- Produces: `Lesson`, `LessonStep`, `LessonStepKind`, `Exercise`, `ExerciseOption`, `OnboardingProfile`, `UserProgress`, `BryqoAppState`.
- Produces: `BryqoAppState.completeOnboarding(experience:goal:dailyGoalMinutes:)`, `BryqoAppState.completeLesson(_:)`, `BryqoAppState.isLessonCompleted(_:)`, `BryqoAppState.canStartLesson(_:in:)`.

- [ ] **Step 1: Write failing tests for progress rules**

Replace `bryco-appTests/bryco_appTests.swift` with:

```swift
import Testing
@testable import bryco_app

struct bryco_appTests {
    @Test func completingLessonAwardsXpOnce() {
        let state = BryqoAppState()
        let lesson = BryqoContent.sampleUnit.lessons[0]

        state.completeLesson(lesson)
        state.completeLesson(lesson)

        #expect(state.progress.completedLessonIds == [lesson.id])
        #expect(state.progress.xp == lesson.xpReward)
    }

    @Test func lessonsUnlockSequentially() {
        let state = BryqoAppState()
        let unit = BryqoContent.sampleUnit

        #expect(state.canStartLesson(unit.lessons[0], in: unit))
        #expect(!state.canStartLesson(unit.lessons[1], in: unit))

        state.completeLesson(unit.lessons[0])

        #expect(state.canStartLesson(unit.lessons[1], in: unit))
    }

    @Test func onboardingStoresProfile() {
        let state = BryqoAppState()

        state.completeOnboarding(
            experience: "Estou começando",
            goal: "Construir uma base",
            dailyGoalMinutes: 10
        )

        #expect(state.hasCompletedOnboarding)
        #expect(state.profile?.dailyGoalMinutes == 10)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `xcodebuild test -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: FAIL because `BryqoAppState` and `BryqoContent` do not exist.

- [ ] **Step 3: Add models**

Create `bryco-app/BryqoModels.swift` with:

```swift
import Foundation

struct LearningUnit: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let lessons: [Lesson]
}

struct Lesson: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let xpReward: Int
    let materialReward: String
    let steps: [LessonStep]
}

struct LessonStep: Identifiable, Equatable {
    let id: String
    let kind: LessonStepKind
    let title: String
    let body: String
    let exercise: Exercise?
}

enum LessonStepKind: Equatable {
    case story
    case concept
    case singleChoice
    case trueFalse
    case ordering
    case summary
}

struct Exercise: Equatable {
    let prompt: String
    let options: [ExerciseOption]
    let correctOptionIds: [String]
    let explanation: String
}

struct ExerciseOption: Identifiable, Equatable {
    let id: String
    let text: String
}

struct OnboardingProfile: Equatable {
    let experience: String
    let goal: String
    let dailyGoalMinutes: Int
}

struct UserProgress: Equatable {
    var completedLessonIds: Set<String> = []
    var xp: Int = 0
    var streakDays: Int = 0
    var earnedMaterials: [String] = []
}
```

- [ ] **Step 4: Add app state**

Create `bryco-app/BryqoAppState.swift` with:

```swift
import Foundation
import Observation

@Observable
final class BryqoAppState {
    var profile: OnboardingProfile?
    var progress = UserProgress()

    var hasCompletedOnboarding: Bool {
        profile != nil
    }

    var completedLessonCount: Int {
        progress.completedLessonIds.count
    }

    func completeOnboarding(experience: String, goal: String, dailyGoalMinutes: Int) {
        profile = OnboardingProfile(
            experience: experience,
            goal: goal,
            dailyGoalMinutes: dailyGoalMinutes
        )
    }

    func isLessonCompleted(_ lesson: Lesson) -> Bool {
        progress.completedLessonIds.contains(lesson.id)
    }

    func canStartLesson(_ lesson: Lesson, in unit: LearningUnit) -> Bool {
        guard let index = unit.lessons.firstIndex(of: lesson) else {
            return false
        }

        if index == 0 {
            return true
        }

        let previousLesson = unit.lessons[index - 1]
        return isLessonCompleted(previousLesson)
    }

    func completeLesson(_ lesson: Lesson) {
        guard !isLessonCompleted(lesson) else {
            return
        }

        progress.completedLessonIds.insert(lesson.id)
        progress.xp += lesson.xpReward
        progress.streakDays = max(progress.streakDays, 1)
        progress.earnedMaterials.append(lesson.materialReward)
    }
}
```

- [ ] **Step 5: Run tests**

Run: `xcodebuild test -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: tests still fail because `BryqoContent.sampleUnit` does not exist. Continue to Task 2.

### Task 2: Local Content Seed

**Files:**
- Create: `bryco-app/BryqoContent.swift`
- Test: `bryco-appTests/bryco_appTests.swift`

**Interfaces:**
- Consumes: `LearningUnit`, `Lesson`, `LessonStep`, `Exercise`, `ExerciseOption`.
- Produces: `BryqoContent.sampleUnit`.

- [ ] **Step 1: Add local content seed**

Create `bryco-app/BryqoContent.swift` with a `BryqoContent.sampleUnit` containing the five planned lessons. Each lesson must include at least story, concept, one exercise, and summary steps.

- [ ] **Step 2: Run tests**

Run: `xcodebuild test -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS for the three progress tests.

- [ ] **Step 3: Commit**

Run:

```bash
git add bryco-app/BryqoModels.swift bryco-app/BryqoAppState.swift bryco-app/BryqoContent.swift bryco-appTests/bryco_appTests.swift
git commit -m "Add Bryqo domain models and local content"
```

### Task 3: App Shell And Onboarding

**Files:**
- Modify: `bryco-app/ContentView.swift`
- Create: `bryco-app/OnboardingView.swift`
- Create: `bryco-app/BryqoTheme.swift`

**Interfaces:**
- Consumes: `BryqoAppState.completeOnboarding(experience:goal:dailyGoalMinutes:)`.
- Produces: `ContentView` that routes to onboarding or tabs.

- [ ] **Step 1: Replace template content shell**

Update `ContentView.swift` to own `@State private var appState = BryqoAppState()` and show `OnboardingView` until onboarding is complete. Remove the template list UI from the visible path.

- [ ] **Step 2: Add onboarding UI**

Create `OnboardingView.swift` with segmented choices for experience, goal, and daily goal. The primary button calls `appState.completeOnboarding(...)`.

- [ ] **Step 3: Add theme constants**

Create `BryqoTheme.swift` with reusable colors, spacing, and simple card styling helpers used by the new views.

- [ ] **Step 4: Build**

Run: `xcodebuild build -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS and app opens to onboarding.

### Task 4: Learning Tabs And Lesson Flow

**Files:**
- Create: `bryco-app/MainTabView.swift`
- Create: `bryco-app/LearnView.swift`
- Create: `bryco-app/ValleyProgressView.swift`
- Create: `bryco-app/LessonView.swift`
- Modify: `bryco-app/ContentView.swift`

**Interfaces:**
- Consumes: `BryqoContent.sampleUnit`, `BryqoAppState.canStartLesson(_:in:)`, `BryqoAppState.completeLesson(_:)`.
- Produces: tab navigation, learning map, and completable lesson flow.

- [ ] **Step 1: Add tab shell**

Create `MainTabView.swift` with tabs for Aprender, Revisar, Progresso, and Perfil. Temporarily use placeholder views for Revisar, Progresso, and Perfil until Task 5.

- [ ] **Step 2: Add learn view**

Create `LearnView.swift` to show Brix copy, daily goal, `ValleyProgressView`, and five lesson rows. Locked lessons are visible but disabled until the previous lesson is complete.

- [ ] **Step 3: Add valley progress**

Create `ValleyProgressView.swift` with SwiftUI shapes for river, dam blocks, bridge, and material count. Visual state should depend on completed lesson count.

- [ ] **Step 4: Add lesson engine view**

Create `LessonView.swift` to render one `LessonStep` at a time, handle option selection, show feedback, advance through steps, and call `completeLesson(_:)` on finish.

- [ ] **Step 5: Build**

Run: `xcodebuild build -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS and the first lesson can be completed.

### Task 5: Review, Progress, And Profile Tabs

**Files:**
- Create: `bryco-app/ReviewView.swift`
- Create: `bryco-app/ProgressView.swift`
- Create: `bryco-app/ProfileView.swift`
- Modify: `bryco-app/MainTabView.swift`

**Interfaces:**
- Consumes: `BryqoAppState.progress`, `BryqoAppState.profile`, `BryqoContent.sampleUnit`.
- Produces: final tab content for review, progress, and profile.

- [ ] **Step 1: Add review view**

Create `ReviewView.swift` with a lightweight review card that lists completed lessons as available for reinforcement and shows a warm empty state before completion.

- [ ] **Step 2: Add progress view**

Create `ProgressView.swift` with XP, streak, completed lessons, unit percentage, and earned materials.

- [ ] **Step 3: Add profile view**

Create `ProfileView.swift` with onboarding choices, daily goal, local-first prototype status, and deferred features.

- [ ] **Step 4: Wire tabs**

Update `MainTabView.swift` to use the final three views.

- [ ] **Step 5: Build**

Run: `xcodebuild build -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS and all four tabs reflect shared progress state.

### Task 6: Final Verification

**Files:**
- Modify as needed based on diagnostics.

**Interfaces:**
- Consumes: all implementation files.
- Produces: passing build and concise handoff.

- [ ] **Step 1: Run tests**

Run: `xcodebuild test -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS.

- [ ] **Step 2: Run build**

Run: `xcodebuild build -project bryco-app.xcodeproj -scheme bryco-app -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS.

- [ ] **Step 3: Check git status**

Run: `git status --short`

Expected: only intentional Bryqo implementation files changed.

- [ ] **Step 4: Commit implementation**

Run:

```bash
git add bryco-app bryco-appTests docs/superpowers/plans/2026-07-15-bryqo-vertical-slice.md
git commit -m "Build Bryqo vertical slice prototype"
```

## Self-Review

- Spec coverage: onboarding, tabs, five lessons, exercises, local progress, XP, streak, review, profile, valley progress, and build validation are covered.
- Deferred scope remains excluded: auth, backend, StoreKit, analytics, notifications, AI, and remote content are not included.
- Placeholder scan: the plan avoids deferred implementation placeholders in acceptance-critical paths; Task 3 uses temporary tab placeholders only as an intermediate step replaced in Task 5.
- Type consistency: model and state names used in later tasks match Task 1 interfaces.
