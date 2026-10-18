import SwiftUI
import Vitral
import VitralTokens

/// Faders in every look and both directions, each moving a value the model keeps.
struct FadersPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        Page("Faders") {
            LabelledGroup("Glass, labels in every place") {
                Panel {
                    VStack(spacing: Space.large) {
                        Fader(value: model.fader("plain", 0.4), label: Text("Level"))
                        Fader(value: model.fader("top", 0.6), title: Text("Opacity"), labels: .top, label: Text("Opacity"))
                        Fader(value: model.fader("leading", 0.3), title: Text("Mix"), labels: .leading, label: Text("Mix"))
                        Fader(value: model.fader("trailing", 0.8), title: Text("Wet"), labels: .trailing, label: Text("Wet"))
                        Fader(value: model.fader("bottom", 0.5), title: Text("Blend"), labels: .bottom, label: Text("Blend"))
                    }
                }
            }
            LabelledGroup("Control Centre's way: thick, the value inside") {
                HStack(spacing: Space.large) {
                    Fader(
                        value: model.fader("brightness", 70),
                        scale: ValueScale(0 ... 100, precision: 0),
                        title: Text("Brightness"),
                        labels: .inside,
                        style: GlassFaderStyle(trackThickness: 44, thumb: .none),
                        label: Text("Brightness")
                    )
                    Fader(
                        value: model.fader("volume", 0.5),
                        axis: .vertical,
                        style: GlassFaderStyle(trackThickness: 56, thumb: .none),
                        label: Text("Volume")
                    )
                    .frame(height: 160)
                }
            }
            LabelledGroup("Lightroom's way: from the centre, gradients, double tap to reset") {
                Panel {
                    VStack(spacing: Space.large) {
                        Fader(
                            value: model.fader("temperature", 5500),
                            scale: ValueScale(2000 ... 50000, precision: 0, taper: .logarithmic),
                            resetValue: 5500,
                            title: Text("Temp"),
                            labels: .top,
                            style: GlassFaderStyle(gradient: [.washTeal, .fixedWhite, .washAmber]),
                            label: Text("Temperature")
                        )
                        Fader(
                            value: model.fader("tint", 0),
                            scale: ValueScale(-150 ... 150, precision: 0),
                            centre: 0,
                            detents: [0],
                            resetValue: 0,
                            title: Text("Tint"),
                            labels: .top,
                            style: GlassFaderStyle(gradient: [.washGreen, .fixedWhite, .washPink]),
                            label: Text("Tint")
                        )
                        Fader(
                            value: model.fader("exposure", 0.35),
                            scale: ValueScale(-5 ... 5, precision: 2),
                            centre: 0,
                            detents: [0],
                            resetValue: 0,
                            title: Text("Exposure"),
                            labels: .top,
                            label: Text("Exposure")
                        )
                        Fader(
                            value: model.fader("contrast", -12),
                            scale: ValueScale(-100 ... 100, precision: 0),
                            centre: 0,
                            detents: [0],
                            resetValue: 0,
                            title: Text("Contrast"),
                            labels: .top,
                            label: Text("Contrast")
                        )
                    }
                }
            }
            LabelledGroup("Vertical glass, with marks and numbers") {
                HStack(spacing: Space.extraLarge) {
                    ForEach(["Low", "Mid", "High"], id: \.self) { band in
                        VStack(spacing: Space.small) {
                            Fader(
                                value: model.fader("eq\(band)", 0),
                                scale: ValueScale(-12 ... 12, precision: 1),
                                axis: .vertical,
                                centre: 0,
                                detents: [0],
                                resetValue: 0,
                                style: GlassFaderStyle(marks: 25, numberStep: 6),
                                label: Text(LocalizedStringKey(band))
                            )
                            .frame(height: 200)
                            Text(LocalizedStringKey(band)).font(.detail).foregroundStyle(.inkMuted)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            LabelledGroup("A mixing desk: dB faders, pushed from anywhere on the strip") {
                MixerDesk()
            }
        }
    }
}

/// Four channel strips: a pan above, a console fader, the channel's name.
struct MixerDesk: View {
    @Environment(GalleryModel.self) private var model

    /// Gains from silence to +6 dB, unity two thirds of the way up, the finest control in the
    /// twelve decibels below it, as a desk's faders are laid out.
    static let gain = ValueScale.consoleGain()
    /// Printed in decibels, placed by the gains they stand for, silence at the bottom.
    static let ticks: [Double] = [6, 0, -6, -12, -24, -40].map(ValueScale.gain(decibels:)) + [0]

    var body: some View {
        HStack(spacing: Space.small) {
            ForEach(["Kick", "Snare", "Bass", "Keys"], id: \.self) { channel in
                VStack(spacing: Space.small) {
                    Fader(
                        value: model.fader("pan\(channel)", 0),
                        scale: ValueScale(-1 ... 1, precision: 2),
                        centre: 0,
                        detents: [0],
                        resetValue: 0,
                        style: GlassFaderStyle(trackThickness: 4, thumb: .capsule),
                        label: Text("\(channel) pan")
                    )
                    .frame(width: 70)
                    Fader(
                        value: model.fader("level\(channel)", 1),
                        scale: Self.gain,
                        axis: .vertical,
                        interaction: .relative(dragStart: model.faderStart("level\(channel)")),
                        detents: [1],
                        resetValue: 1,
                        label: Text("\(channel) level")
                    )
                    .frame(height: 260)
                    Text(verbatim: Self.gain.formatted(model.fader("level\(channel)", 1).wrappedValue) + " dB")
                        .font(.caption2.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(Color(.fixedWhite))
                    Text(LocalizedStringKey(channel))
                        .font(TypeToken.detail.weight(.semibold))
                        .foregroundStyle(Color(.fixedWhite))
                }
                .padding(.vertical, Space.medium)
                .frame(maxWidth: .infinity)
            }
        }
        // One line sets the look of every level fader on the desk; the pans set their own.
        .faderStyle(ConsoleFaderStyle(ticks: Self.ticks, unity: 1, scaleColour: .fixedWhite))
        .padding(Space.small)
        .background { Backdrop(.texture(.metalPlate)) }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}
