import SwiftUI
import VitralTokens

/// What sits under the glass. Glass shows what's behind it, so over a flat colour it reads flat;
/// a pattern or a material gives it something to bend.
public enum BackdropStyle: Sendable {
    /// Graph paper: a fine line every `spacing` points and a stronger one every fifth. `origin` is
    /// where the grid's (0, 0) lands and `scale` its zoom, so a canvas that pans and zooms can slide
    /// the paper with it.
    case grid(origin: CGPoint = .zero, scale: Double = 1, spacing: Double = 28)
    /// A dot at every crossing of a `spacing`-point grid.
    case dots(spacing: Double = 22)
    /// Fine interlaced curves, the way banknotes are engraved, in a colour of the palette.
    case laserCurves(ColorToken = .accent)
    /// Planks of wood, the grain running across.
    case wood
    /// Brushed metal: a sheen from the top and fine streaks across.
    case brushedMetal
    /// Paper: the backdrop colour with a fine fleck.
    case paper
    /// A bus floor in liquid chrome: three raised bars to a square, each square turned a quarter
    /// from its neighbours.
    case busFloor
    /// Soft colour fields from a palette, corner to corner.
    case mesh([ColorToken])
    /// One of Vitral's textures, tiled.
    case texture(Texture)
    /// A picture: tiled at its own size (a texture), or filling the space and cropped (a photo).
    /// Vitral ships none; an app brings its own (see the repository's `Wallpapers`).
    case image(Image, tiled: Bool = false)
    /// The backdrop colour alone.
    case plain
}

/// Fills the space behind a screen's glass, edge to edge, under the safe areas too. Every pattern
/// is drawn, not loaded, and its irregularity comes from a fixed hash: the same size always draws
/// the same picture.
public struct Backdrop: View {
    let style: BackdropStyle

    public init(_ style: BackdropStyle = .grid()) {
        self.style = style
    }

