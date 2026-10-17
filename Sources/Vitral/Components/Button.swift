import SwiftUI
import VitralTokens

/// How big a button is: its type and the least height it keeps (it grows with Dynamic Type).
public enum ButtonSize: Hashable, Sendable {
    case small, medium, large

    var type: TypeToken { self == .small ? .controlSmall : .control }
    var minHeight: Double {
        switch self {
        case .small: Size.controlSmall
        case .medium: Size.controlMedium
        case .large: Size.controlLarge
        }
    }
}

/// A button's content: an optional icon and a title. Every button style draws this, so they all
/// size and align alike.
public struct ButtonLabel: View {
    let title: LocalizedStringKey
    let icon: Image?
    let size: ButtonSize
    let fillsWidth: Bool

    public init(_ title: LocalizedStringKey, icon: Image? = nil, size: ButtonSize = .large, fillsWidth: Bool = false) {
        self.title = title
        self.icon = icon
        self.size = size
        self.fillsWidth = fillsWidth
    }

    public var body: some View {
        HStack(spacing: Space.small) {
            icon
            Text(title)
        }
        .font(size.type)
        .lineLimit(1)
        .frame(maxWidth: fillsWidth ? .infinity : nil)
        // The glass button style adds its own vertical padding.
        .frame(minHeight: size.minHeight - Space.medium)
        .padding(.horizontal, Space.small)
    }
}

/// The main action on a screen: accent-filled glass. One per screen, ideally.
public struct ButtonPrimary: View {
    let label: ButtonLabel
    let action: @MainActor () -> Void

    public init(
        _ title: LocalizedStringKey,
        icon: Image? = nil,
        size: ButtonSize = .large,
        fillsWidth: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = ButtonLabel(title, icon: icon, size: size, fillsWidth: fillsWidth)
        self.action = action
    }

    public var body: some View {
        Button(action: action) { label }
            .buttonStyle(.glassProminent)
            .tint(Color(.accent))
    }
}

/// Any other action: clear glass.
public struct ButtonSecondary: View {
    let label: ButtonLabel
    let action: @MainActor () -> Void

    public init(
        _ title: LocalizedStringKey,
        icon: Image? = nil,
        size: ButtonSize = .large,
        fillsWidth: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = ButtonLabel(title, icon: icon, size: size, fillsWidth: fillsWidth)
        self.action = action
    }

    public var body: some View {
        Button(action: action) { label }
            .buttonStyle(.glass)
            .foregroundStyle(.ink)
    }
}
