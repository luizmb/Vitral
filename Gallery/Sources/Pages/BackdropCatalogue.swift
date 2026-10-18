import SwiftUI
import Vitral
import VitralTokens

/// Every backdrop the Gallery shows, on shelves: textures (anything that repeats, a picture or
/// drawn, by glass) and wallpapers (anything that fills the screen once, generated or a photo).
/// Backdrops are the two together.
enum BackdropCatalogue {
    struct Entry: Sendable {
        /// What the tile says: drawn ones by their `BackdropStyle` case, with a dot.
        let title: String
        /// The showcase's and the snapshot's name.
        let key: String
        let style: BackdropStyle

        /// Drawn in code (it costs the app nothing), or a picture.
        var isDrawn: Bool {
            switch style {
            case .texture, .image: false
            default: true
            }
        }
    }

    struct Shelf: Sendable {
        let title: String
        let entries: [Entry]
    }

    nonisolated static let drawnIcon = "pencil"
    nonisolated static let pictureIcon = "photo"

    /// The materials Vitral draws, by the family of textures they sit with.
    nonisolated static let drawnMaterials: [Texture.Family: [Entry]] = [
        .woods: [Entry(title: ".wood", key: "wood", style: .wood)],
        .metals: [
            Entry(title: ".busFloor", key: "busFloor", style: .busFloor()),
            Entry(title: ".busFloor(45°)", key: "busFloor(45°)", style: .busFloor(angle: .degrees(45))),
            Entry(title: ".brushedMetal", key: "brushedMetal", style: .brushedMetal)
        ]
    ]

    /// Everything that repeats, by glass.
    nonisolated static let textures: [Shelf] =
        Texture.Family.allCases.map { family in
            Shelf(
                title: family.rawValue,
                entries: (drawnMaterials[family] ?? [])
                    + Texture.allCases.filter { $0.family == family }.map { Entry(title: $0.rawValue, key: "texture(.\($0.rawValue))", style: .texture($0)) }
            )
        }
            + [
                Shelf(title: "paper", entries: [
                    Entry(title: ".grid", key: "grid", style: .grid()),
                    Entry(title: ".grid, zoomed out", key: "grid, zoomed out", style: .grid(scale: 0.3)),
                    Entry(title: ".dots", key: "dots", style: .dots()),
                    Entry(title: ".guilloche", key: "guilloche", style: .guilloche()),
                    Entry(title: ".paper", key: "paper", style: .paper)
                ])
            ]

    /// What fills the screen once instead of repeating.
    nonisolated static let wallpapers: [Shelf] = [
        Shelf(title: "generated", entries: [
            Entry(title: ".mesh", key: "mesh", style: .mesh([.accent, .warning, .success, .danger])),
            Entry(title: ".aurora", key: "aurora", style: .aurora()),
            Entry(title: ".aurora, warm", key: "aurora, warm", style: .aurora([.washPink, .washAmber, .washViolet])),
            Entry(title: ".glow", key: "glow", style: .glow()),
            Entry(title: ".glow, sunset", key: "glow, sunset", style: .glow([.washAmber, .washPink, .danger])),
            Entry(title: ".waves", key: "waves", style: .waves()),
            Entry(title: ".waves, violet", key: "waves, violet", style: .waves(.washViolet)),
            Entry(title: ".laser", key: "laser", style: .laser()),
            Entry(title: ".laser, violet", key: "laser, violet", style: .laser([.washViolet, .washPink])),
            Entry(title: ".contours", key: "contours", style: .contours()),
            Entry(title: ".contours, dusk", key: "contours, dusk", style: .contours([.washViolet, .washPink, .washAmber, .washViolet])),
            Entry(title: ".fractal", key: "fractal", style: .fractal()),
            Entry(title: ".fractal, ember", key: "fractal, ember", style: .fractal([.fixedBlack, .counterAccent, .washAmber, .fixedCream]))
        ]),
        Shelf(title: "photos", entries: Wallpaper.all.map { Entry(title: $0.name, key: $0.showcaseName, style: $0.backdrop) }),
        Shelf(title: "plain", entries: [Entry(title: ".plain", key: "plain", style: .plain)])
    ]

    nonisolated static let all = (textures + wallpapers).flatMap(\.entries)

    /// The keys of everything drawn in code.
    nonisolated static let drawn = all.filter(\.isDrawn).map(\.key)

    static func style(named key: String) -> BackdropStyle {
        all.first { $0.key == key }?.style ?? .plain
    }
}

/// Every repeating pattern, a picture or drawn, by glass.
struct TexturesPage: View {
    var body: some View {
        Page("Textures") {
            BackdropKey()
            BackdropShelves(shelves: BackdropCatalogue.textures, tileHeight: 64)
        }
    }
}

/// Every wallpaper, generated or a photo, and who took the photos.
struct WallpapersPage: View {
    var body: some View {
        Page("Wallpapers") {
            BackdropKey()
            BackdropShelves(shelves: BackdropCatalogue.wallpapers, tileHeight: 150)
            Sample("Credits") {
                PanelList {
                    ForEach(Wallpaper.all, id: \.name) { wallpaper in
                        Row(LocalizedStringKey(wallpaper.title), subtitle: LocalizedStringKey(wallpaper.credit))
                    }
                }
            }
        }
    }
}

/// Every backdrop: the textures and the wallpapers.
struct BackdropsPage: View {
    var body: some View {
        Page("Backdrops") {
            BackdropKey()
            BackdropShelves(shelves: BackdropCatalogue.textures, tileHeight: 64)
            BackdropShelves(shelves: BackdropCatalogue.wallpapers, tileHeight: 150)
        }
    }
}

/// What the two badges mean.
struct BackdropKey: View {
    var body: some View {
        Banner(Text("\(Image(systemName: BackdropCatalogue.drawnIcon)) drawn in code, free to ship. \(Image(systemName: BackdropCatalogue.pictureIcon)) a picture, 10 to 75 KB a texture, more for a photo."))
    }
}

/// Shelves of tiles, each leading to its glass showcase.
struct BackdropShelves: View {
    let shelves: [BackdropCatalogue.Shelf]
    let tileHeight: Double

    var body: some View {
        ForEach(shelves, id: \.title) { shelf in
            LabelledGroup(LocalizedStringKey(shelf.title)) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: tileHeight), spacing: Space.small)], spacing: Space.small) {
                    ForEach(shelf.entries, id: \.key) { entry in
                        NavigationLink(value: GlassShowcaseRoute(name: entry.key)) {
                            BackdropTile(entry: entry, height: tileHeight)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

/// A backdrop's swatch, with its name on a tag and a badge for how it's made.
struct BackdropTile: View {
    let entry: BackdropCatalogue.Entry
    let height: Double

    var body: some View {
        Tag(Text(verbatim: entry.title))
            .font(.caption2)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, minHeight: height, alignment: .bottomLeading)
            .overlay(alignment: .topTrailing) {
                Image(systemName: entry.isDrawn ? BackdropCatalogue.drawnIcon : BackdropCatalogue.pictureIcon)
                    .font(.caption2)
                    .foregroundStyle(.inkMuted)
                    .padding(Space.extraSmall)
                    .glassCapsule()
            }
            .padding(Space.extraSmall)
            .background { Backdrop(entry.style) }
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
            // The backdrop doesn't take touches, so the whole tile is made the target.
            .contentShape(RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
    }
}
