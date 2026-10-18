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

/// Puts a finish under a view: glass on the view, anything else behind it.
struct FinishModifier<S: InsettableShape>: ViewModifier {
    let finish: FinishToken
    let shape: S

    func body(content: Content) -> some View {
        if finish.isGlass {
            content
                .background { OnGlass(finish: finish, shape: shape) }
                .glassLayer(finish.glassMaterial ?? GlassToken.clear.interactive(), in: shape)
                .overlay { GlassRim(shape: shape) }
        } else {
            content.background { FinishedShape(finish: finish, shape: shape) }
        }
    }
}

extension FinishToken {
    /// The glass under a glass finish, when one is given.
    var glassMaterial: GlassToken? {
        switch self {
        case let .glass(material): material
        case let .mixed(_, glass, _): glass
        case let .layered(base, _, _): base.glassMaterial
        default: nil
        }
    }

    /// Aqua's layers over it.
    var effects: Set<FinishEffect> {
        switch self {
        case let .layered(base, effects, _): effects.union(base.effects)
        default: []
        }
    }
}

/// What a glass finish lays over its glass: what's mixed in, then Aqua's layers.
struct OnGlass<S: InsettableShape>: View {
    let finish: FinishToken
    let shape: S

    var body: some View {
        switch finish {
        case let .mixed(mixed, _, amount):
            FinishedShape(finish: mixed, shape: shape).opacity(amount)
        case let .layered(base, effects, strength):
            OnGlass(finish: base, shape: shape)
                .overlay { GelLayers(tone: base.tone, effects: effects, strength: strength, shape: shape) }
        default:
            Color.clear
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
        switch finish {
        case let .glass(material):
            GlassFinish(material: material, shape: shape)
        case let .solid(colour):
            shape.fill(Color(colour)).overlay { Rim(shape: shape) }
        case let .gradient(colours):
            shape.fill(LinearGradient(colors: colours.map { Color($0) }, startPoint: .top, endPoint: .bottom)).overlay { Rim(shape: shape) }
        case let .texture(texture):
            Image(texture).resizable(resizingMode: .tile).clipShape(shape).overlay { Rim(shape: shape) }
        case let .aqua(colour):
            AquaGel(colour: colour, shape: shape)
        case .chrome:
            shape
                .fill(LinearGradient(colors: [.chromeHighlight, .chromeMid, .chromeShadow, .chromeMid].map { Color($0) }, startPoint: .top, endPoint: .bottom))
                .overlay { shape.strokeBorder(Color(.chromeShadow), lineWidth: 0.75) }
        case let .mixed(mixed, glass, amount):
            FinishedShape(finish: mixed, shape: shape)
                .opacity(amount)
                .glassLayer(glass ?? GlassToken.clear.interactive(), in: shape)
                .overlay { GlassRim(shape: shape) }
        case let .layered(base, effects, strength):
            FinishedShape(finish: base, shape: shape)
                .overlay { GelLayers(tone: base.tone, effects: effects, strength: strength, shape: shape) }
        }
    }
}

/// Aqua's layers over a shape: the glow, the gloss, the rim, each when asked for.
struct GelLayers<S: InsettableShape>: View {
    let tone: ColorToken
    let effects: Set<FinishEffect>
    /// How strong the layers are (0 ... 1).
    var strength: Double = 1
    let shape: S

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if effects.contains(.glow) {
                    // Light passing through, gathering at the bottom.
                    shape.fill(
                        RadialGradient(
                            colors: [Color(tone).mix(with: .white, by: 0.6).opacity(0.85 * strength), .clear],
                            center: UnitPoint(x: 0.5, y: 1),
                            startRadius: 0,
                            endRadius: max(proxy.size.width, proxy.size.height) * 0.6
                        )
                    )
                }
                if effects.contains(.gloss) {
                    Capsule()
                        .fill(LinearGradient(colors: [Color(ColorToken.fixedWhite.opacity(0.9 * strength)), Color(ColorToken.fixedWhite.opacity(0.08 * strength))], startPoint: .top, endPoint: .bottom))
                        .frame(width: proxy.size.width * 0.84, height: proxy.size.height * 0.48)
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.28)
                }
                if effects.contains(.rim) {
                    shape.strokeBorder(Color(tone).mix(with: .black, by: 0.4).opacity(strength), lineWidth: 0.8)
                }
            }
            .clipShape(shape)
        }
        .allowsHitTesting(false)
    }
}

/// Glass with a rim: a lighter, clearer glass than a panel's (answering touch unless a material
/// is given, which keeps its own), and a bright edge catching the light from above, so a small
/// control reads as a piece of glass rather than a white disc.
struct GlassFinish<S: InsettableShape>: View {
    let material: GlassToken?
    let shape: S

    var body: some View {
        Color.clear
            .glassLayer(material ?? GlassToken.clear.interactive(), in: shape)
            .overlay { GlassRim(shape: shape) }
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

/// Aqua's gel: the colour darkening towards the top and lighter at the bottom, under the gloss,
/// the glow and the rim.
struct AquaGel<S: InsettableShape>: View {
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
            .overlay { GelLayers(tone: colour, effects: [.glow, .gloss, .rim], shape: shape) }
            .shadow(color: Color(colour).mix(with: .black, by: 0.3).opacity(0.45), radius: 3, y: 2)
    }
}
