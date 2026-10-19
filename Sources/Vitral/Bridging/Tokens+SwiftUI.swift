import SwiftUI
import VitralTokens
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// The one place tokens become SwiftUI values. Components only ever go through these.

public extension EnvironmentValues {
    /// The colour scheme Vitral draws in. The app's, set with `.scheme(_:)` from its own state (the
    /// device's appearance arrives through the app's world, like any other fact about the device);
    /// Vitral never asks the device. Light until set.
    @Entry var vitralScheme: ColorScheme = .light
}

public extension View {
    /// Draws this view, and everything in it, in `scheme`: Vitral's token colours, and SwiftUI's own
    /// (system controls, materials, glass, asset colour variants), which read the same value. The
    /// scheme is the app's, from its state; set it once at the root.
    func scheme(_ scheme: ColorScheme) -> some View {
        environment(\.vitralScheme, scheme).environment(\.colorScheme, scheme)
    }
}

public extension Color {
    /// The token's colour in `scheme`.
    init(_ token: ColorToken, scheme: ColorScheme) {
        self.init(token.resolved(isDark: scheme == .dark))
    }

    /// An RGBA value as a SwiftUI colour, in sRGB.
    init(_ rgba: RGBA) {
        self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }
}

/// A token's colour as a shape style, resolved in the scheme the app set (`.scheme(_:)`). What
/// components fill, stroke and tint with wherever a style will do; where a `Color` itself is
/// needed (a gradient's stops, a shadow), they resolve the token with `Color(_:scheme:)`.
public struct TokenColor: ShapeStyle {
    let token: ColorToken

    public init(_ token: ColorToken) {
        self.token = token
    }

    public func resolve(in environment: EnvironmentValues) -> Color {
        Color(token, scheme: environment.vitralScheme)
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(_ rgba: RGBA) {
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}
#elseif canImport(AppKit)
extension NSColor {
    convenience init(_ rgba: RGBA) {
        self.init(srgbRed: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}
#endif

public extension Font {
    init(_ token: TypeToken) {
        self = .system(Font.TextStyle(token.style), design: Font.Design(token.design), weight: Font.Weight(token.weight))
    }
}

#if canImport(UIKit)
public extension UIFont {
    /// The token's font for a UIKit text view (a code editor, say): the same style, weight and
    /// design as `Font(_:)`, at the reader's Dynamic Type size.
    static func token(_ token: TypeToken, traits: UITraitCollection? = nil) -> UIFont {
        UIFont(
            descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle(token.style), compatibleWith: traits)
                .withDesign(UIFontDescriptor.SystemDesign(token.design)) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle(token.style), compatibleWith: traits),
            size: 0
        )
        .withWeight(UIFont.Weight(token.weight))
    }

    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        UIFont(descriptor: fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]]), size: 0)
    }
}

extension UIFont.TextStyle {
    init(_ style: TypeToken.Style) {
        self = switch style {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        }
    }
}

extension UIFontDescriptor.SystemDesign {
    init(_ design: TypeToken.Design) {
        self = switch design {
        case .default: .default
        case .rounded: .rounded
        case .monospaced: .monospaced
        }
    }
}

extension UIFont.Weight {
    init(_ weight: TypeToken.Weight) {
        self = switch weight {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}
#elseif canImport(AppKit)
public extension NSFont {
    /// The token's font for an AppKit text view (a code editor, say): the same style, weight and
    /// design as `Font(_:)`.
    static func token(_ token: TypeToken) -> NSFont {
        NSFont(
            descriptor: NSFontDescriptor.preferredFontDescriptor(forTextStyle: NSFont.TextStyle(token.style))
                .withDesign(NSFontDescriptor.SystemDesign(token.design))?
                .addingAttributes([.traits: [NSFontDescriptor.TraitKey.weight: NSFont.Weight(token.weight)]])
                ?? NSFontDescriptor.preferredFontDescriptor(forTextStyle: NSFont.TextStyle(token.style)),
            size: 0
        ) ?? .systemFont(ofSize: NSFont.systemFontSize)
    }
}

extension NSFont.TextStyle {
    init(_ style: TypeToken.Style) {
        self = switch style {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        }
    }
}

extension NSFontDescriptor.SystemDesign {
    init(_ design: TypeToken.Design) {
        self = switch design {
        case .default: .default
        case .rounded: .rounded
        case .monospaced: .monospaced
        }
    }
}

extension NSFont.Weight {
    init(_ weight: TypeToken.Weight) {
        self = switch weight {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}
#endif

extension Font.TextStyle {
    init(_ style: TypeToken.Style) {
        self = switch style {
        case .largeTitle: .largeTitle
        case .title: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption
        case .caption2: .caption2
        }
    }
}

extension Font.Design {
    init(_ design: TypeToken.Design) {
        self = switch design {
        case .default: .default
        case .rounded: .rounded
        case .monospaced: .monospaced
        }
    }
}

extension Font.Weight {
    init(_ weight: TypeToken.Weight) {
        self = switch weight {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}

public extension Glass {
    /// The system's glass for `token`; `sheer` is none (Vitral draws it, see `glassLayer(_:in:)`).
    static func token(_ token: GlassToken, scheme: ColorScheme) -> Glass {
        variant(token.variant)
            .tint(token.tint.map { Color($0, scheme: scheme) })
            .interactive(token.isInteractive)
    }

    private static func variant(_ variant: GlassToken.Variant) -> Glass {
        switch variant {
        case .regular: .regular
        case .clear: .clear
        case .sheer: .identity
        }
    }
}

public extension Image {
    init(_ glyph: Glyph) {
        self.init(systemName: glyph.rawValue)
    }
}

public extension Image {
    /// One of Vitral's illustrations, from the package's own assets.
    init(_ illustration: Illustration) {
        self.init(illustration.rawValue, bundle: .module)
    }
}

public extension Image {
    /// One of Vitral's texture tiles, from the package's own assets.
    init(_ texture: Texture) {
        self.init("texture-\(texture.rawValue)", bundle: .module)
    }
}
