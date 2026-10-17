import SwiftUI
import UIKit
import Vitral
import VitralTokens

struct IconsPage: View {
    var body: some View {
        Page("Icons") {
            PanelList {
                ForEach(Glyph.allCases, id: \.self) { glyph in
                    Row(LocalizedStringKey(String(describing: glyph)), detail: Text(verbatim: glyph.rawValue)) {
                        Image(glyph)
                            .font(.body)
                            .foregroundStyle(.accent)
                            .frame(width: Size.controlSmall)
                    }
                }
            }
        }
    }
}

struct ImagesPage: View {
    var body: some View {
        Page("Images") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: Space.large)], spacing: Space.large) {
                ForEach(Illustration.allCases, id: \.self) { illustration in
                    LabelledGroup(LocalizedStringKey(String(describing: illustration))) {
                        Panel { IllustrationView(illustration).frame(maxWidth: .infinity) }
                    }
                }
            }
        }
    }
}

/// One photo from the repository's `Wallpapers` folder, with its credit (see
/// `Wallpapers/CREDITS.md`).
struct Wallpaper: Sendable {
    let name: String
    let title: String
    let credit: String

    nonisolated static let all = [
        Wallpaper(name: "earthrise", title: "Earthrise", credit: "Apollo 8 crew, NASA, public domain"),
        Wallpaper(name: "blueMarble", title: "The Blue Marble", credit: "Apollo 17 crew, NASA, public domain"),
        Wallpaper(name: "aurora", title: "Earth's limb with an aurora", credit: "Expedition 58 crew, NASA, public domain"),
        Wallpaper(name: "orbitalSunrise", title: "An orbital sunrise", credit: "Expedition 71 crew, NASA, public domain")
    ]

    var image: Image {
        Image(uiImage: UIImage(named: "\(name).jpg") ?? UIImage())
    }

    var backdrop: BackdropStyle {
        .image(image)
    }

    /// Its name in the glass showcase, apart from the backdrops' (there's an aurora of each).
    var showcaseName: String { "wallpaper(\(name))" }
}

struct WallpapersPage: View {
    var body: some View {
        Page("Wallpapers") {
            ForEach(Wallpaper.all, id: \.name) { wallpaper in
                NavigationLink(value: GlassShowcaseRoute(name: wallpaper.showcaseName)) {
                    Card(LocalizedStringKey(wallpaper.title), subtitle: LocalizedStringKey(wallpaper.credit))
                        .padding(Space.extraLarge)
                        .padding(.vertical, Space.huge)
                        .background { Backdrop(wallpaper.backdrop) }
                        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Every material, by family: the texture images, and beside them the materials Vitral draws in
/// code (named with a dot, as their `BackdropStyle` case is).
struct TexturesPage: View {
    struct Tile: Sendable {
        let name: String
        let showcase: String
        let style: BackdropStyle
    }

    struct Shelf: Sendable {
        let title: String
        let tiles: [Tile]
    }

    nonisolated static let drawn: [Texture.Family: [Tile]] = [
        .woods: [Tile(name: ".wood", showcase: "wood", style: .wood)],
        .metals: [Tile(name: ".busFloor", showcase: "busFloor", style: .busFloor), Tile(name: ".brushedMetal", showcase: "brushedMetal", style: .brushedMetal)]
    ]

    nonisolated static let shelves: [Shelf] =
        Texture.Family.allCases.map { family in
            Shelf(
                title: family.rawValue,
                tiles: (drawn[family] ?? [])
                    + Texture.allCases.filter { $0.family == family }.map { Tile(name: $0.rawValue, showcase: "texture(.\($0.rawValue))", style: .texture($0)) }
            )
        }
            + [Shelf(title: "paper", tiles: [Tile(name: ".paper", showcase: "paper", style: .paper)])]

    var body: some View {
        Page("Textures") {
            ForEach(Self.shelves, id: \.title) { shelf in
                LabelledGroup(LocalizedStringKey(shelf.title)) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: Space.small)], spacing: Space.small) {
                        ForEach(shelf.tiles, id: \.name) { tile in
                            NavigationLink(value: GlassShowcaseRoute(name: tile.showcase)) {
                                TextureTile(name: tile.name, style: tile.style)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

/// A material's swatch, with its name on a tag.
struct TextureTile: View {
    let name: String
    let style: BackdropStyle

    var body: some View {
        Tag(Text(verbatim: name))
            .font(.caption2)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .bottomLeading)
            .padding(Space.extraSmall)
            .background { Backdrop(style) }
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
            // The backdrop doesn't take touches, so the whole tile is made the target.
            .contentShape(RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
    }
}
