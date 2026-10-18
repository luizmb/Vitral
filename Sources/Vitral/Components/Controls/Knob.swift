import SwiftUI
import VitralTokens

/// How a knob is turned.
public enum KnobInteraction {
    /// Round the knob: it points where the finger is, so a touch anywhere on it sets the value.
    case circular
    /// Up and down, the finger free to leave the knob: up raises the value, `travel` points from
    /// the lowest to the highest. The value the drag started from is kept in `dragStart` (the
    /// app's state), set when the drag begins and cleared when it ends.
    case vertical(dragStart: Binding<Double?>, travel: Double = 200)
}

/// What a knob style draws: where the value sits and how it reads.
public struct KnobConfiguration: Sendable {
    public let value: Double
    /// Where the value sits, 0 ... 1.
    public let fraction: Double
    public let scale: ValueScale
    /// Where the pointer is at the lowest and the highest value, in degrees clockwise from
    /// twelve o'clock.
    public let startAngle: Double
    public let endAngle: Double
    public let isDragging: Bool

    /// The pointer's angle, degrees clockwise from twelve o'clock.
    public var angle: Double { DialGeometry.angle(for: fraction, start: startAngle, end: endAngle) }

    /// The angle a value's mark sits at.
    public func angle(of value: Double) -> Double {
        DialGeometry.angle(for: scale.fraction(of: value), start: startAngle, end: endAngle)
    }

    /// `value` as the scale writes it.
    public var formatted: String { scale.formatted(value) }
}

/// How a knob looks. Write one to draw a knob entirely your own way; `GlassKnobStyle` is the
/// default. Set one for every knob under a view with `.knobStyle(_:)`.
public protocol KnobStyle {
    associatedtype Body: View
    @MainActor @ViewBuilder func makeBody(_ configuration: KnobConfiguration) -> Body
}

/// Any knob style, so one can sit in the environment.
public struct AnyKnobStyle: KnobStyle, Sendable {
    let make: @MainActor @Sendable (KnobConfiguration) -> AnyView

    public init<Style: KnobStyle & Sendable>(_ style: Style) {
        self.make = { AnyView(style.makeBody($0)) }
    }

    public func makeBody(_ configuration: KnobConfiguration) -> some View {
        make(configuration)
    }
}

public extension EnvironmentValues {
    /// How every knob under this view looks, unless it's given its own style.
    @Entry var knobStyle = AnyKnobStyle(GlassKnobStyle())
}

public extension View {
    /// How every knob under this view looks: an amp panel's worth in one line.
    func knobStyle<Style: KnobStyle & Sendable>(_ style: Style) -> some View {
        environment(\.knobStyle, AnyKnobStyle(style))
    }
}

/// A knob: turn it round, or drag it up and down, between the scale's ends. Stateless: the value
/// is the binding's (a vertical drag also keeps where it started, in the app's state). It is as
/// big as its frame, square. It looks as `style` says, else as the environment's `.knobStyle`.
/// A double tap returns it to `resetValue` (a pan's centre). `onEditingEnded` is called when an
/// edit is done (the finger lifts, a double tap resets, VoiceOver adjusts).
public struct Knob: View {
    @Binding var value: Double
    let scale: ValueScale
    let interaction: KnobInteraction
    let startAngle: Double
    let endAngle: Double
    let style: AnyKnobStyle?
    let resetValue: Double?
    let onEditingEnded: () -> Void
    let label: Text

    @Environment(\.knobStyle) private var environmentStyle

    /// - Parameters:
    ///   - startAngle, endAngle: where the pointer is at the lowest and highest values, degrees
    ///     clockwise from twelve o'clock (7:30 to 4:30 by default).
    ///   - label: what VoiceOver calls it.
    public init(
        value: Binding<Double>,
        scale: ValueScale = ValueScale(),
        interaction: KnobInteraction = .circular,
        startAngle: Double = -135,
        endAngle: Double = 135,
        style: some KnobStyle & Sendable,
        resetValue: Double? = nil,
        onEditingEnded: @escaping () -> Void = {},
        label: Text
    ) {
        self.init(
            value: value, scale: scale, interaction: interaction, startAngle: startAngle, endAngle: endAngle,
            anyStyle: AnyKnobStyle(style), resetValue: resetValue, onEditingEnded: onEditingEnded, label: label
        )
    }

