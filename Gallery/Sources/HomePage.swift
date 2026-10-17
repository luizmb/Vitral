import SwiftUI
import Vitral
import VitralTokens

/// One card per shelf, in as many columns as fit.
struct HomePage: View {
    var body: some View {
        Page("Vitral") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: Space.large, alignment: .top)], spacing: Space.large) {
                ForEach(GallerySection.allCases, id: \.self) { section in
                    NavigationLink(value: section) {
                        Card(section.title, subtitle: section.subtitle) {
                            TagCloud(section.pages.map(\.title))
                        }
                        .header { SwatchStack(section.swatches) }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(GalleryAccessibilityID.section(section))
                }
            }
        }
    }
}

/// A shelf's pages, one row each.
struct SectionPage: View {
    let section: GallerySection

    var body: some View {
        Page(section.title) {
            PanelList {
                ForEach(section.pages, id: \.self) { page in
                    NavigationLink(value: page) {
                        Row(page.title, subtitle: page.subtitle, showsDisclosure: true)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(GalleryAccessibilityID.page(page))
                }
            }
        }
    }
}
