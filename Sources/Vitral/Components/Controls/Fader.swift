import SwiftUI
import VitralTokens

/// How a fader is moved.
public enum FaderInteraction {
    /// The thumb goes where the finger is: a touch anywhere on the track sets the value.
    case absolute
    /// The thumb moves by as much as the finger does, wherever on the track the drag starts, as a
    /// desk's fader cap is pushed. The value the drag started from is kept in `dragStart` (the
    /// app's state), set when the drag begins and cleared when it ends.
    case relative(dragStart: Binding<Double?>)
}

/// Where a fader's title and value go.
public enum FaderLabelPlacement: Hashable, Sendable {
    case none
    /// Before the track.
    case leading
    /// After the track.
    case trailing
    /// Above the track: the title at its start, the value at its end (Lightroom's way).
    case top
    /// Below the track, the same way.
    case bottom
    /// On the track itself, for a thick track (Control Centre's way).
    case inside
}

/// What a fader style draws.
public struct FaderConfiguration: Sendable {
    public let value: Double
    /// Where the value sits, 0 ... 1 from the lowest.
    public let fraction: Double
    /// Where the fill grows from: the lowest value, or the centre for a two-way fader.
    public let originFraction: Double
    public let scale: ValueScale
    public let axis: Axis
    public let isDragging: Bool

    /// `value` as the scale writes it.
    public var formatted: String { scale.formatted(value) }
}

/// How a fader looks. Write one to draw a fader entirely your own way; `GlassFaderStyle` is the
/// default and `ConsoleFaderStyle` a mixing desk's.
public protocol FaderStyle {
    associatedtype Body: View
    /// The thumb's length along the track: how far in from each end its centre stops.
    var thumbLength: Double { get }
    /// The fader's thickness across the track.
    var breadth: Double { get }
    @MainActor @ViewBuilder func makeBody(_ configuration: FaderConfiguration) -> Body
}

/// Any fader style, so one can sit in the environment.
public struct AnyFaderStyle: FaderStyle, Sendable {
    public let thumbLength: Double
    public let breadth: Double
    let make: @MainActor @Sendable (FaderConfiguration) -> AnyView

    public init<Style: FaderStyle & Sendable>(_ style: Style) {
        self.thumbLength = style.thumbLength
        self.breadth = style.breadth
        self.make = { AnyView(style.makeBody($0)) }
    }

    public func makeBody(_ configuration: FaderConfiguration) -> some View {
        make(configuration)
    }
}

public extension EnvironmentValues {
    /// How every fader under this view looks, unless it's given its own style.
    @Entry var faderStyle = AnyFaderStyle(GlassFaderStyle())
}

public extension View {
    /// How every fader under this view looks: a mixing desk's worth in one line.
    func faderStyle<Style: FaderStyle & Sendable>(_ style: Style) -> some View {
        environment(\.faderStyle, AnyFaderStyle(style))
    }
}

/// A fader: a thumb along a track, horizontal or vertical, between the scale's ends. A `centre`
/// makes it two-way (pan, exposure), filling from the middle; `detents` pull the thumb onto
/// values it passes near (0 dB, the centre); a double tap returns it to `resetValue`. Stateless:
/// the value is the binding's. `onEditingEnded` is called when an edit is done (the finger lifts,
/// a double tap resets, VoiceOver adjusts): the moment to commit it, or to mark an undo step.
public struct Fader: View {
    @Binding var value: Double
    let scale: ValueScale
    let axis: Axis
    let interaction: FaderInteraction
    let centre: Double?
    let detents: [Double]
    let resetValue: Double?
    let title: Text?
    let labels: FaderLabelPlacement
    let given: AnyFaderStyle?
    let onEditingEnded: () -> Void
    let label: Text

    @Environment(\.faderStyle) private var environmentStyle

    /// The style given, else the environment's.
    var style: AnyFaderStyle { given ?? environmentStyle }

