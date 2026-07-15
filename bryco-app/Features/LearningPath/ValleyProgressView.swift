import SwiftUI

struct ValleyProgressView: View {
    let completedLessons: Int
    let totalLessons: Int

    private var progress: Double {
        guard totalLessons > 0 else {
            return 0
        }

        return Double(completedLessons) / Double(totalLessons)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vale em construção")
                        .font(.headline)
                    Text(progressMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.title3.bold())
                    .foregroundStyle(BryqoTheme.forest)
            }

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [BryqoTheme.softBackground, BryqoTheme.leaf.opacity(0.45)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                river
                damBlocks
                bridge
                trees
            }
            .frame(height: 190)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Vale com \(completedLessons) de \(totalLessons) lições concluídas")
        }
        .bryqoCard()
    }

    private var progressMessage: String {
        switch completedLessons {
        case 0:
            return "Brix separou os primeiros materiais."
        case 1...2:
            return "Os primeiros blocos já estão no lugar."
        case 3...4:
            return "A passagem pelo rio está tomando forma."
        default:
            return "Essa parte da construção ficou pronta."
        }
    }

    private var river: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 150))
            path.addCurve(to: CGPoint(x: 340, y: 135), control1: CGPoint(x: 90, y: 120), control2: CGPoint(x: 230, y: 175))
            path.addLine(to: CGPoint(x: 340, y: 190))
            path.addLine(to: CGPoint(x: 0, y: 190))
            path.closeSubpath()
        }
        .fill(BryqoTheme.river.opacity(0.85))
    }

    private var damBlocks: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalLessons, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(index < completedLessons ? BryqoTheme.wood : BryqoTheme.stone.opacity(0.35))
                    .frame(width: 32, height: CGFloat(26 + min(index, 3) * 8))
                    .accessibilityHidden(true)
            }
        }
        .padding(.bottom, 22)
    }

    private var bridge: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(completedLessons >= 3 ? BryqoTheme.sunlight : BryqoTheme.wood.opacity(0.35))
            .frame(width: 150, height: 12)
            .offset(y: -80)
    }

    private var trees: some View {
        HStack {
            Image(systemName: "tree.fill")
            Spacer()
            Image(systemName: completedLessons >= totalLessons ? "water.waves" : "leaf.fill")
        }
        .font(.system(size: 34))
        .foregroundStyle(BryqoTheme.forest)
        .padding(.horizontal, 26)
        .padding(.bottom, 112)
    }
}

#Preview {
    ValleyProgressView(completedLessons: 3, totalLessons: 5)
}
