import SwiftUI
import VitralTokens

/// A short label on a capsule: a category, a property, a count.
public struct Tag: View {
    let text: Text

    public init(_ title: LocalizedStringKey) {
        self.text = Text(title)
    }

    public init(_ text: Text) {
        self.text = text
    }

    public var body: some View {
        text
            .font(TypeToken.detail.weight(.semibold))
            .foregroundStyle(.inkMuted)
            .lineLimit(1)
            .padding(.horizontal, Space.medium)
            .padding(.vertical, Space.extraSmall)
            .background(Color(.neutralSurface), in: Capsule())
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
