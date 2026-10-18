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

/// A button that stays down while it's on, as a desk's mute and solo do: a short label, lit in
/// `lit` when on, glass when off. Stateless: on is the binding's.
public struct ToggleButtonLatched: View {
    let title: Text
    let lit: ColorToken
    let litInk: ColorToken
    let accessibilityLabel: Text?
    @Binding var isOn: Bool

    /// - Parameters:
    ///   - lit: its colour when on.
    ///   - litInk: the label's colour when on.
    public init(_ title: Text, isOn: Binding<Bool>, lit: ColorToken = .danger, litInk: ColorToken = .fixedWhite, accessibilityLabel: Text? = nil) {
        self.title = title
        self._isOn = isOn
        self.lit = lit
        self.litInk = litInk
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Button { isOn.toggle() } label: {
            label
                .contentShape(RoundedRectangle(cornerRadius: Radius.extraSmall, style: .continuous))
        }
        .buttonStyle(.plain)
        .fixedSize()
        .accessibilityRepresentation { Toggle(isOn: $isOn) { accessibilityLabel ?? title } }
    }

    /// Lit: solid colour with a glow, nothing over it. Off: clear glass.
    @ViewBuilder
    var label: some View {
        let face = title
            .font(TypeToken.detail.weight(.bold))
            .frame(minWidth: Size.controlSmall, minHeight: Size.controlSmall)
        if isOn {
            face
                .foregroundStyle(Color(litInk))
                .background(Color(lit), in: RoundedRectangle(cornerRadius: Radius.extraSmall, style: .continuous))
                .shadow(color: Color(lit.opacity(0.6)), radius: 4)
        } else {
            face
                .foregroundStyle(Color(.ink))
                .glassSurface(.clear, cornerRadius: Radius.extraSmall)
        }
    }
}

public extension View {
    /// Sized for where it's shown: medium and large detents on a phone, a page-sized sheet on a
    /// pad or a Mac, where detents would float a small panel in the middle of a big screen.
    func adaptiveSheet() -> some View {
        modifier(AdaptiveSheet())
    }
}

struct AdaptiveSheet: ViewModifier {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    func body(content: Content) -> some View {
        #if os(iOS)
        if sizeClass == .compact {
            content.presentationDetents([.medium, .large])
        } else {
            content.presentationSizing(.page)
        }
        #else
        content.presentationSizing(.page)
        #endif
    }
}
