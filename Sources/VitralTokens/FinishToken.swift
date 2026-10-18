/// What a control's surface is made of (a thumb, a cap, a button), in three layers from the
/// bottom up:
///
/// 1. `glass`: the system's glass, or none.
/// 2. `fill`: a colour, a gradient, a texture, chrome or Aqua's gel; on glass, `amount` of it
///    shows (0 ... 1), so glass can carry a hint of a colour.
/// 3. `sheen`: Aqua's light on top, each part as strong as asked (gloss, glow, rim).
///
/// ```swift
/// .glass(.clear)                                         // clear glass
/// .solid(.accent)                                        // a flat colour
/// .aqua(.accent)                                         // Aqua's gel: the gel fill, full sheen
/// .aqua(.accent).onGlass(.clear, amount: 0.2)            // clear glass with a hint of Aqua
/// .glass(.clear).sheen(gloss: 0.2, glow: 0.2)            // clear glass, lightly glossed
/// ```
///
/// A plain value, so a theme in the app's state can hold one; Vitral's bridging draws it.
public struct FinishToken: Hashable, Sendable {
    /// What colours a finish.
    public enum Fill: Hashable, Sendable {
        case colour(ColorToken)
        /// Top to bottom.
        case gradient([ColorToken])
        case texture(Texture)
        /// Polished metal.
        case chrome
        /// Aqua's gel body: the colour, darker at the top and lighter at the bottom.
        case gel(ColorToken)
    }

    /// Aqua's light over a finish, each part 0 (none) ... 1.
    public struct Sheen: Hashable, Sendable {
        /// A white sheen over the top half, inset from the sides.
        public var gloss: Double
        /// Light gathering at the bottom, in the finish's own colour.
        public var glow: Double
        /// A darker edge, as a gel's.
        public var rim: Double

        public init(gloss: Double = 0, glow: Double = 0, rim: Double = 0) {
            self.gloss = Self.unit(gloss)
            self.glow = Self.unit(glow)
            self.rim = Self.unit(rim)
        }

        public static let none = Sheen()

        /// All three, `strength` strong: Aqua's whole sheen.
        public static func aqua(_ strength: Double = 1) -> Sheen {
            Sheen(gloss: strength, glow: strength, rim: strength)
        }

        public var isNone: Bool { self == .none }

        static func unit(_ value: Double) -> Double { min(1, max(0, value)) }
    }

    public var glass: GlassToken?
    public var fill: Fill?
    /// How much of the fill shows over the glass (0 ... 1); without glass the fill is whole.
    public var amount: Double
    public var sheen: Sheen

    public init(glass: GlassToken? = nil, fill: Fill? = nil, amount: Double = 1, sheen: Sheen = .none) {
        self.glass = glass
        self.fill = fill
        self.amount = Sheen.unit(amount)
        self.sheen = sheen
    }

    /// Glass: `glass`, or clear glass answering touch, with a bright rim.
    public static func glass(_ glass: GlassToken? = nil) -> FinishToken {
        FinishToken(glass: glass ?? GlassToken.clear.interactive())
    }

    public static func solid(_ colour: ColorToken) -> FinishToken {
        FinishToken(fill: .colour(colour))
    }

    /// Top to bottom.
    public static func gradient(_ colours: [ColorToken]) -> FinishToken {
        FinishToken(fill: .gradient(colours))
    }

    public static func texture(_ texture: Texture) -> FinishToken {
        FinishToken(fill: .texture(texture))
    }

    /// Polished chrome.
    public static let chrome = FinishToken(fill: .chrome)

    /// Aqua's gel in `colour`: the gel fill under the whole sheen.
    public static func aqua(_ colour: ColorToken) -> FinishToken {
        FinishToken(fill: .gel(colour), sheen: .aqua())
    }

    /// This finish's fill over `glass` (clear glass answering touch when not given), `amount` of
    /// it showing (0 ... 1); its sheen kept.
    public func onGlass(_ glass: GlassToken? = nil, amount: Double) -> FinishToken {
        FinishToken(glass: glass ?? self.glass ?? GlassToken.clear.interactive(), fill: fill, amount: amount, sheen: sheen)
    }

    /// This finish with `sheen` on top.
    public func sheen(_ sheen: Sheen) -> FinishToken {
        FinishToken(glass: glass, fill: fill, amount: amount, sheen: sheen)
    }

    /// This finish with Aqua's light on top, each part as strong as given (0 ... 1).
    public func sheen(gloss: Double = 0, glow: Double = 0, rim: Double = 0) -> FinishToken {
        sheen(Sheen(gloss: gloss, glow: glow, rim: rim))
    }

    /// Whether it reads as a colour, so text on it takes the light ink rather than the dark: a
    /// colour, gradient or gel showing at least half, or glass tinted strongly.
    public var isColoured: Bool {
        switch fill {
        case .colour, .gradient, .gel: glass == nil || amount >= 0.5
        case .texture, .chrome: false
        case nil: (glass?.tint).map { $0.light.alpha >= 0.4 } ?? false
        }
    }

    /// This finish with its glass tinted `tint` when the glass has no tint of its own, everything
    /// else kept: how a primary button stands out under a glass finish, as the system's prominent
    /// glass does.
    public func tintingGlass(_ tint: ColorToken) -> FinishToken {
        FinishToken(glass: glass.map { $0.tinted($0.tint ?? tint) }, fill: fill, amount: amount, sheen: sheen)
    }

    /// Whether it's glass underneath.
    public var isGlass: Bool { glass != nil }

    /// The colour light picks up passing through it, for the glow.
    public var tone: ColorToken {
        switch fill {
        case let .colour(colour), let .gel(colour): colour
        case let .gradient(colours): colours.last ?? .fixedWhite
        case .texture, .chrome: .fixedWhite
        case nil: glass?.tint?.opacity(1) ?? .fixedWhite
        }
    }
}
