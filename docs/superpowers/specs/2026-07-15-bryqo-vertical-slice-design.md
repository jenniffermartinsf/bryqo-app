# Bryqo Vertical Slice Design

Date: 2026-07-15
Status: Approved for implementation

## Goal

Build the first usable Bryqo vertical slice in the existing iOS SwiftUI app. The slice should demonstrate the core product loop from the product plan:

1. brief onboarding;
2. learning map;
3. five short lessons in one unit;
4. immediate exercise feedback;
5. local progress, XP, and streak;
6. review entry point;
7. visible valley/construction progress.

This is a prototype-quality local-first implementation, not the full MVP.

## Product Scope

The first unit is **Como a internet entrega uma página**.

Lessons:

1. Cliente e servidor
2. Endereço IP
3. DNS
4. Requisição e resposta
5. HTTP e HTTPS

The user can onboard, see the learning path, open lessons, answer exercises, complete lessons, earn XP, and see progress reflected in the valley.

## Out of Scope

The first slice will not include:

- account creation;
- Sign in with Apple;
- backend sync;
- real analytics;
- StoreKit or subscriptions;
- real local notifications;
- AI features;
- advanced adaptive review;
- remote content loading;
- user-generated content;
- full mascot illustration.

These are intentionally deferred because the product plan recommends validating the learning loop before expanding platform complexity.

## App Structure

The app will use a tab bar with four areas:

- **Aprender**: daily goal, Brix message, valley progress, unit map, next lesson.
- **Revisar**: review summary and a lightweight review session entry point.
- **Progresso**: XP, streak, completed lessons, unit progress, materials earned.
- **Perfil**: onboarding choices, daily goal, app status, and prototype settings.

## Onboarding

Onboarding is local and short. It asks:

- experience level;
- learning goal;
- daily goal in minutes.

After completion, the app opens the learning tab and treats the first lesson as the next recommended step.

## Lesson Flow

Each lesson is structured as local content, with multiple step types:

- story/context;
- concept explanation;
- single choice exercise;
- true or false exercise;
- ordering exercise;
- summary.

The lesson view shows one step at a time, gives immediate feedback on exercises, and allows the user to continue after answering. Completing a lesson updates progress, XP, streak, and the visual valley state.

## Data Model

Initial domain models:

- `LearningTrack`
- `LearningUnit`
- `Lesson`
- `LessonStep`
- `Exercise`
- `ExerciseOption`
- `UserProgress`
- `OnboardingProfile`

Content will be seeded in Swift for this first vertical slice. This keeps the first implementation fast and makes the UI and lesson engine easier to iterate. A later step can move content to JSON once the model stabilizes.

## Persistence

Progress can be stored in a lightweight local state container for the first build. SwiftData is not required for the first slice unless it remains useful after removing the template list behavior.

The current template `Item` list should not remain visible in the app experience.

## Visual Direction

The UI should feel warm, clear, and native:

- forest green, river blue, wood brown, warm highlight colors;
- compact cards and clear hierarchy;
- SF Symbols where useful;
- simple SwiftUI shapes for valley, river, bridge, dam, blocks, and materials;
- Brix represented through friendly copy in this slice, not a full custom illustration.

The app should avoid a childish tone. Brix should be encouraging, practical, and non-punitive.

## Accessibility

The implementation should support:

- Dynamic Type where practical;
- good contrast;
- tappable controls with comfortable hit areas;
- text labels alongside meaningful icons;
- feedback that does not rely only on color.

## Error Handling

Because all content is local, the main error cases are invalid state or unsupported lesson steps. Unsupported content should fail gracefully with a clear placeholder message rather than crash.

## Testing And Validation

Implementation validation should include:

- Xcode live diagnostics for changed Swift files where available;
- full Xcode build if a project/scheme is available;
- at least focused Swift Testing coverage for lesson completion/progress rules if feasible within the current project structure.

## Acceptance Criteria

The vertical slice is complete when:

- the template SwiftData list is replaced by the Bryqo experience;
- onboarding can be completed locally;
- the tab bar shows Aprender, Revisar, Progresso, and Perfil;
- Aprender shows the unit map and five lessons;
- at least the five planned lessons can be opened and completed;
- exercises show immediate feedback;
- completing lessons updates XP, streak/progress, and valley visuals;
- Revisar and Progresso reflect completed lesson state;
- the app builds successfully.
