import SwiftUI
import VitralTokens

/// The mark of a choice: filled with the accent and a check when selected, an outline otherwise.
/// Round for one-of-many (radio), square for each-on-its-own (checkbox).
public struct SelectionMark: View {
    public enum Shape: Hashable, Sendable {
        case round, square
    }

    let isSelected: Bool
    let shape: Shape

    public init(isSelected: Bool, shape: Shape = .round) {
        self.isSelected = isSelected
        self.shape = shape
    }

    private var outline: RoundedRectangle {
        RoundedRectangle(cornerRadius: shape == .round ? Size.selectionMark / 2 : Radius.extraSmall, style: .continuous)
    }

    public var body: some View {
        ZStack {
            if isSelected {
                outline
                    .fill(LinearGradient(colors: [Color(.accentTop), Color(.accentBottom)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: Color(.accentGlow), radius: 5, y: 2)
                Image(.checkmark)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.onAccent)
            } else {
                outline.strokeBorder(Color(.outline), lineWidth: 1.5)
            }
        }
        .frame(width: Size.selectionMark, height: Size.selectionMark)
        .accessibilityHidden(true)
    }
}

/// An option that's on or off by itself: a square mark and its label. Reads as a toggle to
/// VoiceOver.
public struct Checkbox: View {
    let title: LocalizedStringKey
    @Binding var isOn: Bool

    public init(_ title: LocalizedStringKey, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    public var body: some View {
        Button { isOn.toggle() } label: {
            HStack(spacing: Space.medium) {
                SelectionMark(isSelected: isOn, shape: .square)
                Text(title)
                    .font(.body)
                    .foregroundStyle(.ink)
            }
            .frame(minHeight: Size.hitTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation { Toggle(title, isOn: $isOn) }
    }
}

/// A setting that takes effect at once: the system switch, in the accent.
public struct ToggleSwitch: View {
    let title: LocalizedStringKey
    @Binding var isOn: Bool

    public init(_ title: LocalizedStringKey, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.body)
                .foregroundStyle(.ink)
        }
        .toggleStyle(.switch)
        .tint(Color(.accent))
        .frame(minHeight: Size.hitTarget)
    }
}
