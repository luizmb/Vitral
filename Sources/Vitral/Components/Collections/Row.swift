import SwiftUI
import VitralTokens

/// How a row looks for its state, which the app's state decides: chosen, set aside, or calling for
/// attention.
public enum RowState: Hashable, Sendable {
    case normal
    /// The chosen one: a wash of the accent behind it.
    case selected
    /// Not available now (missing, disabled): faded.
    case dimmed
    /// Calling for attention (playing, firing, just changed): a wash of `colour` behind it.
    case highlighted(ColorToken = .counterAccent)
}

/// One line of a list: an optional leading part, a title with an optional subtitle, an optional
/// trailing detail and trailing part, and an optional chevron. Optional parts are added
/// builder-style (`.trailing { }`, `.disclosure()`, `.rowState(_:)`).
public struct Row<Leading: View, Trailing: View>: View {
    let title: Text
    let subtitle: Text?
    let detail: Text?
    let showsDisclosure: Bool
    let state: RowState
    let leading: Leading
    let trailing: Trailing

    @Environment(\.accent) private var accent

    init(
        title: Text,
        subtitle: Text?,
        detail: Text?,
        showsDisclosure: Bool,
        state: RowState,
        leading: Leading,
        trailing: Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.showsDisclosure = showsDisclosure
        self.state = state
        self.leading = leading
        self.trailing = trailing
    }

    public var body: some View {
        HStack(spacing: Space.medium) {
            leading
            VStack(alignment: .leading, spacing: Space.hairline) {
                title
                    .font(state == .selected ? .bodyStrong : .body)
                    .foregroundStyle(.ink)
                subtitle.map { subtitle in
                    subtitle
                        .font(.detail)
                        .foregroundStyle(.inkMuted)
                }
            }
            Spacer(minLength: Space.small)
            detail
                .font(TypeToken.detail.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.inkMuted)
            trailing
            if showsDisclosure {
                Image(.chevronForward)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.inkFaint)
            }
        }
        .padding(.horizontal, Space.large)
        .frame(minHeight: Size.hitTarget + Space.small)
        .background(wash.map { Color($0) })
        .opacity(state == .dimmed ? 0.45 : 1)
        .animation(.easeOut(duration: 0.2), value: state)
        .contentShape(Rectangle())
        // One element for VoiceOver: "Lungs, Respiratory tract, 2.1e-4", not three.
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(state == .selected ? .isSelected : [])
    }

    var wash: ColorToken? {
        switch state {
        case .normal, .dimmed: nil
        case .selected: accent.base.opacity(0.14)
        case let .highlighted(colour): colour.opacity(0.18)
        }
    }

    /// A part at the end of the row, before the chevron: a tag, a toggle, a button.
    public func trailing<Part: View>(@ViewBuilder _ part: () -> Part) -> Row<Leading, Part> {
        Row<Leading, Part>(
            title: title, subtitle: subtitle, detail: detail, showsDisclosure: showsDisclosure, state: state, leading: leading, trailing: part()
        )
    }

    /// The forward chevron: the row leads somewhere (in a `GlassList`, a `NavigationLink` row
    /// too).
    public func disclosure(_ shows: Bool = true) -> Row {
        Row(title: title, subtitle: subtitle, detail: detail, showsDisclosure: shows, state: state, leading: leading, trailing: trailing)
    }

    /// How the row looks for its state.
    public func rowState(_ state: RowState) -> Row {
        Row(title: title, subtitle: subtitle, detail: detail, showsDisclosure: showsDisclosure, state: state, leading: leading, trailing: trailing)
    }
}

public extension Row where Trailing == EmptyView {
    init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        detail: Text? = nil,
        showsDisclosure: Bool = false,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(Text(title), subtitle: subtitle.map { Text($0) }, detail: detail, showsDisclosure: showsDisclosure, leading: leading)
    }

    /// A row titled with `Text`: for a title that is the app's data (a name), shown as it is.
    init(
        _ title: Text,
        subtitle: Text? = nil,
        detail: Text? = nil,
        showsDisclosure: Bool = false,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(title: title, subtitle: subtitle, detail: detail, showsDisclosure: showsDisclosure, state: .normal, leading: leading(), trailing: EmptyView())
    }
}

public extension Row where Leading == EmptyView, Trailing == EmptyView {
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, detail: Text? = nil, showsDisclosure: Bool = false) {
        self.init(title, subtitle: subtitle, detail: detail, showsDisclosure: showsDisclosure) { EmptyView() }
    }

    /// A row titled with `Text`, with nothing before it.
    init(_ title: Text, subtitle: Text? = nil, detail: Text? = nil, showsDisclosure: Bool = false) {
        self.init(title, subtitle: subtitle, detail: detail, showsDisclosure: showsDisclosure) { EmptyView() }
    }
}
