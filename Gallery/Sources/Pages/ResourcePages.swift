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
}

struct WallpapersPage: View {
    var body: some View {
        Page("Wallpapers") {
            ForEach(Wallpaper.all, id: \.name) { wallpaper in
                Card(LocalizedStringKey(wallpaper.title), subtitle: LocalizedStringKey(wallpaper.credit))
                    .padding(Space.extraLarge)
                    .padding(.vertical, Space.huge)
                    .background { Backdrop(wallpaper.backdrop) }
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
        }
    }
}

struct TexturesPage: View {
    var body: some View {
        Page("Textures") {
            ForEach(Texture.Family.allCases, id: \.self) { family in
                LabelledGroup(LocalizedStringKey(family.rawValue)) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: Space.small)], spacing: Space.small) {
                        ForEach(Texture.allCases.filter { $0.family == family }, id: \.self) { texture in
                            Tag(Text(verbatim: texture.rawValue))
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(maxWidth: .infinity, minHeight: 64, alignment: .bottomLeading)
                                .padding(Space.extraSmall)
                                .background { Backdrop(.texture(texture)) }
                                .clipShape(RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
                        }
                    }
                }
            }
        }
    }
}
