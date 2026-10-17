/// A soft hue for telling things apart: compartments, lanes, tags, card headers. Each comes as a
/// pastel `surface` and an `ink` strong enough to read on it, in light and dark. Tints carry no
/// meaning of their own: amber is not a warning (feedback colours are for that).
public enum Tint: String, CaseIterable, Hashable, Sendable {
    case blue, teal, green, amber, pink, violet

    /// A pastel fill: the hue over whatever is behind it.
    public var surface: ColorToken {
        ColorToken(light: hue.opacity(0.18), dark: hue.opacity(0.26))
    }

    /// Text and icons on the surface.
    public var ink: ColorToken {
        switch self {
        case .blue: ColorToken(light: RGBA(hex: 0x1F5FBF), dark: RGBA(hex: 0x9CC4FF))
        case .teal: ColorToken(light: RGBA(hex: 0x0E7279), dark: RGBA(hex: 0x7FDDE2))
        case .green: ColorToken(light: RGBA(hex: 0x2A7439), dark: RGBA(hex: 0x93DDA4))
        case .amber: ColorToken(light: RGBA(hex: 0x8F5300), dark: RGBA(hex: 0xF7C979))
        case .pink: ColorToken(light: RGBA(hex: 0xA82E66), dark: RGBA(hex: 0xFFA6CE))
        case .violet: ColorToken(light: RGBA(hex: 0x6542C2), dark: RGBA(hex: 0xC6AEFF))
        }
    }

    var hue: RGBA {
        switch self {
        case .blue: RGBA(hex: 0x3B82F6)
        case .teal: RGBA(hex: 0x14B8C4)
        case .green: RGBA(hex: 0x34C759)
        case .amber: RGBA(hex: 0xF5A524)
        case .pink: RGBA(hex: 0xF0609E)
        case .violet: RGBA(hex: 0x8B5CF6)
        }
    }
}
