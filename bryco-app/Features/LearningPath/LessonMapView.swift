import SwiftUI

struct LessonMapView: View {
    let units: [LearningUnit]
    let appState: BryqoAppState

    @State private var selectedLesson: Lesson? = nil
    @State private var showLockedToast = false
    @State private var showNoHeartsSheet = false

    private let unitConfig: [(icon: String, tint: Color)] = [
        ("wifi",          BryqoTheme.sun),
        ("terminal.fill", BryqoTheme.river),
        ("cpu",           BryqoTheme.primary),
        ("bolt.fill",     Color(hex: 0xCE82FF))
    ]

    var body: some View {
        VStack(spacing: BryqoTheme.Spacing.xxxl) {
            ForEach(Array(units.enumerated()), id: \.offset) { index, unit in
                let cfg = unitConfig[min(index, unitConfig.count - 1)]
                if isUnitAvailable(at: index) {
                    UnitMapSection(
                        unit: unit,
                        icon: cfg.icon,
                        tint: cfg.tint,
                        appState: appState,
                        onSelectLesson: { lesson in
                            if appState.progress.hearts == 0 {
                                showNoHeartsSheet = true
                            } else {
                                selectedLesson = lesson
                            }
                        },
                        onLockedTap: showLockedMessage
                    )
                } else {
                    LockedUnitCard(unit: unit, icon: cfg.icon)
                }
            }
        }
        .navigationDestination(item: $selectedLesson) { lesson in
            LessonView(appState: appState, lesson: lesson)
        }
        .sheet(isPresented: $showNoHeartsSheet) {
            NoHeartsSheet(appState: appState)
        }
        .overlay(alignment: .bottom) {
            if showLockedToast {
                LockedLessonToast()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, BryqoTheme.Spacing.xl)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showLockedToast)
    }

    // MARK: - Helpers

    private func isUnitAvailable(at index: Int) -> Bool {
        guard index > 0 else { return true }
        return units[index - 1].lessons.allSatisfy { appState.isLessonCompleted($0) }
    }

    private func showLockedMessage() {
        guard !showLockedToast else { return }
        showLockedToast = true
        Task {
            try? await Task.sleep(for: .milliseconds(2400))
            showLockedToast = false
        }
    }
}

// MARK: - Locked Unit Card

private struct LockedUnitCard: View {
    let unit: LearningUnit
    let icon: String

    var body: some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(BryqoTheme.textSecondary)
                .frame(width: 52, height: 52)
                .background(BryqoTheme.border.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text("UNIDADE")
                    .bryqoFont(11, weight: .black)
                    .tracking(1.5)
                    .foregroundStyle(BryqoTheme.textSecondary)

                Text(unit.title)
                    .bryqoFont(17, weight: .black, design: .rounded)
                    .foregroundStyle(BryqoTheme.textSecondary)

                Text("Conclua a unidade anterior para desbloquear")
                    .font(.caption)
                    .foregroundStyle(BryqoTheme.textSecondary.opacity(0.7))
            }

            Spacer()
        }
        .padding(BryqoTheme.Spacing.lg)
        .background(BryqoTheme.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(BryqoTheme.border, lineWidth: 1.5)
        }
        .opacity(0.6)
    }
}

// MARK: - Locked Lesson Toast

private struct LockedLessonToast: View {
    var body: some View {
        Label("Complete a lição anterior para desbloquear", systemImage: "lock.fill")
            .bryqoFont(14, weight: .semibold, design: .rounded)
            .foregroundStyle(BryqoTheme.textPrimary)
            .padding(.horizontal, BryqoTheme.Spacing.xl)
            .padding(.vertical, BryqoTheme.Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay { Capsule().stroke(BryqoTheme.border.opacity(0.5), lineWidth: 1) }
            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 4)
    }
}
