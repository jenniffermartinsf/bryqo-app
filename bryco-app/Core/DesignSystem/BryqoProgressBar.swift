import SwiftUI

/// The app's single progress bar: a rounded track with an animated fill.
///
/// Used by lessons, the learning path, achievements and the valley, so every progress
/// indicator shares the same shape, animation and accessibility behavior.
struct BryqoProgressBar: View {
    let progress: Double
    var colors: [Color]
    var height: CGFloat = 12
    var accessibilityLabel: String = "Progresso"

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Solid fill.
    init(progress: Double, tint: Color, height: CGFloat = 12, accessibilityLabel: String = "Progresso") {
        self.init(progress: progress, colors: [tint], height: height, accessibilityLabel: accessibilityLabel)
    }

    /// Gradient fill, from the first color to the last.
    init(progress: Double, colors: [Color], height: CGFloat = 12, accessibilityLabel: String = "Progresso") {
        self.progress = progress
        self.colors = colors
        self.height = height
        self.accessibilityLabel = accessibilityLabel
    }

    private var clampedProgress: Double { max(0, min(1, progress)) }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(BryqoTheme.border)

                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    // Never narrower than a dot, so an empty bar still shows where it starts.
                    .frame(width: max(height, geometry.size.width * clampedProgress))
            }
        }
        .frame(height: height)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: clampedProgress)
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(Int((clampedProgress * 100).rounded()))%")
    }
}

#Preview {
    VStack(spacing: 20) {
        BryqoProgressBar(progress: 0.0, tint: BryqoTheme.success)
        BryqoProgressBar(progress: 0.4, tint: BryqoTheme.success)
        BryqoProgressBar(progress: 0.7, colors: [BryqoTheme.river, BryqoTheme.primary])
        BryqoProgressBar(progress: 1.0, colors: [BryqoTheme.sun, BryqoTheme.sun.opacity(0.65)], height: 8)
    }
    .padding()
}
