/// How big a workspace panel may be across: a side panel's width, a bottom panel's height. It
/// opens at `ideal`, and a drag resizes it between `min` and `max`.
public struct PanelSize: Hashable, Sendable {
    public var min: Double
    public var ideal: Double
    public var max: Double

    public init(min: Double, ideal: Double, max: Double) {
        self.min = min
        self.ideal = ideal
        self.max = max
    }

    /// `size` brought within `min ... max`.
    public func clamped(_ size: Double) -> Double {
        Swift.min(Swift.max(size, min), max)
    }
}

public extension PanelSize {
    /// A list to pick from, leading.
    static let sidebar = PanelSize(min: 220, ideal: 264, max: 380)
    /// Properties of what's picked, trailing.
    static let inspector = PanelSize(min: 280, ideal: 326, max: 520)
    /// Output, logs, a console, at the bottom (its height).
    static let console = PanelSize(min: 120, ideal: 220, max: 520)
}
