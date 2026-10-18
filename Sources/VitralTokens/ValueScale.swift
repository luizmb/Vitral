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
        /// Straight lines between breakpoints, each a value at a place along the control, for a
        /// travel shaped exactly (a desk's gain fader, a camera's stops). The values rise with the
        /// fractions; past the first and last breakpoints the control holds their values, and the
        /// range still bounds what comes out.
        case breakpoints([Breakpoint], measure: Measure = .value)
    }

    /// A value at a place along the control, `fraction` 0 ... 1 from the lowest.
    public struct Breakpoint: Hashable, Sendable {
        public var fraction: Double
        public var value: Double

        public init(_ fraction: Double, _ value: Double) {
            self.fraction = fraction
            self.value = value
        }
    }

    /// What a taper's breakpoints are written in.
    public enum Measure: Hashable, Sendable {
        /// The values themselves.
        case value
        /// Decibels of a gain (a multiplier on amplitude, 1 for unity): the values are gains, the
        /// breakpoints decibels. The first breakpoint is the floor: at or below it, silence (0).
        case decibels
    }

    /// How a value is written.
    public enum Readout: Hashable, Sendable {
        /// The value, with the scale's decimal places.
        case number
        /// A gain in signed decibels (+6.0, −12.0), and `silence` for none.
        case decibels(silence: String = "−∞")
    }

    public var lower: Double
    public var upper: Double
    public var step: Double?
    public var precision: Int
    public var taper: Taper
    public var readout: Readout

    /// - Parameters:
    ///   - range: the lowest and highest values.
    ///   - step: values land on multiples of it from the lowest; `nil` for any value.
    ///   - precision: decimal places kept, and shown by a `.number` readout.
    ///   - readout: how the value is written.
    public init(
        _ range: ClosedRange<Double> = 0 ... 1,
        step: Double? = nil,
        precision: Int = 2,
        taper: Taper = .linear,
        readout: Readout = .number
    ) {
        self.lower = range.lowerBound
        self.upper = range.upperBound
        self.step = step
        self.precision = precision
        self.taper = taper
        self.readout = readout
    }

    /// A mixing desk's gain fader: gains from silence to `headroom` decibels above unity, unity
    /// `unity` of the way up, the `working` decibels below it over the next stretch down (where
    /// most rides live, so the finest control is there), falling to `floor` decibels and then
    /// silence at the bottom. Written in decibels.
    public static func consoleGain(
        unity: Double = 2.0 / 3.0,
        headroom: Double = 20 * log10(2.0),
        working: Double = -12,
        floor: Double = -60,
        precision: Int = 4
    ) -> ValueScale {
        ValueScale(
            0 ... pow(10, headroom / 20),
            precision: precision,
            taper: .breakpoints(
                [Breakpoint(0, floor), Breakpoint(unity / 2, working), Breakpoint(unity, 0), Breakpoint(1, headroom)],
                measure: .decibels
            ),
            readout: .decibels()
        )
    }

    /// The gain `decibels` stands for: 1 at 0 dB, 2 at about +6.
    public static func gain(decibels: Double) -> Double {
        pow(10, decibels / 20)
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

    /// `value` as the readout writes it.
    public func formatted(_ value: Double) -> String {
        formatted(value, places: readout == .number ? precision : 1)
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

    /// `value` as the readout writes it, with `places` decimal places whatever the precision.
    public func formatted(_ value: Double, places: Int) -> String {
        switch readout {
        case .number:
            String(format: "%.\(max(places, 0))f", value)
        case let .decibels(silence):
            value > 0 ? Self.signed(20 * log10(value), places: places) : silence
        }
    }

    /// `decibels` with its sign, a real minus below zero.
    static func signed(_ decibels: Double, places: Int) -> String {
        signed(String(format: "%.\(max(places, 0))f", abs(decibels)), positive: decibels > 0)
    }

    /// A magnitude already written, with its sign; none for zero.
    static func signed(_ written: String, positive: Bool) -> String {
        Double(written) == 0 ? written : (positive ? "+" : "\u{2212}") + written
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
        case let .breakpoints(points, measure) where points.count > 1:
            Self.fraction(of: measured(value, in: measure), along: points)
        default: linearFraction(value)
        }
    }

    /// A fraction's value, by the taper, before stepping and rounding.
    func untapered(_ fraction: Double) -> Double {
        switch taper {
        case .logarithmic where lower > 0: lower * pow(upper / lower, fraction)
        case let .power(exponent) where exponent > 0: lower + span * pow(fraction, exponent)
        case let .breakpoints(points, measure) where points.count > 1:
            unmeasured(Self.value(at: fraction, along: points), in: measure, floor: points[0].value)
        default: lower + span * fraction
        }
    }

    /// `value` in the breakpoints' measure.
    func measured(_ value: Double, in measure: Measure) -> Double {
        switch measure {
        case .value: value
        case .decibels: value > 0 ? 20 * log10(value) : -.infinity
        }
    }

    /// A value from the breakpoints' measure: silence at or under the floor, in decibels.
    func unmeasured(_ value: Double, in measure: Measure, floor: Double) -> Double {
        switch measure {
        case .value: value
        case .decibels: value <= floor ? 0 : Self.gain(decibels: value)
        }
    }

    /// Where `value` sits along the lines between `points`: the first and last points' places
    /// beyond them.
    static func fraction(of value: Double, along points: [Breakpoint]) -> Double {
        zip(points, points.dropFirst())
            .first { _, next in value < next.value }
            .map { point, next in
                value <= point.value
                    ? point.fraction
                    : point.fraction + (next.fraction - point.fraction) * (value - point.value) / (next.value - point.value)
            }
            ?? points[points.count - 1].fraction
    }

    /// The value at `fraction` along the lines between `points`: the first and last points'
    /// values beyond them.
    static func value(at fraction: Double, along points: [Breakpoint]) -> Double {
        zip(points, points.dropFirst())
            .first { _, next in fraction < next.fraction }
            .map { point, next in
                fraction <= point.fraction
                    ? point.value
                    : point.value + (next.value - point.value) * (fraction - point.fraction) / (next.fraction - point.fraction)
            }
            ?? points[points.count - 1].value
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

/// The geometry of a track a thumb slides along: positions measured from the track's start (the
/// left of a horizontal one, the top of a vertical one), where the thumb's centre can travel
/// between half a thumb from each end.
public enum TrackGeometry {
    /// How far the thumb's centre travels.
    public static func travel(length: Double, thumb: Double) -> Double {
        max(length - thumb, 1)
    }

    /// Where the thumb's centre is for `fraction`; `reversed` runs the values the other way
    /// (a vertical track, its lowest value at the bottom).
    public static func position(of fraction: Double, length: Double, thumb: Double, reversed: Bool) -> Double {
        thumb / 2 + travel(length: length, thumb: thumb) * (reversed ? 1 - fraction : fraction)
    }

    /// The fraction a touch at `position` asks for.
    public static func fraction(at position: Double, length: Double, thumb: Double, reversed: Bool) -> Double {
        oriented(min(max((position - thumb / 2) / travel(length: length, thumb: thumb), 0), 1), reversed: reversed)
    }

    static func oriented(_ fraction: Double, reversed: Bool) -> Double {
        reversed ? 1 - fraction : fraction
    }

    /// `fraction`, pulled onto the nearest of `detents` when within `reach` of it.
    public static func snapped(_ fraction: Double, to detents: [Double], reach: Double = 0.025) -> Double {
        detents.min { abs($0 - fraction) < abs($1 - fraction) }.flatMap { abs($0 - fraction) <= reach ? $0 : nil } ?? fraction
    }
}
