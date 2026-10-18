import SwiftUI
import VitralTokens

/// A summary on glass: a title, an optional subtitle and any content under them (stats, a tag
/// cloud). A header (a swatch stack, a tag) and a footer (an action bar) are added with
/// `.header { }` and `.footer { }`, so a card carries only the parts it uses.
public struct Card<Header: View, Content: View, Footer: View>: View {
    let title: Text
    let subtitle: Text?
    let header: Header
    let content: Content
    let footer: Footer

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: Space.medium) {
                header
                VStack(alignment: .leading, spacing: Space.extraSmall) {
                    title
                        .font(.title)
                        .foregroundStyle(.ink)
                    subtitle.map { subtitle in
                        subtitle
                            .font(.subheadline)
                            .foregroundStyle(.inkMuted)
                            .lineLimit(4)
                    }
                }
                content
            }
            .padding(Space.large)
            footer
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(cornerRadius: Radius.card)
    }

    /// Puts `header` above the title.
    public func header<NewHeader: View>(@ViewBuilder _ header: () -> NewHeader) -> Card<NewHeader, Content, Footer> {
        Card<NewHeader, Content, Footer>(title: title, subtitle: subtitle, header: header(), content: content, footer: footer)
    }

    /// Puts `footer` along the bottom edge, under a hairline.
    public func footer<NewFooter: View>(@ViewBuilder _ footer: () -> NewFooter) -> Card<Header, Content, VStack<TupleView<(Hairline, NewFooter)>>> {
        Card<Header, Content, VStack<TupleView<(Hairline, NewFooter)>>>(
            title: title,
            subtitle: subtitle,
            header: header,
            content: content,
            footer: VStack(spacing: 0) { Hairline(); footer() }
        )
    }
}

public extension Card where Header == EmptyView, Footer == EmptyView {
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, @ViewBuilder content: () -> Content) {
        self.init(Text(title), subtitle: subtitle.map { Text($0) }, content: content)
    }

    /// A card with text already made: a name to show as it is (`Text(verbatim:)`), or styled text.
    init(_ title: Text, subtitle: Text? = nil, @ViewBuilder content: () -> Content) {
        self.init(title: title, subtitle: subtitle, header: EmptyView(), content: content(), footer: EmptyView())
    }
}

public extension Card where Header == EmptyView, Content == EmptyView, Footer == EmptyView {
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil) {
        self.init(Text(title), subtitle: subtitle.map { Text($0) })
    }

    init(_ title: Text, subtitle: Text? = nil) {
        self.init(title: title, subtitle: subtitle, header: EmptyView(), content: EmptyView(), footer: EmptyView())
    }
}
