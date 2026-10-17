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

    /// Glass cut to a rounded rectangle with continuous corners.
    func glassSurface(_ material: GlassToken = .regular, cornerRadius: Double = Radius.large) -> some View {
        glassEffect(.token(material), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Glass cut to a capsule.
    func glassCapsule(_ material: GlassToken = .regular) -> some View {
        glassEffect(.token(material), in: Capsule())
    }

    /// A flat fill behind the content, cut to a rounded rectangle with continuous corners.
    func surface(_ fill: ColorToken, cornerRadius: Double = Radius.medium) -> some View {
        background(Color(fill), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
