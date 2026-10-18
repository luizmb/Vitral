import SwiftUI
import VitralTokens

public extension View {
    /// Sized for where it's shown: medium and large detents on a phone, a page-sized sheet on a
    /// pad or a Mac, where detents would float a small panel in the middle of a big screen.
    func adaptiveSheet() -> some View {
        modifier(AdaptiveSheet())
    }
}

struct AdaptiveSheet: ViewModifier {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    func body(content: Content) -> some View {
        #if os(iOS)
        if sizeClass == .compact {
            content.presentationDetents([.medium, .large])
        } else {
            content.presentationSizing(.page)
        }
        #else
        content.presentationSizing(.page)
        #endif
    }
}
