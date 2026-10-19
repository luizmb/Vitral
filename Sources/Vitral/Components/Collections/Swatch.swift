import SwiftUI
import VitralTokens

/// A sample of a colour: a filled circle with a fine ring, so light colours still show on light
/// glass. An optional label (initials, a number) sits on it.
public struct Swatch: View {
    @Environment(\.vitralScheme) private var scheme
    let color: ColorToken
    let label: Text?
    let diameter: Double

    public init(_ color: ColorToken, label: Text? = nil, diameter: Double = Size.swatch) {
        self.color = color
        self.label = label
        self.diameter = diameter
    }

    public var body: some View {
        Circle()
            .fill(Color(color, scheme: scheme))
            .overlay(Circle().strokeBorder(Color(.hairline, scheme: scheme), lineWidth: 1))
            .overlay {
                label
                    // A big swatch is an icon: its initials grow with it.
                    .font((diameter >= Size.controlMedium ? Font.title3 : .caption2).weight(.bold))
                    .foregroundStyle(.onAccent)
                    .shadow(radius: 1)
                    .minimumScaleFactor(0.5)
                    .padding(Space.hairline)
            }
            .frame(width: diameter, height: diameter)
            .accessibilityHidden(true)
    }
}

/// Where a swatch would be: a dashed circle, for an empty stack.
public struct SwatchPlaceholder: View {
    @Environment(\.vitralScheme) private var scheme
    let diameter: Double

    public init(diameter: Double = Size.swatch) {
        self.diameter = diameter
    }

    public var body: some View {
        Circle()
            .strokeBorder(Color(.outline, scheme: scheme), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            .frame(width: diameter, height: diameter)
            .accessibilityHidden(true)
    }
}
