import SwiftUI
import VitralTokens

/// The binding API of the continuous controls, on top of their events: what `Knob(value: Binding…)`
/// and `Fader(value: Binding…)` have always done, a change written to the binding and `onEditingEnded`
/// called whenever an edit is over (any finger lift, a double tap's reset, a VoiceOver step).
func writingEvents(
    to value: Binding<Double>,
    resetValue: Double?,
    onEditingEnded: @escaping () -> Void
) -> (ControlEvent<Double>) -> Void {
    { event in
        switch event {
        case .pressed:
            break
        case let .changed(newValue):
            value.wrappedValue = newValue
        case .released, .cancelled:
            onEditingEnded()
        case .resetRequested:
            if let resetValue {
                value.wrappedValue = resetValue
                onEditingEnded()
            }
        case let .stepped(newValue):
            value.wrappedValue = newValue
            onEditingEnded()
        }
    }
}
