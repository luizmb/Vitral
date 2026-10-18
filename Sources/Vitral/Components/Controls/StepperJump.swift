import SwiftUI
import VitralTokens

/// `| « | ‹ | 5,000 | › | » |`: a whole number on one capsule, with a fine step (‹ ›) and a
/// coarse one (« ») either side, kept within `range`. A step that would leave the range is
/// disabled.
public struct StepperJump: View {
    /// Identifiers of the four steps, for UI tests.
    public enum AccessibilityID {
        public static let decreaseCoarse = "vitral.stepperJump.decreaseCoarse"
        public static let decreaseFine = "vitral.stepperJump.decreaseFine"
        public static let increaseFine = "vitral.stepperJump.increaseFine"
        public static let increaseCoarse = "vitral.stepperJump.increaseCoarse"
    }

    @Binding var value: Int
    let fine: Int
    let coarse: Int
    let range: ClosedRange<Int>
    let decreaseLabel: @Sendable (Int) -> Text
    let increaseLabel: @Sendable (Int) -> Text

    /// - Parameters:
    ///   - decreaseLabel: what VoiceOver says for a step down by the given amount ("Minus 20 days").
    ///   - increaseLabel: the same for a step up.
    public init(
        value: Binding<Int>,
        fine: Int = 1,
        coarse: Int = 10,
        range: ClosedRange<Int> = 1 ... .max,
        decreaseLabel: @escaping @Sendable (Int) -> Text = { Text("Minus \($0)") },
        increaseLabel: @escaping @Sendable (Int) -> Text = { Text("Plus \($0)") }
    ) {
        self._value = value
        self.fine = fine
        self.coarse = coarse
        self.range = range
        self.decreaseLabel = decreaseLabel
        self.increaseLabel = increaseLabel
    }

    public var body: some View {
        HStack(spacing: 0) {
            step(-coarse, glyph: .chevronBackDouble, id: AccessibilityID.decreaseCoarse)
            Hairline(.vertical).frame(height: Space.large + Space.hairline)
            step(-fine, glyph: .chevronBack, id: AccessibilityID.decreaseFine)
            Hairline(.vertical).frame(height: Space.large + Space.hairline)
            Text(value, format: .number)
                .font(.value)
                .foregroundStyle(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Space.extraSmall)
            Hairline(.vertical).frame(height: Space.large + Space.hairline)
            step(fine, glyph: .chevronForward, id: AccessibilityID.increaseFine)
            Hairline(.vertical).frame(height: Space.large + Space.hairline)
            step(coarse, glyph: .chevronForwardDouble, id: AccessibilityID.increaseCoarse)
        }
        .frame(minHeight: Size.hitTarget)
        .glassCapsule()
        .accessibilityElement(children: .contain)
    }

    private func canStep(_ delta: Int) -> Bool {
        delta < 0 ? value > range.lowerBound : value < range.upperBound
    }

    private func step(_ delta: Int, glyph: Glyph, id: String) -> some View {
        Button { value = min(range.upperBound, max(range.lowerBound, value + delta)) } label: {
            Image(glyph)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(canStep(delta) ? .ink : .inkFaint)
                .frame(width: Size.hitTarget, height: Size.hitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .disabled(!canStep(delta))
        .accessibilityLabel(delta < 0 ? decreaseLabel(-delta) : increaseLabel(delta))
        .accessibilityIdentifier(id)
    }
}
