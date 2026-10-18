import SwiftUI
import VitralTokens

public extension EnvironmentValues {
    /// The finish every Vitral control under this view is made of, unless it asks for its own;
    /// `nil` leaves each to its own default.
    @Entry var controlFinish: FinishToken?
}

public extension View {
    /// The finish every Vitral control under this view is made of: buttons, fader thumbs.
    func controlFinish(_ finish: FinishToken?) -> some View {
        environment(\.controlFinish, finish)
    }

    /// Makes this view's surface `finish`, cut to `shape`. Glass is applied to the view itself, as
    /// SwiftUI's glass is (its layers between the glass and the content), so the glass never
    /// refracts the content on it; any other finish fills the space behind.
    func finish(_ finish: FinishToken, in shape: some InsettableShape) -> some View {
        modifier(FinishModifier(finish: finish, shape: shape))
    }
}

/// Puts a finish under a view: glass on the view itself (the fill and sheen between the glass and
/// the content), anything else behind it.
struct FinishModifier<S: InsettableShape>: ViewModifier {
    let finish: FinishToken
    let shape: S

    func body(content: Content) -> some View {
        if let glass = finish.glass {
            content
                .background { FillAndSheen(finish: finish, shape: shape) }
                .glassLayer(glass, in: shape)
                .overlay { GlassRim(shape: shape) }
        } else {
            content.background { FinishedShape(finish: finish, shape: shape) }
        }
    }
}

/// A shape made of a finish.
public struct FinishedShape<S: InsettableShape>: View {
    let finish: FinishToken
    let shape: S

    public init(finish: FinishToken, shape: S) {
        self.finish = finish
        self.shape = shape
    }

    public var body: some View {
        if let glass = finish.glass {
            FillAndSheen(finish: finish, shape: shape)
                .glassLayer(glass, in: shape)
                .overlay { GlassRim(shape: shape) }
        } else {
            FillAndSheen(finish: finish, shape: shape)
        }
    }
}

/// A finish's fill (`amount` of it on glass) and its sheen over it.
struct FillAndSheen<S: InsettableShape>: View {
    let finish: FinishToken
    let shape: S

    var body: some View {
        // `Color.clear` first, so a finish of glass alone (no fill, no sheen) still has the
        // shape's size for the glass to be laid on: an empty stack has none, and draws nothing.
        ZStack {
            Color.clear
            finish.fill.map { fill in
                FillShape(fill: fill, shape: shape, edged: finish.glass == nil).opacity(finish.glass == nil ? 1 : finish.amount)
            }
            if !finish.sheen.isNone {
                // A finish laid on glass shows `amount` of itself, its sheen included: a hint of
                // Aqua is a hint of its gloss too, not the gloss at full strength.
                SheenLayers(tone: finish.tone, sheen: finish.sheen, shape: shape)
                    .opacity(finish.glass != nil && finish.fill != nil ? finish.amount : 1)
            }
        }
    }
}

/// A shape filled: a colour, a gradient, a texture, chrome or gel; `edged` gives it a light edge,
/// as it has when it isn't on glass.
struct FillShape<S: InsettableShape>: View {
    let fill: FinishToken.Fill
    let shape: S
    let edged: Bool

    var body: some View {
        switch fill {
        case let .colour(colour):
            shape.fill(Color(colour)).overlay { if edged { Rim(shape: shape) } }
        case let .gradient(colours):
            shape.fill(LinearGradient(colors: colours.map { Color($0) }, startPoint: .top, endPoint: .bottom)).overlay { if edged { Rim(shape: shape) } }
        case let .texture(texture):
            Image(texture).resizable(resizingMode: .tile).clipShape(shape).overlay { if edged { Rim(shape: shape) } }
        case .chrome:
            shape
                .fill(LinearGradient(colors: [.chromeHighlight, .chromeMid, .chromeShadow, .chromeMid].map { Color($0) }, startPoint: .top, endPoint: .bottom))
                .overlay { shape.strokeBorder(Color(.chromeShadow), lineWidth: 0.75) }
        case let .gel(colour):
            GelBody(colour: colour, shape: shape)
        }
    }
}

/// Aqua's light over a shape: the glow, the gloss and the rim, each as strong as the sheen says.
struct SheenLayers<S: InsettableShape>: View {
    let tone: ColorToken
    let sheen: FinishToken.Sheen
    let shape: S

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if sheen.glow > 0 {
                    // Light passing through, gathering at the bottom.
                    shape.fill(
                        RadialGradient(
                            colors: [Color(tone).mix(with: .white, by: 0.6).opacity(0.85 * sheen.glow), .clear],
                            center: UnitPoint(x: 0.5, y: 1),
                            startRadius: 0,
                            endRadius: max(proxy.size.width, proxy.size.height) * 0.6
                        )
                    )
                }
                if sheen.gloss > 0 {
                    Capsule()
                        .fill(LinearGradient(colors: [Color(ColorToken.fixedWhite.opacity(0.9 * sheen.gloss)), Color(ColorToken.fixedWhite.opacity(0.08 * sheen.gloss))], startPoint: .top, endPoint: .bottom))
                        .frame(width: proxy.size.width * 0.84, height: proxy.size.height * 0.48)
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.28)
                }
                if sheen.rim > 0 {
                    shape.strokeBorder(Color(tone).mix(with: .black, by: 0.4).opacity(sheen.rim), lineWidth: 0.8)
                }
            }
            .clipShape(shape)
        }
        .allowsHitTesting(false)
    }
}

/// Glass's bright edge, catching the light from above.
struct GlassRim<S: InsettableShape>: View {
    let shape: S

    var body: some View {
        shape
            .strokeBorder(
                LinearGradient(colors: [Color(ColorToken.fixedWhite.opacity(0.95)), Color(ColorToken.fixedWhite.opacity(0.15))], startPoint: .top, endPoint: .bottom),
                lineWidth: 1.2
            )
            .allowsHitTesting(false)
    }
}

/// A light edge on a coloured shape.
struct Rim<S: InsettableShape>: View {
    let shape: S

    var body: some View {
        shape.strokeBorder(
            LinearGradient(colors: [Color(ColorToken.fixedWhite.opacity(0.5)), Color(ColorToken.fixedBlack.opacity(0.2))], startPoint: .top, endPoint: .bottom),
            lineWidth: 0.75
        )
    }
}

/// Aqua's gel body: the colour darkening towards the top and lighter at the bottom, with the
/// shadow a drop of gel casts.
struct GelBody<S: InsettableShape>: View {
    let colour: ColorToken
    let shape: S

    var body: some View {
        shape
            .fill(
                LinearGradient(
                    colors: [Color(colour).mix(with: .black, by: 0.18), Color(colour), Color(colour).mix(with: .white, by: 0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color(colour).mix(with: .black, by: 0.3).opacity(0.45), radius: 3, y: 2)
    }
}
