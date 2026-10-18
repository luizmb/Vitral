/// What a control's surface is made of (a thumb, a cap, a button): a material built from the
/// other tokens. Glass by default; or a solid colour, a gradient, a texture, chrome, or Aqua's gel
/// (a saturated body glowing lighter at the bottom, a gloss over its top half). Each is a dial,
/// not a look: how clear the glass is (`GlassToken`'s variant) and how tinted, how much of a
/// colour, gradient, texture or gel is mixed over it (`.overGlass(_:amount:)`), how strong Aqua's
/// layers are over any of them (`.gel(_:)`, `.with(_:strength:)`). A plain value, so a theme in
/// the app's state can hold one; Vitral's bridging draws it, as it draws glass.
public enum FinishToken: Hashable, Sendable {
    /// Liquid glass: `material`, or clear glass answering touch; with a bright rim.
    case glass(GlassToken? = nil)
    case solid(ColorToken)
    /// Top to bottom.
    case gradient([ColorToken])
    case texture(Texture)
    /// Aqua's gel, in `colour`.
    case aqua(ColorToken)
    /// Polished chrome.
    case chrome
    /// `finish` over `glass` (clear glass answering touch when not given), `amount` of it
    /// (0 ... 1): glass with a touch of a colour, a gradient, a texture or Aqua's gel.
    indirect case mixed(FinishToken, glass: GlassToken?, amount: Double)
    /// A finish with Aqua's layers over it, `strength` strong (0 ... 1): the gloss, the glow, the
    /// rim, on glass, a colour, a gradient or a texture alike.
    indirect case layered(FinishToken, Set<FinishEffect>, strength: Double)

    /// This finish with `effects` over it, `strength` strong (0 ... 1).
    public func with(_ effects: FinishEffect..., strength: Double = 1) -> FinishToken {
        .layered(self, Set(effects), strength: strength)
    }

    /// This finish as a gel: the gloss, the glow and the rim over it, `strength` strong (0 ... 1;
    /// on glass, a little keeps it clear).
    public func gel(_ strength: Double = 1) -> FinishToken {
        with(.gloss, .glow, .rim, strength: strength)
    }

    /// This finish laid over `glass`, `amount` of it (0 ... 1): `.aqua(.accent).overGlass(.clear,
    /// amount: 0.3)` is clear glass with a hint of Aqua.
    public func overGlass(_ glass: GlassToken? = nil, amount: Double) -> FinishToken {
        .mixed(self, glass: glass, amount: min(1, max(0, amount)))
    }

    /// Whether it's a colour, so text on it reads in the light ink rather than the dark.
    public var isColoured: Bool {
        switch self {
        case .solid, .gradient, .aqua: true
        // Glass tinted strongly enough to read as the colour.
        case let .glass(material): (material?.tint).map { $0.light.alpha >= 0.4 } ?? false
        case .texture, .chrome: false
        case let .mixed(finish, _, amount): amount >= 0.5 && finish.isColoured
        case let .layered(base, _, _): base.isColoured
        }
    }

    /// This finish with its untinted glass tinted `tint`, everything else kept: how a primary
    /// button stands out under a glass finish, as the system's prominent glass does.
    public func tintingGlass(_ tint: ColorToken) -> FinishToken {
        switch self {
        case let .glass(material): .glass(Self.tinting(material, tint))
        case let .mixed(finish, glass, amount): .mixed(finish, glass: Self.tinting(glass, tint), amount: amount)
        case let .layered(base, effects, strength): .layered(base.tintingGlass(tint), effects, strength: strength)
        default: self
        }
    }

    private static func tinting(_ material: GlassToken?, _ tint: ColorToken) -> GlassToken {
        (material ?? GlassToken.clear.interactive()).tinted(material?.tint ?? tint)
    }

    /// Whether it's glass underneath.
    public var isGlass: Bool {
        switch self {
        case .glass, .mixed: true
        case let .layered(base, _, _): base.isGlass
        default: false
        }
    }

    /// The colour light picks up passing through it, for the glow.
    public var tone: ColorToken {
        switch self {
        case let .solid(colour), let .aqua(colour): colour
        case let .gradient(colours): colours.last ?? .fixedWhite
        case let .glass(material): material?.tint?.opacity(1) ?? .fixedWhite
        case .texture, .chrome: .fixedWhite
        case let .mixed(finish, _, _): finish.tone
        case let .layered(base, _, _): base.tone
        }
    }
}

/// One of Aqua's layers, to put over any finish.
public enum FinishEffect: Hashable, Sendable {
    /// A white sheen over the top half, inset from the sides.
    case gloss
    /// Light gathering at the bottom, in the finish's own colour.
    case glow
    /// A darker edge, as a gel's.
    case rim
}

