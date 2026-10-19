import SwiftUI
import Vitral
import VitralTokens

// Every state side by side, with constant bindings: the pages show components, they don't run
// them.

struct ButtonsPage: View {
    var body: some View {
        Page("Buttons") {
            Sample("Pill") {
                HStack(spacing: Space.medium) {
                    Pill { Label("12 compartments", systemImage: "circle.grid.2x2").padding(.horizontal, Space.medium).frame(height: Size.controlMedium) }
                    Pill(isActive: true, action: {}) { Image(systemName: "link").frame(width: Size.controlMedium, height: Size.controlMedium) }
                    Pill(action: {}) { Image(systemName: "plus").frame(width: Size.controlMedium, height: Size.controlMedium) }
                }
            }
            Sample("ButtonPrimary") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        ButtonPrimary("Calculate", icon: Image(.play), fillsWidth: true) {}
                        ButtonPrimary("Medium", size: .medium) {}
                        ButtonPrimary("Small", size: .small) {}
                        ButtonPrimary("Saving", fillsWidth: true, isBusy: true) {}
                        ButtonPrimary("Disabled", fillsWidth: true) {}.disabled(true)
                    }
                }
            }
            Sample("ButtonSecondary") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        ButtonSecondary("Try again", icon: Image(.retry), fillsWidth: true) {}
                        ButtonSecondary("Medium", size: .medium) {}
                        ButtonSecondary("Small", size: .small) {}
                        ButtonSecondary("Pulling", fillsWidth: true, isBusy: true) {}
                        ButtonSecondary("Disabled", fillsWidth: true) {}.disabled(true)
                        ButtonSecondary("Delete bus", icon: Image(systemName: "trash"), fillsWidth: true, role: .destructive) {}
                    }
                }
            }
            Sample("ButtonLabel: a custom button's content") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        Button {} label: {
                            ButtonLabel(Text(verbatim: "Plain, sized as the rest"), icon: Image(.play), size: .medium)
                        }
                        .buttonStyle(.plain)
                        Button {} label: {
                            ButtonLabel(Text(verbatim: "Busy"), size: .medium, isBusy: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Sample("ToggleButtonLatched: a desk's mute and solo") {
                Panel {
                    HStack(spacing: Space.small) {
                        ToggleButtonLatched(Text(verbatim: "M"), isOn: .constant(true), accessibilityLabel: Text("Mute"))
                        ToggleButtonLatched(Text(verbatim: "S"), isOn: .constant(true), lit: .warning, litInk: .fixedBlack, accessibilityLabel: Text("Solo"))
                        ToggleButtonLatched(Text(verbatim: "M"), isOn: .constant(false), accessibilityLabel: Text("Mute"))
                        ToggleButtonLatched(Text(verbatim: "S"), isOn: .constant(false), lit: .warning, litInk: .fixedBlack, accessibilityLabel: Text("Solo"))
                    }
                }
            }
            Sample("ActionBar") {
                Panel(padding: 0) {
                    ActionBar {
                        ActionBarButton("Edit", icon: Image(systemName: "pencil"), accessibilityLabel: "Edit") {}
                        ActionBarButton("Run", icon: Image(.play), accessibilityLabel: "Run") {}
                        ActionBarButton("Build", icon: Image(systemName: "hammer"), accessibilityLabel: "Build", isBusy: true) {}
                        ActionBarButton(icon: Image(systemName: "trash"), accessibilityLabel: "Delete", role: .destructive) {}
                    }
                }
            }
        }
    }
}

