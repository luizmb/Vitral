# CLAUDE.md

Guidance for working in this repository.

## Layout

- `Sources/VitralTokens`: plain values (colours, spacing, radii, sizes, type, glass and finishes,
  glyphs, value scales). No SwiftUI, UIKit or AppKit: this target must build on Linux, Windows and
  Android.
- `Sources/Vitral`: SwiftUI components. `Bridging/` is the only place tokens become SwiftUI values
  (`Color(_:)`, `Font(_:)`, `Glass.token(_:)`, `Image(_:)`, `FinishedShape`) and the token-taking
  view modifiers.
- `Gallery/`: an XcodeGen app showing every token, resource and component. It hosts the snapshot
  tests (`GallerySnapshotTests`), since glass renders only in a real window.

## Build and test

```bash
swift build 2>&1 | xcsift
swift test 2>&1 | xcsift                     # token tests
cd Gallery && xcodegen generate
xcodebuild test -project VitralGallery.xcodeproj -scheme Gallery \
  -destination 'id=33823492-2843-40CB-B4C6-6D013B5EFB2D' -skipMacroValidation   # snapshots
```

xcsift has reported success on an Xcode build whose compiler crashed. For Gallery builds, grep
for `BUILD SUCCEEDED` / `TEST SUCCEEDED` instead.

Recording snapshots: run the tests once, then record on a second run with
`TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all xcodebuild test …`, then run again to check. A reference
taken on the first run in a process can catch glass or images before they settle. Don't
pre-render by swapping the window's root controller: it leaks appearance into later captures.

## Component rules

- **Stateless, pure SwiftUI.** No `@State`, `@GestureState`, `@StateObject` or any view-owned
  state. Inputs are `let` properties, `@Binding`s, and closures that report events.
- **No app frameworks.** Never reference SwiftRex or any architecture library.
- **Readable names**, thing first and variant second: `ButtonPrimary`, `ButtonSecondary`,
  `SegmentedControlGlass`, `StepperJump`. No prefixes like `GButton`.
- **Compose small into big.** A component is built from smaller Vitral components (`Card` uses
  `Hairline`, `PanelList` uses `Panel`). Shared look goes in view extensions. Optional parts are
  added builder-style (`Card(...).header { }.footer { }`), not through many optional init
  parameters.
- **UI logic only.** No business logic, and no heavy math in `body`; layout math belongs in a
  `Layout` and stays cheap.
- **Tokens only.** No literal colours, sizes or fonts in components. Colours come from
  `ColorToken`, which resolves light and dark by itself.
- **Localisable.** User-facing strings and accessibility labels are parameters
  (`LocalizedStringKey` or `Text`). Accessibility identifiers that a component sets itself are
  hardcoded, but kept in an enum.
- **Colours: defaults, then the environment, then the content.** A control marked with the accent
  reads `@Environment(\.accent)`; a surface reads `@Environment(\.glassMaterial)`. Never hard-code
  `.accent` in a control. A colour that belongs to the content (a tag's tint, a banner's style, a
  palette) is an init parameter with a default.
- **SF Symbols are first-class.** Icons a component draws itself are `Glyph`s (SF Symbols by role).
  Any parameter that takes an icon or artwork takes an `Image`, so callers can pass any SF Symbol.
  Draw a new `Illustration` only where a symbol can't carry the message.
- **Gallery dogfoods.** Everything the Gallery shows is built from Vitral components. Every new
  component gets a Gallery page (or a section on one) showing each state, and with it a snapshot.

## Code style

- Implicit returns, no `return` keyword. No `!`, `as!`, `fatalError`.
- No column alignment with extra spaces.
- Swift Testing (`@Suite`, `@Test`, `#expect`).
- Everything `Sendable`; closures in components are `@MainActor`.
