import SwiftUI
import Vitral
import VitralTokens

/// A compartment in the list sample.
struct DemoCompartment: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let kind: String
    let activity: String
    let tint: Tint
    let isMissing: Bool
    let isFiring: Bool

    func firing(_ isFiring: Bool) -> DemoCompartment {
        DemoCompartment(id: id, name: name, kind: kind, activity: activity, tint: tint, isMissing: isMissing, isFiring: isFiring)
    }

    static let all = [
        DemoCompartment(id: 0, name: "Lungs", kind: "Respiratory tract", activity: "2.1e-4", tint: .blue, isMissing: false, isFiring: false),
        DemoCompartment(id: 1, name: "Blood", kind: "Transfer", activity: "6.8e-5", tint: .pink, isMissing: false, isFiring: true),
        DemoCompartment(id: 2, name: "Liver", kind: "Systemic", activity: "3.3e-5", tint: .amber, isMissing: false, isFiring: false),
        DemoCompartment(id: 3, name: "Kidneys", kind: "Systemic", activity: "1.2e-5", tint: .teal, isMissing: false, isFiring: false),
        DemoCompartment(id: 4, name: "Bone surface", kind: "Not in this model", activity: "—", tint: .violet, isMissing: true, isFiring: false)
    ]
}

/// The list sample: rows from the model's state, every change reported back to it.
struct GlassListPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        GlassList(selection: $model.selectedCompartment, backdrop: .glow()) {
            GlassSection("Compartments", trailing: { Text(verbatim: "\(model.compartments.count)") }) {
                ForEach(model.compartments) { compartment in
                    CompartmentRow(compartment: compartment, state: state(of: compartment), model: model)
                        .tag(compartment.id)
                }
                .onDelete { model.delete(at: $0) }
                .onMove { model.move(from: $0, to: $1) }
            }
            GlassSection("Rows that lead somewhere") {
                NavigationLink(value: GalleryPage.cards) {
                    Row("Cards", subtitle: "A NavigationLink, with .disclosure()").disclosure()
                }
                Row("Settings", subtitle: ".disclosure()").disclosure()
            }
            GlassSection("States") {
                Row("Normal")
                Row("Selected").rowState(.selected)
                Row("Highlighted", subtitle: "Firing, playing, just changed").rowState(.highlighted())
                Row("Dimmed", subtitle: "Missing, unavailable").rowState(.dimmed)
            }
            GlassSection("Plain controls: rows: .padded", rows: .padded) {
                TextField("Title", text: .constant("Highway to Hell"))
                Toggle("Count in", isOn: .constant(true))
                Stepper("Bars before: 2", value: .constant(2), in: 0 ... 8)
            }
        }
        .environment(\.editMode, $model.editMode)
        .toolbar { EditButton() }
        .navigationTitle("GlassList")
    }

    func state(of compartment: DemoCompartment) -> RowState {
        compartment.isMissing ? .dimmed
            : compartment.isFiring ? .highlighted()
            : compartment.id == model.selectedCompartment ? .selected : .normal
    }
}

/// A compartment's row: its swatch, name and kind, its activity on a tag, and what can be done to
/// it. The actions only report; the model applies them.
struct CompartmentRow: View {
    let compartment: DemoCompartment
    let state: RowState
    let model: GalleryModel

    var body: some View {
        Row(LocalizedStringKey(compartment.name), subtitle: LocalizedStringKey(compartment.kind)) {
            Swatch(compartment.tint.ink, diameter: Size.swatch)
        }
        .trailing {
            Tag(Text(verbatim: compartment.activity), style: .tint(compartment.tint))
        }
        .rowState(state)
        .rowActions(actions)
    }

    var actions: [RowAction] {
        [
            RowAction("Delete", icon: Image(systemName: "trash"), role: .destructive) { model.delete(compartment.id) },
            RowAction(compartment.isFiring ? "Quiet" : "Fire", icon: Image(systemName: "bolt"), tint: .counterAccent) { model.toggleFiring(compartment.id) }
        ]
    }
}

