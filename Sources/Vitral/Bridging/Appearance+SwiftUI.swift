import SwiftUI
import VitralTokens

public extension Appearance {
    /// The scheme it draws in, given the one the device reports (which reaches the app through its
    /// world, never asked for here): the device's for `.system`, else its own.
    func resolved(device: ColorScheme) -> ColorScheme {
        switch self {
        case .system: device
        case .light: .light
        case .dark: .dark
        }
    }
}
