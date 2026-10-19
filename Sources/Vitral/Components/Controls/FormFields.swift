import SwiftUI
import VitralTokens

/// A choice from a menu, on one line: the title, and the chosen option, which opens the menu. For
/// many options or long ones, where a `SegmentedControlGlass` won't fit and a `RadioList` would
/// take the screen.
public struct FieldPicker<Value: Hashable & Sendable>: View {
    let title: Text
    @Binding var selection: Value
    let options: [ChoiceOption<Value>]

    @Environment(\.accent) private var accent

    public init(_ title: LocalizedStringKey, selection: Binding<Value>, options: [ChoiceOption<Value>]) {
        self.init(Text(title), selection: selection, options: options)
    }

    public init(_ title: Text, selection: Binding<Value>, options: [ChoiceOption<Value>]) {
        self.title = title
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        HStack(spacing: Space.medium) {
            title.font(.body).foregroundStyle(.ink)
            Spacer(minLength: Space.small)
            Picker(selection: $selection) {
                ForEach(options) { option in
                    (option.title ?? option.accessibilityLabel).tag(option.value)
                }
            } label: {
                title
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .tint(Color(accent.base))
        }
        .frame(minHeight: Size.hitTarget)
    }
}

/// A value to read, on one line: the title, and the value (or any trailing content) after it. For
/// what a form shows but doesn't edit here: a port, a count, a file's name.
public struct FieldValue<Value: View>: View {
    let title: Text
    let value: Value

    public init(_ title: LocalizedStringKey, @ViewBuilder value: () -> Value) {
        self.init(Text(title), value: value)
    }

    public init(_ title: Text, @ViewBuilder value: () -> Value) {
        self.title = title
        self.value = value()
    }

    public var body: some View {
        HStack(spacing: Space.medium) {
            title.font(.body).foregroundStyle(.ink)
            Spacer(minLength: Space.small)
            value
                .font(.body)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.trailing)
        }
        .frame(minHeight: Size.hitTarget)
        .accessibilityElement(children: .combine)
    }
}

public extension FieldValue where Value == Text {
    /// A title and a text value.
    init(_ title: LocalizedStringKey, value: Text) {
        self.init(Text(title)) { value }
    }

    init(_ title: Text, value: Text) {
        self.init(title) { value }
    }
}

/// A number to type, on one line: the title, the number, and an optional unit after it. `format`
/// both writes and reads it, so it is the app's, in the app's locale (`.number.locale(locale)`):
/// 1.5 typed in English is 1,5 in Portuguese.
public struct FieldNumber<Format: ParseableFormatStyle>: View where Format.FormatInput == Double, Format.FormatOutput == String {
    let title: Text
    @Binding var value: Double
    let format: Format
    let suffix: Text?
    let onEndEditing: @MainActor () -> Void

    public init(
        _ title: LocalizedStringKey,
        value: Binding<Double>,
        format: Format,
        suffix: Text? = nil,
        onEndEditing: @escaping @MainActor () -> Void = {}
    ) {
        self.init(Text(title), value: value, format: format, suffix: suffix, onEndEditing: onEndEditing)
    }

    public init(
        _ title: Text,
        value: Binding<Double>,
        format: Format,
        suffix: Text? = nil,
        onEndEditing: @escaping @MainActor () -> Void = {}
    ) {
        self.title = title
        self._value = value
        self.format = format
        self.suffix = suffix
        self.onEndEditing = onEndEditing
    }

    public var body: some View {
        HStack(spacing: Space.small) {
            title.font(.body).foregroundStyle(.ink)
            Spacer(minLength: Space.small)
            TextField(value: $value, format: format) { title }
                .font(.body.monospacedDigit())
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 110)
                .keyboard(.decimal)
                .onSubmit { onEndEditing() }
            suffix.map { suffix in suffix.font(.body).foregroundStyle(.inkMuted) }
        }
        .frame(minHeight: Size.hitTarget)
    }
}

/// A number stepped up and down, on one line: its label (which usually says the value) and the
/// minus and plus.
public struct FieldStepper<Value: Strideable>: View {
    let label: Text
    @Binding var value: Value
    let range: ClosedRange<Value>
    let step: Value.Stride

