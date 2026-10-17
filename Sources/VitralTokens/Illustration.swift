/// The illustrations Vitral ships, by what they say. The raw value is the asset's name.
public enum Illustration: String, CaseIterable, Hashable, Sendable {
    /// A window with a pane fallen out: something went wrong.
    case error = "broken-pane"
    /// A clear window waiting for its colours: nothing here yet.
    case empty = "empty-frame"
    /// A magnifier over clear glass: a search found nothing.
    case noResults = "no-results"
    /// A glass cloud, cut through: no connection.
    case offline
}