    /// - Parameters:
    ///   - title: shown where `labels` says, with the value.
    ///   - label: what VoiceOver calls it.
    public init(
        value: Binding<Double>,
        scale: ValueScale = ValueScale(),
        axis: Axis = .horizontal,
        interaction: FaderInteraction = .absolute,
        centre: Double? = nil,
        detents: [Double] = [],
        resetValue: Double? = nil,
        title: Text? = nil,
        labels: FaderLabelPlacement = .none,
        style: some FaderStyle & Sendable,
        onEditingEnded: @escaping () -> Void = {},
        label: Text
    ) {
        self.init(
            value: value, scale: scale, axis: axis, interaction: interaction, centre: centre, detents: detents,
            resetValue: resetValue, title: title, labels: labels, given: AnyFaderStyle(style), onEditingEnded: onEditingEnded, label: label
        )
    }

    /// A fader in the environment's style (`.faderStyle(_:)`, glass unless set).
    public init(
        value: Binding<Double>,
        scale: ValueScale = ValueScale(),
        axis: Axis = .horizontal,
        interaction: FaderInteraction = .absolute,
        centre: Double? = nil,
        detents: [Double] = [],
        resetValue: Double? = nil,
        title: Text? = nil,
        labels: FaderLabelPlacement = .none,
        onEditingEnded: @escaping () -> Void = {},
        label: Text
    ) {
        self.init(
            value: value, scale: scale, axis: axis, interaction: interaction, centre: centre, detents: detents,
            resetValue: resetValue, title: title, labels: labels, given: nil, onEditingEnded: onEditingEnded, label: label
        )
    }

    init(
        value: Binding<Double>,
        scale: ValueScale,
        axis: Axis,
        interaction: FaderInteraction,
        centre: Double?,
        detents: [Double],
        resetValue: Double?,
        title: Text?,
        labels: FaderLabelPlacement,
        given: AnyFaderStyle?,
        onEditingEnded: @escaping () -> Void,
        label: Text
    ) {
        self._value = value
        self.scale = scale
        self.axis = axis
        self.interaction = interaction
        self.centre = centre
        self.detents = detents
        self.resetValue = resetValue
        self.title = title
        self.labels = labels
        self.given = given
        self.onEditingEnded = onEditingEnded
        self.label = label
    }

    var configuration: FaderConfiguration {
        FaderConfiguration(
            value: value,
            fraction: scale.fraction(of: value),
            originFraction: centre.map { scale.fraction(of: $0) } ?? 0,
            scale: scale,
            axis: axis,
            isDragging: isDragging
        )
    }

    var isDragging: Bool {
        switch interaction {
        case .absolute: false
        case let .relative(dragStart): dragStart.wrappedValue != nil
        }
    }

    public var body: some View {
        switch labels {
        case .none, .inside:
            track
        case .leading:
            HStack(spacing: Space.medium) { caption(alignment: .leading); track }
        case .trailing:
            HStack(spacing: Space.medium) { track; caption(alignment: .trailing) }
        case .top:
            VStack(spacing: Space.extraSmall) { titleAndValue; track }
        case .bottom:
            VStack(spacing: Space.extraSmall) { track; titleAndValue }
        }
    }

