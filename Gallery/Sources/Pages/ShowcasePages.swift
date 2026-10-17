import SwiftUI
import Vitral
import VitralTokens

/// Every backdrop the Gallery can put glass on: the patterns and materials, every texture, and
/// the wallpapers.
enum BackdropCatalogue {
    struct Entry: Sendable {
        let name: String
        let style: BackdropStyle
    }

    struct Shelf: Sendable {
        let title: String
        let entries: [Entry]
    }

    nonisolated static let shelves: [Shelf] =
        [Shelf(title: "Patterns and materials", entries: BackdropsPage.samples.map { Entry(name: $0.name, style: $0.style) })]
            + Texture.Family.allCases.map { family in
                Shelf(
                    title: family.rawValue,
                    entries: Texture.allCases.filter { $0.family == family }.map { Entry(name: "texture(.\($0.rawValue))", style: .texture($0)) }
                )
            }
            + [Shelf(title: "Wallpapers", entries: Wallpaper.all.map { Entry(name: $0.showcaseName, style: $0.backdrop) })]

    nonisolated static let all = shelves.flatMap(\.entries)

    static func style(named name: String) -> BackdropStyle {
        all.first { $0.name == name }?.style ?? .plain
    }
}

/// Where a backdrop's glass showcase is, in the navigation.
struct GlassShowcaseRoute: Hashable {
    let name: String
}

/// Every backdrop, one row each, leading to its showcase.
struct GlassEverywherePage: View {
    var body: some View {
        Page("Glass everywhere") {
            ForEach(BackdropCatalogue.shelves, id: \.title) { shelf in
                LabelledGroup(LocalizedStringKey(shelf.title)) {
                    PanelList {
                        ForEach(shelf.entries, id: \.name) { entry in
                            NavigationLink(value: GlassShowcaseRoute(name: entry.name)) {
                                Row(LocalizedStringKey(entry.name), showsDisclosure: true) {
                                    Backdrop(entry.style)
                                        .frame(width: Size.hitTarget, height: Size.hitTarget)
                                        .clipShape(RoundedRectangle(cornerRadius: Radius.small, style: .continuous))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

/// One backdrop under the same components at every glass, from clear to regular.
struct GlassShowcasePage: View {
    let route: GlassShowcaseRoute

    var body: some View {
        Page(LocalizedStringKey(route.name), backdrop: BackdropCatalogue.style(named: route.name)) {
            ForEach(MaterialsPage.ladder, id: \.name) { rung in
                LabelledGroup(LocalizedStringKey(rung.name)) {
                    GlassSampler()
                }
                .glassMaterial(rung.token)
            }
        }
    }
}

/// A handful of components that take the environment's glass: a list, a field, a segmented
/// control, and the buttons beside them.
struct GlassSampler: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.medium) {
            PanelList {
                Row("Inhalation", subtitle: "Twelve compartments", detail: Text(verbatim: "3.2 Bq"))
                ToggleSwitch("Show grid", isOn: .constant(true)).padding(.horizontal, Space.large)
            }
            FieldText("Activity", text: .constant("3.2"), suffix: Text(verbatim: "Bq"))
            SegmentedControlGlass(
                selection: .constant(1),
                options: [ChoiceOption(0, title: "Day"), ChoiceOption(1, title: "Week"), ChoiceOption(2, title: "Month")]
            )
            HStack(spacing: Space.medium) {
                ButtonPrimary("Save") {}
                ButtonSecondary("Cancel") {}
            }
        }
    }
}

/// Components forced light and forced dark side by side, whatever the system or the Gallery's
/// switch says.
struct AppearancePage: View {
    var body: some View {
        Page("Appearance") {
            LabelledGroup("AppearancePicker") {
                AppearancePicker(selection: .constant(.system))
            }
            ForEach([Appearance.light, .dark], id: \.self) { appearance in
                LabelledGroup(LocalizedStringKey(".appearance(.\(appearance.rawValue))")) {
                    VStack(spacing: Space.medium) {
                        AppearanceSample(backdrop: .texture(.wood))
                        AppearanceSample(backdrop: .waves())
                    }
                    .appearance(appearance)
                }
            }
        }
    }
}

/// Glass components on a backdrop: what an appearance override has to reach (token colours, an
/// asset image with a dark variant, and glass).
struct AppearanceSample: View {
    let backdrop: BackdropStyle

    var body: some View {
        VStack(alignment: .leading, spacing: Space.medium) {
            PanelList {
                Row("Inhalation", subtitle: "Twelve compartments", detail: Text(verbatim: "3.2 Bq"))
            }
            HStack(spacing: Space.medium) {
                ButtonPrimary("Save") {}
                ButtonSecondary("Cancel") {}
            }
        }
        .padding(Space.large)
        .background { Backdrop(backdrop) }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}

extension View {
    /// The Gallery's toolbar on every screen: the appearance switch.
    func galleryChrome(_ appearance: Binding<Appearance>) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AppearancePicker(selection: appearance)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
}
