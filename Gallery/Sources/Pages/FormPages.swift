import SwiftUI
import Vitral
import VitralTokens

/// A form made of nothing but Vitral fields, each changing a value the model keeps.
struct FormsPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Page("Forms") {
            Sample("FieldPicker: a menu of options") {
                PanelList {
                    FieldPicker("Channels", selection: $model.formChannels, options: [
                        ChoiceOption("Mono", title: "Mono"),
                        ChoiceOption("Stereo", title: "Stereo"),
                        ChoiceOption("Left only", title: "Left only"),
                    ])
                    .padding(.horizontal, Space.large)
                }
            }
            Sample("FieldStepper: its label says the value") {
                PanelList {
                    FieldStepper(Text(verbatim: "Division \(model.formDivision)"), value: $model.formDivision, in: 1 ... 4)
                        .padding(.horizontal, Space.large)
                }
            }
            Sample("FieldDate") {
                PanelList {
                    FieldDate("Published", date: $model.formDate)
                        .padding(.horizontal, Space.large)
                }
            }
            Sample("EntryList: entries to remove, and one to add") {
                PanelList {
                    EntryList(
                        entries: model.formEntries,
                        draft: $model.formDraft,
                        placeholder: "Another name",
                        onRemove: { model.formEntries.remove(at: $0) },
                        onAdd: {
                            model.formEntries.append(model.formDraft.trimmingCharacters(in: .whitespaces))
                            model.formDraft = ""
                        }
                    )
                    .padding(.horizontal, Space.large)
                }
            }
            Sample("SwatchPicker") {
                Panel {
                    SwatchPicker(
                        selection: $model.formColour,
                        options: ["red", "orange", "yellow", "green", "teal", "blue", "indigo", "purple"],
                        colour: { FormsPage.colours[$0] ?? .gray },
                        label: { Text(verbatim: $0) }
                    )
                }
            }
            Sample("IconPicker, with badges") {
                Panel {
                    IconPicker(
                        selection: $model.formIcon,
                        options: ["music.mic", "pianokeys", "guitars", "metronome", "speaker.wave.2", "headphones"],
                        badge: { Badge(.glyph(Image(systemName: $0)), fill: .indigo, diameter: 30, gradient: true) },
                        title: { Text(verbatim: $0.split(separator: ".").first.map(String.init) ?? $0) }
                    )
                }
            }
            Sample("Row, titled with an app's own name") {
                PanelList {
                    Row(Text(verbatim: "Guitar Lead"), subtitle: Text("Stereo"), detail: Text("Pair 6")) {
                        Badge(.glyph(Image(systemName: "guitars")), fill: .orange, diameter: 38, gradient: true)
                    }
                }
            }
        }
    }

    static let colours: [String: Color] = [
        "red": .red, "orange": .orange, "yellow": .yellow, "green": .green,
        "teal": .teal, "blue": .blue, "indigo": .indigo, "purple": .purple,
    ]
}