    public init(_ label: LocalizedStringKey, value: Binding<Value>, in range: ClosedRange<Value>, step: Value.Stride = 1) {
        self.init(Text(label), value: value, in: range, step: step)
    }

    public init(_ label: Text, value: Binding<Value>, in range: ClosedRange<Value>, step: Value.Stride = 1) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
    }

    public var body: some View {
        Stepper(value: $value, in: range, step: step) {
            label.font(.body).foregroundStyle(.ink).monospacedDigit()
        }
        .frame(minHeight: Size.hitTarget)
    }
}

/// A date (or a time, or both) to pick, on one line: the title, and the date as `format` writes it
/// (the app's, in its locale). Tapping it opens the calendar below; whether it's open is the app's
/// (`isPicking`), and the calendar's month and day names follow the environment's `locale` and
/// `calendar`, which the app sets.
public struct FieldDate: View {
    let title: Text
    @Binding var date: Date
    let components: DatePickerComponents
    let format: @Sendable (Date) -> Text
    @Binding var isPicking: Bool

    @Environment(\.accent) private var accent

    public init(
        _ title: LocalizedStringKey,
        date: Binding<Date>,
        components: DatePickerComponents = .date,
        format: @escaping @Sendable (Date) -> Text,
        isPicking: Binding<Bool>
    ) {
        self.init(Text(title), date: date, components: components, format: format, isPicking: isPicking)
    }

    public init(
        _ title: Text,
        date: Binding<Date>,
        components: DatePickerComponents = .date,
        format: @escaping @Sendable (Date) -> Text,
        isPicking: Binding<Bool>
    ) {
        self.title = title
        self._date = date
        self.components = components
        self.format = format
        self._isPicking = isPicking
    }

    public var body: some View {
        VStack(spacing: Space.small) {
            Button { isPicking.toggle() } label: {
                HStack(spacing: Space.medium) {
                    title.font(.body).foregroundStyle(.ink)
                    Spacer(minLength: Space.small)
                    format(date)
                        .font(.body.monospacedDigit())
                        .foregroundStyle(isPicking ? Color(accent.base) : Color(.inkMuted))
                }
                .frame(minHeight: Size.hitTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(format(date))
            if isPicking {
                DatePicker(selection: $date, displayedComponents: components) { title }
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .tint(Color(accent.base))
            }
        }
    }
}

/// A list of short entries to keep (names, aliases, tags): each removable, and a field at the end
/// to add another. Stateless: the entries and the draft being typed are the app's.
public struct EntryList: View {
    let entries: [String]
    @Binding var draft: String
    let placeholder: LocalizedStringKey
    let addTitle: LocalizedStringKey
    let removeLabel: (String) -> Text
    let onRemove: (Int) -> Void
    let onAdd: () -> Void

    @Environment(\.accent) private var accent

    /// - Parameters:
    ///   - removeLabel: what VoiceOver says for an entry's remove button.
    ///   - onRemove: called with the index of the entry to remove.
    ///   - onAdd: called to add `draft` (on Return, or the add button).
    public init(
        entries: [String],
        draft: Binding<String>,
        placeholder: LocalizedStringKey,
        addTitle: LocalizedStringKey,
        removeLabel: @escaping (String) -> Text,
        onRemove: @escaping (Int) -> Void,
        onAdd: @escaping () -> Void
    ) {
        self.entries = entries
        self._draft = draft
        self.placeholder = placeholder
        self.addTitle = addTitle
        self.removeLabel = removeLabel
        self.onRemove = onRemove
        self.onAdd = onAdd
    }

    var canAdd: Bool { !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    public var body: some View {
        ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
            HStack(spacing: Space.medium) {
                Text(verbatim: entry).font(.body).foregroundStyle(.ink)
                Spacer(minLength: Space.small)
                Button(role: .destructive) { onRemove(index) } label: {
                    Image(systemName: "minus.circle")
                        .font(.title3)
                        .foregroundStyle(Color(.danger))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(removeLabel(entry))
            }
            .frame(minHeight: Size.hitTarget)
        }
        HStack(spacing: Space.medium) {
            TextField(placeholder, text: $draft)
                .font(.body)
                .onSubmit { if canAdd { onAdd() } }
            Button(addTitle) { onAdd() }
                .disabled(!canAdd)
                .tint(Color(accent.base))
        }
        .frame(minHeight: Size.hitTarget)
    }
}

/// One of many options laid out as a grid of cells, the chosen one marked by the cell itself
/// (`cell` is told whether it is chosen). The base of `SwatchPicker` and `IconPicker`.
public struct ChoiceGrid<Value: Hashable & Sendable, Cell: View>: View {
    @Binding var selection: Value
    let options: [Value]
    let minimumWidth: Double
    let label: (Value) -> Text
    let cell: (Value, Bool) -> Cell

    /// - Parameters:
    ///   - minimumWidth: the narrowest a column may be; as many fit as the width allows.
    ///   - label: what VoiceOver says for an option.
    public init(
        selection: Binding<Value>,
        options: [Value],
        minimumWidth: Double,
        label: @escaping (Value) -> Text,
        @ViewBuilder cell: @escaping (Value, Bool) -> Cell
    ) {
        self._selection = selection
        self.options = options
        self.minimumWidth = minimumWidth
        self.label = label
        self.cell = cell
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumWidth), spacing: Space.medium)], spacing: Space.medium) {
            ForEach(options, id: \.self) { option in
                Button { selection = option } label: {
                    cell(option, option == selection)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(label(option))
                .accessibilityAddTraits(option == selection ? .isSelected : [])
            }
        }
        .padding(.vertical, Space.small)
    }
}

