import SwiftUI
import VitralTokens

/// The appearance to draw in: the system's, light or dark, as three icons on a glass capsule. The
/// labels are what VoiceOver says for each.
public struct AppearancePicker: View {
    public enum AccessibilityID {
        public static let picker = "vitral.appearancePicker"
    }

    @Binding var selection: Appearance
    let systemLabel: LocalizedStringKey
    let lightLabel: LocalizedStringKey
    let darkLabel: LocalizedStringKey

    public init(
        selection: Binding<Appearance>,
        systemLabel: LocalizedStringKey,
        lightLabel: LocalizedStringKey,
        darkLabel: LocalizedStringKey
    ) {
        self._selection = selection
        self.systemLabel = systemLabel
        self.lightLabel = lightLabel
        self.darkLabel = darkLabel
    }

    public var body: some View {
        SegmentedControlGlass(
            selection: $selection,
            options: [
                ChoiceOption(Appearance.system, icon: Image(.appearanceSystem), accessibilityLabel: systemLabel),
                ChoiceOption(Appearance.light, icon: Image(.appearanceLight), accessibilityLabel: lightLabel),
                ChoiceOption(Appearance.dark, icon: Image(.appearanceDark), accessibilityLabel: darkLabel)
            ]
        )
        .fixedSize()
        .accessibilityIdentifier(AccessibilityID.picker)
    }
}
