//
//  bryco_appTests.swift
//  bryco-appTests
//
//  Created by Jenniffer Martins on 15/07/26.
//

import Testing
import SwiftUI
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
            displayName: "Jenniffer",
            experience: "Estou começando",
            goal: "Construir uma base",
            dailyGoalMinutes: 10
        )

        #expect(state.hasCompletedOnboarding)
        #expect(state.profile?.displayName == "Jenniffer")
        #expect(state.profile?.dailyGoalMinutes == 10)
    }

    @Test func themePreferenceSwitchesColorScheme() {
        let state = BryqoAppState()

        // Set the value explicitly rather than assuming a default — `isLightMode` is
        // backed by shared UserDefaults, so the starting value isn't test-isolated.
        state.isLightMode = false
        #expect(state.preferredColorScheme == .dark)

        state.isLightMode = true
        #expect(state.preferredColorScheme == .light)
    }

}
