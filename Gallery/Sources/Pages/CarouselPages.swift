import SwiftUI
import Vitral
import VitralTokens

/// One card of the samples: a material and what it's made of.
struct CarouselCard: Identifiable, Sendable {
    let id: Int
    let title: String
    let subtitle: String
    let backdrop: BackdropStyle

    static let all = [
        CarouselCard(id: 0, title: "Bus floor", subtitle: "Drawn in code", backdrop: .busFloor()),
        CarouselCard(id: 1, title: "Denim", subtitle: "A photo, tiled", backdrop: .texture(.denim)),
        CarouselCard(id: 2, title: "Waves", subtitle: "Generated", backdrop: .waves()),
        CarouselCard(id: 3, title: "Cherry", subtitle: "Mahogany at night", backdrop: .texture(.wood)),
        CarouselCard(id: 4, title: "Aurora", subtitle: "Starry at night", backdrop: .aurora())
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

struct CarouselSample: View {
    @Binding var selection: Int?
    let style: CarouselStyle

    var body: some View {
        VStack(spacing: Space.medium) {
            Carousel(CarouselCard.all, selection: $selection, style: style) { card in
                Card(LocalizedStringKey(card.title), subtitle: LocalizedStringKey(card.subtitle)) {
                    TagCloud(["Glass", "over", "the", "card"])
                }
                .padding(Space.large)
                .frame(height: 220)
                .background { Backdrop(card.backdrop) }
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
            .padding(.horizontal, -Space.large)
            PageDots(CarouselCard.all.map(\.id), selection: $selection)
        }
    }
}