struct SelectionPage: View {
    var body: some View {
        Page("Checkboxes and toggles") {
            Sample("Checkbox") {
                PanelList {
                    Checkbox("Track this compartment", isOn: .constant(true)).padding(.horizontal, Space.large)
                    Checkbox("Intake", isOn: .constant(false)).padding(.horizontal, Space.large)
                }
            }
            Sample("ToggleSwitch") {
                PanelList {
                    ToggleSwitch("Logarithmic axis", isOn: .constant(true)).padding(.horizontal, Space.large)
                    ToggleSwitch("Show grid", isOn: .constant(false)).padding(.horizontal, Space.large)
                    ToggleSwitch("The click goes here", detail: Text("A default only: a song can send its own."), isOn: .constant(true))
                        .padding(.horizontal, Space.large)
                }
            }
            Sample("SelectionMark") {
                Panel {
                    HStack(spacing: Space.extraLarge) {
                        SelectionMark(isSelected: true)
                        SelectionMark(isSelected: false)
                        SelectionMark(isSelected: true, shape: .square)
                        SelectionMark(isSelected: false, shape: .square)
                    }
                }
            }
        }
    }
}

struct ListsPage: View {
    var body: some View {
        Page("Panels and rows") {
            Sample("Panel") {
                Panel {
                    Text("Content on glass, padded.")
                        .font(.body)
                        .foregroundStyle(.ink)
                }
            }
            Sample("PanelList and Row") {
                PanelList {
                    Row("Title only")
                    Row("With a subtitle", subtitle: "A second, quieter line")
                    Row("With a detail", detail: Text(verbatim: "42"))
                    Row("Leading view", detail: Text(verbatim: "accent")) { Swatch(.accent) }
                    Row("Disclosure", showsDisclosure: true)
                }
            }
            Sample("Hairline") {
                Panel {
                    VStack(spacing: Space.medium) {
                        Hairline()
                        HStack(spacing: Space.medium) {
                            Hairline(.vertical).frame(height: Space.extraLarge)
                            Hairline(.vertical).frame(height: Space.extraLarge)
                        }
                    }
                }
            }
        }
    }
}

struct TagsPage: View {
    var body: some View {
        Page("Tags and swatches") {
            Sample("Tag and TagCloud") {
                Panel {
                    TagCloud(["Nuclear", "Dosimetry", "ICRP 137", "Inhalation", "Type S", "48 compartments", "Plasma"])
                }
            }
            Sample("Tag styles") {
                Panel {
                    TagCloud {
                        Tag("Plain")
                        Tag("Tinted", icon: Image(systemName: "guitars"), style: .tinted(.accent))
                        Tag("Warning", style: .tinted(.warning))
                        Tag("Filled", style: .filled(.accent))
                    }
                }
            }
            Sample("TagToggle") {
                Panel {
                    TagCloud {
                        TagToggle("#swift", isOn: .constant(true))
                        TagToggle("#fp", isOn: .constant(true))
                        TagToggle("#ios", isOn: .constant(false))
                        TagToggle("#design", isOn: .constant(false))
                    }
                }
            }
            Sample("Swatch and SwatchStack") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        HStack(spacing: Space.small) {
                            Swatch(.accent)
                            Swatch(.warning)
                            Swatch(.danger)
                        }
                        SwatchStack([.accent, .warning, .danger])
                        SwatchStack([.accent, .accentTop, .warning, .danger, .inkMuted, .ink, .inkFaint, .accentBottom])
                        SwatchStack(items: [SwatchItem(.accent, label: "HH"), SwatchItem(.danger, label: "BB"), SwatchItem(.warning, label: "TN")], diameter: 38)
                        SwatchStack(items: [], diameter: 38)
                    }
                }
            }
            Sample("SwatchPlaceholder: where a swatch would be") {
                Panel {
                    HStack(spacing: Space.small) {
                        SwatchPlaceholder()
                        SwatchPlaceholder(diameter: 38)
                    }
                }
            }
            Sample("Badge: a monogram, an emoji, a picture or a glyph on a disc") {
                Panel {
                    HStack(spacing: Space.medium) {
                        Badge(.monogram("Hanna Huth"), diameter: 44)
                        Badge(.emoji("🥁"), colour: .washAmber, diameter: 44)
                        Badge(.image(Image(systemName: "photo.artframe")), colour: .washTeal, diameter: 44)
                        Badge(.glyph(Image(systemName: "music.mic")), fill: .red, diameter: 44, gradient: true)
                    }
                }
            }
            Sample("Monogram and SwatchStack(monograms:): a name's own colour") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        HStack(spacing: Space.small) {
                            Monogram("AC/DC", diameter: 44)
                            Monogram("Black Sabbath", diameter: 44)
                            Monogram("Deep Purple", diameter: 44)
                            Monogram("Iron Maiden", diameter: 44)
                        }
                        SwatchStack(monograms: ["Highway to Hell", "Paranoid", "Smoke on the Water", "The Trooper"])
                    }
                }
            }
            Sample("Stat") {
                Panel {
                    HStack(spacing: Space.large) {
                        Stat(icon: Image(systemName: "square.stack.3d.up"), value: Text(verbatim: "48"), accessibilityLabel: Text("48 compartments"))
                        Stat(icon: Image(systemName: "arrow.triangle.branch"), value: Text(verbatim: "89"), accessibilityLabel: Text("89 links"))
                    }
                }
            }
        }
    }
}

