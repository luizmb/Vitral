import SwiftUI
import VitralTokens

/// One line of a list: an optional leading view, a title with an optional subtitle, and an
/// optional trailing detail. In a `NavigationLink` it shows the forward chevron.
public struct Row<Leading: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?
    let detail: Text?
    let showsDisclosure: Bool
    let leading: Leading

    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        detail: Text? = nil,
        showsDisclosure: Bool = false,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.showsDisclosure = showsDisclosure
        self.leading = leading()
    }

    public var body: some View {
        HStack(spacing: Space.medium) {
            leading
            VStack(alignment: .leading, spacing: Space.hairline) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.ink)
                subtitle.map { subtitle in
                    Text(subtitle)
                        .font(.detail)
                        .foregroundStyle(.inkMuted)
                }
            }
            Spacer(minLength: Space.small)
            detail
                .font(TypeToken.detail.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.inkMuted)
            if showsDisclosure {
                Image(.chevronForward)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.inkFaint)
            }
        }
        .padding(.horizontal, Space.large)
        .frame(minHeight: Size.hitTarget + Space.small)
        .contentShape(Rectangle())
    }
}

public extension Row where Leading == EmptyView {
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, detail: Text? = nil, showsDisclosure: Bool = false) {
        self.init(title, subtitle: subtitle, detail: detail, showsDisclosure: showsDisclosure) { EmptyView() }
    }
}
