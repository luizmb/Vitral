import SwiftUI
import VitralTokens

/// How a workspace shows its panels.
public enum WorkspaceMode: Hashable, Sendable {
    /// Beside the content, each in its own column (iPad, Mac).
    case docked
    /// Over the content, on glass, the content keeping its whole width (iPhone in landscape, a
    /// narrow iPad window).
    case floating
    /// In sheets the content stays usable behind (iPhone upright).
    case sheet

    /// The mode for a workspace `width` wide whose panels open at `panels` (their ideal widths,
    /// whether open or not, so opening one never moves the other).
    public static func fitting(width: Double, panels: [Double]) -> WorkspaceMode {
        width < Size.workspaceSheets
            ? .sheet
            : width >= Size.workspaceContent + panels.reduce(0, +) ? .docked : .floating
    }
}

/// Which side a panel is on.
public enum PanelSide: Hashable, Sendable {
    case leading, trailing
}

/// How a panel comes and goes.
public enum PanelTransition: Hashable, Sendable {
    /// In from its edge.
    case slide
    /// In from its edge, fading in.
    case slideAndFade
    /// Fading in where it stands.
    case fade
}

public extension EnvironmentValues {
    /// The animation a workspace's panels open and close with.
    @Entry var panelAnimation: Animation = .spring(response: 0.28, dampingFraction: 0.88)
    /// How a workspace's panels come and go.
    @Entry var panelTransition: PanelTransition = .slideAndFade
    /// How the workspace around this view shows its panels (`.docked` outside one).
    @Entry var workspaceMode: WorkspaceMode = .docked
}

public extension View {
    /// The animation every workspace panel under this view opens and closes with.
    func panelAnimation(_ animation: Animation) -> some View {
        environment(\.panelAnimation, animation)
    }

    /// How every workspace panel under this view comes and goes.
    func panelTransition(_ transition: PanelTransition) -> some View {
        environment(\.panelTransition, transition)
    }
}

/// One of a workspace's panels: whether it's open, how wide it is, and what's in it.
public struct WorkspacePanel<Body: View> {
    let isPresented: Binding<Bool>
    let width: Binding<Double>?
    let range: PanelWidth
    let body: Body

    /// Its width, never past `available`: when a mode is forced onto a screen too narrow for the
    /// panels' minimums, the panels share what there is.
    func resolvedWidth(fitting available: Double) -> Double {
        min(range.clamped(width?.wrappedValue ?? range.ideal), available)
    }
}

/// A screen made of content and the panels beside it, like Xcode's: a leading panel (a sidebar),
/// a trailing one (an inspector), each shown or hidden through its binding. Docked in columns when
/// there's room, floating over the content at middle widths, in sheets on a narrow screen; the
/// mode can be forced on any screen (`Workspace(mode: .floating)`). Give a panel a `width` binding
/// and its edge drags to resize it.
///
/// Panels shouldn't hold a `NavigationStack`: inside a column it takes over the app's.
public struct Workspace<Leading: View, Content: View, Trailing: View>: View {
    let mode: WorkspaceMode?
    let exclusive: Bool
    let content: Content
    let leading: WorkspacePanel<Leading>?
    let trailing: WorkspacePanel<Trailing>?

    @Environment(\.panelAnimation) private var animation
    @Environment(\.panelTransition) private var transition

    static var space: String { "vitral.workspace" }

    public var body: some View {
        GeometryReader { proxy in
            let resolved = mode ?? WorkspaceMode.fitting(width: proxy.size.width, panels: [leading?.range.ideal, trailing?.range.ideal].compactMap { $0 })
            layout(resolved, width: proxy.size.width)
                .environment(\.workspaceMode, resolved)
        }
        .coordinateSpace(.named(Self.space))
        .animation(animation, value: leading?.isPresented.wrappedValue)
        .animation(animation, value: trailing?.isPresented.wrappedValue)
        .onChange(of: leading?.isPresented.wrappedValue) { _, isOpen in
            if exclusive, isOpen == true { trailing?.isPresented.wrappedValue = false }
        }
        .onChange(of: trailing?.isPresented.wrappedValue) { _, isOpen in
            if exclusive, isOpen == true { leading?.isPresented.wrappedValue = false }
        }
    }

