import SwiftUI
import VitralTokens

/// A kind of page: an icon and a name for its segment.
public protocol PageKind: Hashable, CaseIterable, Sendable where AllCases: RandomAccessCollection {
    var icon: Image { get }
    var title: LocalizedStringKey { get }
}

/// Pages with their segments on top, Xcode's inspector way: tap a segment or swipe the pages, and
/// the two follow each other. The page is the binding's. Segments show icons, or titles with
/// `showsTitles`.
public struct SegmentedPages<Page: PageKind, Content: View>: View {
    @Binding var selection: Page
    let showsTitles: Bool
    let page: (Page) -> Content

    public init(selection: Binding<Page>, showsTitles: Bool = false, @ViewBuilder page: @escaping (Page) -> Content) {
        self._selection = selection
        self.showsTitles = showsTitles
        self.page = page
    }

    /// A page as a carousel item.
    struct Item: Identifiable {
        let id: Page
    }

    /// The carousel's optional id, over the non-optional selection.
    var shown: Binding<Page?> {
        Binding(get: { selection }, set: { page in page.map { selection = $0 } })
    }

    public var body: some View {
        VStack(spacing: 0) {
            SegmentedControlGlass(
                selection: Binding(get: { selection }, set: { page in withAnimation { selection = page } }),
                options: Page.allCases.map { kind in
                    showsTitles ? ChoiceOption(kind, title: kind.title, icon: kind.icon) : ChoiceOption(kind, icon: kind.icon, accessibilityLabel: kind.title)
                }
            )
            .padding(Space.medium)
            Hairline()
            Carousel(Page.allCases.map(Item.init), selection: shown, inset: 0) { item in
                page(item.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            // A carousel lets its neighbours show past its edges; pages stay inside.
            .clipped()
        }
    }
}
