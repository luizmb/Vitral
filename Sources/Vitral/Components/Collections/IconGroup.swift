import SwiftUI
import VitralTokens

/// Icons on glass a page at a time, the way a home screen opens a folder: an optional header over
/// a grid of tiles, page dots under it when there's more than one page, an optional footer. Every
/// page is the same height, so the group doesn't change size as it's swiped. Pages are asked for
/// as they're shown (`items(page)`), so a long group can fetch them as it goes. Stateless: the page
/// shown is the binding's.
public struct IconGroup<Item: Identifiable, Tile: View, Header: View, Footer: View>: View {
    @Binding var page: Int
    let pageCount: Int
    let columns: Int
    let rows: Int
    let tileHeight: Double
    let pageLabel: ((Int, Int) -> Text)?
    let glass: GlassToken?
    let items: (Int) -> [Item]
    let tile: (Item) -> Tile
    let header: Header
    let footer: Footer

    /// - Parameters:
    ///   - page: the page shown, from 0.
    ///   - pageCount: how many pages there are.
    ///   - columns, rows: each page's grid.
    ///   - tileHeight: every tile's height, so a row lines up (`IconTile`'s by default).
    ///   - pageLabel: dots under the grid when there's more than one page, and what VoiceOver says
    ///     for a page's dot given its number and the count ("Page 2 of 5"); `nil` for no dots.
    ///   - items: what's on a page.
    public init(
        page: Binding<Int>,
        pageCount: Int,
        columns: Int = 3,
        rows: Int = 3,
        tileHeight: Double = Size.iconTile,
        pageLabel: ((Int, Int) -> Text)?,
        glass: GlassToken? = nil,
        items: @escaping (Int) -> [Item],
        @ViewBuilder tile: @escaping (Item) -> Tile,
        @ViewBuilder header: () -> Header = { EmptyView() },
        @ViewBuilder footer: () -> Footer = { EmptyView() }
    ) {
        self._page = page
        self.pageCount = pageCount
        self.columns = columns
        self.rows = rows
        self.tileHeight = tileHeight
        self.pageLabel = pageLabel
        self.glass = glass
        self.items = items
        self.tile = tile
        self.header = header()
        self.footer = footer()
    }

    /// Every item at once, `columns` by `rows` to a page.
    public init(
        _ all: [Item],
        page: Binding<Int>,
        columns: Int = 3,
        rows: Int = 3,
        tileHeight: Double = Size.iconTile,
        pageLabel: ((Int, Int) -> Text)?,
        glass: GlassToken? = nil,
        @ViewBuilder tile: @escaping (Item) -> Tile,
        @ViewBuilder header: () -> Header = { EmptyView() },
        @ViewBuilder footer: () -> Footer = { EmptyView() }
    ) {
        let perPage = max(columns * rows, 1)
        self.init(
            page: page,
            pageCount: max((all.count + perPage - 1) / perPage, 1),
            columns: columns,
            rows: rows,
            tileHeight: tileHeight,
            pageLabel: pageLabel,
            glass: glass,
            items: { index in Array(all.dropFirst(index * perPage).prefix(perPage)) },
            tile: tile,
            header: header,
            footer: footer
        )
    }

    var hasHeader: Bool { Header.self != EmptyView.self }
    var hasFooter: Bool { Footer.self != EmptyView.self }

    /// Each page's grid height: every row, and the gaps between them.
    var gridHeight: Double {
        Double(rows) * tileHeight + Double(max(rows - 1, 0)) * Space.medium
    }

    /// The page as the pager and the dots want it.
    var shown: Binding<Int?> {
        Binding(get: { page }, set: { newValue in newValue.map { page = $0 } })
    }

    public var body: some View {
        VStack(spacing: 0) {
            if hasHeader {
                header.padding(Space.large)
                Hairline()
            }
            pager
            if let pageLabel, pageCount > 1 {
                PageDots(Array(0 ..< pageCount), selection: shown, pageLabel: pageLabel)
                    .padding(.bottom, Space.small)
            }
            if hasFooter {
                footer
                    .padding(.horizontal, Space.large)
                    .padding(.bottom, Space.medium)
            }
        }
        .glassSurface(glass, cornerRadius: Radius.sheet)
    }

