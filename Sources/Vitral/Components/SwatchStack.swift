import SwiftUI
import VitralTokens

/// Colour circles overlapping like a fanned hand, the first on top. Past `maxShown`, a count of
/// the rest ("+3").
public struct SwatchStack: View {
    let colors: [ColorToken]
    let maxShown: Int
    let diameter: Double

    public init(_ colors: [ColorToken], maxShown: Int = 5, diameter: Double = Size.swatch) {
        self.colors = colors
        self.maxShown = maxShown
        self.diameter = diameter
    }

    public var body: some View {
        HStack(spacing: -diameter / 3) {
            ForEach(Array(colors.prefix(maxShown).enumerated()), id: \.offset) { index, color in
                Swatch(color, diameter: diameter)
                    // A ring in the backdrop colour cuts each circle out of the one beneath.
                    .background(Circle().fill(Color(.backdrop)).padding(-1.5))
                    .zIndex(Double(maxShown - index))
            }
            if colors.count > maxShown {
                Text("+\(colors.count - maxShown)")
                    .font(.detail)
                    .foregroundStyle(.inkMuted)
                    .padding(.leading, diameter / 3 + Space.extraSmall)
            }
        }
        .accessibilityHidden(true)
    }
}
