import SwiftUI
import VitralTokens

/// A run of code with what it is: the piece a highlighter hands over.
public struct CodeSpan: Hashable, Sendable {
    public let text: String
    public let role: SyntaxTheme.Role

    public init(_ text: String, _ role: SyntaxTheme.Role = .plain) {
        self.text = text
        self.role = role
    }
}

/// Code, already split into spans, in a theme's colours on its dark island: monospaced, never
/// wrapped (it scrolls sideways), and selectable. Vitral doesn't highlight; the app splits the
/// code and hands over the spans.
public struct CodeBlock: View {
    let spans: [CodeSpan]
    let theme: SyntaxTheme
    let font: TypeToken

    public init(_ spans: [CodeSpan], theme: SyntaxTheme = .neon, font: TypeToken = .codeSmall) {
        self.spans = spans
        self.theme = theme
        self.font = font
    }

    /// Plain code in one colour, for when there's nothing to highlight.
    public init(plain code: String, theme: SyntaxTheme = .neon, font: TypeToken = .codeSmall) {
        self.init([CodeSpan(code)], theme: theme, font: font)
    }

    public var body: some View {
        ScrollView(.horizontal) {
            Text(CodeBlock.attributed(spans, theme: theme))
                .font(font)
                .fixedSize(horizontal: true, vertical: false)
                .textSelection(.enabled)
                .padding(Space.large)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(theme.background), in: RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
    }

    static func attributed(_ spans: [CodeSpan], theme: SyntaxTheme) -> AttributedString {
        spans.reduce(into: AttributedString()) { text, span in
            text.append(AttributedString(span.text, attributes: AttributeContainer().foregroundColor(Color(theme.colour(span.role)))))
        }
    }
}
