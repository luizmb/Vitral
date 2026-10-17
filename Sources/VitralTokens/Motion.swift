/// How things move.
public enum Motion {
    /// How fast a page's backdrop scrolls against its content: a third, so the glass on top reads
    /// as sitting above it.
    public static let parallax = 1.0 / 3
    /// How far a parallax layer drifts as its page moves one page away, in points.
    public static let parallaxDistance = 48.0
}
