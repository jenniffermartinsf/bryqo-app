import SwiftUI

struct ValleyView: View {
    let appState: BryqoAppState
    let unit: LearningUnit
    let units: [LearningUnit]

    @State private var selectedLesson: Lesson?
    @State private var showNoHeartsSheet = false

    private var nextLesson: Lesson? {
        for u in units {
            if let lesson = u.lessons.first(where: { !appState.isLessonCompleted($0) }) {
                return lesson
            }
        }
        return nil
    }

    private var nextLessonUnit: LearningUnit? {
        units.first { u in u.lessons.contains { !appState.isLessonCompleted($0) } }
    }

    private var unitCompletedCount: Int {
        guard let u = nextLessonUnit else { return 0 }
        return u.lessons.filter { appState.isLessonCompleted($0) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                    header
                    dailyGoalCard
                    if progress.hearts < BryqoAppState.heartsMax {
                        heartsRegenCard
                    }
                    if appState.isStreakAtRisk {
                        streakAtRiskBanner
                    }
                    ValleyProgressView(
                        completedLessons: appState.completedLessonCount,
                        totalLessons: unit.lessons.count
                    )
                    continueCard
                    BrixSpeechBubble(text: appState.completedLessonCount == 0
                        ? "Vamos colocar o primeiro bloco?"
                        : "Mais um bloco colocado. Essa estrutura está ficando sólida.")
                    constructions
                }
                .padding(BryqoTheme.Spacing.xl)
            }
            .background(BryqoTheme.background)
            .navigationDestination(item: $selectedLesson) { lesson in
                LessonView(appState: appState, lesson: lesson)
            }
            .sheet(isPresented: $showNoHeartsSheet) {
                NoHeartsSheet(appState: appState)
            }
        }
    }

    // MARK: - Streak At-Risk Banner

    private var streakAtRiskBanner: some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Text("🔥")
                .font(.title2)

            VStack(alignment: .leading, spacing: 3) {
                Text("Sequência em risco!")
                    .font(.headline.bold())
                    .foregroundStyle(BryqoTheme.warning)

                Text(progress.streakFreezeCount > 0
                     ? "Estude hoje ou seu freeze será usado automaticamente."
                     : "Estude hoje para não quebrar \(appState.progress.streakDays) dias consecutivos.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if progress.streakFreezeCount > 0 {
                Label("\(progress.streakFreezeCount)", systemImage: "snowflake")
                    .font(.caption.weight(.black))
                    .foregroundStyle(BryqoTheme.river)
                    .padding(.horizontal, BryqoTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(BryqoTheme.river.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(BryqoTheme.Spacing.lg)
        .background(BryqoTheme.warning.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(BryqoTheme.warning.opacity(0.35), lineWidth: 1.5)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var progress: UserProgress { appState.progress }

    // MARK: - Daily Goal Card

    private var dailyGoalCard: some View {
        HStack(spacing: BryqoTheme.Spacing.xl) {
            DailyGoalRing(
                earnedXp: progress.dailyXpEarned,
                goalXp: appState.dailyGoalXp,
                progress: appState.dailyGoalProgress
            )

            VStack(alignment: .leading, spacing: 5) {
                Text("META · \(appState.dailyGoalTier.uppercased())")
                    .font(.caption.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(BryqoTheme.textSecondary)

                Text("\(progress.dailyXpEarned) / \(appState.dailyGoalXp) XP")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress.dailyXpEarned)

                if appState.dailyGoalProgress >= 1.0 {
                    Label("Meta atingida hoje!", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BryqoTheme.success)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    let remaining = appState.dailyGoalXp - progress.dailyXpEarned
                    Text("Faltam \(remaining) XP")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: remaining)
                }
            }

            Spacer()
        }
        .bryqoCard()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.dailyGoalProgress >= 1.0)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bom te ver de volta")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)

                Text(appState.profile?.displayName ?? "construtor")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)
            }

            Spacer()

            HStack(spacing: BryqoTheme.Spacing.sm) {
                BryqoStatPill(
                    value: "\(appState.progress.streakDays)",
                    icon: "flame.fill",
                    tint: BryqoTheme.coral
                )
                BryqoStatPill(
                    value: "\(appState.progress.xp) XP",
                    icon: "star.fill",
                    tint: BryqoTheme.sun
                )
            }
        }
    }

    // MARK: - Continue Card

    private var continueCard: some View {
        Button {
            if let lesson = nextLesson {
                if appState.progress.hearts == 0 {
                    showNoHeartsSheet = true
                } else {
                    selectedLesson = lesson
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                Text(nextLessonUnit.map { "TRACK · \($0.title.uppercased())" } ?? "UNIDADE COMPLETA")
                    .font(.caption.weight(.black))
                    .tracking(1.4)
                    .foregroundStyle(BryqoTheme.river)

                Text(nextLesson?.title ?? "Toda a trilha foi concluída!")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                // Segmented progress bar
                if let u = nextLessonUnit {
                    HStack(spacing: 5) {
                        ForEach(0..<u.lessons.count, id: \.self) { i in
                            let completed = appState.isLessonCompleted(u.lessons[i])
                            let isCurrent = !completed && i == unitCompletedCount
                            RoundedRectangle(cornerRadius: 3)
                                .fill(completed
                                    ? BryqoTheme.primary
                                    : isCurrent ? BryqoTheme.sun : BryqoTheme.border)
                                .frame(height: 6)
                        }
                    }
                }

                HStack {
                    Spacer()
                    HStack(spacing: BryqoTheme.Spacing.sm) {
                        Text("Continuar construindo")
                            .font(.headline.bold())
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, BryqoTheme.Spacing.xl)
                    .frame(height: 46)
                    .background(nextLesson != nil ? BryqoTheme.primary : BryqoTheme.stone)
                    .clipShape(Capsule())
                }
            }
            .padding(BryqoTheme.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BryqoTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                    .stroke(BryqoTheme.border, lineWidth: 1.5)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(nextLesson == nil)
    }

    // MARK: - Constructions

    private var constructions: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Construções")
            constructionRow("Barragem inicial", icon: "water.waves", progress: appState.completedLessonCount, target: 5)
            constructionRow("Ponte do fluxo", icon: "point.topleft.down.curvedto.point.bottomright.up", progress: max(appState.completedLessonCount - 2, 0), target: 3)
            constructionRow("Oficina do Brix", icon: "hammer.fill", progress: max(appState.completedLessonCount - 4, 0), target: 1)
        }
    }

    private func constructionRow(_ title: String, icon: String, progress: Int, target: Int) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(BryqoTheme.river)
                .frame(width: 46, height: 46)
                .background(BryqoTheme.river.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(BryqoTheme.textPrimary)

                ProgressView(value: Double(min(progress, target)), total: Double(target))
                    .tint(BryqoTheme.primary)

                Text("\(min(progress, target))/\(target) blocos")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
        }
        .bryqoCard()
    }
}

