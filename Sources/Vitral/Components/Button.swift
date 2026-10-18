import SwiftUI
import VitralTokens

/// How big a button is: its type and the least height it keeps (it grows with Dynamic Type).
public enum ButtonSize: Hashable, Sendable {
    case small, medium, large

    var type: TypeToken { self == .small ? .controlSmall : .control }
    var minHeight: Double {
        switch self {
        case .small: Size.controlSmall
        case .medium: Size.controlMedium
        case .large: Size.controlLarge
        }
    }
}

/// A button's content: an optional icon and a title. Every button style draws this, so they all
/// size and align alike. While `isBusy`, a spinner takes the icon's place.
public struct ButtonLabel: View {
    let title: LocalizedStringKey
    let icon: Image?
    let size: ButtonSize
    let fillsWidth: Bool
    let isBusy: Bool

    public init(_ title: LocalizedStringKey, icon: Image? = nil, size: ButtonSize = .large, fillsWidth: Bool = false, isBusy: Bool = false) {
        self.title = title
        self.icon = icon
        self.size = size
        self.fillsWidth = fillsWidth
        self.isBusy = isBusy
    }

    public var body: some View {
        HStack(spacing: Space.small) {
            if isBusy {
                ProgressView().controlSize(.small)
            } else {
                icon
            }
            Text(title)
        }
        .font(size.type)
        .lineLimit(1)
        .frame(maxWidth: fillsWidth ? .infinity : nil)
        // The glass button style adds its own vertical padding.
        .frame(minHeight: size.minHeight - Space.medium)
        .padding(.horizontal, Space.small)
    }
}

/// The main action on a screen: the system's accent-filled glass, or a finish (`finish:`, or the
/// environment's `.controlFinish(_:)`) for a clearer glass, a gel, a texture. One per screen, ideally. While `isBusy` it
/// shows a spinner and takes no taps.
public struct ButtonPrimary: View {
    let label: ButtonLabel
    let finish: FinishToken?
    let action: @MainActor () -> Void

    @Environment(\.accent) private var accent
    @Environment(\.controlFinish) private var controlFinish

    public init(
        _ title: LocalizedStringKey,
        icon: Image? = nil,
        size: ButtonSize = .large,
        fillsWidth: Bool = false,
        isBusy: Bool = false,
        finish: FinishToken? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = ButtonLabel(title, icon: icon, size: size, fillsWidth: fillsWidth, isBusy: isBusy)
        self.finish = finish
        self.action = action
    }

    /// Its own finish, else the environment's, its untinted glass tinted with the accent so the
    /// main action still stands out (as the system's prominent glass does). Neither: the system's
    /// prominent glass.
    var resolvedFinish: FinishToken? {
        finish ?? controlFinish.map { $0.tintingGlass(accent.base.opacity(0.6)) }
    }

    public var body: some View {
        if let finish = resolvedFinish {
            Button(action: action) { label }
                .disabled(label.isBusy)
                .buttonStyle(FinishButtonStyle(finish: finish))
        } else {
            Button(action: action) { label }
                .disabled(label.isBusy)
                .buttonStyle(.glassProminent)
                .tint(Color(accent.base))
        }
    }
}

/// Any other action: the system's glass, or a finish (`finish:`, or the environment's
/// `.controlFinish(_:)`).
public struct ButtonSecondary: View {
    let label: ButtonLabel
    let finish: FinishToken?
    let action: @MainActor () -> Void

    @Environment(\.controlFinish) private var controlFinish

    public init(
        _ title: LocalizedStringKey,
        icon: Image? = nil,
        size: ButtonSize = .large,
        fillsWidth: Bool = false,
        isBusy: Bool = false,
        finish: FinishToken? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = ButtonLabel(title, icon: icon, size: size, fillsWidth: fillsWidth, isBusy: isBusy)
        self.finish = finish
        self.action = action
    }

    /// Under an Aqua finish a secondary button is Aqua's silver gel, as on the Mac; any other
    /// finish it takes as it is.
    var resolvedFinish: FinishToken? {
        finish ?? controlFinish.map { shared in
            if case .aqua = shared { .aqua(.fixedSilver) } else { shared }
        }
    }

    public var body: some View {
        if let finish = resolvedFinish {
            Button(action: action) { label }
                .disabled(label.isBusy)
                .buttonStyle(FinishButtonStyle(finish: finish))
        } else {
            Button(action: action) { label }
                .disabled(label.isBusy)
                .buttonStyle(.glass)
                .foregroundStyle(.ink)
        }
    }
}

/// A button made of a finish: a capsule of it, the label in the light ink on a colour or the
/// dark ink otherwise, pressing in a little.
struct FinishButtonStyle: ButtonStyle {
    let finish: FinishToken

    /// The light ink on a colour, black on chrome or silver, the ink (dark by day, light at night)
    /// on glass or a texture.
    var ink: ColorToken {
        finish.tone == .fixedSilver || finish == .chrome
            ? .fixedBlack
            : finish.isColoured ? .onAccent : .ink
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ink)
            // Light text on a glossy colour sinks into the gloss; a soft shadow under it keeps it
            // readable, as Aqua's labels did.
            .shadow(color: Color(ColorToken.fixedBlack.opacity(ink == .onAccent && !finish.effects.isEmpty ? 0.35 : 0)), radius: 0.5, y: 1)
            // The label leaves the glass style its vertical padding; this finish adds the same.
            .padding(.vertical, Space.medium / 2)
            .padding(.horizontal, Space.medium)
            .finish(finish, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
