import SwiftUI

struct UnitMapSection: View {
    let unit: LearningUnit
    let icon: String
    let tint: Color
    let appState: BryqoAppState
    let onSelectLesson: (Lesson) -> Void
    let onLockedTap: () -> Void

    // Zigzag: left → center → right → center → repeat
    private let xRatios: [CGFloat] = [0.22, 0.50, 0.78, 0.50]
    private let rowHeight: CGFloat = 128

    // MARK: - Computed

    private var completedCount: Int {
        unit.lessons.filter { appState.isLessonCompleted($0) }.count
    }

    private var progress: CGFloat {
        guard !unit.lessons.isEmpty else { return 0 }
        return CGFloat(completedCount) / CGFloat(unit.lessons.count)
    }

    private var sectionHeight: CGFloat {
        rowHeight * CGFloat(unit.lessons.count) + 50
    }

    // MARK: - Layout

    private func nodeX(_ index: Int, width: CGFloat) -> CGFloat {
        xRatios[index % xRatios.count] * width
    }

    private func nodeY(_ index: Int) -> CGFloat {
        rowHeight * CGFloat(index) + 64
    }

    // MARK: - Status

    private func lessonStatus(for lesson: Lesson) -> LessonStatus {
        if appState.isLessonCompleted(lesson) { return .completed }
        if !appState.canStartLesson(lesson, in: unit) { return .locked }
        return .current
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: BryqoTheme.Spacing.xl) {
            unitHeader
            lessonPath
        }
    }

    // MARK: - Unit Header

    private var unitHeader: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            HStack(alignment: .top, spacing: BryqoTheme.Spacing.lg) {
                // Icon
                Image(systemName: icon)
                    .font(.title2.bold())
                    .foregroundStyle(tint)
                    .frame(width: 52, height: 52)
                    .background(tint.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Titles
                VStack(alignment: .leading, spacing: 3) {
                    Text("UNIDADE")
                        .font(.system(size: 11, weight: .black))
                        .tracking(1.5)
                        .foregroundStyle(tint)

                    Text(unit.title)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .lineLimit(2)

                    Text(unit.subtitle)
                        .font(.caption)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                // Lesson count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(completedCount)/\(unit.lessons.count)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(tint)
                    Text("lições")
                        .font(.caption.bold())
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
            }

            // Animated progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(BryqoTheme.border)
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint, tint.opacity(0.65)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * progress), height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completedCount)
                }
            }
            .frame(height: 8)

            if completedCount == unit.lessons.count, let firstLesson = unit.lessons.first {
                Button { onSelectLesson(firstLesson) } label: {
                    Label("PRATICAR NOVAMENTE", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .black))
                        .tracking(0.8)
                        .foregroundStyle(tint)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(tint.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                                .strokeBorder(tint.opacity(0.3), lineWidth: 1.5)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(BryqoTheme.Spacing.lg)
        .background(tint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(tint.opacity(0.20), lineWidth: 1.5)
        }
    }

    // MARK: - Lesson Path

    private var lessonPath: some View {
        let completed = unit.lessons.map { appState.isLessonCompleted($0) }

        return ZStack(alignment: .top) {
            // Invisible layout anchors — ScrollViewProxy.scrollTo targets these
            VStack(spacing: 0) {
                ForEach(Array(unit.lessons.enumerated()), id: \.offset) { _, lesson in
                    Color.clear
                        .frame(height: rowHeight)
                        .id(lesson.id)
                }
                Color.clear.frame(height: 50)
            }

            // Visual path and nodes drawn over the anchors
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .top) {
                    Canvas { context, size in
                        for i in 0..<(unit.lessons.count - 1) {
                            let from = CGPoint(x: nodeX(i, width: size.width), y: nodeY(i))
                            let to   = CGPoint(x: nodeX(i + 1, width: size.width), y: nodeY(i + 1))

                            var path = Path()
                            path.move(to: from)
                            let control = CGPoint(x: to.x, y: from.y + (to.y - from.y) * 0.42)
                            path.addQuadCurve(to: to, control: control)

                            if completed[i] {
                                context.stroke(path, with: .color(BryqoTheme.success), lineWidth: 5)
                            } else {
                                context.stroke(
                                    path,
                                    with: .color(BryqoTheme.border),
                                    style: StrokeStyle(lineWidth: 4, dash: [8, 6])
                                )
                            }
                        }
                    }

                    ForEach(Array(unit.lessons.enumerated()), id: \.offset) { index, lesson in
                        let st = lessonStatus(for: lesson)
                        LessonMapNodeView(
                            lesson: lesson,
                            status: st,
                            entranceDelay: Double(index) * 0.07
                        ) {
                            if st == .locked { onLockedTap() } else { onSelectLesson(lesson) }
                        }
                        .position(x: nodeX(index, width: w), y: nodeY(index))
                    }
                }
            }
            .frame(height: sectionHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        UnitMapSection(
            unit: BryqoContent.sampleUnit,
            icon: "wifi",
            tint: BryqoTheme.sun,
            appState: {
                let s = BryqoAppState()
                s.completeLesson(BryqoContent.sampleUnit.lessons[0])
                s.completeLesson(BryqoContent.sampleUnit.lessons[1])
                return s
            }(),
            onSelectLesson: { _ in },
            onLockedTap: {}
        )
        .padding()
    }
    .background(BryqoTheme.background)
    .preferredColorScheme(.dark)
}
