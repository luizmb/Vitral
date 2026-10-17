import SwiftUI
import Vitral
import VitralTokens

/// The Gallery's three shelves.
enum GallerySection: String, CaseIterable, Hashable {
    case tokens, resources, components

    var title: LocalizedStringKey {
        switch self {
        case .tokens: "Tokens"
        case .resources: "Resources"
        case .components: "Components"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .tokens: "The values everything is built from: colours, spacing, radii, sizes, type and glass."
        case .resources: "Icons and images that ship with Vitral."
        case .components: "Stateless SwiftUI views, small ones composed into bigger ones."
        }
    }

    var pages: [GalleryPage] {
        switch self {
        case .tokens: [.colours, .spacing, .radii, .sizes, .type, .materials]
        case .resources: [.icons, .images]
        case .components: [.buttons, .selection, .lists, .tags, .cards]
        }
    }

    /// A taste of each shelf for its card's header.
    var swatches: [ColorToken] {
        switch self {
        case .tokens: [.accent, .warning, .danger, .ink, .inkFaint]
        case .resources: [.inkMuted, .accentTop]
        case .components: [.accentBottom, .accentTop, .neutralSurface]
        }
    }
}

/// Every page of the Gallery.
enum GalleryPage: String, CaseIterable, Hashable {
    case colours, spacing, radii, sizes, type, materials
    case icons, images
    case buttons, selection, lists, tags, cards

    var title: LocalizedStringKey {
        switch self {
        case .colours: "Colours"
        case .spacing: "Spacing"
        case .radii: "Corner radii"
        case .sizes: "Sizes"
        case .type: "Type"
        case .materials: "Materials"
        case .icons: "Icons"
        case .images: "Images"
        case .buttons: "Buttons"
        case .selection: "Checkboxes and toggles"
        case .lists: "Panels and rows"
        case .tags: "Tags and swatches"
        case .cards: "Cards"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .colours: "Light and dark in one token"
        case .spacing: "Gaps and padding"
        case .radii: "Concentric corners"
        case .sizes: "Controls, marks and hairlines"
        case .type: "Dynamic Type styles"
        case .materials: "Regular, clear, tinted glass"
        case .icons: "Glyphs, by role"
        case .images: "Illustrations"
        case .buttons: "ButtonPrimary, ButtonSecondary"
        case .selection: "Checkbox, ToggleSwitch, SelectionMark"
        case .lists: "Panel, PanelList, Row, SectionLabel"
        case .tags: "Tag, TagCloud, Swatch, SwatchStack, Stat"
        case .cards: "Card, with header and footer"
        }
    }

    @ViewBuilder @MainActor
    var view: some View {
        switch self {
        case .colours: ColoursPage()
        case .spacing: SpacingPage()
        case .radii: RadiiPage()
        case .sizes: SizesPage()
        case .type: TypePage()
        case .materials: MaterialsPage()
        case .icons: IconsPage()
        case .images: ImagesPage()
        case .buttons: ButtonsPage()
        case .selection: SelectionPage()
        case .lists: ListsPage()
        case .tags: TagsPage()
        case .cards: CardsPage()
        }
    }
}

/// Identifiers UI tests find the Gallery's navigation by.
enum GalleryAccessibilityID {
    static func section(_ section: GallerySection) -> String { "gallery.section.\(section.rawValue)" }
    static func page(_ page: GalleryPage) -> String { "gallery.page.\(page.rawValue)" }
}
