import SwiftUI

struct ValleyProgressView: View {
    let completedLessons: Int
    let totalLessons: Int

    private var progress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                    Text("Vale em construção")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text(progressMessage)
                        .foregroundStyle(BryqoTheme.textSecondary)
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.title3.bold())
                    .foregroundStyle(BryqoTheme.river)
            }

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x2F3D36), Color(hex: 0x1D2A30), BryqoTheme.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                moon
                hills
                river
                damBlocks
                bridge
                BrixAvatar(size: 46)
                    .offset(x: -120, y: -38)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                    .stroke(BryqoTheme.border, lineWidth: 1.5)
            }
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
            return "A ponte começou a cruzar o rio."
        default:
            return "Essa parte da construção ficou pronta."
        }
    }

    private var moon: some View {
        Circle()
            .fill(BryqoTheme.sun.opacity(0.9))
            .frame(width: 44, height: 44)
            .blur(radius: 0.4)
            .offset(x: 92, y: -168)
    }

    private var hills: some View {
        ZStack {
            Capsule()
                .fill(BryqoTheme.primary.opacity(0.34))
                .frame(width: 220, height: 100)
                .offset(x: -100, y: -50)
            Capsule()
                .fill(BryqoTheme.primary.opacity(0.22))
                .frame(width: 250, height: 116)
                .offset(x: 120, y: -44)
        }
    }

    private var river: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 190))
            path.addCurve(to: CGPoint(x: 380, y: 170), control1: CGPoint(x: 95, y: 135), control2: CGPoint(x: 250, y: 225))
            path.addLine(to: CGPoint(x: 380, y: 260))
            path.addLine(to: CGPoint(x: 0, y: 260))
            path.closeSubpath()
        }
        .fill(BryqoTheme.river.opacity(0.72))
    }

    private var damBlocks: some View {
        HStack(spacing: 5) {
            ForEach(0..<totalLessons, id: \.self) { index in
                RoundedRectangle(cornerRadius: 5)
                    .fill(index < completedLessons ? BryqoTheme.wood : BryqoTheme.stone.opacity(0.24))
                    .frame(width: 28, height: CGFloat(40 + (index % 3) * 12))
            }
        }
        .padding(.bottom, 34)
    }

    private var bridge: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(completedLessons >= 3 ? BryqoTheme.sun : BryqoTheme.wood.opacity(0.35))
            .frame(width: 140, height: 10)
            .offset(y: -112)
    }
}

#Preview {
    ValleyProgressView(completedLessons: 3, totalLessons: 5)
}
