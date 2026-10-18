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

    @Environment(\.colorScheme) private var colorScheme

    /// How strong the layers are: softer at night, so they don't glare.
    var strength: Double { colorScheme == .dark ? 0.55 : 1 }

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
                            Color(colour.opacity((0.18 + 0.14 * Double(layer)) * strength)),
                            Color(colour.opacity((0.30 + 0.14 * Double(layer)) * strength))
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

/// Light trails: thin strands flowing in a band across the screen, each its own wave within the
/// band, a few glowing. At night they add up to light on a dark ground where they cross; by day
/// they're fine inked strands on the backdrop.
struct Laser: View {
    static let strands = 170

    let palette: [ColorToken]

    @Environment(\.colorScheme) private var colorScheme

    var isNight: Bool { colorScheme == .dark }

    var body: some View {
        Canvas { context, size in
            var lines = context
            lines.blendMode = isNight ? .plusLighter : .normal
            var glow = context
            glow.blendMode = isNight ? .plusLighter : .normal
            glow.addFilter(.blur(radius: 5))
            for index in 0 ..< (palette.isEmpty ? 0 : Laser.strands) {
                let strand = Laser.strand(index, in: size)
                let colour = palette[index % palette.count]
                lines.stroke(
                    strand,
                    with: .color(Color(colour.opacity((isNight ? 0.12 : 0.16) + (isNight ? 0.26 : 0.24) * scatter(index, 91)))),
                    lineWidth: 0.4 + scatter(index, 92) * 1.1
                )
                if index.isMultiple(of: 5) {
                    glow.stroke(strand, with: .color(Color(colour.opacity(isNight ? 0.16 : 0.12))), lineWidth: 3)
                }
            }
        }
        .background(isNight ? Color(.fixedBlack) : Color(.backdrop))
        .drawingGroup()
    }

    /// One strand: the band runs from the upper left to the lower right in a long wave; each
    /// strand sits at its own place across the band, with a ripple of its own.
    static func strand(_ index: Int, in size: CGSize) -> Path {
        Path { path in
            path.addLines(stride(from: -10.0, through: size.width + 10, by: 6).map { x in
                CGPoint(x: x, y: height(index, at: x / max(size.width, 1), in: size))
            })
        }
    }

    static func height(_ index: Int, at along: Double, in size: CGSize) -> Double {
        size.height * (0.22 + 0.34 * along)
            + sin(along * .pi * 1.6 + 0.6) * size.height * 0.07
            + (scatter(index, 93) * 2 - 1) * size.height * (0.1 + 0.06 * sin(along * .pi * 2 + scatter(index, 94) * 3))
            + sin(along * .pi * (3 + 5 * scatter(index, 95)) + scatter(index, 96) * 6) * size.height * 0.025 * scatter(index, 97)
    }
}

/// Sculpted hills, back to front, each a colour of the palette with fine lines following its
/// curve, casting a soft shadow on the one behind.
struct Contours: View {
    static let layers = 7
    static let lines = 16

    let palette: [ColorToken]

    @Environment(\.colorScheme) private var colorScheme

    /// A palette colour toned for the appearance: lighter by day, deeper at night.
    func toned(_ token: ColorToken) -> Color {
        colorScheme == .dark ? Color(token).mix(with: .black, by: 0.58) : Color(token).mix(with: .white, by: 0.3)
    }

    var body: some View {
        Canvas { context, size in
            var layered = context
            layered.addFilter(.shadow(color: Color(ColorToken.fixedBlack.opacity(0.28)), radius: 10, y: -2))
            for layer in 0 ..< (palette.isEmpty ? 0 : Contours.layers) {
                let colour = toned(palette[layer % palette.count])
                layered.fill(
                    Contours.hill(layer, offset: 0, closed: true, in: size),
                    with: .linearGradient(
                        Gradient(colors: [colour, colour.mix(with: .black, by: 0.2)]),
                        startPoint: CGPoint(x: 0, y: Contours.top(layer, in: size)),
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )
                for line in 1 ... Contours.lines {
                    context.stroke(
                        Contours.hill(layer, offset: Double(line) * size.height * 0.011, closed: false, in: size),
                        with: .color(Color(ColorToken.fixedWhite.opacity(line.isMultiple(of: 2) ? 0.22 : 0.12))),
                        lineWidth: 0.6
                    )
                }
            }
        }
        .background(palette.first.map(toned) ?? Color(.backdrop))
        .drawingGroup()
    }

    static func top(_ layer: Int, in size: CGSize) -> Double {
        size.height * (0.04 + 0.13 * Double(layer))
    }

    /// A hill's crest, `offset` below it: two long waves crossing, so no two hills match.
    static func crest(_ layer: Int, at x: Double, offset: Double, in size: CGSize) -> Double {
        top(layer, in: size) + offset * (1 + 0.6 * sin(x / max(size.width, 1) * .pi * 2 + scatter(layer, 81) * 6))
            + sin(x / max(size.width, 1) * .pi * (1.2 + scatter(layer, 82)) + scatter(layer, 83) * 6) * size.height * 0.07
            + sin(x / max(size.width, 1) * .pi * (2.6 + scatter(layer, 84) * 2) + scatter(layer, 85) * 6) * size.height * 0.03
    }

    static func hill(_ layer: Int, offset: Double, closed: Bool, in size: CGSize) -> Path {
        Path { path in
            path.addLines(stride(from: 0.0, through: size.width + 4, by: 4).map { x in
                CGPoint(x: x, y: crest(layer, at: x, offset: offset, in: size))
            })
            if closed {
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.closeSubpath()
            }
        }
    }
}

/// A Julia set (c = −0.8 + 0.156i): each point coloured by how fast it escapes, smoothly, through
/// the palette; the set itself pale by day, nearly black at night. Computed small and drawn
/// smoothed: a few milliseconds, once.
struct Fractal: View {
    static let width = 240

