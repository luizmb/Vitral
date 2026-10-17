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

    /// A flat fill behind the content, cut to a rounded rectangle with continuous corners.
    func surface(_ fill: ColorToken, cornerRadius: Double = Radius.medium) -> some View {
        background(Color(fill), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

public extension EnvironmentValues {
    /// The glass Vitral's surfaces are made of: `veiled()` unless set (`.glassMaterial(_:)`).
    @Entry var glassMaterial: GlassToken = .veiled()
}

/// Glass in a shape, from the given material or the environment's.
struct GlassShape<S: Shape>: ViewModifier {
    let material: GlassToken?
    let shape: S

    @Environment(\.glassMaterial) private var environmentMaterial

    func body(content: Content) -> some View {
        content.glassEffect(.token(material ?? environmentMaterial), in: shape)
    }
}
