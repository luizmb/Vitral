import SwiftUI
import VitralTokens

/// What the screen is waiting for, on a panel of regular (frosted) glass: a title, an optional
/// detail, and a bar for `fraction` (0 ... 1) or a spinner without one. Usually shown in an
/// `Overlay` (`.progressOverlay(_:)`); it is as wide as its words, up to `Size.floatingPanel`, and
/// a bar takes that whole width.
///
/// For a job made of tasks, `overall` is the whole job and `fraction` the task under way: the
/// title sits over the overall bar, the detail (the task) over a thinner one of its own.
public struct ProgressPanel: View {
    let title: Text
    let detail: Text?
    let fraction: Double?
    let overall: Double?

    @Environment(\.accent) private var accent

    public init(_ title: Text, detail: Text? = nil, fraction: Double? = nil, overall: Double? = nil) {
        self.title = title
        self.detail = detail
        self.fraction = fraction
        self.overall = overall
    }

    public init(_ title: LocalizedStringKey, detail: Text? = nil, fraction: Double? = nil, overall: Double? = nil) {
        self.init(Text(title), detail: detail, fraction: fraction, overall: overall)
    }

    public var body: some View {
        VStack(spacing: Space.medium) {
            if let overall {
                title.font(.bodyStrong)
                bar(overall, colour: accent.base)
                VStack(spacing: Space.small) {
                    detail.font(.detail).foregroundStyle(.inkMuted).lineLimit(2)
                    fraction.map { bar($0, colour: .inkMuted) }
                }
            } else if let fraction {
                title.font(.bodyStrong)
                bar(fraction, colour: accent.base)
                detail.font(.detail).foregroundStyle(.inkMuted).lineLimit(2)
            } else {
                ProgressView().controlSize(.large)
                title.font(.bodyStrong)
                detail.font(.detail).foregroundStyle(.inkMuted).lineLimit(2)
            }
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.ink)
        .frame(maxWidth: Size.floatingPanel - Space.large * 2)
        .padding(Space.large)
        .glassSurface(.regular, cornerRadius: Radius.card)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }

    private func bar(_ value: Double, colour: ColorToken) -> some View {
        ProgressView(value: value)
            .progressViewStyle(.linear)
            .tint(Color(colour))
            .frame(width: Size.floatingPanel - Space.large * 2)
    }
}

public extension View {
    /// A `ProgressPanel` in a centred `Overlay` while there's a `panel`.
    func progressOverlay(_ panel: ProgressPanel?, obscuring: Obscuring = .soft) -> some View {
        overlay(item: panel, obscuring: obscuring) { $0 }
    }
}