// MARK: - Hearts Regen Card

extension ValleyView {
    var heartsRegenCard: some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            // Heart slots
            HStack(spacing: 5) {
                ForEach(0..<BryqoAppState.heartsMax, id: \.self) { index in
                    Image(systemName: index < progress.hearts ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(index < progress.hearts ? BryqoTheme.error : BryqoTheme.border)
                }
            }

            Spacer()

            // Countdown
            if let nextAt = appState.nextHeartAt {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    let remaining = max(0, nextAt.timeIntervalSinceNow)
                    let mins = Int(remaining) / 60
                    let secs = Int(remaining) % 60
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("próximo coração")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BryqoTheme.textSecondary)
                        Text(String(format: "%d:%02d", mins, secs))
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundStyle(BryqoTheme.warning)
                            .contentTransition(.numericText())
                    }
                }
            }
        }
        .padding(BryqoTheme.Spacing.lg)
        .background(BryqoTheme.error.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(BryqoTheme.error.opacity(0.20), lineWidth: 1.5)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

private struct DailyGoalRing: View {
    let earnedXp: Int
    let goalXp: Int
    let progress: Double

    private var isDone: Bool { progress >= 1.0 }
    private var ringColor: Color { isDone ? BryqoTheme.success : BryqoTheme.primary }

    var body: some View {
        ZStack {
            Circle()
                .stroke(BryqoTheme.border.opacity(0.6), lineWidth: 9)

            Circle()
                .trim(from: 0, to: min(1.0, progress))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [ringColor.opacity(0.65), ringColor]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.82), value: progress)

            if isDone {
                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(BryqoTheme.success)
                    .transition(.scale.combined(with: .opacity))
            } else {
                VStack(spacing: 0) {
                    Text("\(earnedXp)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: earnedXp)
                    Text("XP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 78, height: 78)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isDone)
    }
}
