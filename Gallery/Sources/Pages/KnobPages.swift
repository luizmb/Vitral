import SwiftUI
import Vitral
import VitralTokens

/// Knobs in every look, each turning a value the model keeps.
struct KnobsPage: View {
    /// An amp's black: black in any light, unlike the ink, which turns light at night.
    static let black = ColorToken(.black)

    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Page("Knobs") {
            KnobGrid {
                KnobSample("Glass, turned round") {
                    Knob(value: $model.knobGain, label: Text("Gain"))
                }
                KnobSample("Dragged up and down") {
                    Knob(
                        value: $model.knobVolume,
                        interaction: .vertical(dragStart: $model.knobVolumeStart),
                        style: GlassKnobStyle(marks: 11, showsValue: true),
                        label: Text("Volume")
                    )
                }
                KnobSample("A texture in the middle") {
                    Knob(
                        value: $model.knobTexture,
                        style: GlassKnobStyle(face: .texture(.wood), marks: 21, pointer: .dot),
                        label: Text("Tone")
                    )
                }
                KnobSample("A chicken-head, 0 to 10") {
                    Knob(
                        value: $model.knobHandle,
                        scale: ValueScale(0 ... 10, step: 1, precision: 0),
                        style: GlassKnobStyle(marks: 11, pointer: .handle, showsArc: false),
                        label: Text("Drive")
                    )
                }
                KnobSample("Log taper, 20 Hz to 20 kHz") {
                    Knob(
                        value: $model.knobFrequency,
                        scale: ValueScale(20 ... 20000, precision: 0, taper: .logarithmic),
                        style: GlassKnobStyle(marks: 31, showsValue: true),
                        label: Text("Frequency")
                    )
                }
                KnobSample("A Soldano: up to 11") {
                    Knob(
                        value: $model.knobSoldano,
                        scale: ValueScale(1 ... 11, step: 1, precision: 0),
                        style: GlassKnobStyle(face: .colour(Self.black), faceSize: 0.5, numbers: .inside, pointer: .dot, showsArc: false),
                        label: Text("Preamp")
                    )
                }
            }
            AmpPanel("A Marshall: gold caps, gold numbers, on leather", backdrop: .texture(.leather)) {
                Knob(
                    value: $model.knobMarshall,
                    scale: ValueScale(0 ... 10, step: 0.5, precision: 0),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .colour(.washAmber), marks: 11, numbers: .outside, showsArc: false,
                        markColour: .washAmber, numberColour: .washAmber, pointerColour: Self.black
                    ),
                    label: Text("Presence")
                )
            }
            AmpPanel("A Fender blackface: numbers on a black skirt, 1 to 10", backdrop: .brushedMetal) {
                Knob(
                    value: $model.knobFender,
                    scale: ValueScale(1 ... 10, step: 0.5, precision: 0),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .colour(Self.black), faceSize: 1, numbers: .inside, numberCount: 10, pointer: .dot, showsArc: false,
                        numberColour: .onAccent, pointerColour: .onAccent
                    ),
                    label: Text("Treble")
                )
            }
            AmpPanel("A Mesa Boogie: black knobs, white numbers, on diamond plate", backdrop: .texture(.metalPlate)) {
                Knob(
                    value: $model.knobMesa,
                    scale: ValueScale(0 ... 10, step: 0.5, precision: 0),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .colour(Self.black), faceSize: 0.9, marks: 21, numbers: .outside, pointer: .line, showsArc: false,
                        markColour: .onAccent, numberColour: .onAccent, pointerColour: .onAccent
                    ),
                    label: Text("Gain")
                )
            }
            AmpPanel("A chrome dome: polished silver, a small dot", backdrop: .texture(.slate)) {
                Knob(
                    value: $model.knobChrome,
                    scale: ValueScale(0 ... 10, step: 0.5, precision: 0),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .chrome, faceSize: 1, marks: 11, numbers: .outside, pointer: .dot, showsArc: false,
                        markColour: .onAccent, numberColour: .onAccent, pointerColour: Self.black
                    ),
                    label: Text("Bass")
                )
            }
            LabelledGroup("JogDial: endless, in steps of 15°") {
                VStack(spacing: Space.medium) {
                    JogDial(rotation: $model.jogRotation, lastTouch: $model.jogTouch, label: Text("Scrub"))
                        .frame(width: 200)
                    Stat(
                        icon: Image(systemName: "dial.medium"),
                        value: Text(verbatim: "\(Int((model.jogRotation / 15).rounded())) steps"),
                        accessibilityLabel: Text(verbatim: "\(Int((model.jogRotation / 15).rounded())) steps turned")
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct KnobGrid<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: Space.large)], spacing: Space.large) {
            content
        }
    }
}

/// A knob with its caption under it.
struct KnobSample<Content: View>: View {
    let caption: LocalizedStringKey
    let content: Content

    init(_ caption: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.caption = caption
        self.content = content()
    }

    var body: some View {
        VStack(spacing: Space.small) {
            content.frame(width: 110, height: 130)
            Text(caption)
                .font(.detail)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
    }
}

/// An amp's panel: a knob on its backdrop, a caption over it.
struct AmpPanel<Content: View>: View {
    let caption: LocalizedStringKey
    let backdrop: BackdropStyle
    let content: Content

    init(_ caption: LocalizedStringKey, backdrop: BackdropStyle, @ViewBuilder content: () -> Content) {
        self.caption = caption
        self.backdrop = backdrop
        self.content = content()
    }

    var body: some View {
        LabelledGroup(caption) {
            content
                .frame(width: 150)
                .padding(Space.large)
                .frame(maxWidth: .infinity)
                .background { Backdrop(backdrop) }
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
    }
}
