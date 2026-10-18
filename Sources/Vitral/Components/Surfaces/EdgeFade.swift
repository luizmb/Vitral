import SwiftUI
import VitralTokens

/// A soft fade where content runs under a bar: a thin frosting, strongest at the screen's edge and
/// gone `beyond` points past the safe area, like a scroll view's edge effect for content that
/// isn't a scroll view (a canvas, a chart). Its depth is the safe-area inset on that edge (the bar,
/// the home indicator), never a fixed height. It draws into the safe area and takes no touches.
public struct EdgeFade: View {
    let edge: VerticalEdge
    let beyond: Double

    public init(_ edge: VerticalEdge, beyond: Double = Space.huge) {
        self.edge = edge
        self.beyond = beyond
    }

    public var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        stops: [.init(color: .black, location: 0), .init(color: .black.opacity(0.6), location: 0.45), .init(color: .clear, location: 1)],
                        startPoint: edge == .top ? .top : .bottom,
                        endPoint: edge == .top ? .bottom : .top
                    )
                )
                .frame(height: (edge == .top ? proxy.safeAreaInsets.top : proxy.safeAreaInsets.bottom) + beyond)
                .frame(maxHeight: .infinity, alignment: edge == .top ? .top : .bottom)
                .ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
