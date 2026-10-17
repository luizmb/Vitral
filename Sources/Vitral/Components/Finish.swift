import SwiftUI
import VitralTokens

/// What a control's surface is made of: a thumb, a cap, a button. Glass by default; or a solid
/// colour, a gradient, a texture, chrome, or Aqua's gel (a saturated body glowing lighter at the
/// bottom, a gloss over its top half).
public enum SurfaceFinish: Hashable, Sendable {
    /// Liquid glass: `material`, or the environment's glass; clear, with a bright rim.
    case glass(GlassToken? = nil)
    case solid(ColorToken)
    /// Top to bottom.
    case gradient([ColorToken])
    case texture(Texture)
    /// Aqua's gel, in `colour`.
    case aqua(ColorToken)
    /// Polished chrome.
    case chrome
    /// A finish with Aqua's layers over it: the gloss, the glow, the rim, on glass, a colour, a
    /// gradient or a texture alike.
    indirect case layered(SurfaceFinish, Set<FinishEffect>)

    /// This finish with `effects` over it.
    public func with(_ effects: FinishEffect...) -> SurfaceFinish {
        .layered(self, Set(effects))
    }

    /// This finish as a gel: the gloss, the glow and the rim over it.
    public var gel: SurfaceFinish {
        with(.gloss, .glow, .rim)
    }

    /// Whether text on it reads in the light ink (on a colour) rather than the dark.
    var isColoured: Bool {
        switch self {
        case .solid, .gradient, .aqua: true
        case .glass, .texture, .chrome: false
        case let .layered(base, _): base.isColoured
        }
    }

    /// The colour light picks up passing through it, for the glow.
    var tone: ColorToken {
        switch self {
        case let .solid(colour), let .aqua(colour): colour
        case let .gradient(colours): colours.last ?? .fixedWhite
        case .glass, .texture, .chrome: .fixedWhite
        case let .layered(base, _): base.tone
        }
    }
}

/// One of Aqua's layers, to put over any finish.
public enum FinishEffect: Hashable, Sendable {
    /// A white sheen over the top half, inset from the sides.
    case gloss
    /// Light gathering at the bottom, in the finish's own colour.
    case glow
    /// A darker edge, as a gel's.
    case rim
}

public extension EnvironmentValues {
    /// The finish every Vitral control under this view is made of, unless it asks for its own;
    /// `nil` leaves each to its own default.
    @Entry var controlFinish: SurfaceFinish?
}

public extension View {
    /// The finish every Vitral control under this view is made of: buttons, fader thumbs.
    func controlFinish(_ finish: SurfaceFinish?) -> some View {
        environment(\.controlFinish, finish)
    }

    /// Fills the space behind this view with `finish`, cut to `shape`.
    func finish(_ finish: SurfaceFinish, in shape: some InsettableShape) -> some View {
        background { FinishedShape(finish: finish, shape: shape) }
    }
}

/// A shape made of a finish.
public struct FinishedShape<S: InsettableShape>: View {
    let finish: SurfaceFinish
    let shape: S

    public init(finish: SurfaceFinish, shape: S) {
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
        case let .layered(base, effects):
            FinishedShape(finish: base, shape: shape)
                .overlay { GelLayers(tone: base.tone, effects: effects, shape: shape) }
        }
    }
}

/// Aqua's layers over a shape: the glow, the gloss, the rim, each when asked for.
struct GelLayers<S: InsettableShape>: View {
    let tone: ColorToken
    let effects: Set<FinishEffect>
    let shape: S

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if effects.contains(.glow) {
                    // Light passing through, gathering at the bottom.
                    shape.fill(
                        RadialGradient(
                            colors: [Color(tone).mix(with: .white, by: 0.6).opacity(0.85), .clear],
                            center: UnitPoint(x: 0.5, y: 1),
                            startRadius: 0,
                            endRadius: max(proxy.size.width, proxy.size.height) * 0.6
                        )
                    )
                }
                if effects.contains(.gloss) {
                    Capsule()
                        .fill(LinearGradient(colors: [Color(ColorToken.fixedWhite.opacity(0.9)), Color(ColorToken.fixedWhite.opacity(0.08))], startPoint: .top, endPoint: .bottom))
                        .frame(width: proxy.size.width * 0.84, height: proxy.size.height * 0.48)
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.28)
                }
                if effects.contains(.rim) {
                    shape.strokeBorder(Color(tone).mix(with: .black, by: 0.4), lineWidth: 0.8)
                }
            }
            .clipShape(shape)
        }
        .allowsHitTesting(false)
    }
}

/// Glass with a rim: a lighter, clearer glass than a panel's, and a bright edge catching the light
/// from above, so a small control reads as a piece of glass rather than a white disc.
struct GlassFinish<S: InsettableShape>: View {
    let material: GlassToken?
    let shape: S

    @Environment(\.glassMaterial) private var environmentMaterial

    var body: some View {
        Color.clear
            .glassEffect(.token((material ?? .clear).interactive()), in: shape)
            .overlay {
                shape.strokeBorder(
                    LinearGradient(colors: [Color(ColorToken.fixedWhite.opacity(0.95)), Color(ColorToken.fixedWhite.opacity(0.15))], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1.2
                )
            }
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
