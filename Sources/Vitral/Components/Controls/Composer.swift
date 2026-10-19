import SwiftUI
import VitralTokens

/// Where a message is written: a field that grows to a few lines, an optional accessory before
/// the send button (a microphone, an attachment), and the send button, a spinner while `isBusy`.
/// On a glass capsule. Stateless: the draft is the binding's; sending is the caller's.
public struct Composer<Accessory: View>: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let isEditable: Bool
    let isBusy: Bool
    let sendLabel: LocalizedStringKey
    let accessory: Accessory
    let send: @MainActor () -> Void

    @Environment(\.accent) private var accent

    /// - Parameters:
    ///   - isEditable: whether the field takes typing (off while dictating, say).
    ///   - isBusy: a reply is on its way: the send button spins and takes no taps.
    ///   - sendLabel: what VoiceOver calls the send button.
    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        isEditable: Bool = true,
        isBusy: Bool = false,
        sendLabel: LocalizedStringKey,
        @ViewBuilder accessory: () -> Accessory = { EmptyView() },
        send: @escaping @MainActor () -> Void
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isEditable = isEditable
        self.isBusy = isBusy
        self.sendLabel = sendLabel
        self.accessory = accessory()
        self.send = send
    }

    var canSend: Bool {
        isEditable && !isBusy && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: Space.small) {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(1 ... 4)
                .textFieldStyle(.plain)
                .foregroundStyle(.ink)
                .disabled(!isEditable)
                .padding(.vertical, Space.small)
                .onSubmit { if canSend { send() } }
            accessory
                .frame(minWidth: Size.controlSmall, minHeight: Size.controlSmall)
            Button(action: send) {
                ZStack {
                    if isBusy {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.onAccent)
                    }
                }
                .frame(width: Size.controlSmall, height: Size.controlSmall)
                .background(Circle().fill(Color(canSend ? accent.base : .inkFaint)))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .accessibilityLabel(Text(sendLabel))
        }
        .padding(.leading, Space.large)
        .padding(.trailing, Space.extraSmall)
        .padding(.vertical, Space.extraSmall)
        .glassSurface(cornerRadius: Radius.sheet)
    }
}
