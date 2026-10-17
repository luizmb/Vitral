import SwiftUI
import VitralTokens

/// One circle of a `SwatchStack`: its colour and an optional label.
public struct SwatchItem: Sendable {
    public let color: ColorToken
    public let label: String?

    /// - Parameter label: drawn verbatim (initials, a number): not a phrase to translate.
    public init(_ color: ColorToken, label: String? = nil) {
        self.color = color
        self.label = label
    }
}

/// Colour circles overlapping like a fanned hand, the first on top. Past `maxShown`, a count of
/// the rest ("+3"); with none at all, a dashed circle.
public struct SwatchStack: View {
    let items: [SwatchItem]
    let maxShown: Int
    let diameter: Double

    public init(_ colors: [ColorToken], maxShown: Int = 5, diameter: Double = Size.swatch) {
        self.init(items: colors.map { SwatchItem($0) }, maxShown: maxShown, diameter: diameter)
    }

    public init(items: [SwatchItem], maxShown: Int = 5, diameter: Double = Size.swatch) {
        self.items = items
        self.maxShown = maxShown
        self.diameter = diameter
    }

    public var body: some View {
        HStack(spacing: -diameter / 3) {
            if items.isEmpty {
                SwatchPlaceholder(diameter: diameter)
            }
            ForEach(Array(items.prefix(maxShown).enumerated()), id: \.offset) { index, item in
                Swatch(item.color, label: item.label.map { Text(verbatim: $0) }, diameter: diameter)
                    // A ring in the backdrop colour cuts each circle out of the one beneath.
                    .background(Circle().fill(Color(.backdrop)).padding(-1.5))
                    .zIndex(Double(maxShown - index))
            }
            if items.count > maxShown {
                Text(verbatim: "+\(items.count - maxShown)")
                    .font(.detail)
                    .foregroundStyle(.inkMuted)
                    .padding(.leading, diameter / 3 + Space.extraSmall)
            }
        }
        .accessibilityHidden(true)
    }
}
