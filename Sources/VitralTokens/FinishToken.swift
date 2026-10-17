/// What a control's surface is made of (a thumb, a cap, a button): a material built from the
/// other tokens. Glass by default; or a solid colour, a gradient, a texture, chrome, or Aqua's gel
/// (a saturated body glowing lighter at the bottom, a gloss over its top half). Aqua's layers go
/// over any of them (`.gel`, `.with(.gloss)`). A plain value, so a theme in the app's state can
/// hold one; Vitral's bridging draws it, as it draws glass.
public enum FinishToken: Hashable, Sendable {
    /// Liquid glass: `material`, or the environment's glass; clear, with a bright rim.
    case glass(GlassToken? = nil)
    case solid(ColorToken)
    /// Top to bottom.
    case gradient([ColorToken])
    case texture(Texture)
    /// Aqua's gel, in `colour`.
    case aqua(ColorToken)
    /// Polished chrome.
    case chrome
    /// A finish with Aqua's layers over it: the gloss, the glow, the rim, on glass, a colour, a
    /// gradient or a texture alike.
    indirect case layered(FinishToken, Set<FinishEffect>)

    /// This finish with `effects` over it.
    public func with(_ effects: FinishEffect...) -> FinishToken {
        .layered(self, Set(effects))
    }

    /// This finish as a gel: the gloss, the glow and the rim over it.
    public var gel: FinishToken {
        with(.gloss, .glow, .rim)
    }

    /// Whether it's a colour, so text on it reads in the light ink rather than the dark.
    public var isColoured: Bool {
        switch self {
        case .solid, .gradient, .aqua: true
        case .glass, .texture, .chrome: false
        case let .layered(base, _): base.isColoured
        }
    }

    /// The colour light picks up passing through it, for the glow.
    public var tone: ColorToken {
        switch self {
        case let .solid(colour), let .aqua(colour): colour
        case let .gradient(colours): colours.last ?? .fixedWhite
        case .glass, .texture, .chrome: .fixedWhite
        case let .layered(base, _): base.tone
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

