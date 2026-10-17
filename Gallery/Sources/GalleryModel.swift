import Observation
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
}
