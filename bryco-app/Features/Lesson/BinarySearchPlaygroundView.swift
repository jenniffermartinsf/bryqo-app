import SwiftUI

/// Interactive binary-search playground: the learner drives the search by comparing the target to
/// the middle element and watches half of the array get discarded each step. Self-contained; owns
/// its scroll + bottom button and reports the mistake count back to the lesson on completion.
struct BinarySearchPlaygroundView: View {
    let exercise: BinarySearchExercise
    let onFinished: (_ mistakes: Int) -> Void

    @State private var vm: BinarySearchViewModel

    init(exercise: BinarySearchExercise, onFinished: @escaping (Int) -> Void) {
        self.exercise = exercise
        self.onFinished = onFinished
        _vm = State(wrappedValue: BinarySearchViewModel(exercise: exercise))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                    badge
                    Text(exercise.intro)
                        .font(.body).lineSpacing(4)
                        .foregroundStyle(BryqoTheme.textSecondary)

                    targetChip
                    arrayRow

                    if vm.isFinished {
                        resultPanel
                    } else {
                        questionCard
                    }
                }
                .padding(BryqoTheme.Spacing.xl)
            }
            if vm.isFinished { bottomButton }
        }
        .sensoryFeedback(.error, trigger: vm.shakeTrigger)
        .sensoryFeedback(.success, trigger: vm.found)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: vm.state)
    }

    // MARK: Header

    private var badge: some View {
        Label("VISUALIZAR · BUSCA BINÁRIA", systemImage: "chart.bar.xaxis")
            .font(.subheadline.weight(.black)).tracking(1)
            .foregroundStyle(BryqoTheme.river)
            .padding(.horizontal, BryqoTheme.Spacing.lg)
            .padding(.vertical, BryqoTheme.Spacing.md)
            .background(BryqoTheme.river.opacity(0.14))
            .clipShape(Capsule())
    }

    private var targetChip: some View {
        HStack(spacing: BryqoTheme.Spacing.sm) {
            Image(systemName: "target").foregroundStyle(BryqoTheme.coral)
            Text("Procurando:").foregroundStyle(BryqoTheme.textSecondary)
            Text("\(exercise.target)")
                .font(.title3.weight(.black).monospacedDigit())
                .foregroundStyle(BryqoTheme.textPrimary)
        }
        .font(.subheadline.weight(.semibold))
    }

    // MARK: Array

    private var arrayRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(exercise.array.enumerated()), id: \.offset) { index, value in
                    cell(index: index, value: value)
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
        }
    }

    private func cell(index: Int, value: Int) -> some View {
        let isMid = index == vm.state.mid
        let isFound = vm.found && index == vm.state.mid
        let isDiscarded = vm.discarded.contains(index)

        let fill: Color = {
            if isFound { return BryqoTheme.success }
            if isMid { return BryqoTheme.river }
            return BryqoTheme.surface
        }()
        let textColor: Color = (isFound || isMid) ? .white : BryqoTheme.textPrimary

        return VStack(spacing: 4) {
            Text(isMid ? "meio" : " ")
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(BryqoTheme.river)

            Text("\(value)")
                .font(.system(.subheadline, design: .rounded).weight(.bold).monospacedDigit())
                .foregroundStyle(textColor)
                .frame(width: 40, height: 46)
                .background(fill)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isMid ? BryqoTheme.river : BryqoTheme.border, lineWidth: isMid ? 2 : 1)
                }
        }
        .opacity(isDiscarded ? 0.28 : 1)
    }

    // MARK: Question

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            if let midValue = vm.state.midValue {
                Text("O alvo **\(exercise.target)** é menor, igual ou maior que o meio **\(midValue)**?")
                    .font(.headline)
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: BryqoTheme.Spacing.md) {
                choiceButton("menor", systemImage: "arrow.left", choice: .lower, tint: BryqoTheme.river)
                choiceButton("igual", systemImage: "equal", choice: .equal, tint: BryqoTheme.success)
                choiceButton("maior", systemImage: "arrow.right", choice: .higher, tint: BryqoTheme.river)
            }

            if vm.lastWasWrong {
                Label("Compare o alvo com o valor do meio de novo.", systemImage: "lightbulb.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BryqoTheme.sun)
                    .transition(.opacity)
            }
        }
        .bryqoCard()
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: vm.lastWasWrong)
    }

    private func choiceButton(_ title: String, systemImage: String, choice: BinarySearchChoice, tint: Color) -> some View {
        Button {
            vm.choose(choice)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage).font(.headline)
                Text(title).font(.subheadline.weight(.bold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BryqoTheme.Spacing.lg)
            .background(tint.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                    .stroke(tint.opacity(0.35), lineWidth: 1.5)
            }
            .contentShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: Result

    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
            Label(vm.found ? "Encontrado!" : "Não está na lista",
                  systemImage: vm.found ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.headline.bold())
                .foregroundStyle(vm.found ? BryqoTheme.success : BryqoTheme.error)

            HStack(spacing: BryqoTheme.Spacing.xl) {
                stat(value: "\(vm.stepsTaken)", label: "passos\nbusca binária", tint: BryqoTheme.primary)
                Image(systemName: "arrow.left.arrow.right").foregroundStyle(BryqoTheme.textSecondary)
                stat(value: "até \(vm.linearWorstCase)", label: "passos\nbusca linear", tint: BryqoTheme.stone)
            }

            Text("É por isso que a busca binária é O(log n): cada passo joga fora metade da lista.")
                .font(.subheadline)
                .foregroundStyle(BryqoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bryqoCard()
    }

    private func stat(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title2.weight(.black)).foregroundStyle(tint)
            Text(label).font(.caption2).multilineTextAlignment(.center)
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomButton: some View {
        BryqoPrimaryButton(title: "CONCLUIR", color: BryqoTheme.primary) {
            onFinished(vm.mistakeCount)
        }
        .padding(BryqoTheme.Spacing.xl)
        .background(BryqoTheme.background)
    }
}
