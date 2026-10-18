import SwiftUI
import Vitral
import VitralTokens

@main
struct GalleryApp: App {
    /// The app is the Gallery's boundary, so it owns the one model; every view only reads it or
    /// reports a change through a binding.
    @State private var model = GalleryModel()

    var body: some Scene {
        WindowGroup {
            @Bindable var model = model
            NavigationStack {
                HomePage()
                    .galleryChrome($model.appearance)
                    .navigationDestination(for: GallerySection.self) { SectionPage(section: $0).galleryChrome($model.appearance) }
                    .navigationDestination(for: GalleryPage.self) { $0.view.galleryChrome($model.appearance) }
                    .navigationDestination(for: GlassShowcaseRoute.self) { GlassShowcasePage(route: $0).galleryChrome($model.appearance) }
                    .navigationDestination(for: WorkspaceRoute.self) { WorkspaceSample(route: $0).galleryChrome($model.appearance) }
            }
            .overlay(item: model.shownSample, dismiss: { model.shownSample = nil }) { sample in
                SampleCodePanel(sample: sample) { model.shownSample = nil }
            }
            .appearance(model.appearance)
            .environment(model)
        }
    }
}
