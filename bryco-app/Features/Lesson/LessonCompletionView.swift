import SwiftUI

struct LessonCompletionView: View {
    let lesson: Lesson
    let xpEarned: Int
    let correctCount: Int
    let totalQuestions: Int
    let streakDays: Int
    let onContinue: () -> Void

    @State private var mascotScale: CGFloat = 0.3
    @State private var contentVisible = false

    var body: some View {
        BryqoScreen {
            VStack(spacing: 0) {
                Spacer()

                // Mascot
                BrixAvatar(size: 100)
                    .scaleEffect(mascotScale)
                    .animation(.spring(response: 0.45, dampingFraction: 0.48), value: mascotScale)

                Spacer().frame(height: BryqoTheme.Spacing.xl)

                // Title
                VStack(spacing: BryqoTheme.Spacing.xs) {
                    Text("Lição Concluída!")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(BryqoTheme.textPrimary)

                    Text(lesson.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 24)
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.12), value: contentVisible)

                Spacer().frame(height: BryqoTheme.Spacing.xxxl)

                // Stats
                HStack(spacing: BryqoTheme.Spacing.md) {
                    statCard(
                        icon: "bolt.fill",
                        value: "+\(xpEarned)",
                        label: "XP",
                        color: BryqoTheme.sun,
                        delay: 0.22
                    )
                    statCard(
                        icon: "checkmark.circle.fill",
                        value: "\(correctCount)/\(totalQuestions)",
                        label: "Acertos",
                        color: BryqoTheme.success,
                        delay: 0.32
                    )
                    statCard(
                        icon: "flame.fill",
                        value: "\(max(1, streakDays))",
                        label: "Streak",
                        color: Color(hex: 0xFF9600),
                        delay: 0.42
                    )
                }
                .padding(.horizontal, BryqoTheme.Spacing.xl)

                Spacer()

                // CTA
                BryqoPrimaryButton(
                    title: "CONTINUAR",
                    systemImage: "arrow.right",
                    color: BryqoTheme.success,
                    textColor: .white,
                    action: onContinue
                )
                .padding(BryqoTheme.Spacing.xl)
                .opacity(contentVisible ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.52), value: contentVisible)
            }
        }
        .overlay(alignment: .top) { ConfettiView() }
        .onAppear {
            mascotScale = 1.0
            contentVisible = true
        }
    }

    private func statCard(icon: String, value: String, label: String, color: Color, delay: Double) -> some View {
        VStack(spacing: BryqoTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(BryqoTheme.textPrimary)

            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BryqoTheme.Spacing.lg)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(color.opacity(0.22), lineWidth: 1.5)
        }
        .opacity(contentVisible ? 1 : 0)
        .scaleEffect(contentVisible ? 1 : 0.75)
        .animation(.spring(response: 0.4, dampingFraction: 0.68).delay(delay), value: contentVisible)
    }
}
