import SwiftUI
import VitralTokens

/// How a banner looks: a preset for each kind of message, each with its colour and icon, or
/// `custom` with every part chosen.
public enum BannerStyle: Sendable {
    /// Something to know.
    case info
    /// Something that worked.
    case success
    /// Something to watch.
    case warning
    /// Something that went wrong.
    case error
    /// Quiet: a note in ink, no colour of its own.
    case neutral
    case custom(foreground: ColorToken, background: ColorToken, icon: Image)

    var foreground: ColorToken {
        switch self {
        case .info: .info
        case .success: .success
        case .warning: .warning
        case .error: .danger
        case .neutral: .inkMuted
        case let .custom(foreground, _, _): foreground
        }
    }

    var background: ColorToken {
        switch self {
        case .info: .infoSurface
        case .success: .successSurface
        case .warning: .warningSurface
        case .error: .dangerSurface
        case .neutral: .neutralSurface
        case let .custom(_, background, _): background
        }
    }

    var icon: Image {
        switch self {
        case .info, .neutral: Image(.info)
        case .success: Image(.success)
        case .warning: Image(.warning)
        case .error: Image(Glyph.error)
        case let .custom(_, _, icon): icon
        }
    }
}

/// A message across the content, styled by what kind of message it is. Anything to do about it
/// goes after the message with `.trailing { }`.
public struct Banner<Trailing: View>: View {
    let style: BannerStyle
    let message: Text
    let trailing: Trailing

    public var body: some View {
        HStack(spacing: Space.small) {
            style.icon
                .font(.subheadline.weight(.medium))
                .accessibilityHidden(true)
            message
                .font(TypeToken(.subheadline, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            trailing
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, Space.medium + Space.hairline)
        .padding(.vertical, Space.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surface(style.background, cornerRadius: Radius.medium)
        .accessibilityElement(children: .combine)
    }

    /// Puts `trailing` (a button, usually) after the message.
    public func trailing<NewTrailing: View>(@ViewBuilder _ trailing: () -> NewTrailing) -> Banner<NewTrailing> {
        Banner<NewTrailing>(style: style, message: message, trailing: trailing())
    }
}

public extension Banner where Trailing == EmptyView {
    init(_ message: LocalizedStringKey, style: BannerStyle = .info) {
        self.init(Text(message), style: style)
    }

    init(_ message: Text, style: BannerStyle = .info) {
        self.init(style: style, message: message, trailing: EmptyView())
    }
}