    let palette: [ColorToken]

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            Fractal.image(
                width: Fractal.width,
                height: min(Int(Double(Fractal.width) * proxy.size.height / max(proxy.size.width, 1)), Fractal.width * 3),
                palette: palette.map { colorScheme == .dark ? $0.dark : $0.light },
                isDark: colorScheme == .dark
            )
            .map { image in
                Image(decorative: image, scale: 1)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }

    /// By day the bands are pastel and the set pale; at night the bands deep and the set nearly
    /// black: a backdrop under glass, not a poster.
    static func image(width: Int, height: Int, palette: [RGBA], isDark: Bool) -> CGImage? {
        CGDataProvider(
            data: Data(
                pixels(
                    width: width,
                    height: max(height, 1),
                    palette: palette.map { mix($0, isDark ? .black : .white, isDark ? 0.58 : 0.38) },
                    set: mix(palette.first ?? .black, isDark ? .black : .white, isDark ? 0.85 : 0.72)
                )
            ) as CFData
        ).flatMap { provider in
            CGImage(
                width: width,
                height: max(height, 1),
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            )
        }
    }

    static func pixels(width: Int, height: Int, palette: [RGBA], set: RGBA) -> [UInt8] {
        (0 ..< height).flatMap { row in
            (0 ..< width).flatMap { column in
                bytes(colour(escape: escape(point(column: column, row: row, width: width, height: height)), palette: palette, set: set))
            }
        }
    }

    /// The point of the plane a pixel shows: 3.2 wide, centred, the height in proportion.
    static func point(column: Int, row: Int, width: Int, height: Int) -> SIMD2<Double> {
        SIMD2<Double>(
            (Double(column) / Double(width) - 0.5) * 3.2,
            (Double(row) / Double(height) - 0.5) * 3.2 * Double(height) / Double(width)
        )
    }

    static let iterations = 64
    static let c = SIMD2<Double>(-0.8, 0.156)

    static func next(_ z: SIMD2<Double>) -> SIMD2<Double> {
        SIMD2<Double>(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + c
    }

    static func size(_ z: SIMD2<Double>) -> Double {
        (z * z).sum()
    }

    /// How many steps `start` takes to escape, smoothed, or `nil` for a point of the set.
    static func escape(_ start: SIMD2<Double>) -> Double? {
        sequence(first: start, next: next)
            .prefix(iterations)
            .enumerated()
            .first { size($0.element) > 4 }
            .map { step in smooth(step: step.offset, at: step.element) }
    }

    /// The escape count made continuous, so the colours band smoothly.
    static func smooth(step: Int, at z: SIMD2<Double>) -> Double {
        max(Double(step) + 1 - log2(log(max(size(z).squareRoot(), 1.000_1))), 0)
    }

    /// How many escape steps one round of the palette takes: the colours cycle in bands
    /// radiating from the set.
    static let band = 9.0

    /// The palette's colour at `escape`, going round it once every `band` steps, or `set` for a
    /// point of the set.
    static func colour(escape: Double?, palette: [RGBA], set: RGBA) -> RGBA {
        escape.map { along(($0 / band).truncatingRemainder(dividingBy: 1), palette: palette + palette.prefix(1)) } ?? set
    }

    static func along(_ t: Double, palette: [RGBA]) -> RGBA {
        palette.count < 2
            ? (palette.first ?? .black)
            : mix(
                palette[min(Int(t * Double(palette.count - 1)), palette.count - 2)],
                palette[min(Int(t * Double(palette.count - 1)), palette.count - 2) + 1],
                t * Double(palette.count - 1) - Double(min(Int(t * Double(palette.count - 1)), palette.count - 2))
            )
    }

    static func mix(_ a: RGBA, _ b: RGBA, _ t: Double) -> RGBA {
        RGBA(red: a.red + (b.red - a.red) * t, green: a.green + (b.green - a.green) * t, blue: a.blue + (b.blue - a.blue) * t)
    }

    static func bytes(_ colour: RGBA) -> [UInt8] {
        [colour.red, colour.green, colour.blue].map { UInt8(min(max($0, 0), 1) * 255) } + [255]
    }
}
