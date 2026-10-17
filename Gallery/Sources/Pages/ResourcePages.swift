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