struct CardsPage: View {
    var body: some View {
        Page("Cards") {
            Sample("CardAdd") {
                CardAdd("New blank model") {}
            }
            Sample("Title and subtitle") {
                Card("Validation", subtitle: "Model to validate the software")
            }
            Sample("With header and content") {
                Card("U-234 Inhalation", subtitle: "ICRP 137, Type S") {
                    HStack(spacing: Space.large) {
                        Stat(icon: Image(systemName: "square.stack.3d.up"), value: Text(verbatim: "48"), accessibilityLabel: Text("48 compartments"))
                        Stat(icon: Image(systemName: "arrow.triangle.branch"), value: Text(verbatim: "89"), accessibilityLabel: Text("89 links"))
                    }
                }
                .header {
                    HStack {
                        SwatchStack([.accent, .warning, .danger, .inkMuted, .accentTop, .ink, .inkFaint])
                        Spacer()
                        Tag("Half-life 245,500 y")
                    }
                }
            }
            Sample("With a footer") {
                Card("Codeine → Morphine", subtitle: "Two substances, one metabolism") {
                    TagCloud(["Pharmacology", "PK"])
                }
                .header { SwatchStack([.accent, .danger]) }
                .footer {
                    ActionBar {
                        ActionBarButton("Edit", icon: Image(systemName: "pencil"), accessibilityLabel: "Edit") {}
                        ActionBarButton("Calculate", icon: Image(systemName: "waveform.path.ecg"), accessibilityLabel: "Calculate") {}
                        ActionBarButton(icon: Image(systemName: "doc.on.doc"), accessibilityLabel: "Duplicate") {}
                        ActionBarButton(icon: Image(systemName: "trash"), accessibilityLabel: "Delete", role: .destructive) {}
                    }
                }
            }
        }
    }
}

enum Method: Hashable, Sendable {
    case birchall, rungeKutta4, rungeKutta45
}

enum ChartScale: Hashable, Sendable {
    case linear, logarithmic
}

struct PickersPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        Page("Pickers") {
            Sample("SegmentedControlGlass") {
                Panel {
                    VStack(spacing: Space.medium) {
                        SegmentedControlGlass(selection: .constant(ChartScale.logarithmic), options: [
                            ChoiceOption(ChartScale.linear, title: "Linear"),
                            ChoiceOption(ChartScale.logarithmic, title: "Logarithmic")
                        ])
                        SegmentedControlGlass(selection: .constant(Method.birchall), options: [
                            ChoiceOption(Method.birchall, icon: Image(systemName: "function"), accessibilityLabel: "Birchall"),
                            ChoiceOption(Method.rungeKutta4, icon: Image(systemName: "4.circle"), accessibilityLabel: "Runge-Kutta 4"),
                            ChoiceOption(Method.rungeKutta45, icon: Image(systemName: "waveform.path"), accessibilityLabel: "Runge-Kutta 45")
                        ])
                    }
                }
            }
            Sample("RadioList") {
                RadioList(selection: .constant(Method.birchall), options: [
                    ChoiceOption(Method.birchall, title: "Birchall", detail: Text(verbatim: "exact")),
                    ChoiceOption(Method.rungeKutta4, title: "Runge-Kutta 4", detail: Text(verbatim: "fixed step")),
                    ChoiceOption(Method.rungeKutta45, title: "Runge-Kutta 45", detail: Text(verbatim: "adaptive"))
                ])
            }
            Sample("StepperJump") {
                Panel {
                    VStack(spacing: Space.medium) {
                        StepperJump(value: .constant(200), fine: 1, coarse: 20, format: model.formats.whole, decreaseLabel: { Text("Minus \($0)") }, increaseLabel: { Text("Plus \($0)") })
                        StepperJump(value: .constant(1), fine: 1, coarse: 20, format: model.formats.whole, decreaseLabel: { Text("Minus \($0)") }, increaseLabel: { Text("Plus \($0)") })
                    }
                }
            }
        }
    }
}

