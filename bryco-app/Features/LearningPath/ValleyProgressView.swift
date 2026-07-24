import SwiftUI

struct ValleyProgressView: View {
    let completedLessons: Int
    let totalLessons: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var wheelRotation: Double = 0
    @State private var brixFloat: CGFloat = 0
    @State private var cloudOffset: CGFloat = 0

    private var progress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            scene
                .frame(height: 270)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(BryqoTheme.border, lineWidth: 1.5)
                }

            // Floating progress chip
            progressChip
                .padding(16)
        }
        .onAppear {
            // Respect Reduce Motion: keep the scene static instead of perpetually animating.
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                wheelRotation = 360
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                brixFloat = -8
            }
            withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                cloudOffset = 18
            }
        }
    }

    // MARK: - Scene

    private var scene: some View {
        ZStack(alignment: .bottom) {
            // Sky gradient
            LinearGradient(
                colors: [Color(hex: 0xC5E8F7), Color(hex: 0xA8D8A0), Color(hex: 0x6BAB6B)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Sun
            Circle()
                .fill(BryqoTheme.sun.opacity(0.9))
                .frame(width: 46, height: 46)
                .shadow(color: BryqoTheme.sun.opacity(0.5), radius: 12, x: 0, y: 0)
                .offset(x: 90, y: -190)

            // Clouds
            clouds

            // Background hills (farthest layer)
            Capsule()
                .fill(Color(hex: 0x8DC87A).opacity(0.55))
                .frame(width: 260, height: 110)
                .offset(x: -90, y: -60)

            Capsule()
                .fill(Color(hex: 0x8DC87A).opacity(0.4))
                .frame(width: 240, height: 100)
                .offset(x: 110, y: -52)

            // Ground layer
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(hex: 0x5A9E52))
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .offset(y: 10)

            // River
            riverPath

            // Trees (left + right of dam)
            tree(xOffset: -140)
            tree(xOffset: 130)

            // Dam blocks
            damBlocks

            // Waterwheel
            waterwheel
                .offset(x: 52, y: -62)

            // Brix on left
            Image("BrixNeutro")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .offset(x: -110, y: brixFloat - 56)
                .accessibilityHidden(true)   // decorative mascot in the scene
        }
    }

    // MARK: - Scene Elements

    private var clouds: some View {
        ZStack {
            cloudShape(width: 80, height: 28)
                .offset(x: -70 + cloudOffset, y: -200)
            cloudShape(width: 60, height: 22)
                .offset(x: 40 - cloudOffset * 0.6, y: -185)
        }
    }

    private func cloudShape(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.82))
            .frame(width: width, height: height)
    }

    private var riverPath: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 200))
            path.addCurve(
                to: CGPoint(x: 380, y: 185),
                control1: CGPoint(x: 90, y: 145),
                control2: CGPoint(x: 250, y: 230)
            )
            path.addLine(to: CGPoint(x: 380, y: 270))
            path.addLine(to: CGPoint(x: 0, y: 270))
            path.closeSubpath()
        }
        .fill(BryqoTheme.river.opacity(0.65))
    }

    private var damBlocks: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalLessons, id: \.self) { index in
                RoundedRectangle(cornerRadius: 5)
                    .fill(index < completedLessons
                        ? BryqoTheme.wood
                        : BryqoTheme.stone.opacity(0.28))
                    .frame(width: 26, height: CGFloat(44 + (index % 3) * 10))
                    .shadow(color: (index < completedLessons ? BryqoTheme.wood : Color.clear).opacity(0.4), radius: 2, y: 2)
            }
        }
        .padding(.bottom, 28)
    }

    private var waterwheel: some View {
        ZStack {
            // Hub
            Circle()
                .fill(BryqoTheme.wood)
                .frame(width: 18, height: 18)

            // Spokes
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(BryqoTheme.wood)
                    .frame(width: 3, height: 32)
                    .rotationEffect(.degrees(Double(i) * 45))
            }

            // Outer ring
            Circle()
                .stroke(BryqoTheme.wood, lineWidth: 3)
                .frame(width: 34, height: 34)
        }
        .rotationEffect(.degrees(wheelRotation))
    }

    private func tree(xOffset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color(hex: 0x4A9640))
                .frame(width: 26, height: 26)
            Rectangle()
                .fill(BryqoTheme.wood)
                .frame(width: 5, height: 18)
        }
        .offset(x: xOffset, y: -52)
    }

    // MARK: - Progress Chip

    private var progressChip: some View {
        HStack(spacing: BryqoTheme.Spacing.sm) {
            Image(systemName: "water.waves")
                .font(.caption.weight(.bold))
                .foregroundStyle(BryqoTheme.river)

            VStack(alignment: .leading, spacing: 3) {
                Text("A Grande Barragem")
                    .font(.caption.weight(.black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                // Segmented progress bar
                HStack(spacing: 3) {
                    ForEach(0..<max(totalLessons, 1), id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i < completedLessons ? BryqoTheme.primary : BryqoTheme.border)
                            .frame(width: 18, height: 5)
                    }
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .padding(.leading, 2)
                }
            }
        }
        .padding(.horizontal, BryqoTheme.Spacing.md)
        .padding(.vertical, BryqoTheme.Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(BryqoTheme.border, lineWidth: 1)
        }
    }
}

#Preview {
    ValleyProgressView(completedLessons: 2, totalLessons: 5)
        .padding()
}
