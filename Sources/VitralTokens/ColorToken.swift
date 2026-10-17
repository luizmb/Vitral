/// A colour as sRGB components, each 0 ... 1.
public struct RGBA: Hashable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// `0xRRGGBB`, as design tools write it.
    public init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    public func opacity(_ alpha: Double) -> RGBA {
        RGBA(red: red, green: green, blue: blue, alpha: alpha)
    }

    public static let white = RGBA(hex: 0xFFFFFF)
    public static let black = RGBA(hex: 0x000000)
}

/// A colour for each appearance. The UI layer picks one from the current colour scheme, so a view
/// written once with a token follows light and dark mode by itself.
public struct ColorToken: Hashable, Sendable {
    public var light: RGBA
    public var dark: RGBA

    public init(light: RGBA, dark: RGBA) {
        self.light = light
        self.dark = dark
    }

    /// The same colour in both appearances.
    public init(_ both: RGBA) {
        self.init(light: both, dark: both)
    }

    public func resolved(isDark: Bool) -> RGBA {
        isDark ? dark : light
    }

    public func opacity(_ alpha: Double) -> ColorToken {
        ColorToken(light: light.opacity(alpha), dark: dark.opacity(alpha))
    }
}

// MARK: - Palette

public extension ColorToken {
    // Ink: text and glyphs, strongest to weakest.
    static let ink = ColorToken(light: RGBA(hex: 0x16140F), dark: RGBA(hex: 0xF3F1EC))
    static let inkMuted = ColorToken(light: RGBA(hex: 0x16140F, alpha: 0.55), dark: RGBA(hex: 0xF3F1EC, alpha: 0.62))
    static let inkFaint = ColorToken(light: RGBA(hex: 0x16140F, alpha: 0.36), dark: RGBA(hex: 0xF3F1EC, alpha: 0.40))
    /// Text and glyphs on an accent fill.
    static let onAccent = ColorToken(.white)

    /// Dividers and outlines, a hair's weight.
    static let hairline = ColorToken(light: RGBA.black.opacity(0.10), dark: RGBA.white.opacity(0.12))
    /// The outline of an unselected selection mark.
    static let outline = ColorToken(light: RGBA.black.opacity(0.28), dark: RGBA.white.opacity(0.35))

    // Accent: the one colour that says "act here".
    static let accent = ColorToken(light: RGBA(hex: 0x0A74F0), dark: RGBA(hex: 0x3B9BFF))
    static let accentTop = ColorToken(light: RGBA(hex: 0x46A3FF), dark: RGBA(hex: 0x5FB0FF))
    static let accentBottom = ColorToken(light: RGBA(hex: 0x0A63D8), dark: RGBA(hex: 0x1F6FD6))
    static let accentGlow = ColorToken(light: RGBA(hex: 0x0A74F0, alpha: 0.45), dark: RGBA(hex: 0x2882FF, alpha: 0.55))
    /// The accent's warm opposite, coral: see `AccentToken.counter`.
    static let counterAccent = ColorToken(light: RGBA(hex: 0xE8602C), dark: RGBA(hex: 0xFF8F5E))
    static let counterAccentTop = ColorToken(light: RGBA(hex: 0xFF8A57), dark: RGBA(hex: 0xFFA47C))
    static let counterAccentBottom = ColorToken(light: RGBA(hex: 0xD64E1C), dark: RGBA(hex: 0xE56A38))
    static let counterAccentGlow = ColorToken(light: RGBA(hex: 0xE8602C, alpha: 0.45), dark: RGBA(hex: 0xFF7A45, alpha: 0.55))

    // Feedback.
    static let warning = ColorToken(light: RGBA(hex: 0xB8730A), dark: RGBA(hex: 0xFFB55A))
    static let warningSurface = ColorToken(light: RGBA(hex: 0xF09614, alpha: 0.13), dark: RGBA(hex: 0xFF9628, alpha: 0.12))
    static let danger = ColorToken(light: RGBA(hex: 0xCC3322), dark: RGBA(hex: 0xFF8A7A))
    static let dangerSurface = ColorToken(light: RGBA(hex: 0xE63C28, alpha: 0.12), dark: RGBA(hex: 0xFF503C, alpha: 0.14))
    static let success = ColorToken(light: RGBA(hex: 0x1E8A4C), dark: RGBA(hex: 0x5FD38D))
    static let successSurface = ColorToken(light: RGBA(hex: 0x28A85E, alpha: 0.12), dark: RGBA(hex: 0x3CC878, alpha: 0.14))
    static let info = ColorToken(light: RGBA(hex: 0x0A63D8), dark: RGBA(hex: 0x6FB4FF))
    static let infoSurface = ColorToken(light: RGBA(hex: 0x0A74F0, alpha: 0.10), dark: RGBA(hex: 0x3B9BFF, alpha: 0.14))
    static let neutralSurface = ColorToken(light: RGBA.black.opacity(0.045), dark: RGBA.white.opacity(0.05))

