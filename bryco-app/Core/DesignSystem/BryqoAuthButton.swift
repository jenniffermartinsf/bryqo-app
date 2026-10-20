import SwiftUI

/// One sign-in button for every provider, so "Salvar com Apple" and "Salvar com Google" share
/// the same shape, size, typography and loading state.
///
/// Both follow their brand rules: Apple's logo on a black button (Sign in with Apple, black
/// style) and Google's unmodified "G" on a dark button with a neutral outline (Google's dark
/// theme). Only the logo differs.
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

    var body: some View {
        Button(action: action) {
            HStack(spacing: BryqoTheme.Spacing.sm) {
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
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
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .background(Color.black)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(Color(hex: 0x8E918F), lineWidth: 1)
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
