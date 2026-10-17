/// How wide a workspace panel may be: it opens at `ideal`, and a drag resizes it between `min`
/// and `max`.
public struct PanelWidth: Hashable, Sendable {
    public var min: Double
    public var ideal: Double
    public var max: Double

    public init(min: Double, ideal: Double, max: Double) {
        self.min = min
        self.ideal = ideal
        self.max = max
    }

    /// `width` brought within `min ... max`.
    public func clamped(_ width: Double) -> Double {
        Swift.min(Swift.max(width, min), max)
    }
}

public extension PanelWidth {
    /// A list to pick from, leading.
    static let sidebar = PanelWidth(min: 220, ideal: 264, max: 380)
    /// Properties of what's picked, trailing.
    static let inspector = PanelWidth(min: 280, ideal: 326, max: 520)
}
