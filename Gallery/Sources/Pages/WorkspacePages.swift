import SwiftUI
import Vitral
import VitralTokens

/// The inspector's pages in the sample.
enum DemoInspectorPage: String, PageKind {
    case properties, colours

    var icon: Image {
        switch self {
        case .properties: Image(systemName: "slider.horizontal.3")
        case .colours: Image(systemName: "paintpalette")
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .properties: "Properties"
        case .colours: "Colours"
        }
    }
}

/// The sample's modes: picked from the width (the default), or each one forced.
enum WorkspaceModeChoice: String, CaseIterable, Hashable, Sendable {
    case automatic, docked, dockedExclusive, floating, sheet

    var mode: WorkspaceMode? {
        switch self {
        case .automatic: nil
        case .docked, .dockedExclusive: .docked
        case .floating: .floating
        case .sheet: .sheet
        }
    }

    var exclusive: Bool { self == .dockedExclusive }

    var title: LocalizedStringKey {
        switch self {
        case .automatic: "Automatic, the default"
        case .docked: "Docked, forced"
        case .dockedExclusive: "Docked, forced, one panel at a time"
        case .floating: "Floating, forced"
        case .sheet: "Sheets, forced"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .automatic: "Docked when wide, floating at middle widths, sheets when narrow; a sidebar, an inspector and a console"
        case .docked: "Workspace(mode: .docked): columns beside the content"
        case .dockedExclusive: "Workspace(mode: .docked, exclusive: true): opening one closes the other"
        case .floating: "Workspace(mode: .floating): glass panels over the content"
        case .sheet: "Workspace(mode: .sheet): sheets, the content usable behind"
        }
    }
}

/// Where a workspace sample is, in the navigation.
struct WorkspaceRoute: Hashable {
    let choice: WorkspaceModeChoice
}

/// One sample per mode, each a whole screen.
struct WorkspacePage: View {
    var body: some View {
        Page("Workspace") {
            Banner("Open a sample, then the sidebar and inspector from the toolbar. Drag a docked or floating panel's inner edge to resize it.")
            PanelList {
                ForEach(WorkspaceModeChoice.allCases, id: \.self) { choice in
                    NavigationLink(value: WorkspaceRoute(choice: choice)) {
                        Row(choice.title, subtitle: choice.subtitle, showsDisclosure: true)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// A workspace to try: a sidebar of compartments, an inspector with pages, and the toolbar's
/// toggles, in the route's mode.
struct WorkspaceSample: View {
    let route: WorkspaceRoute

    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Workspace(mode: route.choice.mode, exclusive: route.choice.exclusive) {
            WorkspaceCanvas()
        }
        .leading(isPresented: $model.showsSidebar, width: $model.sidebarWidth) {
            WorkspaceSidebar()
        }
        .trailing(isPresented: $model.showsInspector, width: $model.inspectorWidth, pages: $model.inspectorPage) { page in
            WorkspaceInspector(page: page)
        }
        .bottom(isPresented: $model.showsConsole, height: $model.consoleHeight) {
            WorkspaceConsole()
        }
        .workspaceToolbar(leading: $model.showsSidebar, trailing: $model.showsInspector, bottom: $model.showsConsole)
        .navigationTitle(route.choice.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorkspaceCanvas: View {
    @Environment(\.workspaceMode) private var mode

    var body: some View {
        Card("U-234 Inhalation", subtitle: "ICRP 137, Type S") {
            Text(verbatim: "Showing panels: \(mode)").font(.detail).foregroundStyle(.inkMuted)
        }
        .frame(maxWidth: 360)
        .padding(Space.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Backdrop(.grid()) }
    }
}

/// The sample's bottom panel: a log.
struct WorkspaceConsole: View {
    static let log = """
        18:42:07  Solving U-234 inhalation, 12 compartments
        18:42:07  Step 1e-3 d, tolerance 1e-9
        18:42:08  Lungs → Blood  2.1e-4 Bq
        18:42:08  Blood → Liver  6.8e-5 Bq
        18:42:09  Done in 1.84 s
        """

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            Text(verbatim: Self.log)
                .font(.codeSmall)
                .foregroundStyle(.inkMuted)
                .textSelection(.enabled)
                .padding(Space.medium)
        }
        .defaultScrollAnchor(.topLeading)
    }
}

struct WorkspaceSidebar: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.medium) {
                SectionLabel("Compartments")
                PanelList {
                    ForEach(["Lungs", "Blood", "Liver", "Kidneys", "Bone"], id: \.self) { name in
                        Row(LocalizedStringKey(name), subtitle: "Compartment") {
                            Swatch(Tint.allCases[name.count % Tint.allCases.count].ink, diameter: Size.swatch)
                        }
                    }
                }
            }
            .padding(Space.medium)
        }
    }
}

struct WorkspaceInspector: View {
    let page: DemoInspectorPage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.medium) {
                switch page {
                case .properties:
                    SectionLabel("Lungs")
                    FieldText("Half-life", text: .constant("2.45e5"), suffix: Text(verbatim: "y"))
                    ToggleSwitch("Track", isOn: .constant(true))
                case .colours:
                    SectionLabel("Tint")
                    FlowLayout(spacing: Space.small) {
                        ForEach(Tint.allCases, id: \.self) { tint in
                            Tag(Text(verbatim: tint.rawValue), style: .tint(tint))
                        }
                    }
                }
            }
            .padding(Space.medium)
        }
    }
}
