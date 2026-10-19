import SwiftUI
import VitralTokens

/// Something on a disc of its own colour, at arm's length: a name's initials, an emoji, a picture
/// or a symbol. The colour is the identity — which track, which band, which bus — so it is a
/// filled disc with the thing on it rather than a tint on a glyph.
public struct Badge: View {
    @Environment(\.vitralScheme) private var scheme
    /// What sits on the disc.
    public enum Content {
        /// A name's initials (`Initials.of`), and the disc its stable colour unless one is given.
        case monogram(String)
        /// An emoji, drawn as it is.
        case emoji(String)
        /// A picture filling the disc.
        case image(Image)
        /// A symbol (an SF Symbol, an asset template), drawn white over the colour.
        case glyph(Image)
    }

    let content: Content
    let fill: Fill
    let diameter: Double
    let gradient: Bool

    /// - Parameters:
    ///   - colour: the disc's colour; a monogram's own stable colour (`ColorToken.stable(for:)`)
    ///     when nil, else the accent.
    ///   - gradient: a soft top-to-bottom gradient of the colour instead of a flat fill.
    public init(_ content: Content, colour: ColorToken? = nil, diameter: Double = Size.icon, gradient: Bool = false) {
        let token = colour ?? {
            if case let .monogram(name) = content { ColorToken.stable(for: name) } else { ColorToken.accent }
        }()
        self.content = content
        self.fill = .token(token)
        self.diameter = diameter
        self.gradient = gradient
    }

    /// The disc's colour: a token resolved in the app's scheme, or a colour the app owns.
    enum Fill {
        case token(ColorToken)
        case colour(Color)
    }

    var fillColour: Color {
        switch fill {
        case let .token(token): Color(token, scheme: scheme)
        case let .colour(colour): colour
        }
    }

    /// A badge on a colour the app owns rather than one of Vitral's tokens.
    public init(_ content: Content, fill: Color, diameter: Double = Size.icon, gradient: Bool = false) {
        self.content = content
        self.fill = .colour(fill)
        self.diameter = diameter
        self.gradient = gradient
    }

    public var body: some View {
        Circle()
            .fill(gradient ? AnyShapeStyle(fillColour.gradient) : AnyShapeStyle(fillColour))
            .overlay { face }
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Color(.hairline, scheme: scheme), lineWidth: 1))
            .frame(width: diameter, height: diameter)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var face: some View {
        switch content {
        case let .monogram(name):
            Text(verbatim: Initials.of(name))
                // A big badge is an icon: its initials grow with it.
                .font((diameter >= Size.controlMedium ? Font.title3 : .caption2).weight(.bold))
                .foregroundStyle(.onAccent)
                .shadow(radius: 1)
                .minimumScaleFactor(0.5)
                .padding(Space.hairline)
        case let .emoji(emoji):
            Text(verbatim: emoji)
                .font(.system(size: diameter * 0.55))
        case let .image(image):
            image
                .resizable()
                .scaledToFill()
        case let .glyph(image):
            image
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: diameter * 0.55, height: diameter * 0.55)
        }
    }
}
