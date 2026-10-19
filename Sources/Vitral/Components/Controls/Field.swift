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

/// What a field says about its input. Anything but `normal` tints the glass, colours the border,
/// shows its icon at the end, and lists its messages under the field. No messages, no label: the
/// colour and icon alone still say it.
///
/// Several messages fit a validation that collects every failure (`Validation<T, [E]>`): map the
/// errors to `Text` and pass them all.
public enum FieldStatus: Sendable {
    case normal
    case success([Text])
    case warning([Text])
    case error([Text])

    public static func success(_ message: Text) -> FieldStatus { .success([message]) }
    public static func warning(_ message: Text) -> FieldStatus { .warning([message]) }
    public static func error(_ message: Text) -> FieldStatus { .error([message]) }

    /// The banner preset with the same colours and icon, so a field and a banner saying the same
    /// thing look alike.
    var style: BannerStyle? {
        switch self {
        case .normal: nil
        case .success: .success
        case .warning: .warning
        case .error: .error
        }
    }

    var messages: [Text] {
        switch self {
        case .normal: []
        case let .success(messages), let .warning(messages), let .error(messages): messages
        }
    }
}

/// What every field sits in: glass at control height, an optional icon before the input and an
/// optional suffix after it, and its status (colours, icon, messages).
public struct FieldContainer<Input: View>: View {
    let icon: Image?
    let suffix: Text?
    let status: FieldStatus
    let input: Input

    @Environment(\.surfaceGlass) private var glass

    public init(icon: Image? = nil, suffix: Text? = nil, status: FieldStatus = .normal, @ViewBuilder input: () -> Input) {
        self.icon = icon
        self.suffix = suffix
        self.status = status
        self.input = input()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.extraSmall) {
            HStack(spacing: Space.small) {
                icon.foregroundStyle(.inkMuted)
                input
                    .font(.body)
                    .foregroundStyle(.ink)
                suffix
                    .font(.detail)
                    .foregroundStyle(.inkFaint)
                status.style.map { style in
                    style.icon
                        .foregroundStyle(style.foreground)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, Space.medium + Space.extraSmall)
            .frame(minHeight: Size.hitTarget)
            .glassSurface(glass.tinted(status.style?.background ?? glass.tint), cornerRadius: Radius.medium)
            .overlay {
                status.style.map { style in
                    RoundedRectangle(cornerRadius: Radius.medium, style: .continuous)
                        .strokeBorder(Color(style.foreground), lineWidth: 1.5)
                }
            }
            FieldMessages(status: status)
        }
    }
}

/// A field's messages, one line each in its status colour.
public struct FieldMessages: View {
    let status: FieldStatus

    public init(status: FieldStatus) {
        self.status = status
    }

    public var body: some View {
        status.style.map { style in
            VStack(alignment: .leading, spacing: Space.hairline) {
                ForEach(Array(status.messages.enumerated()), id: \.offset) { _, message in
                    message
                }
            }
            .font(TypeToken.detail.weight(.medium))
            .foregroundStyle(style.foreground)
            .padding(.horizontal, Space.medium)
        }
    }
}

/// A line of text to type. `onEndEditing` fires when the field loses focus: the place to format
/// (and validate) what was typed, so nothing is rewritten under the cursor while typing.
public struct FieldText: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let icon: Image?
    let suffix: Text?
    let keyboard: FieldKeyboard
    let isMonospaced: Bool
    let status: FieldStatus
    let onEndEditing: @MainActor () -> Void

    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        icon: Image? = nil,
        suffix: Text? = nil,
        keyboard: FieldKeyboard = .text,
        isMonospaced: Bool = false,
        status: FieldStatus = .normal,
        onEndEditing: @escaping @MainActor () -> Void = {}
    ) {
        self.status = status
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.suffix = suffix
        self.keyboard = keyboard
        self.isMonospaced = isMonospaced
        self.onEndEditing = onEndEditing
    }

    public var body: some View {
        FieldContainer(icon: icon, suffix: suffix, status: status) {
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
    let status: FieldStatus

    public init(_ placeholder: LocalizedStringKey, text: Binding<String>, icon: Image? = Image(.lock), status: FieldStatus = .normal) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.status = status
    }

    public var body: some View {
        FieldContainer(icon: icon, status: status) {
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
    public init(_ placeholder: LocalizedStringKey, text: Binding<String>, clearLabel: LocalizedStringKey) {
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
