import Testing
import VitralTokens

@Suite struct ColorTokenTests {
    @Test func hexSplitsIntoComponents() {
        #expect(RGBA(hex: 0xFF8000) == RGBA(red: 1, green: 128.0 / 255, blue: 0))
    }

    @Test func resolvedPicksTheAppearance() {
        let token = ColorToken(light: .white, dark: .black)
        #expect(token.resolved(isDark: false) == .white)
        #expect(token.resolved(isDark: true) == .black)
    }

    @Test func singleColourIsTheSameInBothAppearances() {
        #expect(ColorToken(.white).light == ColorToken(.white).dark)
    }

    @Test func opacityKeepsTheColourAndSetsAlphaInBothAppearances() {
        let faded = ColorToken.accent.opacity(0.2)
        #expect(faded.light == ColorToken.accent.light.opacity(0.2))
        #expect(faded.dark.alpha == 0.2)
        #expect(faded.dark.blue == ColorToken.accent.dark.blue)
    }

    /// Ink must differ between appearances, or text vanishes in one of them.
    @Test func inkTokensChangeWithAppearance() {
        for token in [ColorToken.ink, .inkMuted, .inkFaint, .backdrop] {
            #expect(token.light != token.dark)
        }
    }
}

@Suite struct GlassTokenTests {
    @Test func modifiersKeepTheRest() {
        let glass = GlassToken.clear.tinted(.accent).interactive()
        #expect(glass == GlassToken(.clear, tint: .accent, isInteractive: true))
        #expect(glass.interactive(false).tint == .accent)
    }
}

@Suite struct TypeTokenTests {
    @Test func weightKeepsStyleAndDesign() {
        #expect(TypeToken.value.weight(.bold) == TypeToken(.body, weight: .bold, design: .monospaced))
    }
}
