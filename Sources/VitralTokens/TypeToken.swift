/// A text style: one of the platform's Dynamic Type styles, so text grows and shrinks with the
/// reader's setting, plus a weight and a design.
public struct TypeToken: Hashable, Sendable {
    public enum Style: Hashable, Sendable {
        case largeTitle, title, title2, title3, headline, subheadline, body, callout, footnote, caption, caption2
    }

    public enum Weight: Hashable, Sendable {
        case regular, medium, semibold, bold
    }

    public enum Design: Hashable, Sendable {
        case `default`, rounded, monospaced
    }

    public var style: Style
    public var weight: Weight
    public var design: Design

    public init(_ style: Style, weight: Weight = .regular, design: Design = .default) {
        self.style = style
        self.weight = weight
        self.design = design
    }

    public func weight(_ weight: Weight) -> TypeToken {
        TypeToken(style, weight: weight, design: design)
    }
}

public extension TypeToken {
    static let title = TypeToken(.title3, weight: .bold)
    static let body = TypeToken(.body)
    static let bodyStrong = TypeToken(.body, weight: .semibold)
    static let control = TypeToken(.body, weight: .semibold)
    static let controlSmall = TypeToken(.subheadline, weight: .semibold)
    static let detail = TypeToken(.footnote)
    static let value = TypeToken(.body, weight: .semibold, design: .monospaced)
    /// Code, in the system's monospaced face (SF Mono): a block of it, and a smaller size for
    /// long listings.
    static let code = TypeToken(.body, design: .monospaced)
    static let codeSmall = TypeToken(.footnote, design: .monospaced)
    /// Uppercase section headers.
    static let sectionLabel = TypeToken(.caption, weight: .semibold)
}
