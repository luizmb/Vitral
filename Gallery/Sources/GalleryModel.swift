import Observation
import VitralTokens

/// The Gallery's state, held by the app (its boundary): the appearance switch's choice and the
/// pages the interactive samples are on. Views read it, and change it through bindings.
@MainActor @Observable
final class GalleryModel {
    var appearance = Appearance.system
    var carouselPage: Int? = 0
    var flipPage: Int? = 0
}
