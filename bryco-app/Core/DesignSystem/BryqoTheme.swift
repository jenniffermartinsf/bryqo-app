import SwiftUI
import UIKit

enum BryqoTheme {
    // Background & Surface — updated per design spec
    static let background = Color(light: 0xEFF3EC, dark: 0x14161A)
    static let surface = Color(light: 0xFFFFFF, dark: 0x232628)
    static let elevatedSurface = Color(light: 0xF4F6F1, dark: 0x1C1F22)

    // Brand colours — adaptive in dark mode per spec
    static let primary = Color(light: 0x3F8F5A, dark: 0x4CAF6A)
    static let river = Color(light: 0x4EA9E8, dark: 0x58A6FF)
    static let wood = Color(light: 0x8C6445, dark: 0xB08258)

    // Accent / semantic — same in both themes
    static let coral = Color(hex: 0xFF6B4A)   // Sequência (fogo)
    static let stone = Color(hex: 0x8A9099)
    static let sun = Color(hex: 0xF5B83D)     // XP / meta / nó atual
    static let success = Color(hex: 0x4CAF6A)
    static let warning = Color(hex: 0xFFB545)
    static let error = Color(hex: 0xEF5350)

    // Text — updated per design spec
    static let textPrimary = Color(light: 0x1A1C1E, dark: 0xF1F3EE)
    static let textSecondary = Color(light: 0x6B7280, dark: 0x9AA1A8)

    // Border — semi-transparent per spec: rgba(0,0,0,.08) / rgba(255,255,255,.10)
    static let border = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.10)
            : UIColor.black.withAlphaComponent(0.08)
    })

    // Aliases
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
        Image("BrixNeutro")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel("Brix")
    }
}

struct BrixSpeechBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            BrixAvatar(size: 72)
                .fixedSize()

            Text(text)
                .font(.body.weight(.semibold))
                .foregroundStyle(BryqoTheme.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                .padding(BryqoTheme.Spacing.lg)
                .background {
                    ChatBubbleShape()
                        .fill(BryqoTheme.river.opacity(0.15))
                }
        }
    }
}

// Rounded rect + iMessage-style tail at bottom-left, all in one unified path.
private struct ChatBubbleShape: Shape {
    var cornerRadius: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        let r = cornerRadius
        // Tail goes LEFT (not down) — tip is 14pt to the left, only 4pt below bottom
        let tipX: CGFloat = -14
        let tipY: CGFloat = rect.maxY + 4

        var p = Path()

        p.move(to: CGPoint(x: r, y: 0))

        // Top edge + top-right arc
        p.addLine(to: CGPoint(x: rect.maxX - r, y: 0))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: r),
                 radius: r, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)

        // Right edge + bottom-right arc
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
                 radius: r, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        // Bottom edge going left (stops before tail)
        p.addLine(to: CGPoint(x: r, y: rect.maxY))

        // TAIL outer edge: sweeps left and barely down to tip
        p.addCurve(
            to: CGPoint(x: tipX, y: tipY),
            control1: CGPoint(x: r * 0.4, y: rect.maxY),
            control2: CGPoint(x: tipX + 4, y: rect.maxY + 1)
        )

        // TAIL inner edge: deep concave curve back to left wall
        // control1 pulled far to the right = the characteristic iMessage scoop
        p.addCurve(
            to: CGPoint(x: 0, y: rect.maxY - r * 0.4),
            control1: CGPoint(x: tipX + 10, y: tipY),
            control2: CGPoint(x: r * 0.2, y: rect.maxY)
        )

        // Left edge going up → top-left arc
        p.addLine(to: CGPoint(x: 0, y: r))
        p.addArc(center: CGPoint(x: r, y: r),
                 radius: r, startAngle: .degrees(180), endAngle: .degrees(-90), clockwise: false)

        p.closeSubpath()
        return p
    }
}

struct BryqoSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .bryqoFont(24, relativeTo: .title2, weight: .bold, design: .default)
            .foregroundStyle(BryqoTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
