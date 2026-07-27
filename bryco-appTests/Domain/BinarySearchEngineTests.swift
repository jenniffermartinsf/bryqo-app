import Testing
@testable import bryco_app

@Suite("Binary search engine", .tags(.gamification))
struct BinarySearchEngineTests {

    private let sorted = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]  // 10 elements, mid index 4 → 16

    @Test("Initial mid is the middle of the window")
    func initialMid() {
        let s = BinarySearchState(array: sorted, target: 23)
        #expect(s.low == 0)
        #expect(s.high == 9)
        #expect(s.mid == 4)
        #expect(s.midValue == 16)
    }

    @Test("Correct choice compares target to the middle value", arguments: [
        (8, BinarySearchChoice.lower),   // 8 < 16
        (16, BinarySearchChoice.equal),  // 16 == 16
        (56, BinarySearchChoice.higher)  // 56 > 16
    ])
    func correctChoiceMatchesComparison(target: Int, expected: BinarySearchChoice) {
        let s = BinarySearchState(array: sorted, target: target)
        #expect(BinarySearchEngine.correctChoice(s) == expected)
    }

    @Test("A 'higher' choice moves low past the middle")
    func higherNarrowsRight() {
        var s = BinarySearchState(array: sorted, target: 56)
        s = BinarySearchEngine.apply(.higher, to: s)
        #expect(s.low == 5)
        #expect(s.high == 9)
        #expect(s.stepsTaken == 1)
    }

    @Test("A 'lower' choice moves high before the middle")
    func lowerNarrowsLeft() {
        var s = BinarySearchState(array: sorted, target: 5)
        s = BinarySearchEngine.apply(.lower, to: s)
        #expect(s.low == 0)
        #expect(s.high == 3)
    }

    @Test("Equal marks the search as found")
    func equalFinds() {
        var s = BinarySearchState(array: sorted, target: 16)
        s = BinarySearchEngine.apply(.equal, to: s)
        #expect(s.found)
        #expect(s.isFinished)
    }

    @Test("Driving the correct choices finds any present target in ≤4 steps")
    func findsInLogNSteps() {
        for target in sorted {
            var s = BinarySearchState(array: sorted, target: target)
            var guard_ = 0
            while !s.isFinished, guard_ < 10 {
                s = BinarySearchEngine.apply(BinarySearchEngine.correctChoice(s)!, to: s)
                guard_ += 1
            }
            #expect(s.found, "should find \(target)")
            #expect(s.stepsTaken <= 4, "log2(10) ≈ 3.3, so ≤4 steps for \(target)")
        }
    }

    @Test("A missing target exhausts the window without finding")
    func missingTargetExhausts() {
        var s = BinarySearchState(array: sorted, target: 100)  // larger than everything
        while !s.isFinished {
            s = BinarySearchEngine.apply(BinarySearchEngine.correctChoice(s) ?? .equal, to: s)
        }
        #expect(s.found == false)
        #expect(s.exhausted)
    }
}
