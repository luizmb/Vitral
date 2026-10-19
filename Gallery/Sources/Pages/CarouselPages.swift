import SwiftUI
import Vitral
import VitralTokens

/// One card of the samples.
struct CarouselCard: Identifiable, Sendable {
    let id: Int
    let title: String
    let subtitle: String
    let tags: [String]

    static let all = [
        CarouselCard(id: 0, title: "U-234 Inhalation", subtitle: "ICRP 137, Type S", tags: ["Nuclear", "Inhalation"]),
        CarouselCard(id: 1, title: "Cs-137 Ingestion", subtitle: "ICRP 137", tags: ["Nuclear", "Ingestion"]),
        CarouselCard(id: 2, title: "I-131 Thyroid", subtitle: "Blocked with KI", tags: ["Iodine", "Thyroid"]),
        CarouselCard(id: 3, title: "Pu-239 Wound", subtitle: "NCRP 156", tags: ["Wound", "Actinide"]),
        CarouselCard(id: 4, title: "H-3 Water", subtitle: "Whole body", tags: ["Tritium"])
    ]
}

/// The carousel, sliding and flipping, each with its page dots.
struct CarouselPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Page("Carousel") {
            Sample("Carousel(style: .slide) and PageDots") {
                CarouselSample(selection: $model.carouselPage, style: .slide)
            }
            Sample("Carousel(style: .flip)") {
                CarouselSample(selection: $model.flipPage, style: .flip)
            }
            Sample("SegmentedPages(selection:, showsTitles: true)") {
                SegmentedPages(selection: $model.segmentedPage, showsTitles: true) { page in
                    WorkspaceInspector(page: page)
                }
                .frame(height: 260)
                .glassSurface(cornerRadius: Radius.card)
            }
        }
    }
}

/// Glass cards paging over one backdrop, which stays where it is; the dots under them.
struct CarouselSample: View {
    @Binding var selection: Int?
    let style: CarouselStyle

    var body: some View {
        VStack(spacing: Space.medium) {
            Carousel(CarouselCard.all, selection: $selection, style: style) { card in
                Card(LocalizedStringKey(card.title), subtitle: LocalizedStringKey(card.subtitle)) {
                    TagCloud(card.tags.map { LocalizedStringKey($0) })
                }
            }
            PageDots(CarouselCard.all.map(\.id), selection: $selection, pageLabel: { Text("Page \($0) of \($1)") })
        }
        .padding(.vertical, Space.extraLarge)
        .background { Backdrop(.waves()) }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}
