import SwiftUI
import VitralTokens

/// One option of a choice: its value, and how it reads (a title, an icon, or both). The
/// accessibility label is what VoiceOver says, so icon-only options still have a name.
public struct ChoiceOption<Value: Hashable & Sendable>: Identifiable {
    public let value: Value
    public let title: Text?
    public let icon: Image?
    public let detail: Text?
    public let accessibilityLabel: Text

    public var id: Value { value }

    public init(_ value: Value, title: LocalizedStringKey, icon: Image? = nil, detail: Text? = nil) {
        self.init(value, title: Text(title), icon: icon, detail: detail)
    }

    /// An option titled with a `Text`: for a title that is the app's data (a device's name), which
    /// is shown as it is rather than looked up.
    public init(_ value: Value, title: Text, icon: Image? = nil, detail: Text? = nil) {
        self.value = value
        self.title = title
        self.icon = icon
        self.detail = detail
        self.accessibilityLabel = title
    }

    public init(_ value: Value, icon: Image, accessibilityLabel: LocalizedStringKey) {
        self.value = value
        self.title = nil
        self.icon = icon
        self.detail = nil
        self.accessibilityLabel = Text(accessibilityLabel)
    }
}

/// One of a few options, side by side on a glass capsule; the chosen one lifted on a lighter pill.
public struct SegmentedControlGlass<Value: Hashable & Sendable>: View {
    @Binding var selection: Value
    let options: [ChoiceOption<Value>]

    public init(selection: Binding<Value>, options: [ChoiceOption<Value>]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        HStack(spacing: Space.hairline) {
            ForEach(options) { option in
                Segment(option: option, isSelected: option.value == selection) { selection = option.value }
            }
        }
        .padding(Space.hairline + 1)
        .glassCapsule()
    }
}

/// One segment of a `SegmentedControlGlass`.
public struct Segment<Value: Hashable & Sendable>: View {
    @Environment(\.vitralScheme) private var scheme
    let option: ChoiceOption<Value>
    let isSelected: Bool
    let action: @MainActor () -> Void

    public init(option: ChoiceOption<Value>, isSelected: Bool, action: @escaping @MainActor () -> Void) {
        self.option = option
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Space.extraSmall) {
                option.icon
                option.title
            }
            .font(TypeToken.controlSmall.weight(isSelected ? .semibold : .medium))
            .foregroundStyle(isSelected ? .ink : .inkMuted)
            .lineLimit(1)
            .frame(minWidth: Size.hitTarget, maxWidth: .infinity, minHeight: Size.controlSmall + Space.extraSmall)
            .background {
                if isSelected {
                    Capsule().fill(Color(.selectedSurface, scheme: scheme)).shadow(color: Color(.hairline, scheme: scheme), radius: 3, y: 1)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// One of several options, each on its own row with a round mark: for choices that need a line
/// (or a detail) each.
public struct RadioList<Value: Hashable & Sendable>: View {
    @Binding var selection: Value
    let options: [ChoiceOption<Value>]

    public init(selection: Binding<Value>, options: [ChoiceOption<Value>]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        PanelList {
            ForEach(options) { option in
                RadioRow(option: option, isSelected: option.value == selection) { selection = option.value }
            }
        }
    }
}

/// One row of a `RadioList`: the mark, the title, and the detail on the trailing side.
public struct RadioRow<Value: Hashable & Sendable>: View {
    @Environment(\.vitralScheme) private var scheme
    let option: ChoiceOption<Value>
    let isSelected: Bool
    let action: @MainActor () -> Void

    public init(option: ChoiceOption<Value>, isSelected: Bool, action: @escaping @MainActor () -> Void) {
        self.option = option
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Space.medium) {
                SelectionMark(isSelected: isSelected)
                option.icon
                option.title
                    .font(isSelected ? .bodyStrong : .body)
                    .foregroundStyle(.ink)
                Spacer(minLength: Space.small)
                option.detail
                    .font(TypeToken.detail.weight(.medium))
                    .fontDesign(.monospaced)
                    .foregroundStyle(.inkFaint)
            }
            .padding(.horizontal, Space.large)
            .frame(minHeight: Size.hitTarget + Space.small)
            .background(isSelected ? Color(.selectedSurface, scheme: scheme).opacity(0.5) : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
