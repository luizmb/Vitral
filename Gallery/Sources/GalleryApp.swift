import SwiftUI

@main
struct GalleryApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomePage()
                    .navigationDestination(for: GallerySection.self, destination: SectionPage.init)
                    .navigationDestination(for: GalleryPage.self) { $0.view }
            }
        }
    }
}
