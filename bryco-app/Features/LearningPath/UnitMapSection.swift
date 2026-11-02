import SwiftUI

struct UnitMapSection: View {
    let unit: LearningUnit
    let icon: String
    let tint: Color
    /// `tint` for text: darker in light mode so it stays readable.
    let ink: Color
    let appState: BryqoAppState
    let onSelectLesson: (Lesson) -> Void
    let onLockedTap: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Zigzag: left → center → right → center → repeat. At the accessibility sizes the path is a
    // straight column instead, so each lesson name gets the full width.
    private let xRatios: [CGFloat] = [0.22, 0.50, 0.78, 0.50]
    /// Room for two lines of the lesson name; grows with Dynamic Type, so the rows grow too.
    @ScaledMetric(relativeTo: .body) private var nameHeight: CGFloat = 36
    private var rowHeight: CGFloat { 92 + nameHeight }   // 128 at the default size
    private var isStraightPath: Bool { dynamicTypeSize.isAccessibilitySize }

    // MARK: - Computed

    /// Two lines fit beside the icon; stacked at the accessibility sizes, the text gets every line it needs.
    private var headerLineLimit: Int? { dynamicTypeSize.isAccessibilitySize ? nil : 2 }

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
        (isStraightPath ? 0.5 : xRatios[index % xRatios.count]) * width
    }

    private func nodeY(_ index: Int) -> CGFloat {
        rowHeight * CGFloat(index) + rowHeight / 2
    }

    /// The curve from lesson `index` to the next one.
    private func segment(_ index: Int, width: CGFloat) -> Path {
        let from = CGPoint(x: nodeX(index, width: width), y: nodeY(index))
        let to = CGPoint(x: nodeX(index + 1, width: width), y: nodeY(index + 1))
        var path = Path()
        path.move(to: from)
        path.addQuadCurve(to: to, control: CGPoint(x: to.x, y: from.y + (to.y - from.y) * 0.42))
        return path
    }

    // MARK: - Status

    private func lessonStatus(for lesson: Lesson) -> LessonStatus {
        if appState.isLessonCompleted(lesson) { return .completed }
        // Just unlocked but not revealed yet: it stays locked until the map is on screen.
        if lesson.id == appState.justUnlockedLessonId { return .locked }
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
            BryqoAdaptiveStack(verticalAlignment: .top, spacing: BryqoTheme.Spacing.lg) {
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
                        .bryqoFont(11, weight: .black)
                        .tracking(1.5)
                        .foregroundStyle(ink)

                    Text(unit.title)
                        .bryqoFont(17, relativeTo: .title3, weight: .black, design: .rounded)
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .lineLimit(headerLineLimit)

                    Text(unit.subtitle)
                        .font(.caption)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .lineLimit(headerLineLimit)
                }

                Spacer()

                // Lesson count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(completedCount)/\(unit.lessons.count)")
                        .bryqoFont(20, relativeTo: .title2, weight: .black, design: .rounded)
                        .foregroundStyle(ink)
                    Text("lições")
                        .font(.caption.bold())
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
            }

            BryqoProgressBar(
                progress: progress,
                colors: [tint, tint.opacity(0.65)],
                height: 8,
                accessibilityLabel: "Progresso da unidade"
            )

            if completedCount == unit.lessons.count, let firstLesson = unit.lessons.first {
                Button { onSelectLesson(firstLesson) } label: {
                    Label("PRATICAR NOVAMENTE", systemImage: "arrow.counterclockwise")
                        .bryqoFont(13, weight: .black)
                        .tracking(0.8)
                        .foregroundStyle(ink)
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
                    // The dashed track to every lesson…
                    Canvas { context, size in
                        for i in 0..<(unit.lessons.count - 1) {
                            context.stroke(
                                segment(i, width: size.width),
                                with: .color(BryqoTheme.border),
                                style: StrokeStyle(lineWidth: 4, dash: [8, 6])
                            )
                        }
                    }

                    // …and the solid path drawn over it up to every unlocked lesson. A Shape, not
                    // the Canvas, so `trim` animates: the path grows toward a lesson as it unlocks.
                    ForEach(0..<(unit.lessons.count - 1), id: \.self) { i in
                        let reached = completed[i] && lessonStatus(for: unit.lessons[i + 1]) != .locked
                        segment(i, width: w)
                            .trim(from: 0, to: reached ? 1 : 0)
                            .stroke(BryqoTheme.success, style: StrokeStyle(lineWidth: 5, lineCap: .round))
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
            ink: BryqoTheme.Ink.sun,
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
