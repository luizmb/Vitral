import SwiftUI
import VitralTokens

// Token-taking modifiers: the vocabulary components are written in, and apps can use them too.

public extension View {
    func foregroundStyle(_ token: ColorToken) -> some View {
        foregroundStyle(Color(token))
    }

    func font(_ token: TypeToken) -> some View {
        font(Font(token))
    }

    /// Glass cut to a rounded rectangle with continuous corners: `glass`, or the environment's
    /// `surfaceGlass` when not given.
    func glassSurface(_ glass: GlassToken? = nil, cornerRadius: Double = Radius.large) -> some View {
        modifier(GlassShape(glass: glass, shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)))
    }

    /// Glass cut to a capsule: `glass`, or the environment's `surfaceGlass` when not given.
    func glassCapsule(_ glass: GlassToken? = nil) -> some View {
        modifier(GlassShape(glass: glass, shape: Capsule()))
    }

    /// The glass every Vitral surface under this view is made of, unless it asks for its own.
    func surfaceGlass(_ glass: GlassToken) -> some View {
        environment(\.surfaceGlass, glass)
    }

    /// The accent every Vitral control under this view is marked with: `.primary` unless set.
    func accent(_ accent: AccentToken) -> some View {
        environment(\.accent, accent)
    }

    /// A flat fill behind the content, cut to a rounded rectangle with continuous corners.
    func surface(_ fill: ColorToken, cornerRadius: Double = Radius.medium) -> some View {
        background(Color(fill), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

public extension EnvironmentValues {
    /// The glass Vitral's surfaces are made of: `veiled()` unless set (`.surfaceGlass(_:)`).
    @Entry var surfaceGlass: GlassToken = .veiled()
    /// The accent Vitral's controls are marked with: `.primary` unless set (`.accent(_:)`).
    @Entry var accent: AccentToken = .primary
    /// Whether glass can be drawn here. Glass needs a real window to refract what's behind it; an
    /// offscreen renderer (a package's snapshot tests) draws none, leaving text floating with no
    /// surface. Set `false` there and every Vitral glass draws a plain surface of the same shape
    /// instead, so the pictures still check layout.
    @Entry var rendersGlass = true
}

/// Glass in a shape, from the given glass or the environment's.
struct GlassShape<S: Shape>: ViewModifier {
    let glass: GlassToken?
    let shape: S

    @Environment(\.surfaceGlass) private var environmentGlass

    func body(content: Content) -> some View {
        content.glassLayer(glass ?? environmentGlass, in: shape)
    }
}

extension View {
    /// `glass` behind this view, cut to `shape`: the system's glass, or for `sheer` its tint
    /// and a sheen drawn over the backdrop, nothing behind blurred.
    func glassLayer(_ glass: GlassToken, in shape: some Shape) -> some View {
        modifier(GlassLayer(glass: glass, shape: shape))
    }
}

struct GlassLayer<S: Shape>: ViewModifier {
    let glass: GlassToken
    let shape: S

    @Environment(\.rendersGlass) private var rendersGlass

    // One path for every variant: a branch around `glassEffect` blanked whole
    // `GlassEffectContainer`s. `sheer` is the system's identity glass with Vitral's layer behind;
    // without glass to draw, identity glass over a plain surface.
    func body(content: Content) -> some View {
        content
            .background { SheerGlass(tint: glass.tint, shape: shape).opacity(glass.variant == .sheer ? 1 : 0) }
            .background { PlainSurface(tint: glass.tint, shape: shape).opacity(rendersGlass ? 0 : 1) }
            .glassEffect(rendersGlass ? .token(glass) : .identity, in: shape)
            // Glass is a surface: all of it takes touches, not just what's drawn on it. A plain
            // button holding a card would otherwise answer only on its text, and a tap on the
            // card's empty glass would fall through to whatever is behind.
            .contentShape(shape)
    }
}

/// What glass is drawn as where it can't be: the backdrop's colour, raised a little, its tint over
/// it and a hairline round it.
struct PlainSurface<S: Shape>: View {
    let tint: ColorToken?
    let shape: S

    var body: some View {
        shape
            .fill(Color(.neutralSurface))
            .overlay { shape.fill(Color(tint ?? ColorToken.fixedWhite.opacity(0))) }
            .overlay { shape.stroke(Color(.hairline), lineWidth: 1) }
            .allowsHitTesting(false)
    }
}

/// Glass that blurs nothing: crystal clear, its tint (if any) and light catching its top.
struct SheerGlass<S: Shape>: View {
    let tint: ColorToken?
    let shape: S

    var body: some View {
        shape
            .fill(Color(tint ?? ColorToken.fixedWhite.opacity(0)))
            .overlay {
                shape.fill(
                    LinearGradient(
                        colors: [Color(ColorToken.fixedWhite.opacity(0.12)), .clear],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.4)
                    )
                )
            }
            .allowsHitTesting(false)
    }
}
