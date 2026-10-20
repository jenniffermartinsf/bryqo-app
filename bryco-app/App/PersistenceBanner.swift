import SwiftUI

/// Non-blocking warning shown at the top of the app when progress is not being saved.
struct PersistenceBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: BryqoTheme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(BryqoTheme.warning)
                .accessibilityHidden(true)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BryqoTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .bryqoCard(fill: BryqoTheme.surface, border: BryqoTheme.warning.opacity(0.6))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel("Aviso: \(message)")
    }
}

#Preview {
    VStack(spacing: 16) {
        PersistenceBanner(message: PersistenceHealth.temporaryStorage.bannerMessage!)
        PersistenceBanner(message: PersistenceHealth.saveFailed.bannerMessage!)
    }
    .padding()
}
