import Observation
import SwiftUI
import Vitral
import VitralTokens

/// The Gallery's state, held by the app (its boundary): the appearance switch's choice and the
/// pages the interactive samples are on. Views read it, and change it through bindings.
@MainActor @Observable
final class GalleryModel {
    var appearance = Appearance.system
    var carouselPage: Int? = 0
    var flipPage: Int? = 0
    var showsSidebar = false
    var showsInspector = false
    var showsConsole = false
    var sidebarWidth = PanelSize.sidebar.ideal
    var inspectorWidth = PanelSize.inspector.ideal
    var consoleHeight = PanelSize.console.ideal
    var inspectorPage = DemoInspectorPage.properties
    var segmentedPage = DemoInspectorPage.properties
    var compartments = DemoCompartment.all
    var selectedCompartment: DemoCompartment.ID?
    var editMode = EditMode.inactive
    var knobGain = 0.4
    var knobVolume = 0.6
    var knobVolumeStart: Double?
    var knobTexture = 0.3
    var knobMarshall = 7.0
    var knobFender = 6.0
    var knobMesa = 4.0
    var knobChrome = 5.0
    var knobChromeStud = 3.0
    var knobSoldano = 11.0
    var knobHandle = 5.0
    var knobFrequency = 1000.0
    var jogRotation = 0.0
    var jogTouch: Double?

    // What the list reports, applied here as a store's reducer would.

    func delete(at offsets: IndexSet) {
        compartments.remove(atOffsets: offsets)
    }

    func delete(_ id: DemoCompartment.ID) {
        compartments.removeAll { $0.id == id }
    }

    func move(from offsets: IndexSet, to destination: Int) {
        compartments.move(fromOffsets: offsets, toOffset: destination)
    }

    func toggleFiring(_ id: DemoCompartment.ID) {
        compartments = compartments.map { $0.id == id ? $0.firing(!$0.isFiring) : $0 }
    }
}