    /// The title over the value, beside the track.
    func caption(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: Space.hairline) {
            title.font(.detail).foregroundStyle(.inkMuted)
            Text(verbatim: scale.formatted(value)).font(.value).foregroundStyle(.ink)
        }
        .fixedSize()
    }

    /// The title at the track's start and the value at its end.
    var titleAndValue: some View {
        HStack {
            title.font(.detail).foregroundStyle(.inkMuted)
            Spacer(minLength: Space.small)
            Text(verbatim: scale.formatted(value)).font(TypeToken.detail.weight(.semibold)).monospacedDigit().foregroundStyle(.ink)
        }
    }

    var track: some View {
        GeometryReader { proxy in
            style.makeBody(configuration)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay {
                    if labels == .inside {
                        titleAndValue.padding(.horizontal, Space.medium).allowsHitTesting(false)
                    }
                }
                .contentShape(Rectangle())
                // Side by side, so the drag (and the thumb under the finger) answers at once;
                // waiting to rule out a double tap held every press back.
                .gesture(drag(length: axis == .horizontal ? proxy.size.width : proxy.size.height))
                // Only a control given a `resetValue` has double-tap semantics; without one there is
                // nothing to recognise, and a quick second touch is just a touch.
                .simultaneousGesture(TapGesture(count: 2).onEnded { reset() }, including: resetValue == nil ? .none : .all)
        }
        .frame(width: axis == .vertical ? style.breadth : nil, height: axis == .horizontal ? style.breadth : nil)
        .frame(maxWidth: axis == .horizontal ? .infinity : nil, maxHeight: axis == .vertical ? .infinity : nil)
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(Text(verbatim: scale.formatted(value)))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: value = scale.stepped(value, by: 1)
            case .decrement: value = scale.stepped(value, by: -1)
            @unknown default: break
            }
            onEditingEnded()
        }
    }

    /// Back to `resetValue`, as one whole edit.
    func reset() {
        if let resetValue {
            value = resetValue
            onEditingEnded()
        }
    }

    /// The value for `fraction`, pulled onto a detent when close.
    func value(at fraction: Double) -> Double {
        scale.value(at: TrackGeometry.snapped(fraction, to: detents.map { scale.fraction(of: $0) }))
    }

    func drag(length: Double) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                // A finger that has only wobbled is still tapping: written on landing (where an
                // absolute fader goes) and past the slop, never in between, so a double tap's
                // reset isn't overwritten by the jitter of its second touch.
                let moved = TrackGeometry.isDragging(dx: drag.translation.width, dy: drag.translation.height)
                switch interaction {
                case .absolute:
                    guard moved || drag.translation == .zero else { return }
                    value = value(
                        at: TrackGeometry.fraction(
                            at: axis == .horizontal ? drag.location.x : drag.location.y,
                            length: length,
                            thumb: style.thumbLength,
                            reversed: axis == .vertical
                        )
                    )
                case let .relative(dragStart):
                    if dragStart.wrappedValue == nil { dragStart.wrappedValue = value }
                    // Written only once the finger has moved past the slop: a touch that stays put
                    // (a tap, the second of a double tap) would write back where it started, over
                    // a reset.
                    if moved {
                        value = value(
                            at: scale.fraction(of: dragStart.wrappedValue ?? value)
                                + (axis == .horizontal ? drag.translation.width : -drag.translation.height)
                                / TrackGeometry.travel(length: length, thumb: style.thumbLength)
                        )
                    }
                }
            }
            .onEnded { _ in
                if case let .relative(dragStart) = interaction { dragStart.wrappedValue = nil }
                onEditingEnded()
            }
    }
}

/// Places things along and across a track, whichever way it lies: `along` from the track's start
/// (its lowest value), `across` from its middle line.
struct TrackFrame {
    let size: CGSize
    let axis: Axis
    let thumbLength: Double

    var length: Double { axis == .horizontal ? size.width : size.height }

    /// The point `fraction` along the track, `across` off its middle line.
    func point(_ fraction: Double, across: Double = 0) -> CGPoint {
        axis == .horizontal
            ? CGPoint(x: TrackGeometry.position(of: fraction, length: length, thumb: thumbLength, reversed: false), y: size.height / 2 + across)
            : CGPoint(x: size.width / 2 + across, y: TrackGeometry.position(of: fraction, length: length, thumb: thumbLength, reversed: true))
    }

    /// A size `along` by `across`, whichever way the track lies.
    func size(along: Double, across: Double) -> CGSize {
        axis == .horizontal ? CGSize(width: along, height: across) : CGSize(width: across, height: along)
    }

    /// How far along the track, from its lowest end, `fraction` sits.
    func along(_ fraction: Double) -> Double {
        TrackGeometry.position(of: fraction, length: length, thumb: thumbLength, reversed: false)
    }

    /// The point `along` from the track's lowest end, `across` off its middle line.
    func pointAlong(_ along: Double, across: Double = 0) -> CGPoint {
        axis == .horizontal
            ? CGPoint(x: along, y: size.height / 2 + across)
            : CGPoint(x: size.width / 2 + across, y: length - along)
    }

    /// The distance between two fractions along the track.
    func span(_ from: Double, _ to: Double) -> Double {
        abs(to - from) * TrackGeometry.travel(length: length, thumb: thumbLength)
    }
}

