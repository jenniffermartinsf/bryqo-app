import SwiftUI

struct StreakMilestoneView: View {
    let days: Int
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var mascotScale: CGFloat = 0.1
    @State private var mascotFloat = false
    @State private var contentVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: BryqoTheme.Spacing.xl) {
                Image("BrixFeliz")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .scaleEffect(mascotScale)
                    .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.38), value: mascotScale)
                    .offset(y: mascotFloat ? -8 : 0)
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1.3).repeatForever(autoreverses: true),
                        value: mascotFloat
                    )
                    .accessibilityLabel("Brix comemorando")

                VStack(spacing: BryqoTheme.Spacing.sm) {
                    Text("🔥 \(days) dias!")
                        .bryqoFont(48, relativeTo: .largeTitle, weight: .black, design: .rounded)
                        .foregroundStyle(BryqoTheme.sun)

                    Text(subtitle)
                        .bryqoFont(18, weight: .bold, design: .rounded)
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Você está construindo algo sólido.")
                        .font(.body)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                BryqoPrimaryButton(
                    title: "INCRÍVEL!",
                    systemImage: "star.fill",
                    color: BryqoTheme.sun,
                    textColor: Color(hex: 0x1A1000),
                    action: onDismiss
                )
            }
            .padding(BryqoTheme.Spacing.xxl)
            .background(BryqoTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card + 4, style: .continuous))
            .padding(.horizontal, BryqoTheme.Spacing.xl)
            .opacity(contentVisible ? 1 : 0)
            .scaleEffect(contentVisible ? 1 : 0.88)
            .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.72), value: contentVisible)
        }
        .overlay(alignment: .top) { ConfettiView() }
        .sensoryFeedback(.success, trigger: contentVisible)
        .onAppear {
            mascotScale = 1.0
            contentVisible = true
            // Respect Reduce Motion: skip the perpetual bobbing animation.
            guard !reduceMotion else { return }
            Task {
                try? await Task.sleep(for: .seconds(0.6))
                mascotFloat = true
            }
        }
    }

    private var subtitle: String {
        switch days {
        case 7:   return "Uma semana sólida de fundamentos!"
        case 30:  return "30 dias! Consistência é a chave."
        default:  return "100 dias! Você é uma lenda do CS."
        }
    }
}
