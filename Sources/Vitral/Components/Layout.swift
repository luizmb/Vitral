import SwiftUI
import VitralTokens

/// A divider a hair thick, across (`.horizontal`) or upright (`.vertical`).
public struct Hairline: View {
    let axis: Axis

    public init(_ axis: Axis = .horizontal) {
        self.axis = axis
    }

    public var body: some View {
        Rectangle()
            .fill(Color(.hairline))
            .frame(width: axis == .vertical ? Size.hairline : nil, height: axis == .horizontal ? Size.hairline : nil)
    }
}

/// Glass holding its content, padded.
public struct Panel<Content: View>: View {
    let material: GlassToken?
    let cornerRadius: Double
    let padding: Double
    let content: Content

    public init(
        material: GlassToken? = nil,
        cornerRadius: Double = Radius.card,
        padding: Double = Space.large,
        @ViewBuilder content: () -> Content
    ) {
        self.material = material
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassSurface(material, cornerRadius: cornerRadius)
    }
}

/// Rows on one glass panel, a hairline between each two.
public struct PanelList<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Panel(padding: 0) {
            VStack(spacing: 0) {
                Group(subviews: content) { rows in
                    ForEach(rows) { row in
                        if row.id != rows.first?.id {
                            Hairline().padding(.leading, Space.large)
                        }
                        row
                    }
                }
            }
        }
    }
}

/// An uppercase header over a group.
public struct SectionLabel: View {
    let title: LocalizedStringKey

    public init(_ title: LocalizedStringKey) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.sectionLabel)
            .textCase(.uppercase)
            .kerning(0.5)
            .foregroundStyle(.inkFaint)
            .padding(.horizontal, Space.extraSmall)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A titled group: a section label over its content.
public struct LabelledGroup<Content: View>: View {
    let title: LocalizedStringKey
    let content: Content

    public init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.small) {
            SectionLabel(title)
            content
        }
    }
}

/// A screen's scrolling column over its backdrop (graph paper unless told otherwise), its title in
/// the navigation bar. With `parallax`, the backdrop scrolls at a third of the content's speed, so
/// the glass reads as floating above it; with Reduce Motion it stays still.
public struct Page<Content: View>: View {
    let title: LocalizedStringKey
    let backdrop: BackdropStyle
    let parallax: Bool
    let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ title: LocalizedStringKey, backdrop: BackdropStyle = .grid(), parallax: Bool = true, @ViewBuilder content: () -> Content) {
        self.title = title
        self.backdrop = backdrop
        self.parallax = parallax
        self.content = content()
    }

    var drifts: Bool { parallax && !reduceMotion }

    public var body: some View {
        GeometryReader { viewport in
            ScrollView {
                VStack(alignment: .leading, spacing: Space.extraLarge) {
                    content
                }
                .padding(.horizontal, Space.large)
                .padding(.vertical, Space.extraLarge)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity, minHeight: viewport.size.height, alignment: .top)
                .background(alignment: .top) {
                    if drifts {
                        GeometryReader { column in
                            Backdrop(backdrop)
                                .frame(height: Page.backdropHeight(viewport: viewport.size.height, content: column.size.height))
                                .visualEffect { layer, proxy in
                                    layer.offset(y: Page.drift(contentTop: proxy.frame(in: .scrollView).minY, viewport: viewport.size.height))
                                }
                        }
                    }
                }
            }
            .background {
                if !drifts {
                    Backdrop(backdrop)
                }
            }
        }
        .navigationTitle(Text(title))
    }

    /// How much more than the screen the backdrop reaches above and below, for the bounce.
    nonisolated static func bounce(viewport: Double) -> Double {
        viewport / 3
    }

    /// The backdrop is a screen tall, plus the third of the scroll it travels, plus the bounce at
    /// both ends: art that fills its frame (a photo, an aurora) is never stretched to the page.
    nonisolated static func backdropHeight(viewport: Double, content: Double) -> Double {
        viewport + max(0, content - viewport) * Motion.parallax + bounce(viewport: viewport) * 2
    }

    /// Where the backdrop goes as the content's top moves to `contentTop` (in the scroll view): it
    /// starts the bounce above, and keeps up with only a third of the movement.
    nonisolated static func drift(contentTop: Double, viewport: Double) -> Double {
        -bounce(viewport: viewport) - contentTop * (1 - Motion.parallax)
    }
}