/// The glass fader, and its options: the track's thickness and colours, the thumb, marks and
/// numbers beside the track.
public struct GlassFaderStyle: FaderStyle, Sendable {
    /// The part the finger moves.
    public enum Thumb: Hashable, Sendable {
        /// A round glass thumb.
        case round
        /// A glass capsule lying across the track.
        case capsule
        /// None: the fill is the value (a thick track, Control Centre's way).
        case none
    }

    let trackThickness: Double
    let thumb: Thumb
    let gradient: [ColorToken]?
    let showsFill: Bool
    let marks: Int?
    let numberStep: Double?
    let markColour: ColorToken
    let numberColour: ColorToken
    let thumbFinish: FinishToken?
    let fillFinish: FinishToken?

    /// - Parameters:
    ///   - trackThickness: how thick the track is; a thick one with no thumb fills like Control
    ///     Centre's sliders.
    ///   - thumbFinish: what the thumb is made of; the environment's `controlFinish`, else glass.
    ///   - fillFinish: what the fill is made of; the accent when `nil`.
    ///   - gradient: colours along the track instead of a fill (a temperature's blue to amber).
    ///   - marks: dashes beside the track, this many (`nil` for none).
    ///   - numberStep: a number beside the track every this much.
    public init(
        trackThickness: Double = 6,
        thumb: Thumb = .round,
        gradient: [ColorToken]? = nil,
        showsFill: Bool = true,
        marks: Int? = nil,
        numberStep: Double? = nil,
        markColour: ColorToken = .inkFaint,
        numberColour: ColorToken = .inkMuted,
        thumbFinish: FinishToken? = nil,
        fillFinish: FinishToken? = nil
    ) {
        self.trackThickness = trackThickness
        self.thumb = thumb
        self.gradient = gradient
        self.showsFill = showsFill
        self.marks = marks
        self.numberStep = numberStep
        self.markColour = markColour
        self.numberColour = numberColour
        self.thumbFinish = thumbFinish
        self.fillFinish = fillFinish
    }

    public var thumbLength: Double {
        switch thumb {
        case .round: 28
        case .capsule: 22
        case .none: 0
        }
    }

    public var breadth: Double {
        max(trackThickness, thumb == .none ? 0 : 30) + (marks != nil || numberStep != nil ? 36 : 0)
    }

    public func makeBody(_ configuration: FaderConfiguration) -> some View {
        GlassFader(style: self, configuration: configuration)
    }
}

struct GlassFader: View {
    let style: GlassFaderStyle
    let configuration: FaderConfiguration

    @Environment(\.accent) private var accent
    @Environment(\.controlFinish) private var controlFinish

    /// What the thumb is made of, its glass answering the finger.
    var thumbFinish: FinishToken {
        (style.thumbFinish ?? controlFinish ?? .glass()).interactive()
    }

    /// With marks or numbers, the track moves off the middle to make room beside it.
    var trackOffset: Double {
        style.marks != nil || style.numberStep != nil ? -12 : 0
    }

    var body: some View {
        GeometryReader { proxy in
            let frame = TrackFrame(size: proxy.size, axis: configuration.axis, thumbLength: style.thumbLength)
            ZStack(alignment: .topLeading) {
                trackShape(frame)
                if style.showsFill, style.gradient == nil {
                    fill(frame)
                }
                style.marks.map { count in marks(frame, count: count) }
                style.numberStep.map { step in numbers(frame, step: step) }
                thumb(frame)
            }
        }
    }

    func trackShape(_ frame: TrackFrame) -> some View {
        Capsule()
            .fill(gradientFill(frame))
            .frame(width: frame.size(along: frame.length, across: style.trackThickness).width, height: frame.size(along: frame.length, across: style.trackThickness).height)
            .overlay { Capsule().strokeBorder(Color(.hairline), lineWidth: 0.5) }
            .glassSurface(.clear, cornerRadius: style.trackThickness / 2)
            .position(configuration.axis == .horizontal
                ? CGPoint(x: frame.length / 2, y: frame.size.height / 2 + trackOffset)
                : CGPoint(x: frame.size.width / 2 + trackOffset, y: frame.length / 2))
    }

