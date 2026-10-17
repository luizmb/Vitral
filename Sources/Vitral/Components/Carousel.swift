import SwiftUI
import VitralTokens
#if canImport(UIKit)
import UIKit
#endif

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
    let inset: Double
    let content: (Item) -> Content

    /// - Parameter inset: the space kept on each side of a page.
    public init(
        _ items: [Item],
        selection: Binding<Item.ID?>,
        style: CarouselStyle = .slide,
        inset: Double = Space.large,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self._selection = selection
        self.style = style
        self.inset = inset
        self.content = content
    }

    public var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(items) { item in
                    content(item)
                        .padding(.horizontal, inset)
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

/// Where you are in a carousel, and a way to move: the platform's page control. On iOS it is
/// UIKit's own (`UIPageControl`): dots that grow under the finger, a drag across them scrubs
/// through the pages, a tap steps one, and VoiceOver reads it as an adjustable control. Elsewhere,
/// dots on a glass capsule. Stateless: the page is the binding's, set with animation so the
/// carousel follows.
public struct PageDots<ID: Hashable & Sendable>: View {
    @Binding var selection: ID?
    let ids: [ID]

    @Environment(\.accent) private var accent

    public init(_ ids: [ID], selection: Binding<ID?>) {
        self.ids = ids
        self._selection = selection
    }

    var index: Int {
        ids.firstIndex { $0 == selection } ?? 0
    }

    func select(_ page: Int) {
        withAnimation { selection = ids[min(max(page, 0), ids.count - 1)] }
    }

    public var body: some View {
        #if canImport(UIKit)
        NativePageControl(count: ids.count, current: index, current: accent.base, other: .inkFaint, onChange: select)
            .fixedSize()
        #else
        HStack(spacing: Space.small) {
            ForEach(Array(ids.enumerated()), id: \.offset) { page, id in
                Button { select(page) } label: {
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
        #endif
    }
}

#if canImport(UIKit)
/// UIKit's page control, showing `current` of `count` and reporting the page the user moves to.
struct NativePageControl: UIViewRepresentable {
    let count: Int
    let current: Int
    let currentColour: ColorToken
    let otherColour: ColorToken
    let onChange: @MainActor (Int) -> Void

    init(count: Int, current: Int, current currentColour: ColorToken, other otherColour: ColorToken, onChange: @escaping @MainActor (Int) -> Void) {
        self.count = count
        self.current = current
        self.currentColour = currentColour
        self.otherColour = otherColour
        self.onChange = onChange
    }

    func makeCoordinator() -> Relay {
        Relay(onChange: onChange)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        // The platform's capsule behind the dots, so they read over any backdrop.
        control.backgroundStyle = .prominent
        control.addTarget(context.coordinator, action: #selector(Relay.changed(_:)), for: .valueChanged)
        return control
    }

    func updateUIView(_ control: UIPageControl, context: Context) {
        context.coordinator.onChange = onChange
        control.numberOfPages = count
        control.currentPage = current
        control.currentPageIndicatorTintColor = UIColor(Color(currentColour))
        control.pageIndicatorTintColor = UIColor(Color(otherColour))
    }

    /// Passes UIKit's value-changed event on to the latest `onChange`; it holds no page of its own.
    @MainActor
    final class Relay: NSObject {
        var onChange: @MainActor (Int) -> Void

        init(onChange: @escaping @MainActor (Int) -> Void) {
            self.onChange = onChange
        }

        @objc func changed(_ control: UIPageControl) {
            onChange(control.currentPage)
        }
    }
}
#endif