    /// A selected row or segment, lifted off the glass.
    static let selectedSurface = ColorToken(light: RGBA.white.opacity(0.92), dark: RGBA.white.opacity(0.16))

    /// A thin wash of the backdrop colour on clear glass, so text on it stays legible over a busy
    /// backdrop without the glass going opaque.
    /// At full strength; `GlassToken.veiled(_:)` takes a fraction of it.
    static let veil = ColorToken(light: RGBA(white: 0.97), dark: RGBA(white: 0.08))

    /// Laid over a screen that has to wait (`ProgressOverlay`): it dims what's underneath.
    static let scrim = ColorToken(light: RGBA.black.opacity(0.18), dark: RGBA.black.opacity(0.45))

    /// What sits under the glass when nothing else does.
    static let backdrop = ColorToken(light: RGBA(white: 0.965), dark: RGBA(white: 0.09))
    /// The graph paper's fine lines and its stronger every-fifth lines.
    static let gridLine = ColorToken(light: RGBA.black.opacity(0.05), dark: RGBA.white.opacity(0.06))
    static let gridLineMajor = ColorToken(light: RGBA.black.opacity(0.09), dark: RGBA.white.opacity(0.11))

    // Backdrop materials.
    static let woodBase = ColorToken(light: RGBA(hex: 0xDDBB92), dark: RGBA(hex: 0x3A2A1E))
    static let woodGrain = ColorToken(light: RGBA(hex: 0x8B5A2B, alpha: 0.30), dark: RGBA(hex: 0xC8935F, alpha: 0.22))
    static let metalBase = ColorToken(light: RGBA(hex: 0xCDD0D5), dark: RGBA(hex: 0x2B2D31))
    static let metalStreak = ColorToken(light: RGBA.white.opacity(0.55), dark: RGBA.white.opacity(0.07))
    static let metalShade = ColorToken(light: RGBA.black.opacity(0.06), dark: RGBA.black.opacity(0.35))
    /// Laid over a photographic texture or picture: nothing in light mode, a dimming in dark mode,
    /// so the picture sits with the rest of a dark screen.
    static let pictureDim = ColorToken(light: RGBA.black.opacity(0), dark: RGBA.black.opacity(0.4))

    // Liquid chrome: a polished, reflective metal.
    static let chromeHighlight = ColorToken(light: RGBA(hex: 0xFFFFFF, alpha: 0.95), dark: RGBA(hex: 0xE8EDF2, alpha: 0.85))
    static let chromeMid = ColorToken(light: RGBA(hex: 0xB9C0C8), dark: RGBA(hex: 0x5B636C))
    static let chromeShadow = ColorToken(light: RGBA(hex: 0x6E7782), dark: RGBA(hex: 0x1B1F24))
    static let paperFleck = ColorToken(light: RGBA(hex: 0x6B5A40, alpha: 0.22), dark: RGBA.white.opacity(0.12))

    // Washes: the saturated hues the abstract backdrops (aurora, glow, waves) are painted in.
    static let washGreen = ColorToken(light: RGBA(hex: 0x2EBF8A), dark: RGBA(hex: 0x3DF5A8))
    static let washTeal = ColorToken(light: RGBA(hex: 0x1FA3C7), dark: RGBA(hex: 0x2FD0E8))
    static let washViolet = ColorToken(light: RGBA(hex: 0x7F5CF0), dark: RGBA(hex: 0x9B6BFF))
    static let washPink = ColorToken(light: RGBA(hex: 0xEE6FAE), dark: RGBA(hex: 0xFF5FA8))
    static let washAmber = ColorToken(light: RGBA(hex: 0xF4A63A), dark: RGBA(hex: 0xFFB347))
    /// The sky an aurora hangs in, top and horizon: a blue day in light mode, night in dark mode.
    static let skyTop = ColorToken(light: RGBA(hex: 0x3F7FD9), dark: RGBA(hex: 0x03060E))
    static let skyHorizon = ColorToken(light: RGBA(hex: 0xB4D3F2), dark: RGBA(hex: 0x0C1424))
    /// Stars: none by day.
    static let star = ColorToken(light: RGBA.white.opacity(0), dark: RGBA.white.opacity(0.7))
}

public extension RGBA {
    /// A grey: `white` 0 is black, 1 is white.
    init(white: Double, alpha: Double = 1) {
        self.init(red: white, green: white, blue: white, alpha: alpha)
    }
}