    func gradientFill(_ frame: TrackFrame) -> AnyShapeStyle {
        style.gradient.map { colours in
            AnyShapeStyle(
                LinearGradient(
                    colors: colours.map { Color($0) },
                    startPoint: configuration.axis == .horizontal ? .leading : .bottom,
                    endPoint: configuration.axis == .horizontal ? .trailing : .top
                )
            )
        } ?? AnyShapeStyle(Color(.hairline))
    }

    /// Where the fill starts and ends: from the origin (the lowest, or the centre) to the value.
    var fillFrom: Double { min(configuration.originFraction, configuration.fraction) }
    var fillTo: Double { max(configuration.originFraction, configuration.fraction) }

    /// Where the fill begins and ends along the track, from its lowest end: from the track's very
    /// end when it starts at the lowest value (so no stub of track shows past it), else from the
    /// origin's place; to the thumb's centre, or the track's end at the highest value.
    func fillStart(_ frame: TrackFrame) -> Double {
        fillFrom <= 0 ? 0 : frame.along(fillFrom)
    }

    func fillEnd(_ frame: TrackFrame) -> Double {
        fillTo >= 1 ? frame.length : frame.along(fillTo)
    }

    func fillLength(_ frame: TrackFrame) -> Double {
        max(fillEnd(frame) - fillStart(frame), style.trackThickness)
    }

    func fillCentre(_ frame: TrackFrame) -> CGPoint {
        frame.pointAlong((fillStart(frame) + fillEnd(frame)) / 2, across: trackOffset)
    }

    func fill(_ frame: TrackFrame) -> some View {
        FinishedShape(finish: style.fillFinish ?? .solid(accent.base), shape: Capsule())
            .frame(
                width: frame.size(along: fillLength(frame), across: style.trackThickness).width,
                height: frame.size(along: fillLength(frame), across: style.trackThickness).height
            )
            .position(fillCentre(frame))
    }

    func marks(_ frame: TrackFrame, count: Int) -> some View {
        ForEach(0 ..< max(count, 2), id: \.self) { index in
            Rectangle()
                .fill(Color(style.markColour))
                .frame(
                    width: frame.size(along: 1, across: index % 5 == 0 ? 8 : 5).width,
                    height: frame.size(along: 1, across: index % 5 == 0 ? 8 : 5).height
                )
                .position(frame.point(Double(index) / Double(max(count, 2) - 1), across: trackOffset + 14))
        }
    }

    func numbers(_ frame: TrackFrame, step: Double) -> some View {
        ForEach(configuration.scale.marks(every: step), id: \.self) { mark in
            Text(verbatim: configuration.scale.formatted(mark, places: ValueScale.decimals(of: step)))
                .font(.caption2.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(Color(style.numberColour))
                .fixedSize()
                .position(frame.point(configuration.scale.fraction(of: mark), across: trackOffset + 26))
        }
    }

    @ViewBuilder
    func thumb(_ frame: TrackFrame) -> some View {
        switch style.thumb {
        case .round:
            FinishedShape(finish: thumbFinish, shape: Circle())
                .frame(width: 28, height: 28)
                .shadow(color: Color(.scrim), radius: 4, y: 2)
                .scaleEffect(configuration.isDragging ? 1.12 : 1)
                .position(frame.point(configuration.fraction, across: trackOffset))
        case .capsule:
            FinishedShape(finish: thumbFinish, shape: Capsule())
                .frame(width: frame.size(along: 22, across: 34).width, height: frame.size(along: 22, across: 34).height)
                .shadow(color: Color(.scrim), radius: 4, y: 2)
                .position(frame.point(configuration.fraction, across: trackOffset))
        case .none:
            EmptyView()
        }
    }
}

/// A mixing desk's fader: a dark slot, a ridged metal cap with a white line across, and the dB
/// scale printed beside it.
public struct ConsoleFaderStyle: FaderStyle, Sendable {
    let ticks: [Double]
    let unity: Double
    let lowestLabel: String?
    let slotColour: ColorToken
    let scaleColour: ColorToken
    let lineColour: ColorToken

