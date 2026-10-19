import SwiftUI
import VitralTokens

public extension View {
    /// Sized for where it's shown: medium and large detents in a compact width (a phone), a
    /// page-sized sheet otherwise (a pad, a Mac), where detents would float a small panel in the
    /// middle of a big screen. Whether the width is compact is the app's to say, from its state.
    func adaptiveSheet(isCompact: Bool) -> some View {
        modifier(AdaptiveSheet(isCompact: isCompact))
    }
}

struct AdaptiveSheet: ViewModifier {
    let isCompact: Bool

    func body(content: Content) -> some View {
        if isCompact {
            content.presentationDetents([.medium, .large])
        } else {
            content.presentationSizing(.page)
        }
    }
}
