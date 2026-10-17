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
    case leading, trailing, bottom

    var edge: Edge {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        case .bottom: .bottom
        }
    }
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

/// One of a workspace's panels: whether it's open, how big it is across (a side panel's width, a
/// bottom panel's height), and what's in it.
public struct WorkspacePanel<Body: View> {
    let isPresented: Binding<Bool>
    let size: Binding<Double>?
    let range: PanelSize
    let body: Body

    var isOpen: Bool { isPresented.wrappedValue }

    /// Its size, never past `available`: when a mode is forced onto a screen too small for the
    /// panels' minimums, the panels share what there is.
    func resolvedSize(fitting available: Double) -> Double {
        min(range.clamped(size?.wrappedValue ?? range.ideal), available)
    }
}

/// A screen made of content and the panels around it, like Xcode's: a leading panel (a sidebar),
/// a trailing one (an inspector) and a bottom one (a console), each shown or hidden through its
/// binding. Docked when there's room (the bottom panel under the content, between the sides),
/// floating over the content at middle widths, in one sheet on a narrow screen; the mode can be
/// forced on any screen (`Workspace(mode: .floating)`). Give a panel a size binding and its inner
/// edge drags to resize it.
///
/// Panels shouldn't hold a `NavigationStack`: inside a column it takes over the app's.
public struct Workspace<Leading: View, Content: View, Trailing: View, Bottom: View>: View {
    let mode: WorkspaceMode?
    let exclusive: Bool
    let content: Content
    let leading: WorkspacePanel<Leading>?
    let trailing: WorkspacePanel<Trailing>?
    let bottom: WorkspacePanel<Bottom>?

    @Environment(\.panelAnimation) private var animation
    @Environment(\.panelTransition) private var transition

    static var space: String { "vitral.workspace" }

    public var body: some View {
        GeometryReader { proxy in
            let resolved = mode ?? WorkspaceMode.fitting(width: proxy.size.width, panels: [leading?.range.ideal, trailing?.range.ideal].compactMap { $0 })
            layout(resolved, size: proxy.size)
                .environment(\.workspaceMode, resolved)
                // Sheets are one at a time anyway, so there they always are.
                .onChange(of: leading?.isOpen) { _, isOpen in
                    if exclusive || resolved == .sheet, isOpen == true { close(.trailing, .bottom) }
                }
                .onChange(of: trailing?.isOpen) { _, isOpen in
                    if exclusive || resolved == .sheet, isOpen == true { close(.leading, .bottom) }
                }
                .onChange(of: bottom?.isOpen) { _, isOpen in
                    if exclusive || resolved == .sheet, isOpen == true { close(.leading, .trailing) }
                }
        }
        .coordinateSpace(.named(Self.space))
        .animation(animation, value: leading?.isOpen)
        .animation(animation, value: trailing?.isOpen)
        .animation(animation, value: bottom?.isOpen)
    }

    func close(_ sides: PanelSide...) {
        for side in sides {
            switch side {
            case .leading: leading?.isPresented.wrappedValue = false
            case .trailing: trailing?.isPresented.wrappedValue = false
            case .bottom: bottom?.isPresented.wrappedValue = false
            }
        }
    }

