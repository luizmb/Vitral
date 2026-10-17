/// Gaps and padding, in points. Each step roughly doubles, so a layout picks a step rather than a
/// number.
public enum Space {
    public static let hairline = 2.0
    public static let extraSmall = 4.0
    public static let small = 8.0
    public static let medium = 12.0
    public static let large = 16.0
    public static let extraLarge = 24.0
    public static let huge = 32.0
}

/// Corner radii, in points. Nested shapes take the next radius down, so their corners stay
/// concentric.
public enum Radius {
    public static let extraSmall = 6.0
    public static let small = 8.0
    public static let medium = 12.0
    public static let large = 16.0
    public static let card = 22.0
    public static let sheet = 26.0
}

/// Fixed sizes, in points.
public enum Size {
    /// The smallest a tappable area should be (Apple's guideline).
    public static let hitTarget = 44.0
    public static let controlSmall = 32.0
    public static let controlMedium = 40.0
    public static let controlLarge = 52.0
    /// A checkbox's or radio button's mark.
    public static let selectionMark = 21.0
    /// One circle of a swatch stack.
    public static let swatch = 22.0
    /// A divider's thickness.
    public static let hairline = 0.5
    /// The widest a small floating panel grows (progress, a short message): it reads as one
    /// thought, not a page.
    public static let floatingPanel = 320.0
}