    @ViewBuilder
    func layout(_ mode: WorkspaceMode, width: Double) -> some View {
        switch mode {
        case .docked:
            HStack(spacing: 0) {
                if let leading, leading.isPresented.wrappedValue {
                    docked(leading, side: .leading, width: width)
                }
                content.frame(maxWidth: .infinity, maxHeight: .infinity)
                if let trailing, trailing.isPresented.wrappedValue {
                    docked(trailing, side: .trailing, width: width)
                }
            }
        case .floating:
            ZStack {
                content.frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack(spacing: 0) {
                    if let leading, leading.isPresented.wrappedValue {
                        floating(leading, side: .leading, width: width)
                    }
                    Spacer(minLength: 0)
                    if let trailing, trailing.isPresented.wrappedValue {
                        floating(trailing, side: .trailing, width: width)
                    }
                }
                .padding(Space.medium)
            }
        case .sheet:
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sheet(isPresented: leadingSheet) { leading.map { sheet($0.body) } }
                .background {
                    Color.clear.sheet(isPresented: trailingSheet) { trailing.map { sheet($0.body) } }
                }
        }
    }

    /// One sheet at a time: the leading panel's wins.
    var leadingSheet: Binding<Bool> {
        Binding(get: { leading?.isPresented.wrappedValue ?? false }, set: { leading?.isPresented.wrappedValue = $0 })
    }

    var trailingSheet: Binding<Bool> {
        Binding(
            get: { (trailing?.isPresented.wrappedValue ?? false) && !(leading?.isPresented.wrappedValue ?? false) },
            set: { trailing?.isPresented.wrappedValue = $0 }
        )
    }

    /// How many panels are open.
    var openPanels: Int {
        [leading?.isPresented.wrappedValue, trailing?.isPresented.wrappedValue].filter { $0 == true }.count
    }

    /// The most each docked panel can take: what's left after the content's share, or, when that's
    /// too little, an equal share with the content.
    func dockedRoom(_ width: Double) -> Double {
        max((width - Size.workspaceContent) / Double(max(openPanels, 1)), width / Double(openPanels + 1))
    }

    /// The most each floating panel can take: the screen less its margins, shared.
    func floatingRoom(_ width: Double) -> Double {
        min(width * 0.8, (width - Space.medium * Double(openPanels + 1)) / Double(max(openPanels, 1)))
    }

    func docked<Panel: View>(_ panel: WorkspacePanel<Panel>, side: PanelSide, width: Double) -> some View {
        panel.body
            .frame(width: panel.resolvedWidth(fitting: dockedRoom(width)))
            .frame(maxHeight: .infinity, alignment: .top)
            .glassSurface(cornerRadius: 0)
            .overlay(alignment: side == .leading ? .trailing : .leading) {
                ZStack {
                    Hairline(.vertical)
                    resizeHandle(panel, side: side, inset: 0, width: width)
                }
            }
            // Over the content, so the half of the resize strip on its side still takes the drag.
            .zIndex(1)
            .transition(panelTransition(side))
    }

    func floating<Panel: View>(_ panel: WorkspacePanel<Panel>, side: PanelSide, width: Double) -> some View {
        panel.body
            .frame(width: panel.resolvedWidth(fitting: floatingRoom(width)))
            .frame(maxHeight: .infinity, alignment: .top)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sheet, style: .continuous))
            .glassSurface(.regular, cornerRadius: Radius.sheet)
            .shadow(color: Color(.scrim), radius: Space.large, y: Space.extraSmall)
            .overlay(alignment: side == .leading ? .trailing : .leading) {
                resizeHandle(panel, side: side, inset: Space.medium, width: width)
            }
            .transition(panelTransition(side))
    }

    func sheet<Panel: View>(_ panel: Panel) -> some View {
        panel
            .presentationDetents([.fraction(1 / 3), .fraction(2 / 3), .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(2 / 3)))
            .presentationContentInteraction(.scrolls)
            .presentationDragIndicator(.visible)
    }

    /// A strip on the panel's inner edge: dragging it sets the width to where the finger is, in
    /// the workspace's coordinates, so nothing about the drag has to be remembered.
    @ViewBuilder
    func resizeHandle<Panel: View>(_ panel: WorkspacePanel<Panel>, side: PanelSide, inset: Double, width: Double) -> some View {
        if let binding = panel.width {
            Color.clear
                .frame(width: Space.extraLarge)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                // Centred on the edge, half over the panel and half over the content.
                .offset(x: side == .leading ? Space.extraLarge / 2 : -Space.extraLarge / 2)
                .gesture(
                    DragGesture(minimumDistance: 1, coordinateSpace: .named(Self.space))
                        .onChanged { drag in
                            binding.wrappedValue = panel.range.clamped(side == .leading ? drag.location.x - inset : width - drag.location.x - inset)
                        }
                )
                .accessibilityHidden(true)
        }
    }

    func panelTransition(_ side: PanelSide) -> AnyTransition {
        switch transition {
        case .slide: .move(edge: side == .leading ? .leading : .trailing)
        case .slideAndFade: .move(edge: side == .leading ? .leading : .trailing).combined(with: .opacity)
        case .fade: .opacity
        }
    }
}

