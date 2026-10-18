# Vitral

A Liquid Glass design system for SwiftUI (iOS 26 and macOS 26).

*Vitral* is Portuguese for stained glass: small pieces put together into a picture. That's how the
library works. It has two products:

- **`VitralTokens`**: the values everything is built from. Plain Swift with no UI framework, so it
  builds on Linux, Windows and Android too.
  - Colours, each with a light and a dark value.
  - Spacing, corner radii and sizes.
  - Type styles (Dynamic Type), glass materials and glyphs.
- **`Vitral`**: SwiftUI components on those tokens. Each one is small, holds no state, and is
  composed into bigger ones.

## Install

```swift
.package(url: "https://github.com/luizmb/Vitral.git", branch: "main")
```

Then depend on the `Vitral` product (or only `VitralTokens` outside Apple platforms).

## Use

```swift
import Vitral

Card("U-234 Inhalation", subtitle: "ICRP 137, Type S") {
    TagCloud(["Nuclear", "Inhalation"])
}
.header { SwatchStack([.accent, .warning, .danger]) }
.footer {
    ActionBar {
        ActionBarButton("Edit", icon: Image(systemName: "pencil"), accessibilityLabel: "Edit") { edit() }
        ActionBarButton(icon: Image(systemName: "trash"), accessibilityLabel: "Delete", role: .destructive) { delete() }
    }
}
```

Every colour follows light and dark mode by itself: `Color(.accent)` and `.foregroundStyle(.ink)`
resolve per appearance, so a view is written once.

To force an appearance whatever the system says, on a screen or any part of one:

```swift
SettingsScreen().appearance(.dark)   // .light, .dark, or .system
AppearancePicker(selection: $appearance)
```

`Appearance` is a plain value in `VitralTokens`, so an app's state can hold the user's choice.
Token colours, Vitral's images (dark wood included) and glass all follow the override.

## Customising colour

Every colour has a default from the tokens, and two ways to change it:

- **The environment, for a whole area.** `.accent(_:)` sets the accent every control below is
  marked with: buttons, checkboxes, toggles, tag toggles, action bars, progress bars, page dots
  (`.primary` by default; `.counter`, or your own `AccentToken`). `.surfaceGlass(_:)` sets the
  glass every surface below is made of (`.veiled()` by default). Apply them to a screen, a section
  or a single control.
- **An init parameter, when the colour belongs to the content.** A tag's `style: .tint(.pink)`,
  a banner's `style:` (presets, or `.custom`), a swatch's colour, a backdrop's palette, a code
  block's `theme:`.

```swift
SettingsScreen()
    .accent(.counter)              // every control in it, coral
PageDots(ids, selection: $page)
    .accent(AccentToken(base: .washViolet, top: .washViolet, bottom: .washViolet, glow: .accentGlow))
Tag("Draft", style: .tint(.amber))
```

## Icons and images

