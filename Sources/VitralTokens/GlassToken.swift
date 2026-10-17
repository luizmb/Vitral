/// A glass material: how much of what's behind shows through, an optional tint, and whether it
/// reacts to touch.
public struct GlassToken: Hashable, Sendable {
    public enum Variant: Hashable, Sendable {
        /// Frosted enough to read text on anything.
        case regular
        /// Mostly clear: for glass over media, with a dimmed backdrop.
        case clear
    }

    public var variant: Variant
    public var tint: ColorToken?
    public var isInteractive: Bool

    public init(_ variant: Variant = .regular, tint: ColorToken? = nil, isInteractive: Bool = false) {
        self.variant = variant
        self.tint = tint
        self.isInteractive = isInteractive
    }

    public func tinted(_ tint: ColorToken?) -> GlassToken {
        GlassToken(variant, tint: tint, isInteractive: isInteractive)
    }

    /// Glass that responds to touch (it scales and shimmers under the finger).
    public func interactive(_ isInteractive: Bool = true) -> GlassToken {
        GlassToken(variant, tint: tint, isInteractive: isInteractive)
    }
}

public extension GlassToken {
    static let regular = GlassToken(.regular)
    static let clear = GlassToken(.clear)
    /// Regular glass with a light accent tint: something active or chosen.
    static let active = GlassToken(.regular, tint: ColorToken.accent.opacity(0.18))
}
