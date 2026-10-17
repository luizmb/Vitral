import SwiftUI
import VitralTokens

/// Northern lights: curtains of colour hanging in the sky, brightest at their lower edge, with
/// fine rays rising from it. Stars at night; by day the curtains are painted stronger, to hold
/// their own against a blue sky.
struct Aurora: View {
    let palette: [ColorToken]

    @Environment(\.colorScheme) private var colorScheme

    /// How strongly the curtains are painted: more by day.
    var strength: Double { colorScheme == .dark ? 1 : 1.25 }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.skyTop), Color(.skyHorizon)], startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                for index in 0 ..< 140 {
                    let point = CGPoint(x: scatter(index, 31) * size.width, y: scatter(index, 32) * size.height * 0.8)
                    let radius = 0.3 + scatter(index, 33) * 0.8
                    context.fill(
                        Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)),
                        with: .color(Color(.star).opacity(0.3 + 0.7 * scatter(index, 34)))
                    )
                }
                var glow = context
                glow.addFilter(.blur(radius: 26))
                if colorScheme != .dark {
                    var horizon = context
                    horizon.addFilter(.blur(radius: 50))
                    for (index, colour) in palette.enumerated() {
                        horizon.fill(Aurora.horizonPool(index: index, count: palette.count, size: size), with: .color(Color(colour.opacity(0.45))))
                    }
                }
                var rays = context
                rays.addFilter(.blur(radius: 1.2))
                for (index, colour) in palette.enumerated() {
                    let curtain = Aurora.Curtain(index: index, count: palette.count, size: size)
                    glow.fill(
                        curtain.band,
                        with: .linearGradient(
                            Gradient(colors: [.clear, Color(colour.opacity(0.55 * strength)), Color(colour.opacity(min(1, 0.85 * strength)))]),
                            startPoint: CGPoint(x: 0, y: curtain.bounds.minY),
                            endPoint: CGPoint(x: 0, y: curtain.bounds.maxY)
                        )
                    )
                    for (ray, x) in stride(from: 0.0, through: size.width, by: 3).enumerated() {
                        let foot = curtain.edge(x)
                        let top = foot - curtain.height(x) * (0.6 + 0.8 * scatter(ray, 40 + index))
                        rays.stroke(
                            GraphPaper.segment(CGPoint(x: x, y: top), CGPoint(x: x, y: foot)),
                            with: .linearGradient(
                                Gradient(colors: [.clear, Color(colour.opacity((0.15 + 0.35 * scatter(ray, 50 + index)) * strength))]),
                                startPoint: CGPoint(x: x, y: top),
                                endPoint: CGPoint(x: x, y: foot)
                            ),
                            lineWidth: 1
                        )
                    }
                }
            }
        }
        .drawingGroup()
    }

    /// By day, a wide pool of each colour low over the horizon, so the lower sky isn't bare.
    static func horizonPool(index: Int, count: Int, size: CGSize) -> Path {
        Path(ellipseIn: CGRect(
            x: size.width * ((Double(index) - 0.3) / Double(max(count, 1)) - 0.1 * scatter(index, 81)),
            y: size.height * (0.62 + 0.18 * scatter(index, 82)),
            width: size.width * (1.6 / Double(max(count, 1)) + 0.2),
            height: size.height * 0.3
        ))
    }

    /// One curtain: its lower edge sweeps across the sky in long waves, and it rises above that
    /// edge by a height that swells and thins.
    struct Curtain {
        let index: Int
        let count: Int
        let size: CGSize

        var phase: Double { scatter(index, 61) * .pi * 2 }

        /// Where the curtain's lower edge is at `x`.
        func edge(_ x: Double) -> Double {
            size.height * (0.32 + 0.16 * Double(index) / Double(max(count, 1)))
                + sin(x / size.width * .pi * (1.4 + scatter(index, 62)) + phase) * size.height * 0.07
                + (x / size.width - 0.5) * size.height * 0.12 * (index.isMultiple(of: 2) ? 1 : -1)
        }

        /// How high the curtain rises above its edge at `x`.
        func height(_ x: Double) -> Double {
            size.height * (0.10 + 0.08 * (1 + sin(x / size.width * .pi * 3 + phase * 2)) / 2)
        }

        var band: Path {
            Path { path in
                let xs = Array(stride(from: 0.0, through: size.width, by: 8)) + [size.width]
                path.addLines(xs.map { CGPoint(x: $0, y: edge($0) - height($0)) })
                path.addLines(xs.reversed().map { CGPoint(x: $0, y: edge($0)) })
                path.closeSubpath()
            }
        }

        var bounds: CGRect { band.boundingRect }
    }
}

/// Soft pools of colour, one per colour of the palette, set around the screen and fading into the
/// backdrop: a glow, not a shape.
struct Glow: View {
    let palette: [ColorToken]

    var body: some View {
        Canvas { context, size in
            for (index, colour) in palette.enumerated() {
                let centre = Glow.centre(index: index, count: palette.count, size: size)
                let radius = max(size.width, size.height) * (0.28 + 0.12 * scatter(index, 23))
                context.fill(
                    Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)),
                    with: .radialGradient(
                        Gradient(colors: [Color(colour.opacity(0.7)), Color(colour.opacity(0.25)), .clear]),
                        center: centre,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }
        .background(Color(.backdrop))
    }

    /// The pools go round an ellipse inside the screen, each nudged off its place by the hash.
    static func centre(index: Int, count: Int, size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width * (0.5 + 0.42 * cos(angle(index: index, count: count))),
            y: size.height * (0.5 + 0.4 * sin(angle(index: index, count: count)))
        )
    }

    static func angle(index: Int, count: Int) -> Double {
        (Double(index) + 0.4 * scatter(index, 24)) / Double(max(count, 1)) * .pi * 2 - .pi * 0.7
    }
}

/// Layered hills of one colour, deepening layer by layer toward the bottom, each casting a soft
/// shadow on the one behind it.
struct Waves: View {
    static let layers = 5

    let colour: ColorToken

    var body: some View {
        Canvas { context, size in
            var layered = context
            layered.addFilter(.shadow(color: Color(ColorToken.chromeShadow.opacity(0.35)), radius: 14, y: -3))
            for layer in 0 ..< Waves.layers {
                let crest = Waves.crest(layer: layer, size: size)
                layered.fill(
                    crest,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(colour.opacity(0.18 + 0.14 * Double(layer))),
                            Color(colour.opacity(0.30 + 0.14 * Double(layer)))
                        ]),
                        startPoint: CGPoint(x: 0, y: crest.boundingRect.minY),
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )
            }
        }
        .background(Color(.backdrop))
        .drawingGroup()
    }

    /// A layer from its wavy top edge down to the bottom of `size`.
    static func crest(layer: Int, size: CGSize) -> Path {
        Path { path in
            let top = size.height * (0.22 + 0.15 * Double(layer))
            let xs = Array(stride(from: 0.0, through: size.width, by: 6)) + [size.width]
            path.addLines(xs.map { x in
                CGPoint(x: x, y: top + sin(x / size.width * .pi * (1 + scatter(layer, 71)) + scatter(layer, 72) * .pi * 2) * size.height * 0.05)
            })
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
        }
    }
}
