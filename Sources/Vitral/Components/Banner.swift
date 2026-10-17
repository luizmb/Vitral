import SwiftUI
import VitralTokens

/// How serious a banner is: which colours and default icon it takes.
public enum BannerTone: Hashable, Sendable {
    case neutral, warning, danger

    var foreground: ColorToken {
        switch self {
        case .neutral: .inkMuted
        case .warning: .warning
        case .danger: .danger
        }
    }

    var background: ColorToken {
        switch self {
        case .neutral: .neutralSurface
        case .warning: .warningSurface
        case .danger: .dangerSurface
        }
    }

    var glyph: Glyph {
        switch self {
        case .neutral: .info
        case .warning: .warning
        case .danger: .error
        }
    }
}

/// A message across the content: something to know (neutral), to watch (warning) or that went
/// wrong (danger). Anything to do about it goes after the message with `.trailing { }`.
public struct Banner<Trailing: View>: View {
    let tone: BannerTone
    let icon: Image
    let message: Text
    let trailing: Trailing

    public var body: some View {
        HStack(spacing: Space.small) {
            icon
                .font(.subheadline.weight(.medium))
                .accessibilityHidden(true)
            message
                .font(TypeToken(.subheadline, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            trailing
        }
        .foregroundStyle(tone.foreground)
        .padding(.horizontal, Space.medium + Space.hairline)
        .padding(.vertical, Space.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surface(tone.background, cornerRadius: Radius.medium)
        .accessibilityElement(children: .combine)
    }

    /// Puts `trailing` (a button, usually) after the message.
    public func trailing<NewTrailing: View>(@ViewBuilder _ trailing: () -> NewTrailing) -> Banner<NewTrailing> {
        Banner<NewTrailing>(tone: tone, icon: icon, message: message, trailing: trailing())
    }
}

public extension Banner where Trailing == EmptyView {
    init(_ message: LocalizedStringKey, tone: BannerTone = .neutral, icon: Image? = nil) {
        self.init(Text(message), tone: tone, icon: icon)
    }

    init(_ message: Text, tone: BannerTone = .neutral, icon: Image? = nil) {
        self.init(tone: tone, icon: icon ?? Image(tone.glyph), message: message, trailing: EmptyView())
    }
}
