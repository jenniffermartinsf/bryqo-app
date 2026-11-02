import SwiftUI

/// One sign-in button for every provider, so "Salvar com Apple" and "Salvar com Google" share
/// the same shape, size, typography and loading state.
///
/// Both follow their brand rules, which also say how to stand out from the background: on a
/// light screen, a black button (Apple's black style, Google's dark theme); on a dark screen, a
/// white one (Apple's white style, Google's light theme). Black on the dark theme's near-black
/// cards was barely a button. Only the logo differs between the two.
struct BryqoAuthButton: View {
    enum Provider {
        case apple, google

        var title: String {
            switch self {
            case .apple: "Salvar com Apple"
            case .google: "Salvar com Google"
            }
        }
    }

    let provider: Provider
    var isLoading = false
    var isDisabled = false
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var isOnDark: Bool { colorScheme == .dark }
    private var fill: Color { isOnDark ? .white : .black }
    private var ink: Color { isOnDark ? Color(hex: 0x1F1F1F) : .white }
    private var outline: Color { isOnDark ? Color(hex: 0x747775) : Color(hex: 0x8E918F) }

    var body: some View {
        Button(action: action) {
            HStack(spacing: BryqoTheme.Spacing.sm) {
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(ink)
                            .scaleEffect(0.85)
                    } else {
                        logo
                    }
                }
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)

                Text(isLoading ? "Vinculando…" : provider.title)
                    .font(.headline.bold())
            }
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .background(fill)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(outline, lineWidth: 1)
            }
            .opacity(isDisabled && !isLoading ? 0.5 : 1)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isDisabled || isLoading)
    }

    @ViewBuilder
    private var logo: some View {
        switch provider {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.title3)
        case .google:
            Image("GoogleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        BryqoAuthButton(provider: .apple) {}
        BryqoAuthButton(provider: .google) {}
        BryqoAuthButton(provider: .google, isLoading: true) {}
        BryqoAuthButton(provider: .apple, isDisabled: true) {}
    }
    .padding()
}
