import SwiftUI
import VitralTokens

/// A name's initials on a disc of its own stable colour (`ColorToken.stable(for:)`), for things
/// with no picture: a band, a person, a project. Give `colour` to choose it instead.
public struct Monogram: View {
    let name: String
    let colour: ColorToken?
    let diameter: Double

    public init(_ name: String, colour: ColorToken? = nil, diameter: Double = Size.icon) {
        self.name = name
        self.colour = colour
        self.diameter = diameter
    }

    public var body: some View {
        Swatch(colour ?? .stable(for: name), label: Text(verbatim: Initials.of(name)), diameter: diameter)
    }
}

public extension SwatchStack {
    /// Names as overlapping monograms, each coloured by `colourOf` (its own stable colour unless
    /// told otherwise), the first on top.
    init(
        monograms names: [String],
        colourOf: (String) -> ColorToken = { ColorToken.stable(for: $0) },
        maxShown: Int = 3,
        diameter: Double = Size.controlMedium
    ) {
        self.init(items: names.map { SwatchItem(colourOf($0), label: Initials.of($0)) }, maxShown: maxShown, diameter: diameter)
    }
}
