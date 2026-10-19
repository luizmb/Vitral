import SwiftUI
import Vitral
import VitralTokens

/// The tints, as tags, flat surfaces and tinted glass; and the accent beside its counter.
struct TintsPage: View {
    static let backdrops: [(name: String, style: BackdropStyle)] = [("graph paper", .grid()), ("waves", .waves()), ("linen", .texture(.linen))]

    var body: some View {
        Page("Tints and accents") {
            Sample("Tag(style: .tint(_:))") {
                FlowLayout(spacing: Space.small) {
                    ForEach(Tint.allCases, id: \.self) { tint in
                        Tag(Text(verbatim: tint.rawValue), style: .tint(tint))
                    }
                }
            }
            Sample(".surface(tint.surface)") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: Space.small)], spacing: Space.small) {
                    ForEach(Tint.allCases, id: \.self) { tint in
                        Row(LocalizedStringKey(tint.rawValue), subtitle: "Compartment")
                            .foregroundStyle(tint.ink)
                            .surface(tint.surface, cornerRadius: Radius.medium)
                    }
                }
            }
            ForEach(Self.backdrops, id: \.name) { backdrop in
                LabelledGroup(LocalizedStringKey("Tinted glass over \(backdrop.name)")) {
                    TintedGlass()
                        .padding(Space.medium)
                        .background { Backdrop(backdrop.style) }
                        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                }
            }
            Sample("Accent and counter-accent") {
                HStack(alignment: .top, spacing: Space.medium) {
                    AccentColumn(title: ".primary")
                    AccentColumn(title: ".counter").accent(.counter)
                }
            }
            Sample("Two series") {
                Panel { TwoSeries().frame(height: 140) }
            }
        }
    }
}

/// One panel per tint, in clear glass tinted with its surface.
struct TintedGlass: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: Space.small)], spacing: Space.small) {
            ForEach(Tint.allCases, id: \.self) { tint in
                Panel(glass: GlassToken.clear.tinted(tint.surface), padding: Space.medium) {
                    Text(verbatim: tint.rawValue).font(.bodyStrong).foregroundStyle(tint.ink)
                }
            }
        }
    }
}

/// The accent-marked controls, in whichever accent the environment has.
struct AccentColumn: View {
    let title: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: Space.medium) {
            SectionLabel(title)
            ButtonPrimary("Save") {}
            Panel(padding: Space.medium) {
                VStack(alignment: .leading, spacing: Space.small) {
                    Checkbox("Track", isOn: .constant(true))
                    ToggleSwitch("Grid", isOn: .constant(true))
                    TagToggle("#fp", isOn: .constant(true))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Two made-up series, one in each accent: what the counter-accent is for.
struct TwoSeries: View {
    @Environment(\.vitralScheme) private var scheme

    static let first = [0.2, 0.35, 0.3, 0.55, 0.5, 0.7, 0.65, 0.85]
    static let second = [0.6, 0.5, 0.55, 0.4, 0.45, 0.3, 0.35, 0.2]

    var body: some View {
        Canvas { context, size in
            for (values, colour) in [(Self.first, ColorToken.accent), (Self.second, ColorToken.counterAccent)] {
                context.stroke(Self.line(values, in: size), with: .color(Color(colour, scheme: scheme)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
    }

    static func line(_ values: [Double], in size: CGSize) -> Path {
        Path { path in
            path.addLines(values.enumerated().map { index, value in
                CGPoint(x: size.width * Double(index) / Double(max(values.count - 1, 1)), y: size.height * (1 - value))
            })
        }
    }
}
