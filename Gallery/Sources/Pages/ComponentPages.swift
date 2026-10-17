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
                        ButtonSecondary("Disabled", fillsWidth: true) {}.disabled(true)
                    }
                }
            }
            LabelledGroup("ActionBar") {
                Panel(padding: 0) {
                    ActionBar {
                        ActionBarButton("Edit", icon: Image(systemName: "pencil"), accessibilityLabel: "Edit") {}
                        ActionBarButton("Run", icon: Image(.play), accessibilityLabel: "Run") {}
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