    @ViewBuilder
    func layout(_ mode: WorkspaceMode, size: CGSize) -> some View {
        switch mode {
        case .docked:
            HStack(spacing: 0) {
                if let leading, leading.isOpen {
                    dockedSide(leading, side: .leading, width: size.width)
                }
                VStack(spacing: 0) {
                    content.frame(maxWidth: .infinity, maxHeight: .infinity)
                    if let bottom, bottom.isOpen {
                        dockedBottom(bottom, height: size.height)
                    }
                }
                if let trailing, trailing.isOpen {
                    dockedSide(trailing, side: .trailing, width: size.width)
                }
            }
        case .floating:
            ZStack {
                content.frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack(alignment: .bottom, spacing: Space.medium) {
                    if let leading, leading.isOpen {
                        floatingSide(leading, side: .leading, width: size.width)
                    }
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        if let bottom, bottom.isOpen {
                            floatingBottom(bottom, height: size.height)
                        }
                    }
                    if let trailing, trailing.isOpen {
                        floatingSide(trailing, side: .trailing, width: size.width)
                    }
                }
                .padding(Space.medium)
            }
        case .sheet:
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sheet(isPresented: anySheet) {
                    // One sheet for every panel: opening another swaps what's in it.
                    if leading?.isOpen == true {
                        leading.map { sheet($0.body) }
                    } else if trailing?.isOpen == true {
                        trailing.map { sheet($0.body) }
                    } else {
                        bottom.map { sheet($0.body) }
                    }
                }
        }
    }

    /// Whether a panel's sheet is up; dismissing it closes them all.
    var anySheet: Binding<Bool> {
        Binding(
            get: { openPanels > 0 },
            set: { isUp in
                if !isUp { close(.leading, .trailing, .bottom) }
            }
        )
    }

    /// How many side panels are open.
    var openPanels: Int {
        [leading?.isOpen, trailing?.isOpen, bottom?.isOpen].filter { $0 == true }.count
    }

    var openSides: Int {
        [leading?.isOpen, trailing?.isOpen].filter { $0 == true }.count
    }

    /// The most each docked side panel can take: what's left after the content's share, or, when
    /// that's too little, an equal share with the content.
    func dockedRoom(_ width: Double) -> Double {
        max((width - Size.workspaceContent) / Double(max(openSides, 1)), width / Double(openSides + 1))
    }

    /// The most each floating side panel can take: the screen less its margins, shared.
    func floatingRoom(_ width: Double) -> Double {
        min(width * 0.8, (width - Space.medium * Double(openSides + 1)) / Double(max(openSides, 1)))
    }

    /// The most a bottom panel can take: three quarters of the height, the content keeping a
    /// quarter.
    func bottomRoom(_ height: Double) -> Double {
        height * 0.75
    }

    func dockedSide<Panel: View>(_ panel: WorkspacePanel<Panel>, side: PanelSide, width: Double) -> some View {
        panel.body
            .frame(width: panel.resolvedSize(fitting: dockedRoom(width)))
            .frame(maxHeight: .infinity, alignment: .top)
            .glassSurface(cornerRadius: 0)
            .overlay(alignment: side == .leading ? .trailing : .leading) {
                ZStack {
                    Hairline(.vertical)
                    resizeHandle(panel, side: side, inset: 0, extent: width)
                }
            }
            // Over the content, so the half of the resize strip on its side still takes the drag.
            .zIndex(1)
            .transition(panelTransition(side))
    }

    func dockedBottom<Panel: View>(_ panel: WorkspacePanel<Panel>, height: Double) -> some View {
        panel.body
            .frame(height: panel.resolvedSize(fitting: bottomRoom(height)))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .glassSurface(cornerRadius: 0)
            .overlay(alignment: .top) {
                ZStack {
                    Hairline()
                    resizeHandle(panel, side: .bottom, inset: 0, extent: height)
                }
            }
            .zIndex(1)
            .transition(panelTransition(.bottom))
    }

    func floatingSide<Panel: View>(_ panel: WorkspacePanel<Panel>, side: PanelSide, width: Double) -> some View {
        floatingGlass(panel.body)
            .frame(width: panel.resolvedSize(fitting: floatingRoom(width)))
            .frame(maxHeight: .infinity, alignment: .top)
            .overlay(alignment: side == .leading ? .trailing : .leading) {
                resizeHandle(panel, side: side, inset: Space.medium, extent: width)
            }
            .transition(panelTransition(side))
    }

    func floatingBottom<Panel: View>(_ panel: WorkspacePanel<Panel>, height: Double) -> some View {
        floatingGlass(panel.body)
            .frame(height: panel.resolvedSize(fitting: bottomRoom(height)))
            .frame(maxWidth: .infinity)
            .overlay(alignment: .top) {
                resizeHandle(panel, side: .bottom, inset: Space.medium, extent: height)
            }
            .transition(panelTransition(.bottom))
    }

    func floatingGlass<Panel: View>(_ panel: Panel) -> some View {
        panel
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sheet, style: .continuous))
            .glassSurface(.regular, cornerRadius: Radius.sheet)
            .shadow(color: Color(.scrim), radius: Space.large, y: Space.extraSmall)
    }

    func sheet<Panel: View>(_ panel: Panel) -> some View {
        panel
            .presentationDetents([.fraction(1 / 3), .fraction(2 / 3), .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(2 / 3)))
            .presentationContentInteraction(.scrolls)
            .presentationDragIndicator(.visible)
    }

    /// A strip on the panel's inner edge: dragging it sets the size to where the finger is, in
    /// the workspace's coordinates (`extent` is the workspace's width, or its height for the
    /// bottom panel), so nothing about the drag has to be remembered.
    @ViewBuilder
    func resizeHandle<Panel: View>(_ panel: WorkspacePanel<Panel>, side: PanelSide, inset: Double, extent: Double) -> some View {
        if let binding = panel.size {
            Color.clear
                .frame(width: side == .bottom ? nil : Space.extraLarge, height: side == .bottom ? Space.extraLarge : nil)
                .frame(maxWidth: side == .bottom ? .infinity : nil, maxHeight: side == .bottom ? nil : .infinity)
                .contentShape(Rectangle())
                // Centred on the edge, half over the panel and half over the content.
                .offset(
                    x: side == .leading ? Space.extraLarge / 2 : side == .trailing ? -Space.extraLarge / 2 : 0,
                    y: side == .bottom ? -Space.extraLarge / 2 : 0
                )
                .gesture(
                    DragGesture(minimumDistance: 1, coordinateSpace: .named(Self.space))
                        .onChanged { drag in
                            binding.wrappedValue = panel.range.clamped(Self.size(side: side, location: drag.location, inset: inset, extent: extent))
                        }
                )
                .accessibilityHidden(true)
        }
    }

    /// The panel size a finger at `location` asks for.
    static func size(side: PanelSide, location: CGPoint, inset: Double, extent: Double) -> Double {
        switch side {
        case .leading: location.x - inset
        case .trailing: extent - location.x - inset
        case .bottom: extent - location.y - inset
        }
    }

    func panelTransition(_ side: PanelSide) -> AnyTransition {
        switch transition {
        case .slide: .move(edge: side.edge)
        case .slideAndFade: .move(edge: side.edge).combined(with: .opacity)
        case .fade: .opacity
        }
    }
}

