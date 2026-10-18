import SwiftUI
import VitralTokens

/// A button that stays down while it's on, as a desk's mute and solo do: a short label, lit in
/// `lit` when on, glass when off. Stateless: on is the binding's.
public struct ToggleButtonLatched: View {
    let title: Text
    let lit: ColorToken
    let litInk: ColorToken
    let accessibilityLabel: Text?
    @Binding var isOn: Bool

    /// - Parameters:
    ///   - lit: its colour when on.
    ///   - litInk: the label's colour when on.
    public init(_ title: Text, isOn: Binding<Bool>, lit: ColorToken = .danger, litInk: ColorToken = .fixedWhite, accessibilityLabel: Text? = nil) {
        self.title = title
        self._isOn = isOn
        self.lit = lit
        self.litInk = litInk
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Button { isOn.toggle() } label: {
            label
                .contentShape(RoundedRectangle(cornerRadius: Radius.extraSmall, style: .continuous))
        }
        .buttonStyle(.plain)
        .fixedSize()
        .accessibilityRepresentation { Toggle(isOn: $isOn) { accessibilityLabel ?? title } }
    }

    /// Lit: solid colour with a glow, nothing over it. Off: clear glass.
    @ViewBuilder
    var label: some View {
        let face = title
            .font(TypeToken.detail.weight(.bold))
            .frame(minWidth: Size.controlSmall, minHeight: Size.controlSmall)
        if isOn {
            face
                .foregroundStyle(Color(litInk))
                .background(Color(lit), in: RoundedRectangle(cornerRadius: Radius.extraSmall, style: .continuous))
                .shadow(color: Color(lit.opacity(0.6)), radius: 4)
        } else {
            face
                .foregroundStyle(Color(.ink))
                .glassSurface(.clear, cornerRadius: Radius.extraSmall)
        }
    }
}
