import Vitral
import VitralTokens

/// Just enough Swift highlighting for the Gallery's samples: comments, strings, numbers, keywords,
/// attributes, types, members and calls. Not a parser; the Gallery's own code is all it reads.
enum SwiftHighlighter {
    static let keywords: Set<String> = [
        "let", "var", "func", "struct", "enum", "case", "switch", "if", "else", "for", "in", "while", "return",
        "true", "false", "nil", "self", "Self", "some", "any", "init", "static", "private", "public", "import",
        "guard", "default", "where", "extension", "protocol", "class", "final", "inout", "throws", "async", "await"
    ]

    static func spans(_ code: String) -> [CodeSpan] {
        merged(tokens(Array(code), from: 0, previous: nil))
    }

    /// The tokens from `index` on; `previous` is the last character before them that isn't a space.
    static func tokens(_ text: [Character], from index: Int, previous: Character?) -> [CodeSpan] {
        index < text.count ? followed(text, token(text, at: index, previous: previous), previous: previous) : []
    }

    static func followed(_ text: [Character], _ token: (span: CodeSpan, end: Int), previous: Character?) -> [CodeSpan] {
        [token.span] + tokens(text, from: token.end, previous: token.span.text.last { !$0.isWhitespace } ?? previous)
    }

    /// One token at `index`, and where the next starts.
    static func token(_ text: [Character], at index: Int, previous: Character?) -> (span: CodeSpan, end: Int) {
        switch text[index] {
        case "/" where index + 1 < text.count && text[index + 1] == "/":
            commented(span(text, index, text[index...].firstIndex(of: "\n") ?? text.count, .comment))
        case "\"":
            span(text, index, stringEnd(text, from: index + 1), .string)
        case "@":
            span(text, index, wordEnd(text, from: index + 1), .attribute)
        case let digit where digit.isNumber:
            span(text, index, text[index...].firstIndex { !($0.isNumber || $0 == "." || $0 == "_") } ?? text.count, .number)
        case let letter where letter.isLetter || letter == "_":
            word(text, index, wordEnd(text, from: index), previous: previous)
        default:
            span(text, index, index + 1, .plain)
        }
    }

    static func span(_ text: [Character], _ start: Int, _ end: Int, _ role: SyntaxTheme.Role) -> (span: CodeSpan, end: Int) {
        (CodeSpan(String(text[start ..< end]), role), end)
    }

    /// A comment, a documentation one when it starts with three slashes.
    static func commented(_ token: (span: CodeSpan, end: Int)) -> (span: CodeSpan, end: Int) {
        token.span.text.hasPrefix("///") ? (CodeSpan(token.span.text, .docComment), token.end) : token
    }

    static func word(_ text: [Character], _ start: Int, _ end: Int, previous: Character?) -> (span: CodeSpan, end: Int) {
        span(text, start, end, role(of: String(text[start ..< end]), after: previous, before: end < text.count ? text[end] : nil))
    }

    static func role(of word: String, after previous: Character?, before next: Character?) -> SyntaxTheme.Role {
        keywords.contains(word) ? .keyword
            : word.first?.isUppercase == true ? .type
            : next == "(" || next == "{" ? .functionCall
            : previous == "." ? .variable
            : .plain
    }

    static func wordEnd(_ text: [Character], from index: Int) -> Int {
        text[index...].firstIndex { !($0.isLetter || $0.isNumber || $0 == "_") } ?? text.count
    }

    /// Past the closing quote, skipping escaped ones.
    static func stringEnd(_ text: [Character], from index: Int) -> Int {
        index >= text.count || text[index] == "\"" || text[index] == "\n"
            ? min(index + 1, text.count)
            : stringEnd(text, from: index + (text[index] == "\\" ? 2 : 1))
    }

    /// Neighbouring spans of one role joined, so the text is a few runs, not one per character.
    static func merged(_ spans: [CodeSpan]) -> [CodeSpan] {
        spans.reduce(into: []) { runs, span in
            if let last = runs.last, last.role == span.role {
                runs[runs.count - 1] = CodeSpan(last.text + span.text, span.role)
            } else {
                runs.append(span)
            }
        }
    }
}
