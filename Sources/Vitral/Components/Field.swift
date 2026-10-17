import SwiftUI
import VitralTokens

/// The keyboard a field asks for. Elsewhere than iOS, every case is the plain keyboard.
public enum FieldKeyboard: Hashable, Sendable {
    case text
    /// Digits and the locale's decimal separator.
    case decimal
    /// Digits only.
    case integer
    /// Digits and punctuation, for exponents ("1e-13").
    case scientific
    case email
    case url
}

/// What every field sits in: glass at control height, an optional icon before the input and an
/// optional suffix after it.
public struct FieldContainer<Input: View>: View {
    let icon: Image?
    let suffix: Text?
    let input: Input

    public init(icon: Image? = nil, suffix: Text? = nil, @ViewBuilder input: () -> Input) {
        self.icon = icon
        self.suffix = suffix
        self.input = input()
    }

    public var body: some View {
        HStack(spacing: Space.small) {
            icon.foregroundStyle(.inkMuted)
            input
                .font(.body)
                .foregroundStyle(.ink)
            suffix
                .font(.detail)
                .foregroundStyle(.inkFaint)
        }
        .padding(.horizontal, Space.medium + Space.extraSmall)
        .frame(minHeight: Size.hitTarget)
        .glassSurface(cornerRadius: Radius.medium)
    }
}

/// A line of text to type. `onEndEditing` fires when the field loses focus: the place to format
/// what was typed, so nothing is rewritten under the cursor while typing.
public struct FieldText: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let icon: Image?
    let suffix: Text?
    let keyboard: FieldKeyboard
    let isMonospaced: Bool
    let onEndEditing: @MainActor () -> Void

    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        icon: Image? = nil,
        suffix: Text? = nil,
        keyboard: FieldKeyboard = .text,
        isMonospaced: Bool = false,
        onEndEditing: @escaping @MainActor () -> Void = {}
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.suffix = suffix
        self.keyboard = keyboard
        self.isMonospaced = isMonospaced
        self.onEndEditing = onEndEditing
    }

    public var body: some View {
        FieldContainer(icon: icon, suffix: suffix) {
            TextField(placeholder, text: $text, onEditingChanged: { editing in if !editing { onEndEditing() } })
                .fontDesign(isMonospaced ? .monospaced : .default)
                .keyboard(keyboard)
        }
    }
}

/// A secret to type: the characters are hidden.
public struct FieldSecure: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let icon: Image?

    public init(_ placeholder: LocalizedStringKey, text: Binding<String>, icon: Image? = Image(.lock)) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }

    public var body: some View {
        FieldContainer(icon: icon) {
            SecureField(placeholder, text: $text)
                .textContentType(.password)
        }
    }
}

/// A search query: a magnifying glass before it, and a button that clears it once there's
/// something to clear.
public struct FieldSearch: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let clearLabel: LocalizedStringKey

    /// - Parameter clearLabel: what VoiceOver says for the clear button.
    public init(_ placeholder: LocalizedStringKey, text: Binding<String>, clearLabel: LocalizedStringKey = "Clear") {
        self.placeholder = placeholder
        self._text = text
        self.clearLabel = clearLabel
    }

    public var body: some View {
        FieldContainer(icon: Image(.search)) {
            HStack(spacing: Space.small) {
                TextField(placeholder, text: $text)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                if !text.isEmpty {
                    Button { text = "" } label: {
                        Image(.clear).foregroundStyle(.inkFaint)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(Text(clearLabel))
                }
            }
        }
    }
}

public extension View {
    /// Asks for `keyboard` where there are software keyboards; does nothing elsewhere.
    @ViewBuilder
    func keyboard(_ keyboard: FieldKeyboard) -> some View {
        #if os(iOS)
        switch keyboard {
        case .text: self
        case .decimal: keyboardType(.decimalPad)
        case .integer: keyboardType(.numberPad)
        case .scientific: keyboardType(.numbersAndPunctuation).autocorrectionDisabled().textInputAutocapitalization(.never)
        case .email: keyboardType(.emailAddress).textContentType(.emailAddress).autocorrectionDisabled().textInputAutocapitalization(.never)
        case .url: keyboardType(.URL).textContentType(.URL).autocorrectionDisabled().textInputAutocapitalization(.never)
        }
        #else
        self
        #endif
    }
}