SF Symbols are part of Vitral's vocabulary. `Glyph` names the symbols components draw by role
(`.checkmark`, `.warning`, `.retry`, …), and every glyph is an SF Symbol. Anywhere a component
takes an `Image` (a button's or tag's icon, an empty state's artwork), any SF Symbol works:
`Image(systemName: "hand.tap")`. Vitral's own illustrations (`Illustration`) are for the larger
moments (errors, empty screens) where a symbol is too small to carry the message; when there's no
illustration for a state, use a symbol.

## Glass and finishes

Two tokens say what things are made of:

- **`GlassToken`** is the system's glass for a surface (a panel, a card, a sheet): how clear it is
  (`.regular`, `.clear`, `.sheer`, `.veiled(_:)`), tinted or not, answering touch or not.
  `.glassSurface(_:cornerRadius:)` and `.glassCapsule(_:)` put it under a view;
  `.surfaceGlass(_:)` sets it for every surface below.
- **`FinishToken`** is what a control's face is made of (a button, a thumb, a cap), in three layers
  from the bottom up: `glass` (or none), a `fill` (a colour, gradient, texture, chrome or Aqua's
  gel; on glass, `amount` of it shows), and a `sheen` (gloss, glow and rim, each 0 ... 1).
  `.controlFinish(_:)` sets it for every control below; `.finish(_:in:)` puts it under any view.

```swift
.glass(.clear)                                  // clear glass
.aqua(.accent)                                  // Aqua's gel: the gel fill and the whole sheen
.aqua(.accent).onGlass(.clear, amount: 0.2)     // clear glass with a hint of Aqua
.glass(.clear).sheen(gloss: 0.2, glow: 0.2)     // clear glass, lightly glossed
```

## Components

In `Sources/Vitral/Components`, a folder per group, as in the Gallery.

| Group | Components |
|---|---|
| Surfaces | `Backdrop` (patterns, drawn materials, textures, aurora, glow, waves, laser, contours, fractal, images), `Overlay` (`.overlay(isPresented:)`, `.overlay(item:)`, `dismiss:` on a tap outside), `AppearancePicker`, `EdgeFade` |
| Controls | `Pill`, `ButtonPrimary`, `ButtonSecondary` (both take `finish:`), `ButtonLabel`, `ActionBar`, `ActionBarButton`, `ToggleButtonLatched`, `Checkbox`, `ToggleSwitch`, `SelectionMark`, `SegmentedControlGlass`, `RadioList`, `StepperJump`, `FieldText`, `FieldSecure`, `FieldSearch` (`FieldStatus`) |
| Dials and faders | `Knob` (`.circular`, `.vertical(dragStart:)`), `GlassKnobStyle`, `JogDial`, `Fader` (horizontal or vertical, `.absolute` or `.relative(dragStart:)`, `centre`, `detents`, `resetValue`, `onEditingEnded`), `GlassFaderStyle`, `ConsoleFaderStyle`, `ValueScale` (range, step, precision; linear, log, power or breakpoint tapers, in values or decibels; `.consoleGain()`; a number or decibel readout) |
| Collections | `Panel`, `PanelList`, `Row`, `GlassList`, `GlassSection`, `GlassForm` (the system's form, rows on glass), `.rowActions(_:)`, `Card` (`.header { }`, `.footer { }`), `CardAdd`, `IconGroup` (a home screen's folder: paged grid, optional header, footer, dots), `IconTile`, `IconTileAdd`, `Carousel`, `PageDots`, `SegmentedPages`, `Tag`, `TagToggle`, `TagCloud`, `FlowLayout`, `Swatch`, `SwatchStack` (`monograms:`), `Monogram` (`ColorToken.stable(for:)`, `Initials`), `Stat` |
| Feedback | `Banner`, `EmptyState`, `ErrorScreen`, `ProgressPanel`, `.progressOverlay(_:)` |
| Layout and content | `Page`, `LabelledGroup` (with an `accessory:`), `SectionLabel`, `Hairline`, `Workspace` (`PanelSize`, `PanelToggle`, `.workspaceToolbar`), `.adaptiveSheet()`, `CodeBlock`, `CodeSpan`, `SyntaxTheme` |

Modifiers that take tokens: `.foregroundStyle(_:)`, `.font(_:)`, `.glassSurface(_:cornerRadius:)`,
`.glassCapsule(_:)`, `.surfaceGlass(_:)`, `.finish(_:in:)`, `.controlFinish(_:)`, `.accent(_:)`,
`.surface(_:cornerRadius:)`, `.appearance(_:)`.

Snapshot tests outside a real window (a package's test target) can't draw glass: set
`.environment(\.rendersGlass, false)` there and every Vitral glass draws a plain surface of the
same shape, so the pictures still check layout.

## Gallery

`Gallery/` is an app that shows every token, resource and component, built only from Vitral
itself. It also hosts the snapshot tests, because glass only renders in a real window. Every
sample has an ⓘ that shows its code: before each build, `Gallery/Scripts/ExtractSamples.swift`
copies each `Sample("title") { … }` body out of the pages, so the code shown is the code that ran.

```bash
cd Gallery
xcodegen generate
open VitralGallery.xcodeproj
```

## License

Apache 2.0