public extension Workspace where Leading == EmptyView, Trailing == EmptyView {
    /// A workspace around `content`; add panels with `.leading { }` and `.trailing { }`.
    /// - Parameters:
    ///   - mode: forces how panels show; `nil` picks it from the width.
    ///   - exclusive: one panel at a time, opening one closing the other (it turns its binding
    ///     off): docked panels forced onto an iPhone then never squeeze the content.
    init(mode: WorkspaceMode? = nil, exclusive: Bool = false, @ViewBuilder content: () -> Content) {
        self.mode = mode
        self.exclusive = exclusive
        self.content = content()
        self.leading = nil
        self.trailing = nil
    }
}

public extension Workspace {
    /// The leading panel, open while `isPresented`. With a `width` binding its edge drags to
    /// resize it within `range`.
    func leading<Panel: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelWidth = .sidebar,
        @ViewBuilder content: () -> Panel
    ) -> Workspace<Panel, Content, Trailing> {
        Workspace<Panel, Content, Trailing>(
            mode: mode,
            exclusive: exclusive,
            content: self.content,
            leading: WorkspacePanel(isPresented: isPresented, width: width, range: range, body: content()),
            trailing: trailing
        )
    }

    /// The trailing panel, open while `isPresented`. With a `width` binding its edge drags to
    /// resize it within `range`.
    func trailing<Panel: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelWidth = .inspector,
        @ViewBuilder content: () -> Panel
    ) -> Workspace<Leading, Content, Panel> {
        Workspace<Leading, Content, Panel>(
            mode: mode,
            exclusive: exclusive,
            content: self.content,
            leading: leading,
            trailing: WorkspacePanel(isPresented: isPresented, width: width, range: range, body: content())
        )
    }
}

/// Shows or hides a workspace panel: the sidebar symbol for its side, filled while it's open.
/// Put it anywhere; `.workspaceToolbar` puts a pair in the toolbar.
public struct PanelToggle: View {
    let side: PanelSide
    @Binding var isPresented: Bool
    let label: LocalizedStringKey

    @Environment(\.panelAnimation) private var animation
    @Environment(\.accent) private var accent

    /// - Parameter label: what VoiceOver says.
    public init(_ side: PanelSide, isPresented: Binding<Bool>, label: LocalizedStringKey? = nil) {
        self.side = side
        self._isPresented = isPresented
        self.label = label ?? (side == .leading ? "Sidebar" : "Inspector")
    }

    public var body: some View {
        Button {
            withAnimation(animation) { isPresented.toggle() }
        } label: {
            Image(side == .leading ? .panelLeading : .panelTrailing)
                .symbolVariant(isPresented ? .fill : .none)
                .foregroundStyle(isPresented ? accent.base : .ink)
        }
        .accessibilityLabel(Text(label))
        .accessibilityAddTraits(isPresented ? .isSelected : [])
    }
}

extension View {
    static var leadingPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .navigation
        #endif
    }
}

public extension View {
    /// A `PanelToggle` for each panel given, at the toolbar's leading and trailing ends.
    func workspaceToolbar(
        leading: Binding<Bool>? = nil,
        trailing: Binding<Bool>? = nil,
        leadingLabel: LocalizedStringKey? = nil,
        trailingLabel: LocalizedStringKey? = nil
    ) -> some View {
        toolbar {
            if let leading {
                ToolbarItem(placement: Self.leadingPlacement) { PanelToggle(.leading, isPresented: leading, label: leadingLabel) }
            }
            if let trailing {
                ToolbarItem(placement: .primaryAction) { PanelToggle(.trailing, isPresented: trailing, label: trailingLabel) }
            }
        }
    }
}

public extension Workspace {
    /// The leading panel as pages (`SegmentedPages`): their segments on top, the chosen one below.
    func leading<Page: PageKind, PageBody: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelWidth = .sidebar,
        pages selection: Binding<Page>,
        @ViewBuilder page: @escaping (Page) -> PageBody
    ) -> Workspace<SegmentedPages<Page, PageBody>, Content, Trailing> {
        leading(isPresented: isPresented, width: width, range: range) { SegmentedPages(selection: selection, page: page) }
    }

    /// The trailing panel as pages (`SegmentedPages`): their segments on top, the chosen one below,
    /// Xcode's inspector.
    func trailing<Page: PageKind, PageBody: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelWidth = .inspector,
        pages selection: Binding<Page>,
        @ViewBuilder page: @escaping (Page) -> PageBody
    ) -> Workspace<Leading, Content, SegmentedPages<Page, PageBody>> {
        trailing(isPresented: isPresented, width: width, range: range) { SegmentedPages(selection: selection, page: page) }
    }
}
