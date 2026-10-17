import Foundation

/// The values a control can take: a range, an optional step, how many decimal places they show,
/// and how they spread along the control (the taper). Plain maths, so a reducer can use the same
/// functions the control does.
public struct ValueScale: Hashable, Sendable {
    /// How values spread along the control.
    public enum Taper: Hashable, Sendable {
        /// Evenly.
        case linear
        /// By ratio, as hearing and frequency go (needs a range above zero; otherwise linear).
        case logarithmic
        /// Bunched at the low end for an exponent above 1, at the high end below 1.
        case power(Double)
    }

    public var lower: Double
    public var upper: Double
    public var step: Double?
    public var precision: Int
    public var taper: Taper

    /// - Parameters:
    ///   - range: the lowest and highest values.
    ///   - step: values land on multiples of it from the lowest; `nil` for any value.
    ///   - precision: decimal places shown, and kept.
    public init(_ range: ClosedRange<Double> = 0 ... 1, step: Double? = nil, precision: Int = 2, taper: Taper = .linear) {
        self.lower = range.lowerBound
        self.upper = range.upperBound
        self.step = step
        self.precision = precision
        self.taper = taper
    }

    var span: Double { upper - lower }

    /// Where `value` sits along the control, 0 ... 1.
    public func fraction(of value: Double) -> Double {
        tapered(min(max(value, lower), upper))
    }

    /// The value at `fraction` (0 ... 1) along the control, on a step and rounded to the precision.
    public func value(at fraction: Double) -> Double {
        snapped(untapered(min(max(fraction, 0), 1)))
    }

    /// `value` within the range, on a step, rounded to the precision.
    public func snapped(_ value: Double) -> Double {
        rounded(min(max(onStep(value), lower), upper))
    }

    /// `value` moved `steps` steps (a step, or a hundredth of the range without one), for the
    /// accessibility actions.
    public func stepped(_ value: Double, by steps: Int) -> Double {
        snapped(value + Double(steps) * (step ?? span / 100))
    }

    /// The value after dragging `distance` along a control `length` long from `start`.
    public func dragged(from start: Double, by distance: Double, over length: Double) -> Double {
        value(at: fraction(of: start) + distance / max(length, 1))
    }

    /// `value` with its decimal places.
    public func formatted(_ value: Double) -> String {
        String(format: "%.\(max(precision, 0))f", value)
    }

    /// Values for marks along the control: each step when there are at most `limit` of them,
    /// otherwise `limit` evenly spaced fractions' values.
    public func marks(limit: Int = 11) -> [Double] {
        stepCount <= Double(limit - 1)
            ? (0 ... Int(stepCount.rounded())).map { rounded(lower + Double($0) * (step ?? 0)) }
            : (0 ..< max(limit, 2)).map { value(at: Double($0) / Double(max(limit, 2) - 1)) }
    }

    /// Values for marks every `interval` from the lowest to the highest (the highest included
    /// when it lands on one).
    public func marks(every interval: Double) -> [Double] {
        interval > 0
            ? (0 ... Int(((span / interval) + 1e-9).rounded(.down))).map { rounded(lower + Double($0) * interval) }
            : [lower, upper]
    }

    /// The decimal places `interval` needs to be written: 0 for 1, 1 for 0.5, 2 for 0.25.
    public static func decimals(of interval: Double) -> Int {
        (0 ... 6).first { places in abs((interval * pow(10, Double(places))).rounded() - interval * pow(10, Double(places))) < 1e-9 } ?? 6
    }

    /// `value` written with `places` decimal places, whatever the scale's precision.
    public func formatted(_ value: Double, places: Int) -> String {
        String(format: "%.\(max(places, 0))f", value)
    }

    /// How many steps the range holds (infinite without a step).
    var stepCount: Double {
        step.map { $0 > 0 ? span / $0 : .infinity } ?? .infinity
    }

    /// A value's fraction, by the taper.
    func tapered(_ value: Double) -> Double {
        switch taper {
        case .logarithmic where lower > 0: log(value / lower) / log(upper / lower)
        case let .power(exponent) where exponent > 0: pow(linearFraction(value), 1 / exponent)
        default: linearFraction(value)
        }
    }

    /// A fraction's value, by the taper, before stepping and rounding.
    func untapered(_ fraction: Double) -> Double {
        switch taper {
        case .logarithmic where lower > 0: lower * pow(upper / lower, fraction)
        case let .power(exponent) where exponent > 0: lower + span * pow(fraction, exponent)
        default: lower + span * fraction
        }
    }

    func linearFraction(_ value: Double) -> Double {
        span == 0 ? 0 : (value - lower) / span
    }

    func onStep(_ value: Double) -> Double {
        step.map { $0 > 0 ? lower + (((value - lower) / $0).rounded() * $0) : value } ?? value
    }

    func rounded(_ value: Double) -> Double {
        (value * pow(10, Double(precision))).rounded() / pow(10, Double(precision))
    }
}

/// The geometry of a dial: angles in degrees, clockwise from twelve o'clock.
public enum DialGeometry {
    /// The angle `fraction` (0 ... 1) points at, between `start` and `end`.
    public static func angle(for fraction: Double, start: Double, end: Double) -> Double {
        start + (end - start) * fraction
    }

    /// The angle of a point `dx`, `dy` from the centre (y down), clockwise from twelve o'clock,
    /// -180 ... 180.
    public static func angle(dx: Double, dy: Double) -> Double {
        atan2(dx, -dy) * 180 / .pi
    }

    /// The fraction a touch at `angle` asks for: its place between `start` and `end`; in the gap
    /// between the ends, the nearer end.
    public static func fraction(forAngle angle: Double, start: Double, end: Double) -> Double {
        fraction(along: positive((angle - start).truncatingRemainder(dividingBy: 360)), sweep: end - start)
    }

    static func positive(_ degrees: Double) -> Double {
        degrees < 0 ? degrees + 360 : degrees
    }

    static func fraction(along: Double, sweep: Double) -> Double {
        along <= sweep ? along / sweep : (along - sweep < 360 - along ? 1 : 0)
    }

    /// The turn from `previous` to `current` the short way round, -180 ... 180, for an endless dial.
    public static func turn(from previous: Double, to current: Double) -> Double {
        shortest((current - previous).truncatingRemainder(dividingBy: 360))
    }

    static func shortest(_ delta: Double) -> Double {
        delta > 180 ? delta - 360 : delta < -180 ? delta + 360 : delta
    }
}
