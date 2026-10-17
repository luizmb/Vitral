import SwiftUI
import VitralTokens

/// How a carousel's pages move.
public enum CarouselStyle: Hashable, Sendable {
    /// Side by side, sliding.
    case slide
    /// Each page turns in depth as it leaves, like a card flipped over.
    case flip

    /// How far a page turns (degrees) as it moves one page away.
    var turn: Double {
        switch self {
        case .slide: 0
        case .flip: -70
        }
    }

    /// How much a page fades as it moves one page away.
    var fade: Double {
        switch self {
        case .slide: 0.3
        case .flip: 0.5
        }
    }
}

/// Pages through `items` one width at a time, like a page view controller: swipe, or set
/// `selection` (the shown item's id) to move. Stateless: the page is the binding's.
public struct Carousel<Item: Identifiable, Content: View>: View where Item.ID: Sendable {
    @Binding var selection: Item.ID?
    let items: [Item]
    let style: CarouselStyle
    let content: (Item) -> Content

    public init(
        _ items: [Item],
        selection: Binding<Item.ID?>,
        style: CarouselStyle = .slide,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self._selection = selection
        self.style = style
        self.content = content
    }

    public var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(items) { item in
                    content(item)
                        .padding(.horizontal, Space.large)
                        .containerRelativeFrame(.horizontal)
                        .scrollTransition(axis: .horizontal) { page, phase in
                            page
                                .rotation3DEffect(.degrees(phase.value * style.turn), axis: (x: 0, y: 1, z: 0))
                                .opacity(1 - abs(phase.value) * style.fade)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selection)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

/// A dot per page on a glass capsule, the current one filled with the accent: where you are in
/// a carousel, and a way to jump. VoiceOver reads it as one adjustable control.
public struct PageDots<ID: Hashable & Sendable>: View {
    @Binding var selection: ID?
    let ids: [ID]
    let label: (Int, Int) -> Text

    @Environment(\.accent) private var accent

    /// - Parameter label: what VoiceOver says for page `index` (from 1) of `count`.
    public init(_ ids: [ID], selection: Binding<ID?>, label: @escaping (Int, Int) -> Text = { Text("Page \($0) of \($1)") }) {
        self.ids = ids
        self._selection = selection
        self.label = label
    }

    var index: Int {
        ids.firstIndex { $0 == selection } ?? 0
    }

    public var body: some View {
        HStack(spacing: Space.small) {
            ForEach(ids, id: \.self) { id in
                Button { selection = id } label: {
                    Circle()
                        .fill(id == selection ? Color(accent.base) : Color(.inkFaint))
                        .frame(width: Space.small, height: Space.small)
                        .padding(Space.extraSmall)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Space.small)
        .padding(.vertical, Space.extraSmall)
        .glassCapsule()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label(index + 1, ids.count))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selection = ids[min(index + 1, ids.count - 1)]
            case .decrement: selection = ids[max(index - 1, 0)]
            @unknown default: break
            }
        }
    }
}
