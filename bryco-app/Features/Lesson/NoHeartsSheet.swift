import SwiftUI

struct NoHeartsSheet: View {
    let appState: BryqoAppState

    var body: some View {
        VStack(spacing: BryqoTheme.Spacing.xl) {
            BrixAvatar(size: 72)
                .padding(.top, BryqoTheme.Spacing.md)

            VStack(spacing: BryqoTheme.Spacing.sm) {
                Text("Sem corações!")
                    .bryqoFont(24, relativeTo: .title2, weight: .black, design: .rounded)
                    .foregroundStyle(BryqoTheme.error)

                Text("Seus corações se regeneram com o tempo.\nEstude mais rápido com o Premium.")
                    .font(.body)
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Hearts row — all empty
            HStack(spacing: BryqoTheme.Spacing.md) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "heart")
                        .bryqoFont(28, relativeTo: .largeTitle)
                        .foregroundStyle(BryqoTheme.border)
                }
            }
            .padding(.vertical, BryqoTheme.Spacing.sm)

            // Countdown timer
            if let nextAt = appState.nextHeartAt {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    let remaining = max(0, nextAt.timeIntervalSinceNow)
                    let mins = Int(remaining) / 60
                    let secs = Int(remaining) % 60

                    VStack(spacing: 4) {
                        Text("PRÓXIMO CORAÇÃO EM")
                            .bryqoFont(11, weight: .black)
                            .tracking(1.2)
                            .foregroundStyle(BryqoTheme.textSecondary)

                        Text(String(format: "%02d:%02d", mins, secs))
                            .bryqoFont(38, relativeTo: .largeTitle, weight: .black, design: .monospaced)
                            .foregroundStyle(BryqoTheme.warning)
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(BryqoTheme.Spacing.lg)
                    .background(BryqoTheme.warning.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
                }
            }

            // Premium teaser — visually locked, no action
            HStack(spacing: BryqoTheme.Spacing.md) {
                Image(systemName: "crown.fill")
                    .font(.headline)
                    .foregroundStyle(BryqoTheme.sun)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bryx Premium")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text("Corações ilimitados — em breve")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }

                Spacer()

                Text("Em breve")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, BryqoTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(BryqoTheme.sun.opacity(0.15))
                    .foregroundStyle(BryqoTheme.sun)
                    .clipShape(Capsule())
            }
            .padding(BryqoTheme.Spacing.lg)
            .background(BryqoTheme.sun.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                    .stroke(BryqoTheme.sun.opacity(0.22), lineWidth: 1.5)
            }
            .opacity(0.7)

            Spacer()
        }
        .padding(.horizontal, BryqoTheme.Spacing.xl)
        .background(BryqoTheme.surface)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
