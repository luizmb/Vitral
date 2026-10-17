import SwiftUI
import VitralTokens

/// Actions side by side along an edge (a card's foot), an upright hairline between each two.
/// Titled buttons share the width; icon-only ones keep to a tap target.
public struct ActionBar<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 0) {
            Group(subviews: content) { buttons in
                ForEach(buttons) { button in
                    if button.id != buttons.first?.id {
                        Hairline(.vertical).frame(height: Space.extraLarge)
                    }
                    button
                }
            }
        }
    }
}

/// One action of an `ActionBar`: an icon with an optional title, in the accent, or in the danger
/// colour for a destructive one.
public struct ActionBarButton: View {
    let title: LocalizedStringKey?
    let icon: Image
    let accessibilityLabel: LocalizedStringKey
    let role: ButtonRole?
    let isBusy: Bool
    let action: @MainActor () -> Void

    @Environment(\.accent) private var accent

    /// - Parameter accessibilityLabel: what VoiceOver says. Needed when there's no title, and kept
    ///   for both so a title can be dropped on narrow layouts without losing it.
    public init(
        _ title: LocalizedStringKey? = nil,
        icon: Image,
        accessibilityLabel: LocalizedStringKey,
        role: ButtonRole? = nil,
        isBusy: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.isBusy = isBusy
        self.title = title
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.role = role
        self.action = action
    }

    public var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: Space.small) {
                if isBusy {
                    ProgressView().controlSize(.small)
                } else {
                    icon.font(.subheadline.weight(.medium))
                }
                title.map { Text($0).font(.controlSmall).lineLimit(1).minimumScaleFactor(0.8) }
            }
            .foregroundStyle(role == .destructive ? .danger : accent.base)
            .frame(maxWidth: title == nil ? nil : .infinity)
            .frame(minWidth: Size.hitTarget, minHeight: Size.hitTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}
