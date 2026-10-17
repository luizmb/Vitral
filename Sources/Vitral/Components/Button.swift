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
/// size and align alike. While `isBusy`, a spinner takes the icon's place.
public struct ButtonLabel: View {
    let title: LocalizedStringKey
    let icon: Image?
    let size: ButtonSize
    let fillsWidth: Bool
    let isBusy: Bool

    public init(_ title: LocalizedStringKey, icon: Image? = nil, size: ButtonSize = .large, fillsWidth: Bool = false, isBusy: Bool = false) {
        self.title = title
        self.icon = icon
        self.size = size
        self.fillsWidth = fillsWidth
        self.isBusy = isBusy
    }

    public var body: some View {
        HStack(spacing: Space.small) {
            if isBusy {
                ProgressView().controlSize(.small)
            } else {
                icon
            }
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

/// The main action on a screen: accent-filled glass. One per screen, ideally. While `isBusy` it
/// shows a spinner and takes no taps.
public struct ButtonPrimary: View {
    let label: ButtonLabel
    let action: @MainActor () -> Void

    @Environment(\.accent) private var accent

    public init(
        _ title: LocalizedStringKey,
        icon: Image? = nil,
        size: ButtonSize = .large,
        fillsWidth: Bool = false,
        isBusy: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = ButtonLabel(title, icon: icon, size: size, fillsWidth: fillsWidth, isBusy: isBusy)
        self.action = action
    }

    public var body: some View {
        Button(action: action) { label }
            .disabled(label.isBusy)
            .buttonStyle(.glassProminent)
            .tint(Color(accent.base))
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
        isBusy: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = ButtonLabel(title, icon: icon, size: size, fillsWidth: fillsWidth, isBusy: isBusy)
        self.action = action
    }

    public var body: some View {
        Button(action: action) { label }
            .disabled(label.isBusy)
            .buttonStyle(.glass)
            .foregroundStyle(.ink)
    }
}