struct FieldsPage: View {
    var body: some View {
        Page("Fields") {
            Sample("FieldText") {
                Panel {
                    VStack(spacing: Space.medium) {
                        FieldText("Name", text: .constant(""))
                        FieldText("Name", text: .constant("U-234 Inhalation"))
                        FieldText("Step", text: .constant("0,001"), suffix: Text(verbatim: "d"), keyboard: .decimal, isMonospaced: true)
                    }
                }
            }
            Sample("Statuses") {
                Panel {
                    VStack(spacing: Space.medium) {
                        FieldText("Email", text: .constant("luiz@ios.lu"), keyboard: .email, status: .success(Text("Looks right.")))
                        FieldText("Step", text: .constant("0,0001"), suffix: Text(verbatim: "d"), keyboard: .decimal, isMonospaced: true, status: .warning(Text("Small steps take longer.")))
                        FieldText("Tolerance", text: .constant("abc"), isMonospaced: true, status: .error([
                            Text("Must be a number."),
                            Text("Must be between 1e-14 and 1e-2.")
                        ]))
                        FieldText("Name", text: .constant(""), status: .error([]))
                    }
                }
            }
            Sample("FieldSecure") {
                Panel {
                    FieldSecure("Personal access token", text: .constant("ghp_secret"))
                }
            }
            Sample("FieldContainer and FieldMessages: a field of your own") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        FieldContainer(icon: Image(systemName: "calendar"), status: .warning(Text(verbatim: "That's a Sunday."))) {
                            DatePicker("Date", selection: .constant(Date(timeIntervalSinceReferenceDate: 0)), displayedComponents: .date)
                                .labelsHidden()
                        }
                        FieldMessages(status: .error([Text(verbatim: "Must be a number."), Text(verbatim: "Must be positive.")]))
                    }
                }
            }
            Sample("FieldSearch") {
                Panel {
                    VStack(spacing: Space.medium) {
                        FieldSearch("Name, artist or tag", text: .constant(""), clearLabel: "Clear")
                        FieldSearch("Name, artist or tag", text: .constant("Highway"), clearLabel: "Clear")
                    }
                }
            }
        }
    }
}

struct BannersPage: View {
    var body: some View {
        Page("Banners") {
            Sample("Presets") {
                VStack(spacing: Space.medium) {
                    Banner("Calculated in 0.4 s.", style: .info)
                    Banner("Saved to GitHub.", style: .success)
                    Banner("RK4 at this step may be unstable.", style: .warning)
                    Banner("The solver stopped at day 412.", style: .error)
                    Banner("Times are in days.", style: .neutral)
                }
            }
            Sample("Custom") {
                Banner(
                    "Recording: every change is kept.",
                    style: .custom(foreground: .accent, background: ColorToken.accent.opacity(0.12), icon: Image(systemName: "record.circle"))
                )
            }
            Sample("With an action") {
                Banner("This file changed on disk while you were editing it.", style: .warning)
                    .trailing { ButtonSecondary("Reload", size: .small) {} }
            }
        }
    }
}

