import Testing
@testable import bryco_app

@Suite("BinarySearchViewModel", .tags(.gamification))
struct BinarySearchViewModelTests {

    private func makeVM(target: Int) -> BinarySearchViewModel {
        BinarySearchViewModel(exercise: BinarySearchExercise(
            intro: "Ache o alvo.",
            array: [2, 5, 8, 12, 16, 23, 38, 56, 72, 91],
            target: target
        ))
    }

    @Test("A wrong comparison costs a mistake and does not narrow the window")
    func wrongChoicePenalized() {
        let vm = makeVM(target: 56)   // 56 > 16, correct is .higher
        vm.choose(.lower)

        #expect(vm.mistakeCount == 1)
        #expect(vm.lastWasWrong)
        #expect(vm.state.low == 0)      // unchanged
        #expect(vm.state.high == 9)
        #expect(vm.discarded.isEmpty)
    }

    @Test("A correct 'higher' discards the left half including the middle")
    func correctHigherDiscardsLeft() {
        let vm = makeVM(target: 56)
        vm.choose(.higher)

        #expect(vm.lastWasWrong == false)
        #expect(vm.state.low == 5)
        // indices 0...4 (values up to the mid 16) are ruled out
        #expect(vm.discarded.isSuperset(of: Set(0...4)))
    }

    @Test("Driving correct choices finds the target and reports the log-n win")
    func findsTargetQuickly() {
        let vm = makeVM(target: 72)
        while !vm.isFinished {
            vm.choose(BinarySearchEngine.correctChoice(vm.state)!)
        }
        #expect(vm.found)
        #expect(vm.stepsTaken <= 4)
        #expect(vm.linearWorstCase == 10)   // vs up to 10 for a linear scan
        #expect(vm.mistakeCount == 0)
    }

    @Test("Choosing after the search finished is a no-op")
    func choiceAfterFinishIgnored() {
        let vm = makeVM(target: 16)
        vm.choose(.equal)   // found immediately (16 is the mid)
        #expect(vm.found)

        vm.choose(.higher)
        #expect(vm.stepsTaken == 1)
        #expect(vm.mistakeCount == 0)
    }
}
