import SwiftUI
import Vitral
import VitralTokens

/// One icon of the samples: a song and its band.
struct DemoIcon: Identifiable, Sendable {
    let id: Int
    let title: String
    let subtitle: String

    static let titles = [
        "Highway to Hell", "Hells Bells", "Back in Black", "Crazy Train", "Paranoid", "Iron Man",
        "Ace of Spades", "Smoke on the Water", "Black Night", "Run to the Hills", "The Trooper",
        "Holy Diver", "Rainbow in the Dark", "Breaking the Law", "Painkiller", "Crazy", "Whole Lotta Love",
        "Kashmir", "Immigrant Song", "Children of the Grave"
    ]

    static let all = titles.enumerated().map { index, title in
        DemoIcon(id: index, title: title, subtitle: "Band \(index % 4 + 1)")
    }
}

/// A place in a grid: the add tile, or an icon.
enum DemoSlot: Identifiable, Sendable {
    case add
    case icon(DemoIcon)

    var id: Int {
        switch self {
        case .add: -1
        case let .icon(icon): icon.id
        }
    }
}

/// Icon groups: a folder with a header, dots and a footer; picking by holding; a bare grid.
struct IconGroupPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Page("Icon groups") {
            Sample("IconGroup with a header, page dots and a footer") {
                IconGroup(DemoIcon.all, page: $model.iconPage) { icon in
                    IconTile(
                        Text(verbatim: icon.title),
                        subtitle: Text(verbatim: icon.subtitle),
                        isPicked: model.pickedIcons.isEmpty ? nil : model.pickedIcons.contains(icon.id),
                        tap: { model.tapIcon(icon.id) },
                        hold: { model.pickIcon(icon.id) }
                    ) {
                        Monogram(icon.title)
                    }
                } header: {
                    HStack {
                        Text(model.pickedIcons.isEmpty ? "Classics" : "\(model.pickedIcons.count) picked").font(.title)
                        Spacer()
                        if !model.pickedIcons.isEmpty {
                            ButtonSecondary("Done", size: .small) { model.pickedIcons = [] }
                        }
                    }
                } footer: {
                    Text("\(DemoIcon.all.count) songs. Hold one to pick.")
                        .font(.detail)
                        .foregroundStyle(.inkMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Sample("IconTileAdd first, four across, two rows, no dots") {
                IconGroup(
                    [DemoSlot.add] + DemoIcon.all.prefix(7).map(DemoSlot.icon),
                    page: .constant(0),
                    columns: 4,
                    rows: 2,
                    showsPageControl: false
                ) { slot in
                    switch slot {
                    case .add:
                        IconTileAdd(Text("Add"), action: {})
                    case let .icon(icon):
                        IconTile(Text(verbatim: icon.title), tap: {}) {
                            Monogram(icon.title)
                        }
                    }
                }
            }
        }
    }
}