    /// - Parameters:
    ///   - ticks: the values printed on the scale, in the scale's own values (+10, 0, −10 … on a
    ///     decibel scale; gains, `ValueScale.gain(decibels:)`, on a `consoleGain` one).
    ///   - unity: the tick printed boldest and longest (0 dB; a gain of 1).
    ///   - lowestLabel: what the scale says at its lowest, when there's a tick there (−∞).
    public init(
        ticks: [Double],
        unity: Double = 0,
        lowestLabel: String? = "−∞",
        slotColour: ColorToken = .fixedBlack,
        scaleColour: ColorToken = .inkMuted,
        lineColour: ColorToken = .fixedWhite
    ) {
        self.ticks = ticks
        self.unity = unity
        self.lowestLabel = lowestLabel
        self.slotColour = slotColour
        self.scaleColour = scaleColour
        self.lineColour = lineColour
    }

    public var thumbLength: Double { 34 }
    public var breadth: Double { 76 }

    public func makeBody(_ configuration: FaderConfiguration) -> some View {
        ConsoleFader(style: self, configuration: configuration)
    }
}

struct ConsoleFader: View {
    let style: ConsoleFaderStyle
    let configuration: FaderConfiguration

    var body: some View {
        GeometryReader { proxy in
            let frame = TrackFrame(size: proxy.size, axis: configuration.axis, thumbLength: style.thumbLength)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(style.slotColour))
                    .frame(width: frame.size(along: frame.length - 8, across: 4).width, height: frame.size(along: frame.length - 8, across: 4).height)
                    .overlay { RoundedRectangle(cornerRadius: 2).strokeBorder(Color(.chromeShadow), lineWidth: 0.5) }
                    .position(frame.point(0.5, across: -10))
                ForEach(style.ticks, id: \.self) { tick in
                    tickMark(frame, tick: tick)
                }
                cap
                    .frame(width: frame.size(along: 34, across: 46).width, height: frame.size(along: 34, across: 46).height)
                    .position(frame.point(configuration.fraction, across: -10))
            }
        }
    }

    func tickMark(_ frame: TrackFrame, tick: Double) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(style.scaleColour))
                .frame(width: frame.size(along: 1, across: tick == style.unity ? 10 : 6).width, height: frame.size(along: 1, across: tick == style.unity ? 10 : 6).height)
                .position(frame.point(configuration.scale.fraction(of: tick), across: 20))
            Text(verbatim: tick <= configuration.scale.lower ? (style.lowestLabel ?? configuration.scale.formatted(tick, places: 0)) : label(tick))
                .font(.caption2.weight(tick == style.unity ? .bold : .medium))
                .monospacedDigit()
                .foregroundStyle(Color(style.scaleColour))
                .fixedSize()
                // Starting just past the tick, not centred on a point: a wider label (−12) would
                // otherwise run under the tick and lose its sign.
                .frame(width: 28, alignment: configuration.axis == .vertical ? .leading : .center)
                .position(frame.point(configuration.scale.fraction(of: tick), across: configuration.axis == .vertical ? 42 : 33))
        }
    }

    /// A tick as the scale writes it, signed above zero on a plain number scale (a decibel
    /// readout signs its own).
    func label(_ tick: Double) -> String {
        configuration.scale.readout == .number && tick > 0
            ? "+" + configuration.scale.formatted(tick, places: 0)
            : configuration.scale.formatted(tick, places: 0)
    }

    /// The metal cap: brushed chrome, ridges across for the finger, and a white line where it reads.
    var cap: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(.chromeHighlight), Color(.chromeMid), Color(.chromeShadow)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            VStack(spacing: 3) {
                ForEach(0 ..< 5, id: \.self) { _ in
                    Rectangle().fill(Color(ColorToken.chromeShadow.opacity(0.6))).frame(height: 1)
                }
            }
            .padding(.vertical, 5)
            .rotationEffect(.degrees(configuration.axis == .horizontal ? 90 : 0))
            Rectangle()
                .fill(Color(style.lineColour))
                .frame(width: configuration.axis == .horizontal ? 2 : nil, height: configuration.axis == .vertical ? 2 : nil)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: Color(.scrim), radius: 3, y: 2)
        .scaleEffect(configuration.isDragging ? 1.04 : 1)
    }
}
