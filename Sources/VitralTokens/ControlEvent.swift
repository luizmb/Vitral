/// What happened to a continuous control (a knob, a fader), as it physically happened.
///
/// A control given `onEvent` reports these and never changes its value itself: the app decides what
/// each one means. That is what lets an app driving a remote device tell the user's hand from the
/// device's echoes, and send one message for a double tap instead of one per touch.
///
/// A drag reads `pressed`, `changed`…, `released`. A touch that moves nothing (a tap) reads `pressed`,
/// `cancelled`. A double tap reads `pressed, cancelled, pressed, cancelled` plus one `resetRequested`,
/// which may arrive before or after the second `cancelled` (the gesture system doesn't order them).
/// VoiceOver adjustments read one `stepped` each, complete on their own.
public enum ControlEvent<Value: Sendable>: Sendable {
    /// A finger is down on the control; nothing has changed yet.
    case pressed
    /// The finger moved past the touch slop: the value under it.
    case changed(Value)
    /// The finger lifted after changing the value.
    case released
    /// The finger lifted without changing anything: a tap, or either half of a double tap.
    case cancelled
    /// A double tap: the app's reset value is wanted. The control changes nothing itself.
    case resetRequested
    /// One VoiceOver increment or decrement: the new value, a complete change on its own.
    case stepped(Value)
}

extension ControlEvent: Equatable where Value: Equatable {}

/// A touch on a continuous control, so its events can be told apart: whether a finger is down, and
/// whether it has changed the value yet. Pure, for control implementations: each step returns the next
/// touch and the event to report.
public enum ControlTouch: Sendable, Equatable {
    case idle
    case pressed
    case changed

    /// The finger is on the control (every drag update): `pressed` on the first, nothing after.
    public func touching<Value>() -> (ControlTouch, ControlEvent<Value>?) {
        self == .idle ? (.pressed, .pressed) : (self, nil)
    }

    /// The finger moved the value to `value`.
    public func changing<Value>(to value: Value) -> (ControlTouch, ControlEvent<Value>) {
        (.changed, .changed(value))
    }

    /// The finger lifted: `released` after a change, `cancelled` after none.
    public func lifting<Value>() -> (ControlTouch, ControlEvent<Value>) {
        (.idle, self == .changed ? .released : .cancelled)
    }
}
