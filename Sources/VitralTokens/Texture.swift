/// The seamless textures Vitral ships (Poly Haven, CC0; see CREDITS.md): small tiles that repeat to
/// fill any space. The raw value names the asset.
public enum Texture: String, CaseIterable, Hashable, Sendable {
    // Woods. `wood` and `woodPale` change with the appearance: a light wood in light mode, a dark
    // one in dark mode.
    /// Cherry in light mode, sapele (African mahogany) in dark mode.
    case wood
    /// Ash in light mode, black walnut in dark mode.
    case woodPale
    case oak, walnut, teak, rosewood, lacqueredCherry, hinoki, planks

    // Stones.
    case marble, marbleTiles, marbleMosaic, terrazzo, slate, slatePatterned, sandstone, granite, concrete

    // Fabrics and leathers.
    case linen, cotton, denim, velvet, corduroy, herringbone, leather, leatherWhite, leatherRed

    // Metal.
    case metalPlate

    /// Whether the tile has its own dark-mode version (and so isn't dimmed in dark mode).
    public var followsAppearance: Bool {
        self == .wood || self == .woodPale
    }

    public enum Family: String, CaseIterable, Sendable {
        case woods, stones, fabrics, metals
    }

    public var family: Family {
        switch self {
        case .wood, .woodPale, .oak, .walnut, .teak, .rosewood, .lacqueredCherry, .hinoki, .planks: .woods
        case .marble, .marbleTiles, .marbleMosaic, .terrazzo, .slate, .slatePatterned, .sandstone, .granite, .concrete: .stones
        case .linen, .cotton, .denim, .velvet, .corduroy, .herringbone, .leather, .leatherWhite, .leatherRed: .fabrics
        case .metalPlate: .metals
        }
    }
}
