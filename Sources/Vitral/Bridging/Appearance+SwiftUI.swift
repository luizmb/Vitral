import SwiftUI
import VitralTokens

public extension Appearance {
    /// The colour scheme it forces, or `nil` for the system's.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

public extension View {
    /// Draws this view, and everything in it, light or dark whatever the system is set to;
    /// `.system` leaves it as it is. Token colours, Vitral's images and glass all follow, since they
    /// resolve from the environment's colour scheme. For a whole window, with its bars, pair it with
    /// `preferredColorScheme(appearance.colorScheme)`.
    func appearance(_ appearance: Appearance) -> some View {
        modifier(AppearanceOverride(appearance: appearance))
    }
}

/// Sets the environment's colour scheme to the forced one, or passes on the one it was given, so
/// switching back to `.system` doesn't rebuild the view.
struct AppearanceOverride: ViewModifier {
    let appearance: Appearance

    @Environment(\.colorScheme) private var inherited

    func body(content: Content) -> some View {
        content.environment(\.colorScheme, appearance.colorScheme ?? inherited)
    }
}
