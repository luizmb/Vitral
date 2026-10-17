import SwiftUI
import UIKit
import Vitral
import VitralTokens

struct IconsPage: View {
    var body: some View {
        Page("Icons") {
            Banner("Every glyph is an SF Symbol, named by its role. Anywhere Vitral takes an icon, any SF Symbol works: Image(systemName:).")
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
            Banner("Vitral ships these illustrations. Anywhere it takes artwork, any SF Symbol works too: EmptyState(title, icon: Image(systemName:)).")
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


