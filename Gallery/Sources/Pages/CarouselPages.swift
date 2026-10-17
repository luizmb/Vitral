import SwiftUI
import Vitral
import VitralTokens

/// One card of the samples.
struct CarouselCard: Identifiable, Sendable {
    let id: Int
    let title: String
    let subtitle: String
    let tags: [String]
    let art: BackdropStyle

    static let all = [
        CarouselCard(id: 0, title: "U-234 Inhalation", subtitle: "ICRP 137, Type S", tags: ["Nuclear", "Inhalation"], art: .aurora()),
        CarouselCard(id: 1, title: "Cs-137 Ingestion", subtitle: "ICRP 137", tags: ["Nuclear", "Ingestion"], art: .glow()),
        CarouselCard(id: 2, title: "I-131 Thyroid", subtitle: "Blocked with KI", tags: ["Iodine", "Thyroid"], art: .texture(.denim)),
        CarouselCard(id: 3, title: "Pu-239 Wound", subtitle: "NCRP 156", tags: ["Wound", "Actinide"], art: .busFloor(angle: .degrees(45))),
        CarouselCard(id: 4, title: "H-3 Water", subtitle: "Whole body", tags: ["Tritium"], art: .waves(.washTeal))
    ]
}

/// The carousel, sliding and flipping, each with its page dots.
struct CarouselPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Page("Carousel") {
            LabelledGroup("Carousel(style: .slide) and PageDots") {
                CarouselSample(selection: $model.carouselPage, style: .slide)
            }
            LabelledGroup("Carousel(style: .flip)") {
                CarouselSample(selection: $model.flipPage, style: .flip)
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
                .header {
                    // The artwork drifts behind the card as it pages: .parallaxLayer().
                    Backdrop(card.art)
                        .parallaxLayer()
                        .frame(height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
                }
            }
            PageDots(CarouselCard.all.map(\.id), selection: $selection)
        }
        .padding(.vertical, Space.extraLarge)
        .background { Backdrop(.waves()) }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}
