import SwiftUI
import VitralTokens

/// A sample of a colour: a filled circle with a fine ring, so light colours still show on light
/// glass.
public struct Swatch: View {
    let color: ColorToken
    let diameter: Double

    public init(_ color: ColorToken, diameter: Double = Size.swatch) {
        self.color = color
        self.diameter = diameter
    }

    public var body: some View {
        Circle()
            .fill(Color(color))
            .overlay(Circle().strokeBorder(Color(.hairline), lineWidth: 1))
            .frame(width: diameter, height: diameter)
            .accessibilityHidden(true)
    }
}
