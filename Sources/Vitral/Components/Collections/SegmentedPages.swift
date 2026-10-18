import SwiftUI
import VitralTokens

/// A kind of page: an icon and a name for its segment.
public protocol PageKind: Hashable, CaseIterable, Sendable where AllCases: RandomAccessCollection {
    var icon: Image { get }
    var title: LocalizedStringKey { get }
}

/// Pages with their segments on top, Xcode's inspector way: tap a segment or swipe the pages, and
/// the two follow each other. The page is the binding's. Segments show icons, or titles with
/// `showsTitles`. The pages are the platform's page view, so a swipe always settles on one, even
/// when the system's back swipe takes the touch over.
public struct SegmentedPages<Page: PageKind, Content: View>: View {
    @Binding var selection: Page
    let showsTitles: Bool
    let page: (Page) -> Content

    public init(selection: Binding<Page>, showsTitles: Bool = false, @ViewBuilder page: @escaping (Page) -> Content) {
        self._selection = selection
        self.showsTitles = showsTitles
        self.page = page
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
            TabView(selection: $selection) {
                ForEach(Array(Page.allCases), id: \.self) { kind in
                    page(kind)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tag(kind)
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
    }
}
