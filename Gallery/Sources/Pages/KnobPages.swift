import SwiftUI
import Vitral
import VitralTokens

/// Knobs in every look, each turning a value the model keeps.
struct KnobsPage: View {
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
                KnobSample("A chicken-head, whole numbers only") {
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
                        scale: ValueScale(1 ... 11, precision: 1),
                        style: GlassKnobStyle(face: .colour(.fixedBlack), faceSize: 0.5, numbers: .inside, numberStep: 1, pointer: .dot, showsArc: false, showsValue: true),
                        label: Text("Preamp")
                    )
                }
            }
            AmpPanel("A Marshall: numbered 0 to 10, it rests between them", backdrop: .texture(.leather)) {
                Knob(
                    value: $model.knobMarshall,
                    scale: ValueScale(0 ... 10, precision: 2),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .colour(.fixedGold), marks: 11, numbers: .outside, numberStep: 1, showsArc: false, showsValue: true,
                        markColour: .fixedGold, numberColour: .fixedGold, valueColour: .fixedGold, pointerColour: .fixedBlack
                    ),
                    label: Text("Presence")
                )
            }
            AmpPanel("A Fender blackface: numbers on a black skirt, 1 to 10", backdrop: .brushedMetal) {
                Knob(
                    value: $model.knobFender,
                    scale: ValueScale(1 ... 10, precision: 2),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .colour(.fixedBlack), faceSize: 1, numbers: .inside, numberStep: 1, pointer: .dot, showsArc: false, showsValue: true,
                        numberColour: .fixedWhite, pointerColour: .fixedWhite
                    ),
                    label: Text("Treble")
                )
            }
            AmpPanel("A Mesa Boogie: black knobs, white numbers, on diamond plate", backdrop: .texture(.metalPlate)) {
                Knob(
                    value: $model.knobMesa,
                    scale: ValueScale(0 ... 10, precision: 2),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .colour(.fixedBlack), faceSize: 0.9, marks: 21, numbers: .outside, numberStep: 1, pointer: .line, showsArc: false, showsValue: true,
                        markColour: .fixedWhite, numberColour: .fixedWhite, valueColour: .fixedWhite, pointerColour: .fixedWhite
                    ),
                    label: Text("Gain")
                )
            }
            AmpPanel("A chrome dome with a chrome dimple", backdrop: .texture(.slate)) {
                Knob(
                    value: $model.knobChrome,
                    scale: ValueScale(0 ... 10, precision: 2),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .chrome, faceSize: 1, marks: 11, numbers: .outside, numberStep: 1, pointer: .chromeDimple, showsArc: false, showsValue: true,
                        markColour: .fixedWhite, numberColour: .fixedWhite, valueColour: .fixedWhite, pointerColour: .fixedBlack
                    ),
                    label: Text("Bass")
                )
            }
            AmpPanel("A chrome dome with a chrome stud", backdrop: .texture(.leatherRed)) {
                Knob(
                    value: $model.knobChromeStud,
                    scale: ValueScale(0 ... 10, precision: 2),
                    startAngle: -150,
                    endAngle: 150,
                    style: GlassKnobStyle(
                        face: .chrome, faceSize: 1, marks: 11, numbers: .outside, numberStep: 1, pointer: .chromeStud, showsArc: false,
                        markColour: .fixedCream, numberColour: .fixedCream, valueColour: .fixedCream
                    ),
                    label: Text("Treble")
                )
            }
            LabelledGroup(".knobStyle(_:) on a panel: every knob in it, one line") {
                HStack(spacing: Space.large) {
                    ForEach(["Bass", "Middle", "Treble"], id: \.self) { name in
                        VStack(spacing: Space.small) {
                            Knob(value: model.fader("panel\(name)", 5), scale: ValueScale(0 ... 10, precision: 1), startAngle: -150, endAngle: 150, label: Text(LocalizedStringKey(name)))
                                .frame(width: 96)
                            Text(LocalizedStringKey(name)).font(TypeToken.detail.weight(.semibold)).foregroundStyle(Color(.fixedCream))
                        }
                    }
                }
                .knobStyle(GlassKnobStyle(face: .chrome, faceSize: 1, marks: 11, pointer: .chromeStud, showsArc: false, markColour: .fixedCream))
                .padding(Space.large)
                .frame(maxWidth: .infinity)
                .background { Backdrop(.texture(.leather)) }
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
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