    /// A knob in the environment's style (`.knobStyle(_:)`, glass unless set).
    public init(
        value: Binding<Double>,
        scale: ValueScale = ValueScale(),
        interaction: KnobInteraction = .circular,
        startAngle: Double = -135,
        endAngle: Double = 135,
        resetValue: Double? = nil,
        onEditingEnded: @escaping () -> Void = {},
        label: Text
    ) {
        self.init(
            value: value, scale: scale, interaction: interaction, startAngle: startAngle, endAngle: endAngle,
            anyStyle: nil, resetValue: resetValue, onEditingEnded: onEditingEnded, label: label
        )
    }

    init(
        value: Binding<Double>,
        scale: ValueScale,
        interaction: KnobInteraction,
        startAngle: Double,
        endAngle: Double,
        anyStyle: AnyKnobStyle?,
        resetValue: Double?,
        onEditingEnded: @escaping () -> Void,
        label: Text
    ) {
        self._value = value
        self.scale = scale
        self.interaction = interaction
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.style = anyStyle
        self.resetValue = resetValue
        self.onEditingEnded = onEditingEnded
        self.label = label
    }

    var isDragging: Bool {
        switch interaction {
        case .circular: false
        case let .vertical(dragStart, _): dragStart.wrappedValue != nil
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            // The drawing takes no touches (interactive glass would answer them itself); a clear
            // disc on top takes them all.
            (style ?? environmentStyle).makeBody(
                KnobConfiguration(
                    value: value,
                    fraction: scale.fraction(of: value),
                    scale: scale,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    isDragging: isDragging
                )
            )
            .frame(width: proxy.size.width, height: proxy.size.height)
            .allowsHitTesting(false)
            .overlay {
                Circle()
                    .fill(.clear)
                    .contentShape(Circle())
                    .gesture(drag(in: proxy.size), including: resetValue == nil ? .all : .subviews)
                    // With a reset, the double tap comes first and the drag once it can't be one.
                    .gesture(
                        TapGesture(count: 2).onEnded { reset() }.exclusively(before: drag(in: proxy.size)),
                        including: resetValue == nil ? .subviews : .all
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
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

    func drag(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                switch interaction {
                case .circular:
                    value = scale.value(
                        at: DialGeometry.fraction(
                            forAngle: DialGeometry.angle(dx: drag.location.x - size.width / 2, dy: drag.location.y - size.height / 2),
                            start: startAngle,
                            end: endAngle
                        )
                    )
                case let .vertical(dragStart, travel):
                    if dragStart.wrappedValue == nil { dragStart.wrappedValue = value }
                    value = scale.dragged(from: dragStart.wrappedValue ?? value, by: -drag.translation.height, over: travel)
                }
            }
            .onEnded { _ in
                if case let .vertical(dragStart, _) = interaction { dragStart.wrappedValue = nil }
                onEditingEnded()
            }
    }
}

/// The glass knob, and its options: what the centre is made of, marks around it, numbers inside
/// or outside, the pointer, an arc of the accent showing the value, and the value written under.
public struct GlassKnobStyle: KnobStyle, Sendable {
    /// The knob's centre.
    public enum Face: Hashable, Sendable {
        /// Glass all through.
        case glass
        /// One of Vitral's textures, round in the middle of the glass.
        case texture(Texture)
        /// A flat colour, round in the middle of the glass.
        case colour(ColorToken)
        /// Polished chrome, domed: a vintage amp's silver knob.
        case chrome
    }

    /// Where the numbers go.
    public enum Numbers: Hashable, Sendable {
        case none
        /// On the knob's face, just inside its edge.
        case inside
        /// Round the knob, outside it.
        case outside
    }

    /// What shows where the knob points.
    public enum Pointer: Hashable, Sendable {
        /// A line from the edge towards the centre.
        case line
        /// A dot near the edge.
        case dot
        /// A raised bar across the whole knob, a chicken-head's.
        case handle
        /// A chrome bead standing out of the knob near its edge, lit on top.
        case chromeStud
        /// A chrome dimple pressed into the knob near its edge, shadowed on top.
        case chromeDimple
    }

    let face: Face
    let faceSize: Double
    let marks: Int?
    let numbers: Numbers
    let numberCount: Int
    let numberStep: Double?
    let pointer: Pointer
    let showsArc: Bool
    let showsValue: Bool
    let markColour: ColorToken
    let numberColour: ColorToken
    let valueColour: ColorToken
    let pointerColour: ColorToken?

    /// - Parameters:
    ///   - faceSize: how much of the knob the face covers, 0 ... 1: a small one leaves a ring of
    ///     glass round it (where numbers inside go), 1 is a whole skirt (numbers go on it).
    ///   - marks: dashes round the knob, this many (`nil` for none).
    ///   - numberCount: the most numbers written (the scale's steps when they fit), when there's
    ///     no `numberStep`.
    ///   - numberStep: a number every this much (1 for 0, 1, 2 … 10), written with the decimals
    ///     it needs. It only labels the knob: the value keeps the scale's step and precision, so a
    ///     knob numbered 1 to 10 can rest at 7.35.
    ///   - markColour, numberColour, valueColour: the dashes', numbers' and readout's colour, for
    ///     the panel they sit on.
    ///   - pointerColour: the pointer's colour; the accent when `nil`.
    public init(
        face: Face = .glass,
        faceSize: Double = 0.72,
        marks: Int? = nil,
        numbers: Numbers = .none,
        numberCount: Int = 11,
        numberStep: Double? = nil,
        pointer: Pointer = .line,
        showsArc: Bool = true,
        showsValue: Bool = false,
        markColour: ColorToken = .inkFaint,
        numberColour: ColorToken = .inkMuted,
        valueColour: ColorToken = .ink,
        pointerColour: ColorToken? = nil
    ) {
        self.face = face
        self.faceSize = faceSize
        self.marks = marks
        self.numbers = numbers
        self.numberCount = numberCount
        self.numberStep = numberStep
        self.pointer = pointer
        self.showsArc = showsArc
        self.showsValue = showsValue
        self.markColour = markColour
        self.numberColour = numberColour
        self.valueColour = valueColour
        self.pointerColour = pointerColour
    }

    public func makeBody(_ configuration: KnobConfiguration) -> some View {
        GlassKnob(style: self, configuration: configuration)
    }
}

/// The glass knob, drawn: rings outward-in (numbers outside, marks, the arc), then the glass cap
/// with its face, numbers inside and pointer.
struct GlassKnob: View {
    let style: GlassKnobStyle
    let configuration: KnobConfiguration

    @Environment(\.accent) private var accent

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let outer = style.numbers == .outside ? side * 0.16 : 0
            let ring = side - outer * 2
            ZStack {
                if style.numbers == .outside {
                    numbers(radius: side / 2 - outer / 2, size: outer * 0.62)
                }
                style.marks.map { count in marks(count: count, radius: ring / 2, length: ring * 0.06) }
                if style.showsArc {
                    arc(diameter: ring * 0.92, width: ring * 0.035)
                }
                cap(diameter: ring * 0.78)
                if style.numbers == .inside {
                    numbers(radius: ring * 0.78 / 2 * (style.faceSize >= 0.9 ? 0.76 : (1 + style.faceSize) / 2), size: ring * 0.09)
                }
                if style.showsValue {
                    Text(verbatim: configuration.formatted)
                        .font(.system(size: ring * 0.11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(style.valueColour)
                        // Under the knob; with numbers outside, in the gap between the last and the first.
                        .offset(y: style.numbers == .outside ? side / 2 - outer / 2 : ring * 0.5 + ring * 0.04)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    func cap(diameter: Double) -> some View {
        ZStack {
            Circle()
                .fill(.clear)
                .glassLayer(GlassToken.regular.interactive(), in: Circle())
            faceFill(diameter: diameter * min(max(style.faceSize, 0), 1))
            pointerMark(diameter: diameter)
        }
        .frame(width: diameter, height: diameter)
        .shadow(color: Color(.scrim), radius: diameter * 0.06, y: diameter * 0.03)
        .scaleEffect(configuration.isDragging ? 1.04 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isDragging)
    }

    @ViewBuilder
    func faceFill(diameter: Double) -> some View {
        switch style.face {
        case .glass:
            EmptyView()
        case let .texture(texture):
            Image(texture)
                .resizable(resizingMode: .tile)
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())
                .overlay { Circle().strokeBorder(Color(.hairline), lineWidth: 1) }
        case let .colour(colour):
            Circle().fill(Color(colour)).frame(width: diameter, height: diameter)
        case .chrome:
            ChromeDome().frame(width: diameter, height: diameter)
        }
    }

    @ViewBuilder
    func pointerMark(diameter: Double) -> some View {
        switch style.pointer {
        case .line:
            Capsule()
                .fill(Color(style.pointerColour ?? accent.base))
                .frame(width: diameter * 0.05, height: diameter * 0.26)
                .offset(y: -diameter * 0.3)
                .rotationEffect(.degrees(configuration.angle))
        case .dot:
            Circle()
                .fill(Color(style.pointerColour ?? accent.base))
                .frame(width: diameter * 0.1, height: diameter * 0.1)
                .offset(y: -diameter * 0.36)
                .rotationEffect(.degrees(configuration.angle))
        case .handle:
            ZStack {
                Capsule()
                    .fill(Color(.ink).opacity(0.85))
                    .frame(width: diameter * 0.16, height: diameter * 0.96)
                Capsule()
                    .fill(Color(style.pointerColour ?? .onAccent))
                    .frame(width: diameter * 0.04, height: diameter * 0.3)
                    .offset(y: -diameter * 0.3)
            }
            .shadow(color: Color(.scrim), radius: diameter * 0.04, y: diameter * 0.02)
            .rotationEffect(.degrees(configuration.angle))
        case .chromeStud, .chromeDimple:
            ChromeBead(isConcave: style.pointer == .chromeDimple)
                .frame(width: diameter * 0.14, height: diameter * 0.14)
                // Placed by angle, not turned with it: the light comes from above, whatever the knob does.
                .offset(
                    x: sin(configuration.angle * .pi / 180) * diameter * 0.34,
                    y: -cos(configuration.angle * .pi / 180) * diameter * 0.34
                )
        }
    }

    /// The share of a full turn the knob sweeps.
    var sweep: Double {
        (configuration.endAngle - configuration.startAngle) / 360
    }

    func arc(diameter: Double, width: Double) -> some View {
        ZStack {
            Circle()
                .trim(from: 0, to: sweep)
                .stroke(Color(.hairline), style: StrokeStyle(lineWidth: width, lineCap: .round))
            Circle()
                .trim(from: 0, to: sweep * configuration.fraction)
                .stroke(Color(accent.base), style: StrokeStyle(lineWidth: width, lineCap: .round))
        }
        .frame(width: diameter, height: diameter)
        // A circle's trim starts at three o'clock; the knob's angles at twelve.
        .rotationEffect(.degrees(configuration.startAngle - 90))
    }

    func marks(count: Int, radius: Double, length: Double) -> some View {
        ForEach(0 ..< max(count, 2), id: \.self) { index in
            Capsule()
                .fill(Color(style.markColour))
                .frame(width: max(length * 0.25, 1), height: length)
                .offset(y: -radius + length / 2)
                .rotationEffect(.degrees(DialGeometry.angle(for: Double(index) / Double(max(count, 2) - 1), start: configuration.startAngle, end: configuration.endAngle)))
        }
    }

    /// The values that get a number.
    var numbered: [Double] {
        style.numberStep.map { configuration.scale.marks(every: $0) } ?? configuration.scale.marks(limit: style.numberCount)
    }

    /// A number as written: with its step's decimals, or the scale's precision.
    func label(_ mark: Double) -> String {
        style.numberStep.map { configuration.scale.formatted(mark, places: ValueScale.decimals(of: $0)) } ?? configuration.scale.formatted(mark)
    }

    func numbers(radius: Double, size: Double) -> some View {
        ForEach(numbered, id: \.self) { mark in
            Text(verbatim: label(mark))
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(style.numberColour)
                .offset(
                    x: sin(configuration.angle(of: mark) * .pi / 180) * radius,
                    y: -cos(configuration.angle(of: mark) * .pi / 180) * radius
                )
        }
    }
}

/// Polished chrome, domed: the metal's reflections turning round it, and a bright highlight up and
/// to the left where the light catches the dome.
struct ChromeDome: View {
    var body: some View {
        ZStack {
            Circle().fill(
                AngularGradient(
                    colors: [.chromeHighlight, .chromeMid, .chromeShadow, .chromeMid, .chromeHighlight, .chromeMid, .chromeShadow, .chromeMid, .chromeHighlight].map { Color($0) },
                    center: .center
                )
            )
            Circle().fill(
                RadialGradient(
                    colors: [Color(.chromeHighlight), Color(ColorToken.chromeHighlight.opacity(0))],
                    center: UnitPoint(x: 0.35, y: 0.3),
                    startRadius: 0,
                    endRadius: 60
                )
            )
            .blendMode(.screen)
            Circle().fill(
                RadialGradient(
                    colors: [.clear, Color(ColorToken.chromeShadow.opacity(0.55))],
                    center: .center,
                    startRadius: 20,
                    endRadius: 70
                )
            )
            Circle().strokeBorder(Color(.chromeShadow), lineWidth: 1)
        }
        .compositingGroup()
    }
}

/// A half sphere of chrome: convex, lit on top with a shadow below; or concave, the other way
/// round, shadowed on top as light falls into it.
struct ChromeBead: View {
    let isConcave: Bool

    var body: some View {
        ZStack {
            Circle().fill(
                LinearGradient(
                    colors: [Color(.chromeHighlight), Color(.chromeMid), Color(.chromeShadow)],
                    startPoint: isConcave ? .bottom : .top,
                    endPoint: isConcave ? .top : .bottom
                )
            )
            Circle()
                .fill(Color(ColorToken.chromeHighlight.opacity(0.9)))
                .frame(width: 2, height: 2)
                .scaleEffect(2)
                .offset(x: -1.5, y: isConcave ? 2 : -2)
                .blur(radius: 0.5)
        }
        .overlay { Circle().strokeBorder(Color(.chromeShadow), lineWidth: 0.6) }
        .shadow(color: Color(.scrim), radius: isConcave ? 0 : 1.5, y: isConcave ? 0 : 1)
    }
}

/// An endless dial, a jog wheel's: turn it round and round, and `rotation` (degrees, any size)
/// follows the finger. Stateless: `lastTouch` (the app's state) keeps the finger's previous angle
/// during a turn. Turn rotation into steps, a playhead's movement or a scrub as the app needs.
public struct JogDial: View {
    @Binding var rotation: Double
    @Binding var lastTouch: Double?
    let marks: Int
    let label: Text

    @Environment(\.accent) private var accent

    /// - Parameters:
    ///   - marks: grooves round the edge, turning with it.
    ///   - label: what VoiceOver calls it.
    public init(rotation: Binding<Double>, lastTouch: Binding<Double?>, marks: Int = 24, label: Text) {
        self._rotation = rotation
        self._lastTouch = lastTouch
        self.marks = marks
        self.label = label
    }

    public var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .fill(.clear)
                    .glassLayer(GlassToken.regular.interactive(), in: Circle())
                ForEach(0 ..< marks, id: \.self) { index in
                    Capsule()
                        .fill(Color(.inkFaint))
                        .frame(width: side * 0.012, height: side * 0.07)
                        .offset(y: -side * 0.43)
                        .rotationEffect(.degrees(Double(index) * 360 / Double(max(marks, 1)) + rotation))
                }
                // The finger dimple.
                Circle()
                    .fill(Color(.neutralSurface))
                    .overlay { Circle().strokeBorder(Color(.hairline), lineWidth: 1) }
                    .frame(width: side * 0.16, height: side * 0.16)
                    .offset(y: -side * 0.28)
                    .rotationEffect(.degrees(rotation))
                Circle()
                    .fill(.clear)
                    .glassLayer(.regular, in: Circle())
                    .frame(width: side * 0.3, height: side * 0.3)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .shadow(color: Color(.scrim), radius: side * 0.05, y: side * 0.025)
            .scaleEffect(lastTouch == nil ? 1 : 1.02)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: lastTouch == nil)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let touch = DialGeometry.angle(dx: drag.location.x - proxy.size.width / 2, dy: drag.location.y - proxy.size.height / 2)
                        rotation += lastTouch.map { DialGeometry.turn(from: $0, to: touch) } ?? 0
                        lastTouch = touch
                    }
                    .onEnded { _ in lastTouch = nil }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rotation += 360 / Double(max(marks, 1))
            case .decrement: rotation -= 360 / Double(max(marks, 1))
            @unknown default: break
            }
        }
    }
}
