@testable import Gallery
import SnapshotTesting
import SwiftUI
import Testing
import UIKit

/// Every Gallery page in light and dark, drawn from the app's own window: glass only renders in a
/// real window, which is why these run hosted in the Gallery app.
///
/// Rasterising differs across CPU architectures and simulator versions, so references only compare
/// on the machine that recorded them (iPhone 17 Pro Max simulator). CI sets `TEST_RUNNER_CI` and
/// skips them. Liquid Glass dithers faintly from frame to frame, so a few pixels in two hundred may
/// drift in colour; a layout change moves far more than that.
@MainActor
@Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["CI"] == nil))
struct GallerySnapshotTests {
    @Test(arguments: GalleryPage.allCases)
    func page(_ page: GalleryPage) {
        snapshot(page.view, named: page.rawValue)
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
                of: UIHostingController(rootView: NavigationStack { view }),
                as: .image(drawHierarchyInKeyWindow: true, precision: 0.995, perceptualPrecision: 0.98, size: CGSize(width: 440, height: 956), traits: UITraitCollection(userInterfaceStyle: style)),
                named: "\(name)-\(style == .dark ? "dark" : "light")",
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }
}
