/// The symbols components draw, by role. The raw value is the SF Symbol name, so the UI layer draws
/// them with the system's symbol images.
public enum Glyph: String, CaseIterable, Hashable, Sendable {
    case checkmark = "checkmark"
    case close = "xmark"
    case add = "plus"
    case chevronBack = "chevron.left"
    case chevronForward = "chevron.right"
    case chevronBackDouble = "chevron.left.2"
    case chevronForwardDouble = "chevron.right.2"
    case warning = "exclamationmark.triangle"
    case error = "exclamationmark.octagon"
    case info = "info.circle"
    case retry = "arrow.clockwise"
    case play = "play.fill"
}
