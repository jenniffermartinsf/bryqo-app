import SwiftUI

enum BryqoTheme {
    static let forest = Color(red: 0.16, green: 0.39, blue: 0.25)
    static let leaf = Color(red: 0.42, green: 0.65, blue: 0.36)
    static let river = Color(red: 0.20, green: 0.55, blue: 0.78)
    static let wood = Color(red: 0.55, green: 0.35, blue: 0.20)
    static let stone = Color(red: 0.47, green: 0.50, blue: 0.52)
    static let sunlight = Color(red: 0.92, green: 0.58, blue: 0.20)
    static let paper = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let ink = Color(red: 0.12, green: 0.15, blue: 0.13)
    static let softBackground = Color(red: 0.93, green: 0.96, blue: 0.91)

    static let cornerRadius: CGFloat = 8
    static let spacing: CGFloat = 16
}

struct BryqoCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

extension View {
    func bryqoCard() -> some View {
        modifier(BryqoCard())
    }
}
