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
import VitralTokens

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
  (`.primary` by default; `.counter`, or your own `AccentToken`). `.glassMaterial(_:)` sets the
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

## Components

| Group | Components |
|---|---|
| Buttons | `ButtonPrimary`, `ButtonSecondary`, `ButtonLabel`, `ActionBar`, `ActionBarButton` |
| Selection | `Checkbox`, `ToggleSwitch`, `SelectionMark` |
| Layout | `Page`, `Panel`, `PanelList`, `Row`, `LabelledGroup`, `SectionLabel`, `Hairline` |
| Tags and colour | `Tag`, `TagCloud`, `FlowLayout`, `Swatch`, `SwatchStack`, `Stat` |
| Cards | `Card` with optional `.header { }` and `.footer { }`, `CardAdd` |
| Fields | `FieldText`, `FieldSecure`, `FieldSearch`, `FieldContainer`, with `FieldStatus` |
| Pickers | `SegmentedControlGlass`, `RadioList`, `StepperJump`, `AppearancePicker` |
| Feedback | `Banner`, `EmptyState`, `ErrorScreen`, `ProgressPanel` |
| Paging | `Carousel` (`.slide`, `.flip`), `PageDots` (the native page control on iOS), `SegmentedPages` |
| Workspace | `Workspace` (`.leading`, `.trailing`, `.bottom`, optionally with `pages:`), `PanelSize`, `PanelToggle`, `.workspaceToolbar`, `.panelAnimation`, `.panelTransition` |
| Code | `CodeBlock`, `CodeSpan`, `SyntaxTheme` (`.neon`), `TypeToken.code` |
| Overlays | `Overlay` (glass over what's behind, content at a placement), `.overlay(isPresented:)`, `.overlay(item:)`, `.progressOverlay(_:)` |
| Backdrops | `Backdrop`: patterns, drawn materials (`.busFloor(angle:)`, `.wood`, …), textures, aurora, glow, waves, images |

Modifiers that take tokens: `.foregroundStyle(_:)`, `.font(_:)`, `.glassSurface(_:cornerRadius:)`,
`.glassCapsule(_:)`, `.glassMaterial(_:)`, `.surface(_:cornerRadius:)`, `.appearance(_:)`.

## Gallery

`Gallery/` is an app that shows every token, resource and component, built only from Vitral
itself. It also hosts the snapshot tests, because glass only renders in a real window.

```bash
cd Gallery
xcodegen generate
open VitralGallery.xcodeproj
```

## License

Apache 2.0
