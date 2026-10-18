import SwiftUI
import Vitral
import VitralTokens

/// Code in the neon theme, the theme's roles, and code text styles.
struct CodePage: View {
    /// A snippet, split by hand the way a highlighter would.
    static let sample: [CodeSpan] = [
        CodeSpan("/// Doses a compartment receives.\n", .docComment),
        CodeSpan("@MainActor", .attribute), CodeSpan(" "),
        CodeSpan("struct", .keyword), CodeSpan(" "), CodeSpan("Compartment", .typeDeclaration), CodeSpan(": "),
        CodeSpan("Sendable", .type), CodeSpan(" {\n    "),
        CodeSpan("let", .keyword), CodeSpan(" "), CodeSpan("name", .otherDeclaration), CodeSpan(": "), CodeSpan("String", .type), CodeSpan("\n    "),
        CodeSpan("var", .keyword), CodeSpan(" "), CodeSpan("halfLife", .otherDeclaration), CodeSpan(" = "), CodeSpan("2.45e5", .number),
        CodeSpan(" "), CodeSpan("// years", .comment), CodeSpan("\n\n    "),
        CodeSpan("func", .keyword), CodeSpan(" "), CodeSpan("label", .otherDeclaration), CodeSpan("() -> "), CodeSpan("String", .type),
        CodeSpan(" {\n        "), CodeSpan("\"U-234 \\(", .string), CodeSpan("name", .variable), CodeSpan(")\"", .string),
        CodeSpan("."), CodeSpan("uppercased", .functionCall), CodeSpan("()\n    }\n}")
    ]

    var body: some View {
        Page("Code") {
            Sample("CodeBlock(spans, theme: .neon)") {
                CodeBlock(Self.sample)
            }
            Sample("CodeBlock(plain:)") {
                CodeBlock(plain: "swift test 2>&1 | xcsift")
            }
            Sample("SyntaxTheme.neon") {
                CodeBlock(SyntaxTheme.Role.allCases.map { CodeSpan("\($0.rawValue)\n", $0) }, font: .code)
            }
            Sample("Inline, Font(.code)") {
                Panel {
                    Text("Run \(Text(verbatim: "xcodegen generate").font(Font(.code))) after adding a file.")
                        .foregroundStyle(.ink)
                }
            }
        }
    }
}
