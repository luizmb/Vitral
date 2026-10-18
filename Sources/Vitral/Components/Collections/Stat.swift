import SwiftUI
import VitralTokens

/// A figure with its icon: how many of something.
public struct Stat: View {
    let icon: Image
    let value: Text
    let accessibilityLabel: Text

    /// - Parameter accessibilityLabel: what VoiceOver says, since the icon alone means nothing
    ///   spoken ("12 compartments").
    public init(icon: Image, value: Text, accessibilityLabel: Text) {
        self.icon = icon
        self.value = value
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Label { value } icon: { icon }
            .font(.detail)
            .foregroundStyle(.inkFaint)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
    }
}
