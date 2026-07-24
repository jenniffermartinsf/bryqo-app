import SwiftUI

/// A system font of a fixed point size that still scales with the user's Dynamic Type setting.
///
/// The app was built with many hard-coded `.font(.system(size:))` values, which ignore the
/// user's text-size preference. This modifier keeps the exact same visual size at the default
/// Dynamic Type setting while scaling proportionally for larger/smaller accessibility sizes.
private struct ScaledFontModifier: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    init(size: CGFloat, relativeTo textStyle: Font.TextStyle, weight: Font.Weight, design: Font.Design) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    /// Applies a system font of the given point size that scales with Dynamic Type.
    ///
    /// Use in place of `.font(.system(size:weight:design:))` so text respects accessibility
    /// text sizes. `relativeTo` controls which text style drives the scaling curve — anchor
    /// large display text to `.largeTitle`/`.title` and body-like text to `.body`.
    func bryqoFont(
        _ size: CGFloat,
        relativeTo textStyle: Font.TextStyle = .body,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> some View {
        modifier(ScaledFontModifier(size: size, relativeTo: textStyle, weight: weight, design: design))
    }
}
