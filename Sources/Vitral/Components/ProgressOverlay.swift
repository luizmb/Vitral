import SwiftUI
import VitralTokens

/// Work the screen has to wait for: dims what's underneath, takes no taps through, and says what's
/// happening on a panel of regular (frosted) glass, whatever the environment's glass: what's
/// underneath is changing, and it shouldn't show through the words. `fraction` (0 ... 1) shows a
/// bar; without it, a spinner.
public struct ProgressOverlay: View {
    let title: Text
    let detail: Text?
    let fraction: Double?

    @Environment(\.accent) private var accent

    public init(_ title: Text, detail: Text? = nil, fraction: Double? = nil) {
        self.title = title
        self.detail = detail
        self.fraction = fraction
    }

    public init(_ title: LocalizedStringKey, detail: Text? = nil, fraction: Double? = nil) {
        self.init(Text(title), detail: detail, fraction: fraction)
    }

    public var body: some View {
        ZStack {
            Color(.scrim)
                .ignoresSafeArea()
            Panel(material: .regular) {
                VStack(spacing: Space.medium) {
                    if let fraction {
                        title.font(.bodyStrong)
                        ProgressView(value: fraction)
                            .progressViewStyle(.linear)
                            .tint(Color(accent.base))
                    } else {
                        ProgressView().controlSize(.large)
                        title.font(.bodyStrong)
                    }
                    detail
                        .font(.detail)
                        .foregroundStyle(.inkMuted)
                        .lineLimit(2)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 320)
            .padding(Space.extraLarge)
        }
        .foregroundStyle(.ink)
        // Swallows touches: what's underneath is being changed.
        .contentShape(Rectangle())
        .onTapGesture {}
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

public extension View {
    /// Covers the view with `overlay` while it's there, softly blurring what's underneath.
    func progressOverlay(_ overlay: ProgressOverlay?) -> some View {
        blur(radius: overlay == nil ? 0 : Space.extraSmall / 2)
            .overlay { overlay }
    }
}