/// A colour to choose from a grid of discs, the chosen one ticked.
public struct SwatchPicker<Value: Hashable & Sendable>: View {
    @Binding var selection: Value
    let options: [Value]
    let diameter: Double
    let colour: (Value) -> Color
    let label: (Value) -> Text

    /// - Parameters:
    ///   - colour: each option's colour, which may be an app's own rather than a token.
    ///   - label: what VoiceOver says for it (its colour's name).
    public init(
        selection: Binding<Value>,
        options: [Value],
        diameter: Double = Size.controlMedium,
        colour: @escaping (Value) -> Color,
        label: @escaping (Value) -> Text
    ) {
        self._selection = selection
        self.options = options
        self.diameter = diameter
        self.colour = colour
        self.label = label
    }

    public var body: some View {
        ChoiceGrid(selection: $selection, options: options, minimumWidth: diameter + Space.small, label: label) { option, isChosen in
            Circle()
                .fill(colour(option))
                .overlay(Circle().strokeBorder(Color(.hairline), lineWidth: 1))
                .overlay {
                    if isChosen {
                        Image(systemName: "checkmark")
                            .font(.system(size: diameter * 0.4, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: diameter, height: diameter)
        }
    }
}

/// A picture to choose from a grid: each option's icon over its name, the chosen one on a wash of
/// the accent.
public struct IconPicker<Value: Hashable & Sendable, Icon: View>: View {
    @Binding var selection: Value
    let options: [Value]
    let minimumWidth: Double
    let icon: (Value) -> Icon
    let title: (Value) -> Text

    @Environment(\.accent) private var accent

    public init(
        selection: Binding<Value>,
        options: [Value],
        minimumWidth: Double = 64,
        @ViewBuilder icon: @escaping (Value) -> Icon,
        title: @escaping (Value) -> Text
    ) {
        self._selection = selection
        self.options = options
        self.minimumWidth = minimumWidth
        self.icon = icon
        self.title = title
    }

    public var body: some View {
        ChoiceGrid(selection: $selection, options: options, minimumWidth: minimumWidth, label: title) { option, isChosen in
            VStack(spacing: Space.hairline) {
                icon(option).font(.title3).frame(height: 30)
                title(option)
                    .font(.system(size: 9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(.ink)
            }
            .padding(.vertical, Space.extraSmall)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Space.small)
                    .fill(isChosen ? Color(accent.base).opacity(0.18) : .clear)
            )
        }
    }
}

public extension IconPicker where Icon == Badge {
    /// An icon picker whose icons are badges: a monogram, an emoji, a picture or a glyph on a disc.
    init(
        selection: Binding<Value>,
        options: [Value],
        minimumWidth: Double = 64,
        badge: @escaping (Value) -> Badge,
        title: @escaping (Value) -> Text
    ) {
        self.init(selection: selection, options: options, minimumWidth: minimumWidth, icon: badge, title: title)
    }
}
