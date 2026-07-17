import SwiftUI
import UIKit

enum BryqoTheme {
    static let background = Color(light: 0xF8F8F4, dark: 0x1A1C1E)
    static let surface = Color(light: 0xFFFFFF, dark: 0x232628)
    static let elevatedSurface = Color(light: 0xF0ECE4, dark: 0x2B2A25)
    static let primary = Color(hex: 0x3F8F5A)
    static let river = Color(hex: 0x4EA9E8)
    static let wood = Color(hex: 0x8C6445)
    static let stone = Color(hex: 0x8A9099)
    static let sun = Color(hex: 0xF5B83D)
    static let success = Color(hex: 0x4CAF6A)
    static let warning = Color(hex: 0xFFB545)
    static let error = Color(hex: 0xEF5350)
    static let textPrimary = Color(light: 0x1F211D, dark: 0xF8F3EA)
    static let textSecondary = Color(light: 0x6D675C, dark: 0xB8AE9B)
    static let border = Color(light: 0xDED8CB, dark: 0x3A3428)

    static let forest = primary
    static let leaf = success
    static let sunlight = sun
    static let softBackground = background

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
        static let xxxl: CGFloat = 40
    }

    enum Radius {
        static let card: CGFloat = 20
        static let button: CGFloat = 18
        static let input: CGFloat = 16
        static let pill: CGFloat = 999
    }

    static let cornerRadius: CGFloat = Radius.card
    static let spacing: CGFloat = Spacing.lg
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }

    init(light: UInt, dark: UInt) {
        self.init(
            UIColor { traits in
                let hex = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(
                    red: CGFloat((hex >> 16) & 0xff) / 255,
                    green: CGFloat((hex >> 8) & 0xff) / 255,
                    blue: CGFloat(hex & 0xff) / 255,
                    alpha: 1
                )
            }
        )
    }

    // Returns a darker version of the color — used for 3D button shadows.
    var shadowed: Color {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        return Color(red: Double(r * 0.72), green: Double(g * 0.72), blue: Double(b * 0.72), opacity: Double(a))
    }
}

struct BryqoScreen<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            BryqoTheme.background
                .ignoresSafeArea()

            content
        }
    }
}

// Duolingo-style 3D button: face sinks onto shadow on press.
struct Duo3DButtonStyle: ButtonStyle {
    var color: Color
    var isDisabled: Bool

    private let depth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && !isDisabled
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.button, style: .continuous)
                .fill(color.shadowed)
                .frame(height: 54)
                .offset(y: pressed ? 1 : depth)
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: BryqoTheme.Radius.button, style: .continuous)
                        .fill(isDisabled ? color.opacity(0.45) : color)
                )
                .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.button, style: .continuous))
                .frame(height: 54)
                .offset(y: pressed ? depth - 1 : 0)
        }
        .frame(height: 54 + depth)
        .animation(.spring(response: 0.12, dampingFraction: 0.85), value: pressed)
    }
}

struct BryqoPrimaryButton: View {
    let title: String
    var systemImage: String?
    var isDisabled = false
    var color: Color = BryqoTheme.river
    var textColor: Color = Color(hex: 0x082235)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BryqoTheme.Spacing.md) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(isDisabled ? textColor.opacity(0.55) : textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .disabled(isDisabled)
        .buttonStyle(Duo3DButtonStyle(color: color, isDisabled: isDisabled))
    }
}

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct BryqoCardModifier: ViewModifier {
    var padding: CGFloat = BryqoTheme.Spacing.lg
    var fill: Color = BryqoTheme.surface
    var border: Color = BryqoTheme.border

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                    .stroke(border, lineWidth: 1.5)
            }
    }
}

struct BryqoCard: ViewModifier {
    func body(content: Content) -> some View {
        content.modifier(BryqoCardModifier())
    }
}

extension View {
    func bryqoCard(
        padding: CGFloat = BryqoTheme.Spacing.lg,
        fill: Color = BryqoTheme.surface,
        border: Color = BryqoTheme.border
    ) -> some View {
        modifier(BryqoCardModifier(padding: padding, fill: fill, border: border))
    }
}

struct BryqoStatPill: View {
    let value: String
    let icon: String
    var tint: Color = BryqoTheme.sun

    var body: some View {
        Label(value, systemImage: icon)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, BryqoTheme.Spacing.md)
            .padding(.vertical, BryqoTheme.Spacing.sm)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(tint.opacity(0.16), lineWidth: 1)
            }
    }
}

struct BrixAvatar: View {
    var size: CGFloat = 56

    var body: some View {
        Image("BrixMascot")
            .resizable()
            .scaledToFit()
            .padding(size * 0.04)
            .background(BryqoTheme.river.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.25, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                    .stroke(BryqoTheme.river.opacity(0.16), lineWidth: 1)
            }
        .frame(width: size, height: size)
        .accessibilityLabel("Brix")
    }
}

struct BrixSpeechBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: BryqoTheme.Spacing.lg) {
            BrixAvatar(size: 42)

            Text(text)
                .font(.body.weight(.semibold))
                .foregroundStyle(BryqoTheme.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(BryqoTheme.Spacing.lg)
                .background(BryqoTheme.river.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                        .stroke(BryqoTheme.river.opacity(0.22), lineWidth: 1)
                }
        }
    }
}

struct BryqoSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold, design: .default))
            .foregroundStyle(BryqoTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
