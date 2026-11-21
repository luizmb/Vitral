import SwiftUI
import Vitral
import VitralTokens

/// Knob and Fader given a plain value and `onEvent`: they report what happens and change nothing
/// themselves. The page applies the events, logs them, and counts the messages a remote device would
/// get (one per release, reset or VoiceOver step) — a double tap is one, not three.
struct ControlEventsPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        Page("Control events") {
            LabelledGroup("A knob") {
                Panel {
                    HStack(spacing: Space.large) {
                        Knob(
                            value: model.eventKnob,
                            format: model.formats.number(2),
                            style: GlassKnobStyle(marks: 11, showsValue: true),
                            resetsOnDoubleTap: true,
                            label: Text("Event knob")
                        ) { model.apply($0, to: \.eventKnob, named: "knob", resetTo: 0.5) }
                        .frame(width: 120, height: 120)
                        Text("Turn it, tap it, double tap it (back to 0.50), or step it with VoiceOver.")
                            .font(.footnote)
                            .foregroundStyle(.inkMuted)
                    }
                }
            }
            LabelledGroup("A fader") {
                Panel {
                    Fader(
                        value: model.eventFader,
                        format: model.formats.number(2),
                        resetsOnDoubleTap: true,
                        title: Text("Event fader"),
                        labels: .top,
                        label: Text("Event fader")
                    ) { model.apply($0, to: \.eventFader, named: "fader", resetTo: 0.5) }
                }
            }
            LabelledGroup("What they reported") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.small) {
                        HStack {
                            Text("Messages a device would get").font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(verbatim: "\(model.eventMessages)").font(.title3.monospacedDigit().weight(.semibold))
                        }
                        Hairline()
                        if model.eventLog.isEmpty {
                            Text("Nothing yet.").foregroundStyle(.inkMuted)
                        } else {
                            ForEach(Array(model.eventLog.enumerated()), id: \.offset) { _, line in
                                Text(verbatim: line).font(.caption.monospaced()).foregroundStyle(.ink)
                            }
                        }
                        ButtonSecondary("Clear", size: .small) { model.clearEvents() }
                    }
                }
            }
        }
    }
}

extension GalleryModel {
    /// What an app does with a control's events: changes the value when asked, logs every event, and
    /// counts one message per completed edit.
    func apply(_ event: ControlEvent<Double>, to value: ReferenceWritableKeyPath<GalleryModel, Double>, named name: String, resetTo reset: Double) {
        switch event {
        case let .changed(newValue): self[keyPath: value] = newValue
        case let .stepped(newValue): self[keyPath: value] = newValue
        case .resetRequested: self[keyPath: value] = reset
        case .pressed, .released, .cancelled: break
        }
        switch event {
        case .released, .resetRequested, .stepped: eventMessages += 1
        case .pressed, .changed, .cancelled: break
        }
        eventLog = Array(([describe(event, name)] + eventLog).prefix(14))
    }

    func clearEvents() {
        eventLog = []
        eventMessages = 0
    }

    private func describe(_ event: ControlEvent<Double>, _ name: String) -> String {
        switch event {
        case .pressed: "\(name)  pressed"
        case let .changed(value): "\(name)  changed \(value.formatted(.number.precision(.fractionLength(2))))"
        case .released: "\(name)  released  → send"
        case .cancelled: "\(name)  cancelled"
        case .resetRequested: "\(name)  resetRequested  → send"
        case let .stepped(value): "\(name)  stepped \(value.formatted(.number.precision(.fractionLength(2))))  → send"
        }
    }
}
