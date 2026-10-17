/// Which appearance a screen, or a part of one, is drawn in: the system's, or light or dark
/// whatever the system is set to. A plain value, so an app's state can hold the user's choice.
public enum Appearance: String, CaseIterable, Hashable, Sendable {
    case system
    case light
    case dark
}
