/// The colours code is drawn in, by what each piece of it is. Colours only: splitting code into
/// pieces (highlighting) is the app's job; a theme says how each piece looks.
///
/// A theme is one appearance on purpose: code reads as an editor's dark island on light pages
/// too, so it has a single background and a single colour per role.
public struct SyntaxTheme: Hashable, Sendable {
    /// What a piece of code is. The raw values are the category names highlighters and
    /// stylesheets use (`token-keyword`, `token-comment-doc`, …).
    public enum Role: String, CaseIterable, Hashable, Sendable {
        case plain
        case keyword
        case string
        case regex
        case number
        case comment
        case docComment = "comment-doc"
        case mark
        case attribute
        case typeDeclaration = "declaration-type"
        case otherDeclaration = "declaration-other"
        case type
        case variable
        case functionCall = "function-call"
        case constant
        case macro
        case preprocessor
    }

    public var background: ColorToken
    public var colours: [Role: ColorToken]

    public init(background: ColorToken, colours: [Role: ColorToken]) {
        self.background = background
        self.colours = colours
    }

    /// The colour for `role`, or the plain one when the theme doesn't set it.
    public func colour(_ role: Role) -> ColorToken {
        colours[role] ?? colours[.plain] ?? ColorToken(.white)
    }
}

public extension SyntaxTheme {
    /// Bright colours on a dark slate: the theme used across the editors and the blog.
    static let neon = SyntaxTheme(
        background: ColorToken(RGBA(hex: 0x1E2028)),
        colours: [
            .plain: ColorToken(RGBA(hex: 0xFFFFFF)),
            .keyword: ColorToken(RGBA(hex: 0xFFE400)),
            .string: ColorToken(RGBA(hex: 0xFF2700)),
            .regex: ColorToken(RGBA(hex: 0xFF2700)),
            .number: ColorToken(RGBA(hex: 0xFF00E3)),
            .comment: ColorToken(RGBA(hex: 0x16FF00)),
            .docComment: ColorToken(RGBA(hex: 0x17BF06)),
            .mark: ColorToken(RGBA(hex: 0x92A1B1)),
            .attribute: ColorToken(RGBA(hex: 0x22FEF0)),
            .typeDeclaration: ColorToken(RGBA(hex: 0x5DD8FF)),
            .otherDeclaration: ColorToken(RGBA(hex: 0x41A1C0)),
            .type: ColorToken(RGBA(hex: 0x3EA58F)),
            .variable: ColorToken(RGBA(hex: 0x65DCF3)),
            .functionCall: ColorToken(RGBA(hex: 0x3F90CF)),
            .constant: ColorToken(RGBA(hex: 0x00FFC1)),
            .macro: ColorToken(RGBA(hex: 0xE58800)),
            .preprocessor: ColorToken(RGBA(hex: 0xFF8F04))
        ]
    )
}
