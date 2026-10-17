/// The colour that marks what's active or chosen, in the four shades components draw it with.
/// `primary` is Vitral's blue; `counter` is its warm opposite, for when two things must be told
/// apart at a glance (two series, before and after, A and B). Blue against coral stays apart for
/// the common colour-vision deficiencies.
public struct AccentToken: Hashable, Sendable {
    public var base: ColorToken
    /// The top and bottom of a filled mark's gradient.
    public var top: ColorToken
    public var bottom: ColorToken
    /// The glow under a filled mark.
    public var glow: ColorToken

    public init(base: ColorToken, top: ColorToken, bottom: ColorToken, glow: ColorToken) {
        self.base = base
        self.top = top
        self.bottom = bottom
        self.glow = glow
    }
}

public extension AccentToken {
    static let primary = AccentToken(base: .accent, top: .accentTop, bottom: .accentBottom, glow: .accentGlow)
    static let counter = AccentToken(base: .counterAccent, top: .counterAccentTop, bottom: .counterAccentBottom, glow: .counterAccentGlow)
}
