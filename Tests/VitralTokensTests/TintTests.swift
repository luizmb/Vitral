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

@Suite struct FixedColourTests {
    @Test(arguments: [ColorToken.fixedBlack, .fixedCharcoal, .fixedWhite, .fixedCream, .fixedGold, .fixedSilver])
    func theSameInLightAndDark(_ token: ColorToken) {
        #expect(token.light == token.dark)
    }
}

@Suite struct FinishTokenTests {
    @Test func layersKeepTheBasesColourAndTone() {
        #expect(FinishToken.solid(.accent).gel.isColoured)
        #expect(FinishToken.glass().gel.isColoured == false)
        #expect(FinishToken.aqua(.accent).with(.gloss).tone == .accent)
    }

    @Test func replacingGlassKeepsTheLayers() {
        #expect(FinishToken.glass(.clear).gel.replacingGlass(with: .solid(.accent)) == FinishToken.solid(.accent).gel)
        #expect(FinishToken.chrome.replacingGlass(with: .solid(.accent)) == .chrome)
    }

    @Test func gelIsEveryLayer() {
        #expect(FinishToken.solid(.accent).gel == .layered(.solid(.accent), [.gloss, .glow, .rim]))
    }
}
