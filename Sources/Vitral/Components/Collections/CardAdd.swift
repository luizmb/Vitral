import SwiftUI
import VitralTokens

/// The card that makes a new one: a dashed outline on clear glass, an icon and a title, in the
/// grid among the cards it adds to.
public struct CardAdd: View {
    let title: LocalizedStringKey
    let icon: Image
    let action: @MainActor () -> Void

    public init(_ title: LocalizedStringKey, icon: Image = Image(.add), action: @escaping @MainActor () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: Space.medium) {
                icon
                    .font(.title2)
                    .frame(width: Size.controlLarge + Space.medium, height: Size.controlLarge + Space.medium)
                    .overlay(Circle().strokeBorder(Color(.outline), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])))
                Text(title).font(.bodyStrong)
            }
            .foregroundStyle(.inkMuted)
            .frame(maxWidth: .infinity, minHeight: 132)
            .glassSurface(.clear, cornerRadius: Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color(.outline), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
            .contentShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
