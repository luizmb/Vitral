import Testing
import VitralTokens

@Suite struct TintTests {
    @Test(arguments: Tint.allCases)
    func surfaceIsATranslucentWashInBothAppearances(_ tint: Tint) {
        #expect(tint.surface.light.alpha < 0.5)
        #expect(tint.surface.dark.alpha < 0.5)
    }

    @Test(arguments: Tint.allCases)
    func inkIsOpaque(_ tint: Tint) {
        #expect(tint.ink.light.alpha == 1)
        #expect(tint.ink.dark.alpha == 1)
    }

    @Test func counterAccentIsNotThePrimary() {
        #expect(AccentToken.counter != AccentToken.primary)
        #expect(AccentToken.primary.base == .accent)
    }
}
