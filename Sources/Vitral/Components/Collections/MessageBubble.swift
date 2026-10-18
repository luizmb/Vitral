import SwiftUI
import VitralTokens

/// Whose message a bubble holds.
public enum MessageSide: Hashable, Sendable {
    /// The person using the app: on the trailing side, tinted with the accent.
    case mine
    /// Anyone else (another person, an assistant): on the leading side, plain glass.
    case theirs
}

/// One message of a conversation on glass, its author over it, on its side of the column.
/// Stateless: the text is the caller's.
public struct MessageBubble: View {
    let text: Text
    let author: Text?
    let side: MessageSide

    @Environment(\.accent) private var accent

    /// - Parameter author: shown small over the bubble (a name, "Assistant"); `nil` for none.
    public init(_ text: Text, author: Text? = nil, side: MessageSide) {
        self.text = text
        self.author = author
        self.side = side
    }

    public var body: some View {
        VStack(alignment: side == .mine ? .trailing : .leading, spacing: Space.extraSmall) {
            author
                .font(.detail)
                .foregroundStyle(.inkMuted)
            text
                .foregroundStyle(.ink)
                .textSelection(.enabled)
                .padding(.horizontal, Space.medium)
                .padding(.vertical, Space.small)
                .glassSurface(side == .mine ? GlassToken.clear.tinted(accent.base.opacity(0.22)) : nil, cornerRadius: Radius.large)
        }
        .frame(maxWidth: .infinity, alignment: side == .mine ? .trailing : .leading)
        .accessibilityElement(children: .combine)
    }
}