    var pager: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(0 ..< max(pageCount, 1), id: \.self) { index in
                    grid(index)
                        .padding(Space.large)
                        .containerRelativeFrame(.horizontal)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: shown)
        .scrollIndicators(.hidden)
        .scrollDisabled(pageCount < 2)
        .frame(height: gridHeight + Space.large * 2)
    }

    func grid(_ index: Int) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Space.medium), count: max(columns, 1)), spacing: Space.medium) {
            ForEach(items(index)) { item in
                tile(item).frame(height: tileHeight, alignment: .top)
            }
        }
        .frame(height: gridHeight, alignment: .top)
    }
}

/// One icon in an icon group: the icon, a title of up to two lines and a subtitle under it, all
/// top-aligned so a row's words hang from the same line. A tap does `tap`; holding does `hold`
/// (start picking, say). While picking (`isPicked` not `nil`), a mark on the icon says whether
/// this one is picked, and the ones not picked fade.
public struct IconTile<Icon: View>: View {
    let title: Text
    let subtitle: Text?
    let isPicked: Bool?
    let accessibilityLabel: Text?
    let accessibilityHint: Text?
    let tap: @MainActor () -> Void
    let hold: (@MainActor () -> Void)?
    let icon: Icon

    /// - Parameters:
    ///   - isPicked: `nil` when not picking.
    ///   - accessibilityLabel: what VoiceOver says instead of the title and subtitle.
    public init(
        _ title: Text,
        subtitle: Text? = nil,
        isPicked: Bool? = nil,
        accessibilityLabel: Text? = nil,
        accessibilityHint: Text? = nil,
        tap: @escaping @MainActor () -> Void,
        hold: (@MainActor () -> Void)? = nil,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isPicked = isPicked
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.tap = tap
        self.hold = hold
        self.icon = icon()
    }

    public var body: some View {
        // A button, not a tap gesture: in a scroll view (a group's pages scroll) SwiftUI places a
        // tap gesture's hits off from where the tile is drawn; a button's are where it is. A hold
        // is a long press that wins over the button, so lifting the finger after it doesn't tap too.
        Button(action: tap) { face }
            .buttonStyle(IconTileButtonStyle())
            .highPriorityGesture(LongPressGesture(minimumDuration: 0.45).onEnded { _ in hold?() }, including: hold == nil ? .subviews : .all)
            .opacity(isPicked == false ? 0.6 : 1)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(isPicked == true ? .isSelected : [])
            .modifier(OptionalAccessibility(label: accessibilityLabel, hint: accessibilityHint))
    }

    var face: some View {
        VStack(spacing: Space.extraSmall) {
            icon
                .frame(width: Size.icon, height: Size.icon)
                .overlay(alignment: .topTrailing) {
                    isPicked.map { picked in
                        SelectionMark(isSelected: picked).offset(x: Space.extraSmall, y: -Space.hairline)
                    }
                }
            VStack(spacing: 0) {
                title
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.ink)
                subtitle
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .contentShape(Rectangle())
    }
}

/// A tile pressed: a little smaller while the finger is down, as a home screen's icons are.
struct IconTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// The tile where the next icon would go: a dashed circle with a plus, and its title.
public struct IconTileAdd: View {
    @Environment(\.vitralScheme) private var scheme
    let title: Text
    let icon: Image
    let action: @MainActor () -> Void

    public init(_ title: Text, icon: Image = Image(.add), action: @escaping @MainActor () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: Space.extraSmall) {
                Circle()
                    .strokeBorder(Color(.outline, scheme: scheme), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .frame(width: Size.icon, height: Size.icon)
                    .overlay(icon.font(.title3).foregroundStyle(.inkMuted))
                title
                    .font(.caption)
                    .foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// A label and a hint only when given, so a combined element keeps what it reads otherwise.
struct OptionalAccessibility: ViewModifier {
    let label: Text?
    let hint: Text?

    func body(content: Content) -> some View {
        switch (label, hint) {
        case let (label?, hint?): content.accessibilityLabel(label).accessibilityHint(hint)
        case let (label?, nil): content.accessibilityLabel(label)
        case let (nil, hint?): content.accessibilityHint(hint)
        case (nil, nil): content
        }
    }
}
