import Testing
@testable import VitralTokens

@Suite("ControlTouch")
struct ControlTouchTests {
    /// Runs a sequence of touch steps from idle and collects the events they report.
    func events(_ steps: [(ControlTouch) -> (ControlTouch, ControlEvent<Double>?)]) -> [ControlEvent<Double>] {
        steps.reduce((ControlTouch.idle, [ControlEvent<Double>]())) { acc, step in
            let (touch, event) = step(acc.0)
            return (touch, acc.1 + (event.map { [$0] } ?? []))
        }.1
    }

    let touch: (ControlTouch) -> (ControlTouch, ControlEvent<Double>?) = { $0.touching() }
    let lift: (ControlTouch) -> (ControlTouch, ControlEvent<Double>?) = { let (t, e): (ControlTouch, ControlEvent<Double>) = $0.lifting(); return (t, e) }
    func change(_ value: Double) -> (ControlTouch) -> (ControlTouch, ControlEvent<Double>?) {
        { let (t, e) = $0.changing(to: value); return (t, e) }
    }

    @Test func aDragReportsPressedChangesReleased() {
        #expect(events([touch, touch, change(0.2), touch, change(0.4), lift]) == [.pressed, .changed(0.2), .changed(0.4), .released])
    }

    @Test func aTapIsPressedThenCancelled() {
        #expect(events([touch, touch, touch, lift]) == [.pressed, .cancelled])
    }

    @Test func eachTouchStartsAfresh() {
        // The two halves of a double tap, each a tap of its own.
        #expect(events([touch, lift, touch, lift]) == [.pressed, .cancelled, .pressed, .cancelled])
    }

    @Test func aChangeAfterLiftingNeedsANewPress() {
        #expect(events([touch, change(0.5), lift, touch, lift]) == [.pressed, .changed(0.5), .released, .pressed, .cancelled])
    }
}
