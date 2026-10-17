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
        case .resources: "Icons and images that ship with Vitral, and wallpapers an app can take."
        case .components: "Stateless SwiftUI views, small ones composed into bigger ones."
        }
    }

    var pages: [GalleryPage] {
        switch self {
        case .tokens: [.colours, .spacing, .radii, .sizes, .type, .materials]
        case .resources: [.icons, .images, .textures, .wallpapers]
        case .components: [.glassEverywhere, .appearance, .backdrops, .buttons, .selection, .pickers, .fields, .banners, .lists, .tags, .cards, .emptyStates, .progress]
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
    case icons, images, textures, wallpapers
    case glassEverywhere, appearance, backdrops, buttons, selection, pickers, fields, banners, lists, tags, cards, emptyStates, progress

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
        case .textures: "Textures"
        case .wallpapers: "Wallpapers"
        case .glassEverywhere: "Glass everywhere"
        case .appearance: "Appearance"
        case .backdrops: "Backdrops"
        case .buttons: "Buttons"
        case .selection: "Checkboxes and toggles"
        case .pickers: "Pickers"
        case .fields: "Fields"
        case .banners: "Banners"
        case .lists: "Panels and rows"
        case .tags: "Tags and swatches"
        case .cards: "Cards"
        case .emptyStates: "Empty and error states"
        case .progress: "Progress"
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
        case .images: "Illustrations for empty and error states"
        case .textures: "Woods, stones, fabrics and metal, tiled"
        case .wallpapers: "Photos an app copies in; not in the library"
        case .glassEverywhere: "Every backdrop under every glass"
        case .appearance: "AppearancePicker, .appearance(_:)"
        case .backdrops: "Patterns, materials, textures, mesh"
        case .buttons: "ButtonPrimary, ButtonSecondary, ActionBar"
        case .pickers: "SegmentedControlGlass, RadioList, StepperJump"
        case .fields: "FieldText, FieldSecure, FieldSearch"
        case .banners: "Banner, in three tones"
        case .selection: "Checkbox, ToggleSwitch, SelectionMark"
        case .lists: "Panel, PanelList, Row, SectionLabel"
        case .tags: "Tag, TagToggle, TagCloud, Swatch, SwatchStack, Stat"
        case .cards: "Card, with header and footer; CardAdd"
        case .emptyStates: "EmptyState, ErrorScreen"
        case .progress: "ProgressOverlay"
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
        case .textures: TexturesPage()
        case .wallpapers: WallpapersPage()
        case .glassEverywhere: GlassEverywherePage()
        case .appearance: AppearancePage()
        case .backdrops: BackdropsPage()
        case .buttons: ButtonsPage()
        case .selection: SelectionPage()
        case .pickers: PickersPage()
        case .fields: FieldsPage()
        case .banners: BannersPage()
        case .lists: ListsPage()
        case .tags: TagsPage()
        case .cards: CardsPage()
        case .emptyStates: EmptyStatesPage()
        case .progress: ProgressPage()
        }
    }
}

/// Identifiers UI tests find the Gallery's navigation by.
enum GalleryAccessibilityID {
    static func section(_ section: GallerySection) -> String { "gallery.section.\(section.rawValue)" }
    static func page(_ page: GalleryPage) -> String { "gallery.page.\(page.rawValue)" }
}
