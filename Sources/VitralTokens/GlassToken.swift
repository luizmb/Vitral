/// A glass material: how much of what's behind shows through, an optional tint, and whether it
/// reacts to touch.
public struct GlassToken: Hashable, Sendable {
    public enum Variant: Hashable, Sendable {
        /// Frosted enough to read text on anything.
        case regular
        /// Mostly clear: for glass over media, with a dimmed backdrop.
        case clear
        /// Barely there: nothing behind it blurred, only its tint and a sheen from above say it's
        /// glass. For small pieces over a busy backdrop (a node on a canvas) that must stay sharp.
        /// It doesn't answer touch.
        case sheer
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
    static let sheer = GlassToken(.sheer)
    /// Clear glass behind a veil of the backdrop colour, `amount` strong (0 ... 1): a dial between
    /// `clear` (0) and nearly opaque (1). Vitral's default is `veiled(0.45)`: the backdrop shows
    /// through, the text on it still reads.
    static func veiled(_ amount: Double = 0.45) -> GlassToken {
        GlassToken(.clear, tint: ColorToken.veil.opacity(min(1, max(0, amount))))
    }
    /// Regular glass with a light accent tint: something active or chosen.
    static let active = GlassToken(.regular, tint: ColorToken.accent.opacity(0.18))
}
