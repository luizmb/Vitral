import SwiftUI
import Vitral
import VitralTokens

@main
struct GalleryApp: App {
    /// The appearance switch's choice. The app is the Gallery's boundary, so it holds the one piece
    /// of state; every view only reads it or reports a change through the binding.
    @State private var appearance = Appearance.system

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomePage()
                    .galleryChrome($appearance)
                    .navigationDestination(for: GallerySection.self) { SectionPage(section: $0).galleryChrome($appearance) }
                    .navigationDestination(for: GalleryPage.self) { $0.view.galleryChrome($appearance) }
                    .navigationDestination(for: GlassShowcaseRoute.self) { GlassShowcasePage(route: $0).galleryChrome($appearance) }
            }
            .appearance(appearance)
        }
    }
}
