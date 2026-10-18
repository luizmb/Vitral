import SwiftUI
import Vitral
import VitralTokens

/// The Gallery's shelves: the tokens and resources, then the components by what they're for.
enum GallerySection: String, CaseIterable, Hashable {
    case tokens, resources, surfaces, controls, collections, feedback, layout

    var title: LocalizedStringKey {
        switch self {
        case .tokens: "Tokens"
        case .resources: "Resources"
        case .surfaces: "Surfaces"
        case .controls: "Controls"
        case .collections: "Collections"
        case .feedback: "Feedback"
        case .layout: "Layout and content"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .tokens: "The values everything is built from: colours, spacing, radii, sizes, type and glass."
        case .resources: "Icons and images that ship with Vitral, and wallpapers an app can take."
        case .surfaces: "What things are made of and sit on: glass, finishes, tints, backdrops, overlays."
        case .controls: "What a finger changes: buttons, toggles, pickers, fields, knobs, faders."
        case .collections: "Many things at once: lists, cards, icon groups, carousels, tags."
        case .feedback: "What the app says back: banners, empty and error states, progress."
        case .layout: "How a screen is laid out, and code on it."
        }
    }

    var pages: [GalleryPage] {
        switch self {
        case .tokens: [.colours, .spacing, .radii, .sizes, .type, .materials]
        case .resources: [.icons, .images, .textures, .wallpapers]
        case .surfaces: [.finishes, .tints, .appearance, .backdrops, .overlays]
        case .controls: [.buttons, .selection, .pickers, .fields, .knobs, .faders]
        case .collections: [.lists, .glassList, .cards, .iconGroups, .carousel, .tags, .conversation]
        case .feedback: [.banners, .emptyStates, .progress]
        case .layout: [.workspace, .code]
        }
    }

    /// A taste of each shelf for its card's header.
    var swatches: [ColorToken] {
        switch self {
        case .tokens: [.accent, .warning, .danger, .ink, .inkFaint]
        case .resources: [.inkMuted, .accentTop]
        case .surfaces: [.washTeal, .washViolet, .washPink]
        case .controls: [.accent, .counterAccent]
        case .collections: [.washAmber, .washGreen, .washTeal, .washViolet]
        case .feedback: [.info, .success, .warning, .danger]
        case .layout: [.neutralSurface, .ink]
        }
    }
}

/// Every page of the Gallery.
enum GalleryPage: String, CaseIterable, Hashable {
    case colours, spacing, radii, sizes, type, materials
    case icons, images, textures, wallpapers
    case appearance, tints, finishes, code, carousel, iconGroups, glassList, conversation, knobs, faders, backdrops, buttons, selection, pickers, fields, banners, lists, tags, cards, emptyStates, progress, overlays, workspace

    var title: LocalizedStringKey {
        switch self {
        case .colours: "Colours"
        case .spacing: "Spacing"
        case .radii: "Corner radii"
        case .sizes: "Sizes"
        case .type: "Type"
        case .materials: "Glass"
        case .icons: "Icons"
        case .images: "Images"
        case .textures: "Textures"
        case .wallpapers: "Wallpapers"
        case .appearance: "Appearance"
        case .tints: "Tints and accents"
        case .finishes: "Finishes"
        case .code: "Code"
        case .carousel: "Carousel"
        case .iconGroups: "Icon groups"
        case .conversation: "Conversation"
        case .glassList: "GlassList"
        case .knobs: "Knobs"
        case .faders: "Faders"
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
        case .overlays: "Overlays"
        case .workspace: "Workspace"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .colours: "Light and dark in one token"
        case .spacing: "Gaps and padding"
        case .radii: "Concentric corners"
        case .sizes: "Controls, marks and hairlines"
        case .type: "Dynamic Type styles"
        case .materials: "GlassToken: regular, clear, sheer, veiled, tinted"
        case .icons: "Glyphs, by role"
        case .images: "Illustrations for empty and error states"
        case .textures: "Every repeating pattern, by glass"
        case .wallpapers: "Full-size: generated, and photos an app copies in"
        case .appearance: "AppearancePicker, .appearance(_:)"
        case .tints: "Tint, .accent(.counter)"
        case .finishes: "FinishToken: glass, a fill, a sheen"
        case .code: "CodeBlock, SyntaxTheme, .code"
        case .carousel: "Carousel, PageDots, SegmentedPages"
        case .iconGroups: "IconGroup, IconTile, IconTileAdd: a home screen's folder"
        case .conversation: "MessageBubble, Composer"
        case .glassList: "GlassList, GlassSection (edge to edge or padded), Row, RowAction"
        case .knobs: "Knob, GlassKnobStyle, JogDial"
        case .faders: "Fader, GlassFaderStyle, ConsoleFaderStyle"
        case .backdrops: "Textures and wallpapers together"
        case .buttons: "ButtonPrimary, ButtonSecondary, ActionBar"
        case .pickers: "SegmentedControlGlass, RadioList, StepperJump"
        case .fields: "FieldText, FieldSecure, FieldSearch"
        case .banners: "Banner, in three tones"
        case .selection: "Checkbox, ToggleSwitch, SelectionMark"
        case .lists: "Panel, PanelList, Row, SectionLabel"
        case .tags: "Tag, TagToggle, TagCloud, Swatch, SwatchStack, Stat"
        case .cards: "Card, with header and footer; CardAdd"
        case .emptyStates: "EmptyState, ErrorScreen"
        case .progress: "ProgressPanel, .progressOverlay"
        case .overlays: "Overlay: glass over what's behind"
        case .workspace: "Panels beside the content, Xcode's way"
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
        case .materials: GlassPage()
        case .icons: IconsPage()
        case .images: ImagesPage()
        case .textures: TexturesPage()
        case .wallpapers: WallpapersPage()
        case .appearance: AppearancePage()
        case .tints: TintsPage()
        case .finishes: FinishesPage()
        case .code: CodePage()
        case .carousel: CarouselPage()
        case .iconGroups: IconGroupPage()
        case .conversation: ConversationPage()
        case .glassList: GlassListPage()
        case .knobs: KnobsPage()
        case .faders: FadersPage()
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
        case .overlays: OverlaysPage()
        case .workspace: WorkspacePage()
        }
    }
}

/// Identifiers UI tests find the Gallery's navigation by.
enum GalleryAccessibilityID {
    static func section(_ section: GallerySection) -> String { "gallery.section.\(section.rawValue)" }
    static func page(_ page: GalleryPage) -> String { "gallery.page.\(page.rawValue)" }
}
