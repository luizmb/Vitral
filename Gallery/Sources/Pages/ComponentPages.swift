import SwiftUI
import Vitral
import VitralTokens

// Every state side by side, with constant bindings: the pages show components, they don't run
// them.

struct ButtonsPage: View {
    var body: some View {
        Page("Buttons") {
            LabelledGroup("ButtonPrimary") {
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
            LabelledGroup("ButtonSecondary") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        ButtonSecondary("Try again", icon: Image(.retry), fillsWidth: true) {}
                        ButtonSecondary("Medium", size: .medium) {}
                        ButtonSecondary("Small", size: .small) {}
                        ButtonSecondary("Pulling", fillsWidth: true, isBusy: true) {}
                        ButtonSecondary("Disabled", fillsWidth: true) {}.disabled(true)
                    }
                }
            }
            LabelledGroup("ActionBar") {
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
            LabelledGroup("Checkbox") {
                PanelList {
                    Checkbox("Track this compartment", isOn: .constant(true)).padding(.horizontal, Space.large)
                    Checkbox("Intake", isOn: .constant(false)).padding(.horizontal, Space.large)
                }
            }
            LabelledGroup("ToggleSwitch") {
                PanelList {
                    ToggleSwitch("Logarithmic axis", isOn: .constant(true)).padding(.horizontal, Space.large)
                    ToggleSwitch("Show grid", isOn: .constant(false)).padding(.horizontal, Space.large)
                }
            }
            LabelledGroup("SelectionMark") {
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
            LabelledGroup("Panel") {
                Panel {
                    Text("Content on glass, padded.")
                        .font(.body)
                        .foregroundStyle(.ink)
                }
            }
            LabelledGroup("PanelList and Row") {
                PanelList {
                    Row("Title only")
                    Row("With a subtitle", subtitle: "A second, quieter line")
                    Row("With a detail", detail: Text(verbatim: "42"))
                    Row("Leading view", detail: Text(verbatim: "accent")) { Swatch(.accent) }
                    Row("Disclosure", showsDisclosure: true)
                }
            }
            LabelledGroup("Hairline") {
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
            LabelledGroup("Tag and TagCloud") {
                Panel {
                    TagCloud(["Nuclear", "Dosimetry", "ICRP 137", "Inhalation", "Type S", "48 compartments", "Plasma"])
                }
            }
            LabelledGroup("Tag styles") {
                Panel {
                    TagCloud {
                        Tag("Plain")
                        Tag("Tinted", icon: Image(systemName: "guitars"), style: .tinted(.accent))
                        Tag("Warning", style: .tinted(.warning))
                        Tag("Filled", style: .filled(.accent))
                    }
                }
            }
            LabelledGroup("TagToggle") {
                Panel {
                    TagCloud {
                        TagToggle("#swift", isOn: .constant(true))
                        TagToggle("#fp", isOn: .constant(true))
                        TagToggle("#ios", isOn: .constant(false))
                        TagToggle("#design", isOn: .constant(false))
                    }
                }
            }
            LabelledGroup("Swatch and SwatchStack") {
                Panel {
                    VStack(alignment: .leading, spacing: Space.medium) {
                        HStack(spacing: Space.small) {
                            Swatch(.accent)
                            Swatch(.warning)
                            Swatch(.danger)
                        }
                        SwatchStack([.accent, .warning, .danger])
                        SwatchStack([.accent, .accentTop, .warning, .danger, .inkMuted, .ink, .inkFaint, .accentBottom])
                    }
                }
            }
            LabelledGroup("Stat") {
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
            LabelledGroup("Title and subtitle") {
                Card("Validation", subtitle: "Model to validate the software")
            }
            LabelledGroup("With header and content") {
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
            LabelledGroup("With a footer") {
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
    var body: some View {
        Page("Pickers") {
            LabelledGroup("SegmentedControlGlass") {
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
            LabelledGroup("RadioList") {
                RadioList(selection: .constant(Method.birchall), options: [
                    ChoiceOption(Method.birchall, title: "Birchall", detail: Text(verbatim: "exact")),
                    ChoiceOption(Method.rungeKutta4, title: "Runge-Kutta 4", detail: Text(verbatim: "fixed step")),
                    ChoiceOption(Method.rungeKutta45, title: "Runge-Kutta 45", detail: Text(verbatim: "adaptive"))
                ])
            }
            LabelledGroup("StepperJump") {
                Panel {
                    VStack(spacing: Space.medium) {
                        StepperJump(value: .constant(200), fine: 1, coarse: 20)
                        StepperJump(value: .constant(1), fine: 1, coarse: 20)
                    }
                }
            }
        }
    }
}

struct FieldsPage: View {
    var body: some View {
        Page("Fields") {
            LabelledGroup("FieldText") {
                Panel {
                    VStack(spacing: Space.medium) {
                        FieldText("Name", text: .constant(""))
                        FieldText("Name", text: .constant("U-234 Inhalation"))
                        FieldText("Step", text: .constant("0,001"), suffix: Text(verbatim: "d"), keyboard: .decimal, isMonospaced: true)
                    }
                }
            }
            LabelledGroup("FieldSecure") {
                Panel {
                    FieldSecure("Personal access token", text: .constant("ghp_secret"))
                }
            }
            LabelledGroup("FieldSearch") {
                Panel {
                    VStack(spacing: Space.medium) {
                        FieldSearch("Name, artist or tag", text: .constant(""))
                        FieldSearch("Name, artist or tag", text: .constant("Highway"))
                    }
                }
            }
        }
    }
}

struct BannersPage: View {
    var body: some View {
        Page("Banners") {
            LabelledGroup("Tones") {
                VStack(spacing: Space.medium) {
                    Banner("Calculated in 0.4 s.")
                    Banner("RK4 at this step may be unstable.", tone: .warning)
                    Banner("The solver stopped at day 412.", tone: .danger)
                }
            }
            LabelledGroup("With an action") {
                Banner("This file changed on disk while you were editing it.", tone: .warning)
                    .trailing { ButtonSecondary("Reload", size: .small) {} }
            }
        }
    }
}
