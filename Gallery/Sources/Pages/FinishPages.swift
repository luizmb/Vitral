import SwiftUI
import Vitral
import VitralTokens

/// Every finish, on buttons and fader thumbs; Aqua's layers over each; and a whole group in
/// Aqua's gel from one `controlFinish`.
struct FinishesPage: View {
    static let finishes: [(name: String, finish: FinishToken)] = [
        ("glass", .glass()),
        ("solid", .solid(.accent)),
        ("gradient", .gradient([.washViolet, .washPink])),
        ("texture", .texture(.denim)),
        ("chrome", .chrome),
        ("aqua", .aqua(.accent)),
        ("aqua, graphite", .aqua(.fixedSilver))
    ]

    static let layered: [(name: String, finish: FinishToken)] = [
        ("glass(.clear).sheen(.aqua(0.4))", .glass(.clear).sheen(.aqua(0.4))),
        ("solid.sheen(.aqua())", .solid(.washGreen).sheen(.aqua())),
        ("gradient.sheen(gloss: 1)", .gradient([.washAmber, .counterAccent]).sheen(gloss: 1)),
        ("texture.sheen(gloss: 1, rim: 1)", .texture(.wood).sheen(gloss: 1, rim: 1))
    ]

    /// The dials: how clear the glass is, how tinted, how much is mixed over it, how strong the
    /// gel is.
    static let levels: [(name: String, finish: FinishToken)] = [
        ("glass(.regular)", .glass(.regular)),
        ("glass(.clear)", .glass(.clear)),
        ("glass(.sheer)", .glass(.sheer)),
        ("clear, accent 0.3", .glass(GlassToken(.clear, tint: ColorToken.accent.opacity(0.3)))),
        ("aqua.onGlass(amount: 0.15)", .aqua(.accent).onGlass(.clear, amount: 0.15)),
        ("aqua.onGlass(amount: 0.4)", .aqua(.accent).onGlass(.clear, amount: 0.4)),
        ("texture.onGlass(amount: 0.3)", .texture(.denim).onGlass(.clear, amount: 0.3)),
        ("gradient.onGlass(amount: 0.5)", .gradient([.washViolet, .washPink]).onGlass(.clear, amount: 0.5)),
        ("glass(.clear).sheen(.aqua(0.2))", .glass(.clear).sheen(.aqua(0.2))),
        ("glass(.clear).sheen(.aqua(0.6))", .glass(.clear).sheen(.aqua(0.6)))
    ]

    @Environment(GalleryModel.self) private var model

    var body: some View {
        Page("Finishes", backdrop: .glow()) {
            Sample("FinishToken, on ButtonPrimary(finish:)") {
                FinishGrid(finishes: Self.finishes)
            }
            Sample("A sheen over anything: .sheen(.aqua(_:)), .sheen(gloss:glow:rim:)") {
                FinishGrid(finishes: Self.layered)
            }
            Sample("Levels: clearance, tint, .onGlass(_:amount:), sheen strength") {
                FinishGrid(finishes: Self.levels)
            }
            Sample("No finish: the system's glass") {
                Panel {
                    HStack(spacing: Space.medium) {
                        ButtonPrimary("Save") {}
                        ButtonSecondary("Cancel") {}
                    }
                }
            }
            Sample(".controlFinish(.glass(.clear).sheen(.aqua(0.25))): clearer, the primary tinted") {
                Panel {
                    HStack(spacing: Space.medium) {
                        ButtonPrimary("Save") {}
                        ButtonSecondary("Cancel") {}
                    }
                }
                .controlFinish(.glass(.clear).sheen(.aqua(0.25)))
            }
            Sample("Fader thumbs and fills") {
                Panel {
                    VStack(spacing: Space.large) {
                        Fader(value: model.fader("finishGlass", 0.4), format: model.formats.number(2), title: Text(verbatim: "glass (default)"), labels: .top, label: Text("Glass"))
                        Fader(
                            value: model.fader("finishGel", 0.6),
                            format: model.formats.number(2),
                            title: Text(verbatim: "thumb: .glass(.clear).sheen(.aqua(0.4))"),
                            labels: .top,
                            style: GlassFaderStyle(thumbFinish: .glass(.clear).sheen(.aqua(0.4))),
                            label: Text("Gel")
                        )
                        Fader(
                            value: model.fader("finishAqua", 0.7),
                            format: model.formats.number(2),
                            title: Text(verbatim: "thumb: .aqua, fill: .aqua"),
                            labels: .top,
                            style: GlassFaderStyle(trackThickness: 14, thumbFinish: .aqua(.fixedSilver), fillFinish: .aqua(.accent)),
                            label: Text("Aqua")
                        )
                        Fader(
                            value: model.fader("finishCentre", 64),
                            scale: ValueScale(0 ... 100, precision: 0),
                            format: model.formats.number(0),
                            title: Text(verbatim: "Control Centre's, fill: .gradient.sheen(.aqua())"),
                            labels: .inside,
                            style: GlassFaderStyle(trackThickness: 44, thumb: .none, fillFinish: .gradient([.washViolet, .washPink]).sheen(.aqua())),
                            label: Text("Level")
                        )
                    }
                }
            }
            Sample(".controlFinish(.aqua(.accent)), on a whole group") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.large) {
                        HStack(spacing: Space.medium) {
                            ButtonPrimary("Save") {}
                            ButtonSecondary("Cancel") {}
                        }
                        Fader(value: model.fader("aquaGroup", 0.5), format: model.formats.number(2), title: Text(verbatim: "Volume"), labels: .top, label: Text("Volume"))
                    }
                }
                .controlFinish(.aqua(.accent))
            }
        }
    }
}

/// A button per finish, with its name.
struct FinishGrid: View {
    let finishes: [(name: String, finish: FinishToken)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: Space.medium)], spacing: Space.medium) {
            ForEach(finishes, id: \.name) { entry in
                VStack(spacing: Space.extraSmall) {
                    ButtonPrimary("Button", finish: entry.finish) {}
                    Text(verbatim: entry.name).font(.detail).foregroundStyle(.inkMuted)
                }
            }
        }
    }
}
