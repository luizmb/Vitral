import SwiftUI
import VitralTokens

/// A list on the backdrop: the platform's own (lazy, its rows reused as they scroll, with
/// selection, swipe actions, reordering and editing), its rows on a frosted veil instead of the
/// system's grey. Stateless: the rows come from the caller's `ForEach` over its state, and every
/// change goes back out as an event (`selection`, `.onDelete`, `.onMove`, `.rowActions`), for the
/// app's state to apply.
///
/// Each row sits on the environment's glass (`.surfaceGlass(_:)`); a list only draws the rows on
/// screen, so it stays cheap. A `NavigationLink` row shows no system chevron: give it
/// `.disclosure()`, the same chevron as every other row.
public struct GlassList<Selection: Hashable, Content: View>: View {
    let selection: Binding<Selection?>?
    let content: Content

    @Environment(\.accent) private var accent

    /// A list whose rows are picked: tapping one reports its `tag` through `selection` (from the
    /// app's state, dispatching the choice). Show the chosen row with `.rowState(.selected)`.
    public init(selection: Binding<Selection?>, @ViewBuilder content: () -> Content) {
        self.selection = selection
        self.content = content()
    }

    public var body: some View {
        styled
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, Size.hitTarget)
            .tint(Color(accent.base))
    }

    var styled: some View {
        #if os(iOS)
        list
            .listStyle(.insetGrouped)
            .listSectionSpacing(Space.large)
        #else
        list.listStyle(.inset)
        #endif
    }

    @ViewBuilder
    var list: some View {
        if let selection {
            List(selection: selection) { content }
        } else {
            List { content }
        }
    }
}

public extension GlassList where Selection == Never {
    /// A list nothing is picked from.
    init(@ViewBuilder content: () -> Content) {
        self.selection = nil
        self.content = content()
    }
}

/// A section of a `GlassList`: a header (its title, and an optional trailing part such as a count
/// or a button) over rows on the veil.
public struct GlassSection<Trailing: View, Content: View>: View {
    let title: LocalizedStringKey?
    let trailing: Trailing
    let content: Content

    public init(_ title: LocalizedStringKey? = nil, @ViewBuilder trailing: () -> Trailing, @ViewBuilder content: () -> Content) {
        self.title = title
        self.trailing = trailing()
        self.content = content()
    }

    public var body: some View {
        Section {
            content
                .listRowInsets(EdgeInsets())
                .listRowBackground(GlassRowBackground())
                .listRowSeparatorTint(Color(.hairline))
                // One chevron for every row: rows that lead somewhere say so with `.disclosure()`.
                .navigationLinkIndicatorVisibility(.hidden)
        } header: {
            if title != nil || Trailing.self != EmptyView.self {
                HStack {
                    title.map { SectionLabel($0) }
                    Spacer()
                    trailing
                        .font(.detail)
                        .foregroundStyle(.inkMuted)
                }
                .textCase(nil)
            }
        }
    }
}

public extension GlassSection where Trailing == EmptyView {
    init(_ title: LocalizedStringKey? = nil, @ViewBuilder content: () -> Content) {
        self.init(title, trailing: { EmptyView() }, content: content)
    }
}

/// A row's background: the environment's glass, cut square (the section rounds the ends).
struct GlassRowBackground: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .glassSurface(cornerRadius: 0)
    }
}

/// Something to do to a row, offered by swiping it and in its context menu.
public struct RowAction {
    let title: LocalizedStringKey
    let icon: Image?
    let role: ButtonRole?
    let tint: ColorToken?
    let action: @MainActor () -> Void

    public init(
        _ title: LocalizedStringKey,
        icon: Image? = nil,
        role: ButtonRole? = nil,
        tint: ColorToken? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.role = role
        self.tint = tint
        self.action = action
    }
}

public extension View {
    /// `actions` on this row: swiped in from `edge` (the first one runs on a full swipe) and in its
    /// context menu. Each only reports the tap; the app's state does the change.
    func rowActions(_ actions: [RowAction], edge: HorizontalEdge = .trailing) -> some View {
        swipeActions(edge: edge) {
            ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                RowActionButton(action: action)
                    .tint(action.tint.map { Color($0) })
            }
        }
        .contextMenu {
            ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                RowActionButton(action: action)
            }
        }
    }
}

struct RowActionButton: View {
    let action: RowAction

    var body: some View {
        Button(role: action.role) {
            action.action()
        } label: {
            if let icon = action.icon {
                Label { Text(action.title) } icon: { icon }
            } else {
                Text(action.title)
            }
        }
    }
}
