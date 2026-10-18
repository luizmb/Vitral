import SwiftUI
import VitralTokens

/// How much an overlay hides what's underneath, beyond its glass: a blur and a darkening.
public struct Obscuring: Hashable, Sendable {
    /// How far what's underneath is blurred, in points (through `.overlay(isPresented:)` and
    /// `.overlay(item:)`, which can blur the view they cover).
    public var blur: Double
    /// How much darker it gets, 0 ... 1.
    public var dim: Double

    public init(blur: Double = 0, dim: Double = 0) {
        self.blur = blur
        self.dim = dim
    }

    /// The glass alone.
    public static let none = Obscuring()
    /// A light blur: what's underneath recedes, still recognisable.
    public static let soft = Obscuring(blur: 3, dim: 0.06)
    /// A heavy blur: only shapes and colours remain.
    public static let strong = Obscuring(blur: 14, dim: 0.12)
    /// Darkened, lightly blurred: the content on top stands alone.
    public static let dark = Obscuring(blur: 4, dim: 0.5)
}

/// A layer over everything behind it: glass across the whole area (frosted and dimmed by
/// default, so what's underneath recedes), taking no taps through, with `content` at `placement`.
/// `obscuring` hides what's underneath further (on its own an `Overlay` can darken; the
/// `.overlay(isPresented:)` modifier also blurs). The content is as big as it wants to be; the
/// overlay only places it.
public struct Overlay<Content: View>: View {
    let placement: Alignment
    let material: GlassToken
    let obscuring: Obscuring
    let content: Content

    public init(placement: Alignment = .center, material: GlassToken = .scrim, obscuring: Obscuring = .none, @ViewBuilder content: () -> Content) {
        self.placement = placement
        self.material = material
        self.obscuring = obscuring
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: placement) {
            Rectangle()
                .fill(.clear)
                .glassLayer(material, in: Rectangle())
                .overlay { Color(ColorToken.fixedBlack.opacity(obscuring.dim)) }
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
        obscuring: Obscuring = .none,
        @ViewBuilder content: () -> Content
    ) -> some View {
        blur(radius: isPresented ? obscuring.blur : 0)
            .overlay {
                if isPresented {
                    Overlay(placement: placement, material: material, obscuring: obscuring, content: content)
                }
            }
    }

    /// An `Overlay` over this view while there's an `item`, its content made from it.
    func overlay<Item, Content: View>(
        item: Item?,
        placement: Alignment = .center,
        material: GlassToken = .scrim,
        obscuring: Obscuring = .none,
        @ViewBuilder content: (Item) -> Content
    ) -> some View {
        blur(radius: item == nil ? 0 : obscuring.blur)
            .overlay {
                if let item {
                    Overlay(placement: placement, material: material, obscuring: obscuring) { content(item) }
                }
            }
    }
}