public extension Workspace where Leading == EmptyView, Trailing == EmptyView, Bottom == EmptyView {
    /// A workspace around `content`; add panels with `.leading { }`, `.trailing { }` and
    /// `.bottom { }`.
    /// - Parameters:
    ///   - mode: forces how panels show; `nil` picks it from the width.
    ///   - exclusive: one panel at a time, opening one closing the others (it turns their bindings
    ///     off): docked panels forced onto an iPhone then never squeeze the content.
    init(mode: WorkspaceMode? = nil, exclusive: Bool = false, @ViewBuilder content: () -> Content) {
        self.mode = mode
        self.exclusive = exclusive
        self.content = content()
        self.leading = nil
        self.trailing = nil
        self.bottom = nil
    }
}

public extension Workspace {
    /// The leading panel, open while `isPresented`. With a `width` binding its edge drags to
    /// resize it within `range`.
    func leading<Panel: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelSize = .sidebar,
        @ViewBuilder content: () -> Panel
    ) -> Workspace<Panel, Content, Trailing, Bottom> {
        Workspace<Panel, Content, Trailing, Bottom>(
            mode: mode,
            exclusive: exclusive,
            content: self.content,
            leading: WorkspacePanel(isPresented: isPresented, size: width, range: range, body: content()),
            trailing: trailing,
            bottom: bottom
        )
    }

    /// The trailing panel, open while `isPresented`. With a `width` binding its edge drags to
    /// resize it within `range`.
    func trailing<Panel: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelSize = .inspector,
        @ViewBuilder content: () -> Panel
    ) -> Workspace<Leading, Content, Panel, Bottom> {
        Workspace<Leading, Content, Panel, Bottom>(
            mode: mode,
            exclusive: exclusive,
            content: self.content,
            leading: leading,
            trailing: WorkspacePanel(isPresented: isPresented, size: width, range: range, body: content()),
            bottom: bottom
        )
    }

    /// The bottom panel, Xcode's debug area: under the content, between the side panels, open
    /// while `isPresented`. With a `height` binding its top edge drags to resize it within `range`.
    func bottom<Panel: View>(
        isPresented: Binding<Bool>,
        height: Binding<Double>? = nil,
        range: PanelSize = .console,
        @ViewBuilder content: () -> Panel
    ) -> Workspace<Leading, Content, Trailing, Panel> {
        Workspace<Leading, Content, Trailing, Panel>(
            mode: mode,
            exclusive: exclusive,
            content: self.content,
            leading: leading,
            trailing: trailing,
            bottom: WorkspacePanel(isPresented: isPresented, size: height, range: range, body: content())
        )
    }

    /// The leading panel as pages (`SegmentedPages`): their segments on top, the chosen one below.
    func leading<Page: PageKind, PageBody: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelSize = .sidebar,
        pages selection: Binding<Page>,
        @ViewBuilder page: @escaping (Page) -> PageBody
    ) -> Workspace<SegmentedPages<Page, PageBody>, Content, Trailing, Bottom> {
        leading(isPresented: isPresented, width: width, range: range) { SegmentedPages(selection: selection, page: page) }
    }

    /// The trailing panel as pages (`SegmentedPages`): their segments on top, the chosen one below,
    /// Xcode's inspector.
    func trailing<Page: PageKind, PageBody: View>(
        isPresented: Binding<Bool>,
        width: Binding<Double>? = nil,
        range: PanelSize = .inspector,
        pages selection: Binding<Page>,
        @ViewBuilder page: @escaping (Page) -> PageBody
    ) -> Workspace<Leading, Content, SegmentedPages<Page, PageBody>, Bottom> {
        trailing(isPresented: isPresented, width: width, range: range) { SegmentedPages(selection: selection, page: page) }
    }

    /// The bottom panel as pages (`SegmentedPages`): output, logs, a console side by side.
    func bottom<Page: PageKind, PageBody: View>(
        isPresented: Binding<Bool>,
        height: Binding<Double>? = nil,
        range: PanelSize = .console,
        pages selection: Binding<Page>,
        @ViewBuilder page: @escaping (Page) -> PageBody
    ) -> Workspace<Leading, Content, Trailing, SegmentedPages<Page, PageBody>> {
        bottom(isPresented: isPresented, height: height, range: range) { SegmentedPages(selection: selection, page: page) }
    }
}

