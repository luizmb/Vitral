import SwiftUI
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
            Card("No images yet", subtitle: "Illustrations arrive with the error screen.")
        }
    }
}
