import SwiftUI
import Vitral
import VitralTokens

/// Every finish, on buttons and fader thumbs; Aqua's layers over each; and a whole group in
/// Aqua's gel from one `controlFinish`.
struct FinishesPage: View {
    static let finishes: [(name: String, finish: SurfaceFinish)] = [
        ("glass", .glass()),
        ("solid", .solid(.accent)),
        ("gradient", .gradient([.washViolet, .washPink])),
        ("texture", .texture(.denim)),
        ("chrome", .chrome),
        ("aqua", .aqua(.accent)),
        ("aqua, graphite", .aqua(.fixedSilver))
    ]

    static let layered: [(name: String, finish: SurfaceFinish)] = [
        ("glass.gel", .glass().gel),
        ("solid.gel", .solid(.washGreen).gel),
        ("gradient.with(.gloss)", .gradient([.washAmber, .counterAccent]).with(.gloss)),
        ("texture.with(.gloss, .rim)", .texture(.wood).with(.gloss, .rim))
    ]

    @Environment(GalleryModel.self) private var model

    var body: some View {
        Page("Finishes", backdrop: .glow()) {
            LabelledGroup("SurfaceFinish, on ButtonPrimary(finish:)") {
                FinishGrid(finishes: Self.finishes)
            }
            LabelledGroup("Aqua's layers over anything: .gel, .with(.gloss, .glow, .rim)") {
                FinishGrid(finishes: Self.layered)
            }
            LabelledGroup("Fader thumbs and fills") {
                Panel {
                    VStack(spacing: Space.large) {
                        Fader(value: model.fader("finishGlass", 0.4), title: Text(verbatim: "glass (default)"), labels: .top, label: Text("Glass"))
                        Fader(
                            value: model.fader("finishGel", 0.6),
                            title: Text(verbatim: "thumb: .glass().gel"),
                            labels: .top,
                            style: GlassFaderStyle(thumbFinish: .glass().gel),
                            label: Text("Gel")
                        )
                        Fader(
                            value: model.fader("finishAqua", 0.7),
                            title: Text(verbatim: "thumb: .aqua, fill: .aqua"),
                            labels: .top,
                            style: GlassFaderStyle(trackThickness: 10, thumbFinish: .aqua(.fixedSilver), fillFinish: .aqua(.accent)),
                            label: Text("Aqua")
                        )
                        Fader(
                            value: model.fader("finishCentre", 64),
                            scale: ValueScale(0 ... 100, precision: 0),
                            title: Text(verbatim: "Control Centre's, fill: .gradient.gel"),
                            labels: .inside,
                            style: GlassFaderStyle(trackThickness: 44, thumb: .none, fillFinish: .gradient([.washViolet, .washPink]).gel),
                            label: Text("Level")
                        )
                    }
                }
            }
            LabelledGroup(".controlFinish(.aqua(.accent)), on a whole group") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.large) {
                        HStack(spacing: Space.medium) {
                            ButtonPrimary("Save") {}
                            ButtonSecondary("Cancel") {}
                        }
                        Fader(value: model.fader("aquaGroup", 0.5), title: Text(verbatim: "Volume"), labels: .top, label: Text("Volume"))
                    }
                }
                .controlFinish(.aqua(.accent))
            }
        }
    }
}

/// A button per finish, with its name.
struct FinishGrid: View {
    let finishes: [(name: String, finish: SurfaceFinish)]

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
