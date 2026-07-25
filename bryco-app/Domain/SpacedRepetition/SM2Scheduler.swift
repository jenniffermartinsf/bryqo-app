import Foundation

/// The SM-2 spaced-repetition scheduler (SuperMemo 2).
///
/// Pure and deterministic: given a quality grade and the previous `ReviewState`, it returns the
/// next schedule. All time math goes through the injected `now`/`calendar`, so tests can pin dates.
enum SM2Scheduler {
    /// Lowest allowed easiness factor.
    static let minEase = 1.3
    /// Starting easiness factor for a brand-new item.
    static let defaultEase = 2.5

    /// Maps a finished lesson's mistake count to an SM-2 quality grade (0–5).
    /// A grade below 3 is treated as a lapse and forces the lesson to be relearned.
    static func quality(forMistakes mistakes: Int) -> Int {
        switch mistakes {
        case 0: return 5   // flawless
        case 1: return 4
        case 2: return 3
        default: return 2  // lapse → relearn
        }
    }

    /// Applies one review with `quality` to `existing` (or a fresh item) and returns the new schedule.
    static func schedule(
        quality: Int,
        for lessonId: String,
        from existing: ReviewState?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> ReviewState {
        let q = max(0, min(5, quality))
        var repetitions = existing?.repetitions ?? 0
        var ease = existing?.easeFactor ?? defaultEase
        let previousInterval = existing?.intervalDays ?? 0
        let interval: Int

        if q < 3 {
            // Lapse: reset the streak and relearn tomorrow.
            repetitions = 0
            interval = 1
        } else {
            switch repetitions {
            case 0: interval = 1
            case 1: interval = 6
            default: interval = max(1, Int((Double(previousInterval) * ease).rounded()))
            }
            repetitions += 1
        }

        // Classic SM-2 easiness update, clamped to the floor.
        ease += 0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02)
        ease = max(minEase, ease)

        let nextReviewAt = calendar.date(byAdding: .day, value: interval, to: now) ?? now
        return ReviewState(
            lessonId: lessonId,
            repetitions: repetitions,
            easeFactor: ease,
            intervalDays: interval,
            lastReviewedAt: now,
            nextReviewAt: nextReviewAt
        )
    }
}
