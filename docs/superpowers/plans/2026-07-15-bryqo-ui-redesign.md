# Bryqo UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign Bryqo into a polished dark-first gamified iOS experience using the attached Bryqo design system.

**Architecture:** Preserve the existing domain/content/progress model and replace the visual shell, onboarding, and feature screens. Add reusable design-system components in `Core/DesignSystem` so feature screens share cards, buttons, pills, Brix avatar, and floating tabs. Keep all behavior local-first and avoid introducing backend/auth/notification implementation.

**Tech Stack:** Swift, SwiftUI, Observation, Swift Testing, SF Symbols.

## Global Constraints

- Use Bryqo design tokens: `#1A1C1E`, `#232628`, `#3F8F5A`, `#4EA9E8`, `#8C6445`, `#8A9099`, `#F5B83D`.
- Use card radius `20`, button radius `18`, and 8pt grid spacing.
- Navigation uses: Vale, Aprender, Mochila, Conquistas, Perfil.
- Sign in with Apple, notifications, settings persistence, backend, StoreKit, analytics, and AI remain out of scope.
- Brix copy must be short, positive, practical, and non-punitive.
- Existing lesson completion must still update XP, materials, and progress.
- Commits must use Conventional Commits.

---

### Task 1: Design System Foundation

**Files:**
- Modify: `bryco-app/Core/DesignSystem/BryqoTheme.swift`

**Interfaces:**
- Produces: `BryqoTheme` tokens, `BryqoScreen`, `BryqoPrimaryButton`, `BryqoCard`, `BryqoStatPill`, `BrixAvatar`, `BrixSpeechBubble`.

- [ ] **Step 1: Expand design system**

Replace the current theme with dark-first tokens and reusable components for screen background, cards, buttons, stats, Brix avatar, and Brix speech bubble.

- [ ] **Step 2: Build**

Run Xcode BuildProject.

Expected: PASS.

### Task 2: Onboarding Redesign

**Files:**
- Modify: `bryco-app/Domain/Models/BryqoModels.swift`
- Modify: `bryco-app/App/BryqoAppState.swift`
- Modify: `bryco-app/Features/Onboarding/OnboardingView.swift`
- Modify: `bryco-appTests/bryco_appTests.swift`

**Interfaces:**
- Produces: `OnboardingProfile.displayName`.
- Updates: `BryqoAppState.completeOnboarding(displayName:experience:goal:dailyGoalMinutes:)`.

- [ ] **Step 1: Add display name to onboarding model and tests**

Update `OnboardingProfile` and the onboarding test to expect `displayName`.

- [ ] **Step 2: Redesign onboarding**

Replace the single scroll view with a staged flow: welcome, local profile, track preview, daily goal. Use dark background, large title text, large cards, fixed bottom CTA, and River Blue CTA.

- [ ] **Step 3: Run tests**

Run Xcode RunAllTests.

Expected: PASS.

### Task 3: Custom App Shell

**Files:**
- Modify: `bryco-app/App/MainTabView.swift`
- Create: `bryco-app/Features/Valley/ValleyView.swift`
- Create: `bryco-app/Features/Backpack/BackpackView.swift`
- Create: `bryco-app/Features/Achievements/AchievementsView.swift`

**Interfaces:**
- Produces: custom floating tab shell with `Vale`, `Aprender`, `Mochila`, `Conquistas`, `Perfil`.
- Consumes: existing `LearnView`, `ProfileView`, `BryqoAppState`, and `BryqoContent.sampleUnit`.

- [ ] **Step 1: Replace native TabView**

Implement a custom tab shell with a floating rounded navigation bar.

- [ ] **Step 2: Add new feature screens**

Add Valley, Backpack, and Achievements screens using design-system components.

- [ ] **Step 3: Build**

Run Xcode BuildProject.

Expected: PASS.

### Task 4: Learn And Lesson Visual Polish

**Files:**
- Modify: `bryco-app/Features/LearningPath/LearnView.swift`
- Modify: `bryco-app/Features/Lesson/LessonView.swift`
- Modify: `bryco-app/Features/LearningPath/ValleyProgressView.swift`

**Interfaces:**
- Consumes: `BryqoTheme`, `BryqoCard`, `BryqoPrimaryButton`, `BrixAvatar`, `BryqoStatPill`.
- Preserves: `LessonView` calls `appState.completeLesson(lesson)`.

- [ ] **Step 1: Redesign Learn**

Create a polished home with greeting, XP/streak pills, daily goal card, large continue card, and track/lesson cards.

- [ ] **Step 2: Redesign Lesson**

Apply dark-first cards, strong progress header, polished answer cards, and non-punitive Brix feedback.

- [ ] **Step 3: Improve Valley progress component**

Make the construction visualization richer and consistent with the dark-first style.

- [ ] **Step 4: Build**

Run Xcode BuildProject.

Expected: PASS.

### Task 5: Profile And Compatibility Cleanup

**Files:**
- Modify: `bryco-app/Features/Profile/ProfileView.swift`
- Modify as needed: `bryco-app/Features/Review/ReviewView.swift`
- Modify as needed: `bryco-app/Features/Progress/BryqoProgressView.swift`

**Interfaces:**
- Profile consumes `OnboardingProfile.displayName`.
- Old Review/Progress views may remain compile-safe even if no longer in main navigation.

- [ ] **Step 1: Redesign Profile**

Match the reference structure: account card, daily goal segmented row, notification toggle, reduce motion toggle, appearance note, support/local-first card.

- [ ] **Step 2: Keep old screens compile-safe**

Update Review/Progress styles or leave them buildable if not used in the custom tab shell.

- [ ] **Step 3: Run tests and build**

Run Xcode RunAllTests and BuildProject.

Expected: PASS.

### Task 6: Final Commit

**Files:**
- All changed implementation files.
- `docs/superpowers/plans/2026-07-15-bryqo-ui-redesign.md`

**Interfaces:**
- Produces final Conventional Commit.

- [ ] **Step 1: Check git status**

Run: `git status --short`

Expected: only intentional redesign files are changed.

- [ ] **Step 2: Commit**

Run:

```bash
git add bryco-app bryco-appTests docs/superpowers/plans/2026-07-15-bryqo-ui-redesign.md
git commit -m "feat: redesign Bryqo gamified UI"
```

## Self-Review

- Spec coverage: design tokens, onboarding, custom navigation, learn, valley, backpack, achievements, profile, Brix copy, and validation are covered.
- Placeholder scan: no task depends on unspecified future work.
- Type consistency: `OnboardingProfile.displayName` and `completeOnboarding(displayName:experience:goal:dailyGoalMinutes:)` are introduced before use.
