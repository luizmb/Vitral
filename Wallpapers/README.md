# Wallpapers

Photographic backdrops for Vitral apps. (Textures are small enough to ship inside Vitral:
`BackdropStyle.texture(_:)`. Photos aren't.) They live in the repository, **not** in the package: an
app that linked them all would carry every image whether it showed it or not. An app takes only
the ones it uses, copied into its own asset catalog, and shows one with
`Backdrop(.image(Image("…")))` or `Page(backdrop: .image(…))`.

- `Images/`: the photos (JPEG, 1920 px; they fill the screen and are cropped).
- `catalog.json`: each image's name, file, title, source, authors and licence.
- `CREDITS.md`: the same, for people. Keep it in step with `catalog.json`.

Only add images an app may ship without asking anyone: CC0, public domain, or CC-BY (and then the
app credits the author). Not Unsplash or Pexels: their licences forbid redistributing photos as a
collection, which this is.
