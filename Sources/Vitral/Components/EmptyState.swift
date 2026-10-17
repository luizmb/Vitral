import SwiftUI
import VitralTokens

/// What a screen or a column shows when there's nothing to show: a picture, a title, an optional
/// message, and anything to do about it added with `.actions { }`. A blank space reads as broken;
/// this says what's going on.
public struct EmptyState<Artwork: View, Actions: View>: View {
    let artwork: Artwork
    let title: LocalizedStringKey
    let message: Text?
    let actions: Actions

    public var body: some View {
        VStack(spacing: Space.medium) {
            artwork.accessibilityHidden(true)
            VStack(spacing: Space.extraSmall) {
                Text(title)
                    .font(.title)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                message
                    .font(.callout)
                    .foregroundStyle(.inkMuted)
            }
            .multilineTextAlignment(.center)
            actions.padding(.top, Space.small)
        }
        .padding(.horizontal, Space.extraLarge)
        .frame(maxWidth: 440)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Puts `actions` (a button or two) under the message.
    public func actions<NewActions: View>(@ViewBuilder _ actions: () -> NewActions) -> EmptyState<Artwork, NewActions> {
        EmptyState<Artwork, NewActions>(artwork: artwork, title: title, message: message, actions: actions())
    }
}

public extension EmptyState where Actions == EmptyView {
    /// With one of Vitral's illustrations.
    init(_ title: LocalizedStringKey, message: Text? = nil, illustration: Illustration = .empty) where Artwork == IllustrationView {
        self.init(artwork: IllustrationView(illustration), title: title, message: message, actions: EmptyView())
    }

    /// With a symbol, for tighter spaces (a side column, an inspector).
    init(_ title: LocalizedStringKey, message: Text? = nil, icon: Image) where Artwork == SymbolArtwork {
        self.init(artwork: SymbolArtwork(icon), title: title, message: message, actions: EmptyView())
    }
}

/// An illustration at its natural size, shrinking (never growing) to fit.
public struct IllustrationView: View {
    let illustration: Illustration

    public init(_ illustration: Illustration) {
        self.illustration = illustration
    }

    public var body: some View {
        Image(illustration)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 160, maxHeight: 160)
    }
}

/// A symbol drawn large and faint, standing in for an illustration.
public struct SymbolArtwork: View {
    let icon: Image

    public init(_ icon: Image) {
        self.icon = icon
    }

    public var body: some View {
        icon
            .font(.largeTitle)
            .foregroundStyle(.inkFaint)
    }
}

/// Something went wrong: the broken-pane illustration, what happened, and a way to try again when
/// there is one.
public struct ErrorScreen: View {
    let title: LocalizedStringKey
    let message: Text?
    let illustration: Illustration
    let retryTitle: LocalizedStringKey
    let onRetry: (@MainActor () -> Void)?

    /// - Parameters:
    ///   - message: what happened, in the reader's terms. `Text` so it can carry values
    ///     ("Couldn't reach \(host)").
    ///   - onRetry: shows a "try again" button when given.
    public init(
        _ title: LocalizedStringKey,
        message: Text? = nil,
        illustration: Illustration = .error,
        retryTitle: LocalizedStringKey = "Try again",
        onRetry: (@MainActor () -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.illustration = illustration
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    public var body: some View {
        EmptyState(title, message: message, illustration: illustration)
            .actions {
                onRetry.map { retry in ButtonPrimary(retryTitle, icon: Image(.retry), action: retry) }
            }
    }
}
