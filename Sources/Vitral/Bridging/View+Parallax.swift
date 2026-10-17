import SwiftUI
import VitralTokens

public extension View {
    /// Makes this view a layer that drifts against its scroll view as it moves: the artwork inside a
    /// carousel's card, say, which slides a little slower than the card. The layer grows by
    /// `distance` on both sides so its edges never show; clip it with whatever holds it. Still
    /// with Reduce Motion.
    func parallaxLayer(_ axis: Axis = .horizontal, distance: Double = Motion.parallaxDistance) -> some View {
        modifier(ParallaxLayer(axis: axis, distance: distance))
    }
}

struct ParallaxLayer: ViewModifier {
    let axis: Axis
    let distance: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .padding(axis == .horizontal ? .horizontal : .vertical, -distance)
            .scrollTransition(axis: axis) { [distance = reduceMotion ? 0 : distance] layer, phase in
                layer.offset(
                    x: axis == .horizontal ? -phase.value * distance : 0,
                    y: axis == .vertical ? -phase.value * distance : 0
                )
            }
    }
}
