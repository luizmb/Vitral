import SwiftUI
import VitralTokens

/// How a tag is coloured.
public enum TagStyle: Hashable, Sendable {
    /// Quiet ink on a neutral capsule.
    case plain
    /// The colour on a faint wash of itself: a category with an identity.
    case tinted(ColorToken)
    /// Filled with the colour: something chosen.
    case filled(ColorToken)
    /// One of the tints: its ink on its pastel surface.
    case tint(Tint)

    var foreground: ColorToken {
        switch self {
        case .plain: .inkMuted
        case let .tinted(color): color
        case .filled: .onAccent
        case let .tint(tint): tint.ink
        }
    }

    var background: ColorToken {
        switch self {
        case .plain: .neutralSurface
        case let .tinted(color): color.opacity(0.18)
        case let .filled(color): color
        case let .tint(tint): tint.surface
        }
    }
}

/// A short label on a capsule, with an optional icon: a category, a property, a count.
public struct Tag: View {
    @Environment(\.vitralScheme) private var scheme
    let text: Text
    let icon: Image?
    let style: TagStyle

    public init(_ title: LocalizedStringKey, icon: Image? = nil, style: TagStyle = .plain) {
        self.init(Text(title), icon: icon, style: style)
    }

    public init(_ text: Text, icon: Image? = nil, style: TagStyle = .plain) {
        self.text = text
        self.icon = icon
        self.style = style
    }

    public var body: some View {
        HStack(spacing: Space.extraSmall) {
            icon
            text
        }
        .font(TypeToken.detail.weight(.semibold))
        .foregroundStyle(style.foreground)
        .lineLimit(1)
        .padding(.horizontal, Space.medium)
        .padding(.vertical, Space.extraSmall)
        .background(Color(style.background, scheme: scheme), in: Capsule())
    }
}

/// A tag that turns on and off: filled with the accent when on, plain when off.
public struct TagToggle: View {
    let title: Text
    let icon: Image?
    @Binding var isOn: Bool

    @Environment(\.accent) private var accent

    public init(_ title: LocalizedStringKey, icon: Image? = nil, isOn: Binding<Bool>) {
        self.init(Text(title), icon: icon, isOn: isOn)
    }

    /// A tag titled with `Text`: for a title that is the app's data (a chord symbol), shown as it is.
    public init(_ title: Text, icon: Image? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.icon = icon
        self._isOn = isOn
    }

    public var body: some View {
        Button { isOn.toggle() } label: {
            Tag(title, icon: icon, style: isOn ? .filled(accent.base) : .plain)
                .frame(minHeight: Size.controlSmall)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation { Toggle(isOn: $isOn) { title } }
    }
}

/// Lays its subviews out left to right, wrapping to a new line when the next one doesn't fit.
public struct FlowLayout: Layout {
    let spacing: Double
    let lineSpacing: Double

    public init(spacing: Double = Space.small, lineSpacing: Double = Space.small) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        frames(for: subviews, width: proposal.width ?? .infinity).reduce(CGSize.zero) { size, frame in
            CGSize(width: max(size.width, frame.maxX), height: max(size.height, frame.maxY))
        }
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (subview, frame) in zip(subviews, frames(for: subviews, width: bounds.width)) {
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    /// One pass over the subviews' ideal sizes: each goes after the previous one, or starts a new
    /// line when it would cross `width`.
    private func frames(for subviews: Subviews, width: Double) -> [CGRect] {
        subviews.reduce(into: (frames: [CGRect](), x: 0.0, y: 0.0, lineHeight: 0.0)) { acc, subview in
            let size = subview.sizeThatFits(.unspecified)
            let wraps = acc.x > 0 && acc.x + size.width > width
            let origin = wraps ? CGPoint(x: 0, y: acc.y + acc.lineHeight + lineSpacing) : CGPoint(x: acc.x, y: acc.y)
            acc.frames.append(CGRect(origin: origin, size: size))
            acc.x = origin.x + size.width + spacing
            acc.y = origin.y
            acc.lineHeight = wraps ? size.height : max(acc.lineHeight, size.height)
        }
        .frames
    }
}

/// Tags that wrap onto as many lines as they need.
public struct TagCloud<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        FlowLayout { content }
    }
}

public extension TagCloud {
    /// One tag per title.
    init(_ titles: [LocalizedStringKey]) where Content == ForEach<[(offset: Int, element: LocalizedStringKey)], Int, Tag> {
        self.init { ForEach(Array(titles.enumerated()), id: \.offset) { Tag($0.element) } }
    }
}
