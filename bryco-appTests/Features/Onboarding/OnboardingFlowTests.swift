import Foundation
import Testing
@testable import bryco_app

/// Covers the *outcome* of onboarding — the profile that `completeOnboarding` writes and the
/// profile-derived values the rest of the app reads. The step-by-step wizard itself lives inside
/// `OnboardingView` as `@State`, which is intentionally not unit-tested (views are excluded).
@Suite("Onboarding outcome", .tags(.gamification))
struct OnboardingFlowTests {

    private func makeState() -> BryqoAppState { BryqoAppState(inMemory: true) }

    @Test("Completing onboarding stores the profile and flips the completed flag")
    func completingStoresProfile() {
        let state = makeState()
        #expect(state.hasCompletedOnboarding == false)

        state.completeOnboarding(
            displayName: "Jenniffer",
            experience: "Sei o básico",
            goal: "Me preparar para entrevistas",
            dailyGoalMinutes: 15
        )

        #expect(state.hasCompletedOnboarding)
        #expect(state.profile?.displayName == "Jenniffer")
        #expect(state.profile?.experience == "Sei o básico")
        #expect(state.profile?.goal == "Me preparar para entrevistas")
        #expect(state.profile?.dailyGoalMinutes == 15)
    }

    @Test("A blank name falls back to \"construtor\"", arguments: ["", "   ", "\n\t"])
    func blankNameFallsBack(rawName: String) {
        let state = makeState()

        state.completeOnboarding(displayName: rawName, experience: "x", goal: "y", dailyGoalMinutes: 10)

        #expect(state.profile?.displayName == "construtor")
    }

    @Test("Resetting onboarding clears the profile")
    func resetClearsProfile() {
        let state = makeState()
        state.completeOnboarding(displayName: "Ana", experience: "x", goal: "y", dailyGoalMinutes: 10)
        #expect(state.hasCompletedOnboarding)

        state.resetOnboarding()

        #expect(state.hasCompletedOnboarding == false)
        #expect(state.profile == nil)
    }

    @Test("The daily goal tier maps the chosen minutes", arguments: [
        (5, "Casual"), (10, "Regular"), (15, "Sério"), (20, "Intenso")
    ])
    func dailyGoalTierLabel(minutes: Int, tier: String) {
        let state = makeState()
        state.completeOnboarding(displayName: "Ana", experience: "x", goal: "y", dailyGoalMinutes: minutes)

        #expect(state.dailyGoalTier == tier)
        #expect(state.dailyGoalXp == BryqoAppState.xpGoal(for: minutes))
    }

    @Test("Daily goal progress is XP earned over the tier goal, capped at 100%")
    func dailyGoalProgressIsCapped() {
        let state = makeState()
        state.completeOnboarding(displayName: "Ana", experience: "x", goal: "y", dailyGoalMinutes: 10) // goal = 30 XP

        state.progress.dailyXpEarned = 15
        #expect(abs(state.dailyGoalProgress - 0.5) < 0.0001)

        state.progress.dailyXpEarned = 90
        #expect(state.dailyGoalProgress == 1.0)
    }
}
