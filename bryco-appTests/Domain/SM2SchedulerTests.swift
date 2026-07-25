import Foundation
import Testing
@testable import bryco_app

/// The SM-2 scheduler is pure and deterministic, so every case pins `now` and asserts the exact
/// resulting schedule.
@Suite("SM-2 scheduler", .tags(.gamification))
struct SM2SchedulerTests {

    private let anchor = Date(timeIntervalSince1970: 1_700_000_000)

    private func daysBetween(_ a: Date, _ b: Date) -> Int {
        Calendar.current.dateComponents([.day], from: a, to: b).day ?? -1
    }

    // MARK: - Quality mapping

    @Test("Mistake count maps to an SM-2 quality grade", arguments: [
        (0, 5), (1, 4), (2, 3), (3, 2), (7, 2)
    ])
    func qualityFromMistakes(mistakes: Int, expected: Int) {
        #expect(SM2Scheduler.quality(forMistakes: mistakes) == expected)
    }

    // MARK: - First reviews

    @Test("A brand-new perfect review schedules one day out")
    func firstPerfectReview() {
        let state = SM2Scheduler.schedule(quality: 5, for: "l1", from: nil, now: anchor)

        #expect(state.repetitions == 1)
        #expect(state.intervalDays == 1)
        #expect(daysBetween(anchor, state.nextReviewAt) == 1)
        #expect(state.easeFactor > SM2Scheduler.defaultEase) // q=5 raises ease
    }

    @Test("The second successful review jumps to six days")
    func secondReviewIsSixDays() {
        let first = SM2Scheduler.schedule(quality: 5, for: "l1", from: nil, now: anchor)
        let second = SM2Scheduler.schedule(quality: 4, for: "l1", from: first, now: anchor)

        #expect(second.repetitions == 2)
        #expect(second.intervalDays == 6)
    }

    @Test("From the third review on, interval grows by the ease factor")
    func thirdReviewUsesEase() {
        var state = SM2Scheduler.schedule(quality: 5, for: "l1", from: nil, now: anchor)   // interval 1
        state = SM2Scheduler.schedule(quality: 5, for: "l1", from: state, now: anchor)       // interval 6
        let third = SM2Scheduler.schedule(quality: 5, for: "l1", from: state, now: anchor)

        #expect(third.repetitions == 3)
        // interval = round(6 * ease); ease is a bit above 2.5 → ~15-16 days
        #expect(third.intervalDays >= 15)
    }

    // MARK: - Lapses

    @Test("A lapse (quality < 3) resets repetitions and relearns tomorrow")
    func lapseResets() {
        var state = SM2Scheduler.schedule(quality: 5, for: "l1", from: nil, now: anchor)
        state = SM2Scheduler.schedule(quality: 5, for: "l1", from: state, now: anchor) // reps 2, interval 6
        let lapsed = SM2Scheduler.schedule(quality: 1, for: "l1", from: state, now: anchor)

        #expect(lapsed.repetitions == 0)
        #expect(lapsed.intervalDays == 1)
    }

    @Test("The ease factor never drops below the floor")
    func easeHasFloor() {
        var state: ReviewState? = nil
        // Hammer with the worst passing-then-failing grades to push ease down.
        for _ in 0..<10 {
            state = SM2Scheduler.schedule(quality: 0, for: "l1", from: state, now: anchor)
        }

        #expect(state!.easeFactor == SM2Scheduler.minEase)
    }
}
