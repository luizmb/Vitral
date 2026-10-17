import SwiftUI
import Vitral
import VitralTokens

struct ColoursPage: View {
    private struct ColourGroup {
        let title: String
        let tokens: [(name: String, token: ColorToken)]
    }

    private static let groups = [
        ColourGroup(title: "Ink", tokens: [("ink", .ink), ("inkMuted", .inkMuted), ("inkFaint", .inkFaint), ("onAccent", .onAccent)]),
        ColourGroup(title: "Accent", tokens: [("accent", .accent), ("accentTop", .accentTop), ("accentBottom", .accentBottom), ("accentGlow", .accentGlow)]),
        ColourGroup(title: "Feedback", tokens: [("warning", .warning), ("warningSurface", .warningSurface), ("danger", .danger), ("dangerSurface", .dangerSurface)]),
        ColourGroup(
            title: "Surfaces",
            tokens: [("neutralSurface", .neutralSurface), ("selectedSurface", .selectedSurface), ("backdrop", .backdrop), ("hairline", .hairline), ("outline", .outline)]
        )
    ]

    var body: some View {
        Page("Colours") {
            ForEach(Self.groups, id: \.title) { group in
                LabelledGroup(LocalizedStringKey(group.title)) {
                    PanelList {
                        ForEach(group.tokens, id: \.name) { entry in
                            ColourRow(name: entry.name, token: entry.token)
                        }
                    }
                }
            }
        }
    }
}

private struct ColourRow: View {
    let name: String
    let token: ColorToken

    var body: some View {
        Row(LocalizedStringKey(name), detail: Text(verbatim: "\(token.light.hexString) / \(token.dark.hexString)")) {
            Swatch(token, diameter: Size.controlSmall)
        }
    }
}

extension RGBA {
    /// `#RRGGBB`, with the opacity after it when it isn't opaque.
    var hexString: String {
        [red, green, blue].reduce("#") { hex, component in hex + String(format: "%02X", Int((component * 255).rounded())) }
            + (alpha < 1 ? " \(Int((alpha * 100).rounded()))%" : "")
    }
}

/// Rows of named measures, each value in points.
private struct MeasurePage: View {
    let title: LocalizedStringKey
    let entries: [(name: String, value: Double)]

    var body: some View {
        Page(title) {
            PanelList {
                ForEach(entries, id: \.name) { entry in
                    Row(LocalizedStringKey(entry.name), detail: Text("\(entry.value.formatted()) pt"))
                }
            }
        }
    }
}

struct SpacingPage: View {
    var body: some View {
        MeasurePage(title: "Spacing", entries: [
            ("hairline", Space.hairline), ("extraSmall", Space.extraSmall), ("small", Space.small), ("medium", Space.medium),
            ("large", Space.large), ("extraLarge", Space.extraLarge), ("huge", Space.huge)
        ])
    }
}

struct SizesPage: View {
    var body: some View {
        MeasurePage(title: "Sizes", entries: [
            ("hitTarget", Size.hitTarget), ("controlSmall", Size.controlSmall), ("controlMedium", Size.controlMedium),
            ("controlLarge", Size.controlLarge), ("selectionMark", Size.selectionMark), ("swatch", Size.swatch), ("hairline", Size.hairline)
        ])
    }
}

struct RadiiPage: View {
    private static let entries: [(name: String, value: Double)] = [
        ("extraSmall", Radius.extraSmall), ("small", Radius.small), ("medium", Radius.medium),
        ("large", Radius.large), ("card", Radius.card), ("sheet", Radius.sheet)
    ]

    var body: some View {
        Page("Corner radii") {
            PanelList {
                ForEach(Self.entries, id: \.name) { entry in
                    Row(LocalizedStringKey(entry.name), detail: Text("\(entry.value.formatted()) pt")) {
                        Panel(material: .active, cornerRadius: entry.value, padding: 0) { EmptyView() }
                            .frame(width: Size.controlLarge, height: Size.controlLarge)
                    }
                    .padding(.vertical, Space.extraSmall)
                }
            }
        }
    }
}

struct TypePage: View {
    private static let entries: [(name: String, token: TypeToken)] = [
        ("title", .title), ("body", .body), ("bodyStrong", .bodyStrong), ("control", .control),
        ("controlSmall", .controlSmall), ("detail", .detail), ("value", .value), ("sectionLabel", .sectionLabel)
    ]

    var body: some View {
        Page("Type") {
            ForEach(Self.entries, id: \.name) { entry in
                LabelledGroup(LocalizedStringKey(entry.name)) {
                    Panel {
                        Text("Glass, pieced together: 1,234.5")
                            .font(entry.token)
                            .foregroundStyle(.ink)
                    }
                }
            }
        }
    }
}

struct MaterialsPage: View {
    private static let entries: [(name: String, token: GlassToken)] = [
        ("regular", .regular), ("clear", .clear), ("active", .active), ("regular, tinted warning", GlassToken.regular.tinted(.warningSurface))
    ]

    var body: some View {
        Page("Materials") {
            ForEach(Self.entries, id: \.name) { entry in
                LabelledGroup(LocalizedStringKey(entry.name)) {
                    Panel(material: entry.token) {
                        TagCloud(["Glass", "over", "the", "backdrop"])
                    }
                }
            }
        }
    }
}