    public var body: some View {
        ZStack {
            switch style {
            case let .grid(origin, scale, spacing):
                Color(.backdrop)
                GraphPaper(origin: origin, step: spacing * scale)
            case let .dots(spacing):
                Color(.backdrop)
                DotGrid(spacing: spacing)
            case let .laserCurves(color):
                Color(.backdrop)
                LaserCurves(color: color)
            case .wood:
                Color(.woodBase)
                WoodGrain()
            case .brushedMetal:
                Color(.metalBase)
                BrushedMetal()
            case .paper:
                Color(.backdrop)
                PaperFleck()
            case .busFloor:
                BusFloor()
            case let .mesh(palette):
                Color(.backdrop)
                MeshBackdrop(palette: palette)
            case let .texture(texture):
                Image(texture).resizable(resizingMode: .tile)
                if !texture.followsAppearance {
                    Color(.pictureDim)
                }
            case let .image(image, tiled):
                Color(.backdrop)
                if tiled {
                    image.resizable(resizingMode: .tile)
                } else {
                    image.resizable().scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                }
                Color(.pictureDim)
            case .plain:
                Color(.backdrop)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A number in 0 ..< 1 that looks random but is fixed by its inputs (SplitMix64's finaliser): the
/// irregular in a pattern without randomness in a view.
func scatter(_ index: Int, _ salt: Int = 0) -> Double {
    Double(mixed(UInt64(bitPattern: Int64(index)) &+ UInt64(bitPattern: Int64(salt)) &* 0x9E37_79B9_7F4A_7C15) >> 11) / 9_007_199_254_740_992
}

private func mixed(_ z: UInt64) -> UInt64 {
    finalShift(secondRound(firstRound(z)))
}

private func firstRound(_ z: UInt64) -> UInt64 { (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9 }
private func secondRound(_ z: UInt64) -> UInt64 { (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB }
private func finalShift(_ z: UInt64) -> UInt64 { z ^ (z >> 31) }

/// Graph paper drawn in one pass. Below 10 points apart only the stronger lines are drawn, so a
/// zoomed-out grid doesn't turn into a grey wash.
public struct GraphPaper: View {
    let origin: CGPoint
    let step: Double

    public init(origin: CGPoint = .zero, step: Double = 28) {
        self.origin = origin
        self.step = step
    }

    public var body: some View {
        Canvas { context, size in
            let minor = GraphicsContext.Shading.color(Color(.gridLine))
            let major = GraphicsContext.Shading.color(Color(.gridLineMajor))
            for line in GraphPaper.lines(in: size, origin: origin, step: max(step, 1)) {
                context.stroke(line.path, with: line.isMajor ? major : minor, lineWidth: line.isMajor ? 1 : 0.5)
            }
        }
    }

    /// Every line that crosses `size`, upright ones first, then across.
    static func lines(in size: CGSize, origin: CGPoint, step: Double) -> [(path: Path, isMajor: Bool)] {
        visible(indices(from: origin.x, across: size.width, step: step), step: step).map { index in
            (segment(CGPoint(x: origin.x + Double(index) * step, y: 0), CGPoint(x: origin.x + Double(index) * step, y: size.height)), index.isMultiple(of: 5))
        }
            + visible(indices(from: origin.y, across: size.height, step: step), step: step).map { index in
                (segment(CGPoint(x: 0, y: origin.y + Double(index) * step), CGPoint(x: size.width, y: origin.y + Double(index) * step)), index.isMultiple(of: 5))
            }
    }

    /// The grid indices from the first line before 0 to the first after `length`.
    static func indices(from start: Double, across length: Double, step: Double) -> ClosedRange<Int> {
        Int((-start / step).rounded(.down)) ... Int(((length - start) / step).rounded(.up))
    }

    /// Every fifth line always; the rest only while they're at least 10 points apart.
    static func visible(_ indices: ClosedRange<Int>, step: Double) -> [Int] {
        indices.filter { $0.isMultiple(of: 5) || step >= 10 }
    }

    static func segment(_ from: CGPoint, _ to: CGPoint) -> Path {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
    }
}

/// The palette's colours washed in from the corners, clear in the middle, faint enough for text on
/// glass to stay legible.
struct MeshBackdrop: View {
    let palette: [ColorToken]

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.5, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
            colors: [0, -1, 1, -1, -1, -1, 2, -1, 3].map { index in
                index < 0 || palette.isEmpty ? .clear : Color(palette[index % palette.count].opacity(0.3))
            },
            smoothsColors: true
        )
    }
}

/// A dot at each crossing, every fifth a little stronger.
struct DotGrid: View {
    let spacing: Double

    var body: some View {
        Canvas { context, size in
            for x in stride(from: spacing / 2, through: size.width, by: spacing) {
                for y in stride(from: spacing / 2, through: size.height, by: spacing) {
                    context.fill(Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)), with: .color(Color(.gridLineMajor)))
                }
            }
        }
    }
}

/// Two bands of interlaced sine curves, each curve a step out of phase with the last.
struct LaserCurves: View {
    let color: ColorToken

    var body: some View {
        Canvas { context, size in
            for band in [0.3, 0.72] {
                for curve in 0 ..< 28 {
                    context.stroke(
                        LaserCurves.curve(index: curve, centre: size.height * band, size: size),
                        with: .color(Color(color.opacity(0.10 + 0.14 * scatter(curve, Int(band * 100))))),
                        lineWidth: 0.7
                    )
                }
            }
        }
    }

    static func curve(index: Int, centre: Double, size: CGSize) -> Path {
        Path { path in
            let phase = Double(index) * 0.22
            let points = stride(from: 0.0, through: size.width, by: 4).map { x in
                CGPoint(
                    x: x,
                    y: centre + sin(x / size.width * .pi * 3 + phase) * size.height * 0.08 + sin(x / size.width * .pi * 7 - phase * 2) * size.height * 0.025
                )
            }
            path.addLines(points)
        }
    }
}

/// Planks with grain: wavy lines across, close and faint, drifting a little in each plank.
struct WoodGrain: View {
    var body: some View {
        Canvas { context, size in
            let plank = 140.0
            for (row, y) in stride(from: 0.0, through: size.height, by: 3.5).enumerated() {
                context.stroke(
                    WoodGrain.grain(row: row, y: y, width: size.width),
                    with: .color(Color(ColorToken.woodGrain.opacity(ColorToken.woodGrain.light.alpha * (0.3 + 0.9 * scatter(row, 7))))),
                    lineWidth: 0.5 + scatter(row, 3)
                )
            }
            for seam in stride(from: plank, through: size.height, by: plank) {
                context.stroke(GraphPaper.segment(CGPoint(x: 0, y: seam), CGPoint(x: size.width, y: seam)), with: .color(Color(.woodGrain)), lineWidth: 1.2)
            }
        }
    }

    static func grain(row: Int, y: Double, width: Double) -> Path {
        Path { path in
            path.addLines(stride(from: 0.0, through: width, by: 6).map { x in
                CGPoint(x: x, y: y + sin(x / (60 + 80 * scatter(row, 1)) + scatter(row, 2) * 6) * 2.2 * scatter(row, 5))
            })
        }
    }
}

/// Brushed metal: a soft sheen from the top, and fine streaks across of every length.
struct BrushedMetal: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.metalStreak), .clear, Color(.metalShade)], startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                for (row, y) in stride(from: 0.0, through: size.height, by: 1.5).enumerated() {
                    let start = scatter(row, 11) * size.width * 0.6
                    context.stroke(
                        GraphPaper.segment(CGPoint(x: start, y: y), CGPoint(x: start + size.width * (0.3 + 0.7 * scatter(row, 13)), y: y)),
                        with: .color(Color(scatter(row, 17) > 0.5 ? .metalStreak : .metalShade)),
                        lineWidth: 0.5
                    )
                }
            }
        }
    }
}

