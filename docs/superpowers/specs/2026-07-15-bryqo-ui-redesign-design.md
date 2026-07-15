# Bryqo UI Redesign Design

Date: 2026-07-15
Status: Approved for implementation

## Goal

Redesign the existing Bryqo vertical slice so it feels like a polished, professional, gamified iOS app. The redesign should follow the attached Bryqo design system, gamification bible, HIG, motion system, and Brix character bible.

The existing lesson/progress logic should remain intact. This work is primarily a UI, design system, and interaction polish pass.

## Visual Direction

The app should use a premium dark-first visual style inspired by the provided reference screenshots, while keeping a distinct Bryqo identity.

Core tokens:

- Background: `#1A1C1E`
- Surface: `#232628`
- Bryqo Green: `#3F8F5A`
- River Blue: `#4EA9E8`
- Wood Brown: `#8C6445`
- Stone: `#8A9099`
- Sun: `#F5B83D`
- Card radius: `20`
- Button radius: `18`
- Grid: `8pt`

The app should feel warm, calm, and tactile. It should use large cards, strong typography, pill stats, subtle borders, and clear selected/locked/completed states.

## Navigation

Replace the plain native tab presentation with a custom floating tab bar using the Bryqo HIG areas:

- Vale
- Aprender
- Mochila
- Conquistas
- Perfil

The current Review and Progress concepts should be represented through the new navigation:

- Review content can live in Mochila as reinforcement/review material.
- Progress and achievements can live under Conquistas.
- Vale becomes the primary visual progress/map area.

## Onboarding

Refactor onboarding into a staged flow:

1. Welcome screen with Bryqo identity, valley/Brix visual, slogan, and primary CTA.
2. Local profile screen with a name field and optional Sign in with Apple visual button. The Apple button is UI-only in this cycle and does not start authentication.
3. Track preview screen showing the three MVP tracks.
4. Daily goal screen with 5, 10, 15, and 20 minute options.

The bottom CTA should remain visually stable and fixed near the safe area. The flow should feel like the reference screenshots: generous spacing, large title text, dark background, large rounded cards, and River Blue primary CTA.

## Learn Screen

The Learn screen should become a gamified home:

- personalized greeting using the onboarding name when available;
- streak and XP pills;
- daily goal card with progress bar;
- large “Continuar” card for the next unlocked lesson;
- track cards with unlocked and locked states;
- clear visual hierarchy and short copy.

The screen should avoid looking like a settings/list template.

## Valley Screen

The Valley screen should visualize construction progress:

- dam/river/valley scene using polished SwiftUI shapes for now;
- lesson completion should add visible construction progress;
- copy should reinforce “aprender é construir”;
- Brix should appear as an avatar/companion element, not a full illustration asset.

## Mochila Screen

Mochila should represent the user’s learning materials:

- earned materials from completed lessons;
- review/reinforcement entry points;
- empty state that explains how to earn materials without guilt.

## Achievements Screen

Conquistas should show:

- XP total;
- level/progress to next level;
- streak/sequence;
- activity grid;
- achievement cards, including locked states.

## Profile Screen

Profile should match the reference screenshot:

- local account card with avatar;
- daily goal segmented options;
- notification toggle as UI-only for now;
- reduce motion toggle as UI-only for now;
- appearance note;
- support/privacy local-first messaging.

## Brix

Brix should follow the character bible:

- short, positive, practical copy;
- never punitive;
- no pressure around streaks;
- no infantilizing language.

In this redesign, Brix is represented with a compact avatar badge and contextual speech/copy. A full custom illustration is out of scope.

## Motion

Use motion sparingly:

- selection: spring;
- navigation/content transitions: easeInOut;
- success/progress: easeOut;
- duration range: 120ms to 350ms.

Respect Reduce Motion where practical. Haptics are optional for this pass.

## Architecture

Keep the current project structure:

- `App`
- `Core/DesignSystem`
- `Domain/Models`
- `Features`
- `Resources/Content`

Expected implementation changes:

- Expand `BryqoTheme` into a more complete token/component helper file.
- Add reusable design components where they reduce duplication.
- Replace `MainTabView` with a custom-tab-shell approach.
- Redesign feature views without changing domain model behavior unnecessarily.
- Extend onboarding profile minimally if a display name is needed.

## Out Of Scope

- Real Sign in with Apple.
- Real notifications permission or scheduling.
- Real persistent settings.
- Full asset pipeline for illustrated Brix.
- Backend, StoreKit, analytics, or AI.
- New lesson content.

## Testing And Validation

Validation should include:

- Xcode build;
- full test suite;
- live diagnostics on heavily edited Swift files;
- manual simulator check of onboarding, tab navigation, lesson start, lesson completion, and profile screen.

## Acceptance Criteria

The redesign is complete when:

- the app no longer feels like a raw SwiftUI template;
- dark-first visual style matches Bryqo design tokens;
- onboarding follows the staged reference style;
- tab navigation uses Vale, Aprender, Mochila, Conquistas, Perfil;
- Learn has a polished gamified home layout;
- Vale shows visual construction progress;
- Mochila and Conquistas replace the plain review/progress presentation;
- Profile resembles the reference quality and structure;
- lesson completion still updates XP, materials, and progress;
- build and tests pass;
- the final commit uses Conventional Commits.
