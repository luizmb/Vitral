import SwiftUI
import VitralTokens

/// A capsule of glass around any content: a toolbar's cluster of icons, a status, a small
/// control. With an `action` it's a button and the glass answers the touch; `isActive` marks it on
/// with the active glass (a light wash of the accent).
public struct Pill<Content: View>: View {
    let isActive: Bool
    let action: (@MainActor () -> Void)?
    let content: Content

    public init(isActive: Bool = false, action: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.isActive = isActive
        self.action = action
        self.content = content()
    }

    var glass: GlassToken {
        (isActive ? GlassToken.active : .regular).interactive(action != nil)
    }

    public var body: some View {
        if let action {
            Button(action: action) { capsule }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isActive ? .isSelected : [])
        } else {
            capsule
        }
    }

    var capsule: some View {
        content
            .foregroundStyle(.ink)
            .glassCapsule(glass)
    }
}
