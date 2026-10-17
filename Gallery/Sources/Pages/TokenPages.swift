import SwiftUI
import Vitral
import VitralTokens

struct ColoursPage: View {
    private struct ColourGroup {
        let title: String
        let tokens: [(name: String, token: ColorToken)]
    }

    private static let groups: [ColourGroup] = [
        ColourGroup(title: "Ink", tokens: [("ink", .ink), ("inkMuted", .inkMuted), ("inkFaint", .inkFaint), ("onAccent", .onAccent)]),
        ColourGroup(title: "Accent", tokens: [("accent", .accent), ("accentTop", .accentTop), ("accentBottom", .accentBottom), ("accentGlow", .accentGlow)]),
        ColourGroup(
            title: "Counter-accent",
            tokens: [("counterAccent", .counterAccent), ("counterAccentTop", .counterAccentTop), ("counterAccentBottom", .counterAccentBottom), ("counterAccentGlow", .counterAccentGlow)]
        ),
        ColourGroup(
            title: "Fixed, the same in light and dark",
            tokens: [
                ("fixedBlack", .fixedBlack), ("fixedCharcoal", .fixedCharcoal), ("fixedWhite", .fixedWhite),
                ("fixedCream", .fixedCream), ("fixedGold", .fixedGold), ("fixedSilver", .fixedSilver)
            ]
        ),
        ColourGroup(title: "Tints", tokens: Tint.allCases.flatMap { [("\($0.rawValue).surface", $0.surface), ("\($0.rawValue).ink", $0.ink)] }),
        ColourGroup(title: "Feedback", tokens: [("info", .info), ("infoSurface", .infoSurface), ("success", .success), ("successSurface", .successSurface), ("warning", .warning), ("warningSurface", .warningSurface), ("danger", .danger), ("dangerSurface", .dangerSurface)]),
        ColourGroup(
            title: "Surfaces",
            tokens: [("neutralSurface", .neutralSurface), ("selectedSurface", .selectedSurface), ("backdrop", .backdrop), ("gridLine", .gridLine), ("gridLineMajor", .gridLineMajor), ("hairline", .hairline), ("outline", .outline)]
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
        ("controlSmall", .controlSmall), ("detail", .detail), ("value", .value), ("code", .code), ("codeSmall", .codeSmall),
        ("sectionLabel", .sectionLabel)
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
    /// From clear to regular, the veil the dial in between.
    nonisolated static let ladder: [(name: String, token: GlassToken)] = [
        ("clear", .clear),
        ("veiled(0.2)", .veiled(0.2)),
        ("veiled(0.45), the default", .veiled()),
        ("veiled(0.7)", .veiled(0.7)),
        ("regular", .regular)
    ]

    var body: some View {
        Page("Materials") {
            ForEach(MaterialLadder.backdrops, id: \.name) { backdrop in
                LabelledGroup(LocalizedStringKey("Over \(backdrop.name)")) {
                    MaterialLadder(backdrop: backdrop.style)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                }
            }
            LabelledGroup("active") {
                Panel(material: .active) { TagCloud(["Chosen", "glass"]) }
            }
        }
    }
}

/// Every rung from clear to regular, over one backdrop.
struct MaterialLadder: View {
    nonisolated static let backdrops: [(name: String, style: BackdropStyle)] = [("graph paper", .grid()), ("the bus floor", .busFloor()), ("wood", .wood)]

    let backdrop: BackdropStyle

    var body: some View {
        VStack(spacing: Space.small) {
            ForEach(MaterialsPage.ladder, id: \.name) { entry in
                Row(LocalizedStringKey(entry.name), subtitle: "Glass over the backdrop")
                    .glassSurface(entry.token, cornerRadius: Radius.medium)
            }
        }
        .padding(Space.medium)
        .background { Backdrop(backdrop) }
    }
}