struct EmptyStatesPage: View {
    var body: some View {
        Page("Empty and error states") {
            Sample("EmptyState with an illustration and an action") {
                Panel {
                    EmptyState("No models yet", message: Text("Make one from scratch, or import a file."), illustration: .empty)
                        .actions { ButtonPrimary("New model", icon: Image(.add)) {} }
                }
            }
            Sample("EmptyState with a symbol") {
                Panel {
                    EmptyState("Nothing selected", message: Text("Tap a track to edit it here."), icon: Image(systemName: "hand.tap"))
                }
            }
            Sample("SymbolArtwork: a symbol standing in for an illustration") {
                Panel {
                    SymbolArtwork(Image(systemName: "music.note.list"))
                }
            }
            Sample("ErrorScreen with retry") {
                Panel {
                    ErrorScreen("Couldn't sync", message: Text("GitHub didn't answer for \(30) seconds."), illustration: .offline, retry: ("Try again", {}))
                }
            }
            Sample("ErrorScreen without retry") {
                Panel {
                    ErrorScreen("This file can't be read", message: Text("It isn't a model Vitral knows."))
                }
            }
        }
    }
}

struct ProgressPage: View {
    var body: some View {
        Page("Progress") {
            Sample("ProgressPanel, with a fraction") {
                ProgressPanel("Importing 3 of 12", detail: Text(verbatim: "Highway to Hell.wav"), fraction: 0.25)
            }
            Sample("ProgressPanel, the task and the whole job") {
                ProgressPanel("Importing 3 of 12", detail: Text(verbatim: "Hells Bells.wav"), fraction: 0.6, overall: 0.2)
            }
            Sample("ProgressPanel, without one") {
                ProgressPanel("Pushing to GitHub", detail: Text(verbatim: "feature/new-article"))
            }
            Sample(".progressOverlay(_:)") {
                OverlaySample(title: "Back in Black", subtitle: "AC/DC")
                    .progressOverlay(ProgressPanel("Importing 3 of 12", detail: Text(verbatim: "Hells Bells.wav"), fraction: 0.6, overall: 0.2))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct OverlaysPage: View {
    var body: some View {
        Page("Overlays") {
            Sample("Overlay, centred") {
                OverlaySample(title: "Inhalation", subtitle: "Twelve compartments")
                    .overlay(isPresented: true) {
                        Tag("Locked while syncing", icon: Image(.lock), style: .tint(.blue))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
            Sample("EdgeFade: frosting where content runs under a bar") {
                Panel {
                    ZStack {
                        VStack(alignment: .leading, spacing: Space.small) {
                            ForEach(1...9, id: \.self) { line in
                                Text(verbatim: "Line \(line) of a canvas that runs under the bars")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        EdgeFade(.top, beyond: 48)
                        EdgeFade(.bottom, beyond: 48)
                    }
                    .frame(height: 200)
                    .clipped()
                }
            }
            Sample("Overlay(placement: .bottom)") {
                OverlaySample(title: "Inhalation", subtitle: "Twelve compartments")
                    .overlay(isPresented: true, placement: .bottom) {
                        Banner("Saved to your library", style: .success)
                            .glassSurface(.regular, cornerRadius: Radius.medium)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
            Sample("obscuring: .strong, a heavy blur") {
                OverlaySample(title: "Inhalation", subtitle: "Twelve compartments")
                    .overlay(isPresented: true, obscuring: .strong) {
                        Tag("Locked while syncing", icon: Image(.lock), style: .tint(.blue))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
            Sample("obscuring: .dark, darkened") {
                OverlaySample(title: "Inhalation", subtitle: "Twelve compartments")
                    .overlay(isPresented: true, obscuring: .dark) {
                        ButtonPrimary("Unlock") {}
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
            Sample("Overlay(placement: .topTrailing, glass: .clear)") {
                OverlaySample(title: "Inhalation", subtitle: "Twelve compartments")
                    .overlay(isPresented: true, placement: .topTrailing, glass: .clear) {
                        Tag("Draft", icon: Image(.info), style: .tint(.amber))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
        }
    }
}

/// Something for an overlay to cover: a card on a backdrop.
struct OverlaySample: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        Card(title, subtitle: subtitle) {
            TagCloud(["Glass", "over", "the", "content"])
        }
        .padding(Space.large)
        .frame(height: 240)
        .background { Backdrop(.waves()) }
    }
}