/// Paper: tiny flecks, one in each small cell, placed and sized by the hash.
struct PaperFleck: View {
    var body: some View {
        Canvas { context, size in
            let cell = 6.0
            let columns = Int(size.width / cell) + 1
            for index in 0 ..< columns * (Int(size.height / cell) + 1) {
                let x = Double(index % columns) * cell + scatter(index, 1) * cell
                let y = Double(index / columns) * cell + scatter(index, 2) * cell
                let radius = 0.35 + scatter(index, 3) * 0.75
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)), with: .color(Color(.paperFleck)))
            }
        }
    }
}

/// Chrome tread plate: in each square of a checkerboard, three short bars side by side, lying
/// across in one square and upright in the next. Each bar is a raised capsule lit from above (a
/// bright edge, a dark underside) on a darker chrome floor.
struct BusFloor: View {
    static let square = 30.0

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.chromeMid), Color(.chromeShadow)], startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                let chrome = Gradient(stops: [
                    .init(color: Color(.chromeHighlight), location: 0),
                    .init(color: Color(.chromeMid), location: 0.45),
                    .init(color: Color(.chromeShadow), location: 1)
                ])
                for frame in BusFloor.bars(in: size) {
                    let capsule = Path(roundedRect: frame, cornerRadius: min(frame.width, frame.height) / 2)
                    context.fill(capsule.offsetBy(dx: 0.8, dy: 1.2), with: .color(Color(.chromeShadow)))
                    // Lit across the bar's short side, whichever way it lies.
                    context.fill(
                        capsule,
                        with: .linearGradient(
                            chrome,
                            startPoint: CGPoint(x: frame.minX, y: frame.minY),
                            endPoint: frame.width > frame.height ? CGPoint(x: frame.minX, y: frame.maxY) : CGPoint(x: frame.maxX, y: frame.minY)
                        )
                    )
                }
            }
            // Liquid metal: broad reflections sweeping across the whole floor.
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color(ColorToken.chromeHighlight.opacity(0.35)), location: 0.22),
                    .init(color: .clear, location: 0.38),
                    .init(color: Color(ColorToken.chromeShadow.opacity(0.35)), location: 0.6),
                    .init(color: Color(ColorToken.chromeHighlight.opacity(0.25)), location: 0.78),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)
        }
        .drawingGroup()
    }

    /// Every bar's frame: three to a square, across where the square's row and column add up to an
    /// even number, upright where they don't.
    static func bars(in size: CGSize) -> [CGRect] {
        squares(in: size).flatMap { column, row in
            (0 ..< 3).map { index in
                (column + row).isMultiple(of: 2)
                    ? CGRect(x: Double(column) * square + 5, y: Double(row) * square + 5 + Double(index) * 7.5, width: square - 10, height: 4.5)
                    : CGRect(x: Double(column) * square + 5 + Double(index) * 7.5, y: Double(row) * square + 5, width: 4.5, height: square - 10)
            }
        }
    }

    static func squares(in size: CGSize) -> [(Int, Int)] {
        (0 ... Int(size.width / square)).flatMap { column in (0 ... Int(size.height / square)).map { (column, $0) } }
    }
}