/// Shows or hides a workspace panel: the panel symbol for its side, filled while it's open. Put it
/// anywhere; `.workspaceToolbar` puts them in the toolbar.
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
        self.label = label ?? PanelToggle.defaultLabel(side)
    }

    static func defaultLabel(_ side: PanelSide) -> LocalizedStringKey {
        switch side {
        case .leading: "Sidebar"
        case .trailing: "Inspector"
        case .bottom: "Bottom panel"
        }
    }

    var glyph: Glyph {
        switch side {
        case .leading: .panelLeading
        case .trailing: .panelTrailing
        case .bottom: .panelBottom
        }
    }

    public var body: some View {
        Button {
            withAnimation(animation) { isPresented.toggle() }
        } label: {
            Image(glyph)
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
    /// A `PanelToggle` for each panel given: the leading one at the toolbar's leading end, the
    /// bottom and trailing ones at its trailing end.
    func workspaceToolbar(
        leading: Binding<Bool>? = nil,
        trailing: Binding<Bool>? = nil,
        bottom: Binding<Bool>? = nil,
        leadingLabel: LocalizedStringKey? = nil,
        trailingLabel: LocalizedStringKey? = nil,
        bottomLabel: LocalizedStringKey? = nil
    ) -> some View {
        toolbar {
            if let leading {
                ToolbarItem(placement: Self.leadingPlacement) { PanelToggle(.leading, isPresented: leading, label: leadingLabel) }
            }
            if let bottom {
                ToolbarItem(placement: .primaryAction) { PanelToggle(.bottom, isPresented: bottom, label: bottomLabel) }
            }
            if let trailing {
                ToolbarItem(placement: .primaryAction) { PanelToggle(.trailing, isPresented: trailing, label: trailingLabel) }
            }
        }
    }
}
