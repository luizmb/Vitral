@testable import Gallery
import SnapshotTesting
import SwiftUI
import Testing
import UIKit
import Vitral
import VitralTokens

/// Every Gallery page in light and dark, drawn from the app's own window: glass only renders in a
/// real window, which is why these run hosted in the Gallery app.
///
/// Rasterising differs across CPU architectures and simulator versions, so references only compare
/// on the machine that recorded them (iPhone 17 Pro Max simulator). CI sets `TEST_RUNNER_CI` and
/// skips them. Liquid Glass dithers faintly from frame to frame, so a few pixels in two hundred may
/// drift in colour; a layout change moves far more than that. Recorded at 1x: enough to see layout,
/// wrapping and colour, at a ninth of a 3x image's size.
@MainActor
@Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["CI"] == nil))
struct GallerySnapshotTests {
    @Test(arguments: GalleryPage.allCases)
    func page(_ page: GalleryPage) {
        snapshot(page.view, named: page.rawValue)
    }

    @Test(arguments: BackdropCatalogue.drawn)
    func backdrop(_ name: String) {
        let style = BackdropCatalogue.style(named: name)
        snapshot(
            Panel { TagCloud(["Glass", "over", "the", "backdrop"]) }
                .padding(Space.extraLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { Backdrop(style) },
            named: "backdrop-\(name)"
        )
    }

    @Test(arguments: MaterialLadder.backdrops.map(\.name))
    func materials(over name: String) {
        let style = MaterialLadder.backdrops.first { $0.name == name }?.style ?? .plain
        snapshot(MaterialLadder(backdrop: style).frame(maxHeight: .infinity).background { Backdrop(style) }, named: "materials-\(name)")
    }

    @Test(arguments: Wallpaper.all.map(\.name))
    func wallpaper(_ name: String) {
        let wallpaper = Wallpaper.all.first { $0.name == name }
        snapshot(
            Card(LocalizedStringKey(wallpaper?.title ?? name), subtitle: LocalizedStringKey(wallpaper?.credit ?? ""))
                .padding(Space.extraLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { Backdrop(wallpaper?.backdrop ?? .plain) },
            named: "wallpaper-\(name)"
        )
    }

    /// A few showcases, one of each kind: every one would add megabytes of near-identical glass.
    @Test(arguments: ["grid", "busFloor", "busFloor(45°)", "waves", "aurora", "glow", "texture(.denim)", "texture(.wood)", "wallpaper(earthrise)"])
    func showcase(_ name: String) {
        snapshot(GlassShowcasePage(route: GlassShowcaseRoute(name: name)), named: "showcase-\(name)")
    }

    @Test func home() {
        snapshot(HomePage(), named: "home")
    }

    @Test(arguments: GallerySection.allCases)
    func section(_ section: GallerySection) {
        snapshot(SectionPage(section: section), named: "section-\(section.rawValue)")
    }

    private func snapshot(_ view: some View, named name: String, fileID: StaticString = #fileID, filePath: StaticString = #filePath, testName: String = #function, line: UInt = #line, column: UInt = #column) {
        for style in [UIUserInterfaceStyle.light, .dark] {
            assertSnapshot(
                of: UIHostingController(rootView: NavigationStack { view }.environment(GalleryModel()).environment(\.locale, GalleryModel().locale).scheme(style == .dark ? .dark : .light)),
                as: Self.strategy(style: style),
                named: "\(name)-\(style == .dark ? "dark" : "light")",
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }

    /// The window's picture, redrawn as 8-bit sRGB: a window draws in wide colour at 16 bits a
    /// channel, which doubles every reference without showing anything more.
    private static func strategy(style: UIUserInterfaceStyle) -> Snapshotting<UIViewController, UIImage> {
        Snapshotting<UIImage, UIImage>.image(precision: 0.995, perceptualPrecision: 0.98).asyncPullback { controller in
            windowCapture(style: style).snapshot(controller).map(standardRange)
        }
    }

    private static func windowCapture(style: UIUserInterfaceStyle) -> Snapshotting<UIViewController, UIImage> {
        .image(
            drawHierarchyInKeyWindow: true,
            size: CGSize(width: 440, height: 956),
            traits: UITraitCollection { $0.userInterfaceStyle = style; $0.displayScale = 1 }
        )
    }

    /// An sRGB display's format: 8 bits a channel.
    private static func standardRange(_ image: UIImage) -> UIImage {
        UIGraphicsImageRenderer(
            size: image.size,
            format: UIGraphicsImageRendererFormat(for: UITraitCollection { $0.displayScale = image.scale; $0.displayGamut = .SRGB })
        )
        .image { _ in image.draw(at: .zero) }
    }
}
