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

    /// Glass cut to a rounded rectangle with continuous corners: `material`, or the environment's
    /// `glassMaterial` when not given.
    func glassSurface(_ material: GlassToken? = nil, cornerRadius: Double = Radius.large) -> some View {
        modifier(GlassShape(material: material, shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)))
    }

    /// Glass cut to a capsule: `material`, or the environment's `glassMaterial` when not given.
    func glassCapsule(_ material: GlassToken? = nil) -> some View {
        modifier(GlassShape(material: material, shape: Capsule()))
    }

    /// The glass every Vitral surface under this view is made of, unless it asks for its own.
    func glassMaterial(_ material: GlassToken) -> some View {
        environment(\.glassMaterial, material)
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
    /// The glass Vitral's surfaces are made of: `veiled()` unless set (`.glassMaterial(_:)`).
    @Entry var glassMaterial: GlassToken = .veiled()
    /// The accent Vitral's controls are marked with: `.primary` unless set (`.accent(_:)`).
    @Entry var accent: AccentToken = .primary
}

/// Glass in a shape, from the given material or the environment's.
struct GlassShape<S: Shape>: ViewModifier {
    let material: GlassToken?
    let shape: S

    @Environment(\.glassMaterial) private var environmentMaterial

    func body(content: Content) -> some View {
        content.glassLayer(material ?? environmentMaterial, in: shape)
    }
}

extension View {
    /// `material` behind this view, cut to `shape`: the system's glass, or for `sheer` its tint
    /// and a sheen drawn over the backdrop, nothing behind blurred.
    func glassLayer(_ material: GlassToken, in shape: some Shape) -> some View {
        modifier(GlassMaterial(material: material, shape: shape))
    }
}

struct GlassMaterial<S: Shape>: ViewModifier {
    let material: GlassToken
    let shape: S

    // One path for every variant: a branch around `glassEffect` blanked whole
    // `GlassEffectContainer`s. `sheer` is the system's identity glass with Vitral's layer behind.
    func body(content: Content) -> some View {
        content
            .background { SheerGlass(tint: material.tint, shape: shape).opacity(material.variant == .sheer ? 1 : 0) }
            .glassEffect(.token(material), in: shape)
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
