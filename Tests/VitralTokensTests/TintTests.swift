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
        #expect(FinishToken.solid(.accent).gel().isColoured)
        #expect(FinishToken.glass().gel().isColoured == false)
        #expect(FinishToken.aqua(.accent).with(.gloss).tone == .accent)
    }

    @Test func tintingGlassTintsOnlyUntintedGlass() {
        let tint = ColorToken.accent.opacity(0.6)
        #expect(FinishToken.glass(.clear).gel(0.3).tintingGlass(tint) == FinishToken.glass(GlassToken.clear.tinted(tint)).gel(0.3))
        #expect(FinishToken.glass().tintingGlass(tint) == .glass(GlassToken.clear.interactive().tinted(tint)))
        #expect(FinishToken.glass(GlassToken.clear.tinted(.washGreen)).tintingGlass(tint) == .glass(GlassToken.clear.tinted(.washGreen)))
        #expect(FinishToken.chrome.tintingGlass(tint) == .chrome)
    }

    @Test func tintedGlassGlowsInItsTint() {
        #expect(FinishToken.glass(GlassToken.clear.tinted(ColorToken.accent.opacity(0.2))).tone == ColorToken.accent.opacity(1))
        #expect(FinishToken.glass(GlassToken.clear.tinted(ColorToken.accent.opacity(0.6))).isColoured)
        #expect(FinishToken.glass(GlassToken.clear.tinted(ColorToken.accent.opacity(0.2))).isColoured == false)
    }

    @Test func overGlassIsGlassReadingAsItsMixOnlyPastHalf() {
        #expect(FinishToken.aqua(.accent).overGlass(.clear, amount: 0.3).isGlass)
        #expect(FinishToken.aqua(.accent).overGlass(.clear, amount: 0.3).isColoured == false)
        #expect(FinishToken.aqua(.accent).overGlass(.clear, amount: 0.7).isColoured)
        #expect(FinishToken.aqua(.accent).overGlass(amount: 2) == .mixed(.aqua(.accent), glass: nil, amount: 1))
    }

    @Test func gelIsEveryLayer() {
        #expect(FinishToken.solid(.accent).gel(0.5) == .layered(.solid(.accent), [.gloss, .glow, .rim], strength: 0.5))
    }
}
