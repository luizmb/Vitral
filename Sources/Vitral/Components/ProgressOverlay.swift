import SwiftUI
import VitralTokens

/// Work the screen has to wait for: dims what's underneath, takes no taps through, and says what's
/// happening on a glass panel. `fraction` (0 ... 1) shows a bar; without it, a spinner.
public struct ProgressOverlay: View {
    let title: Text
    let detail: Text?
    let fraction: Double?

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
            Color(ColorToken(.black).opacity(0.25))
                .ignoresSafeArea()
            Panel {
                VStack(spacing: Space.medium) {
                    if let fraction {
                        ProgressView(value: fraction) { title.font(.bodyStrong) }
                            .progressViewStyle(.linear)
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
    /// Covers the view with `overlay` while it's there.
    func progressOverlay(_ overlay: ProgressOverlay?) -> some View {
        self.overlay { overlay }
    }
}
