import SwiftUI
import VitralTokens

/// A layer over everything behind it: glass across the whole area (frosted and dimmed by
/// default, so what's underneath recedes), taking no taps through, with `content` at `placement`.
/// The content is as big as it wants to be; the overlay only places it.
public struct Overlay<Content: View>: View {
    let placement: Alignment
    let material: GlassToken
    let content: Content

    public init(placement: Alignment = .center, material: GlassToken = .scrim, @ViewBuilder content: () -> Content) {
        self.placement = placement
        self.material = material
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: placement) {
            Rectangle()
                .fill(.clear)
                .glassEffect(.token(material), in: Rectangle())
                .ignoresSafeArea()
                // Swallows touches: what's underneath isn't to be used now.
                .contentShape(Rectangle())
                .onTapGesture {}
                .accessibilityHidden(true)
            content
                .padding(Space.extraLarge)
        }
    }
}

public extension GlassToken {
    /// An overlay's glass: clear glass tinted with the scrim, so what's behind it blurs and dims.
    static let scrim = GlassToken(.clear, tint: .scrim)
}

public extension View {
    /// An `Overlay` over this view while `isPresented`.
    func overlay<Content: View>(
        isPresented: Bool,
        placement: Alignment = .center,
        material: GlassToken = .scrim,
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay {
            if isPresented {
                Overlay(placement: placement, material: material, content: content)
            }
        }
    }

    /// An `Overlay` over this view while there's an `item`, its content made from it.
    func overlay<Item, Content: View>(
        item: Item?,
        placement: Alignment = .center,
        material: GlassToken = .scrim,
        @ViewBuilder content: (Item) -> Content
    ) -> some View {
        overlay {
            if let item {
                Overlay(placement: placement, material: material) { content(item) }
            }
        }
    }
}
