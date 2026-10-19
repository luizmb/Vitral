import SwiftUI
import Vitral
import VitralTokens

/// A conversation: bubbles on both sides, and the composer under them.
struct ConversationPage: View {
    @Environment(GalleryModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Page("Conversation", backdrop: .glow()) {
            Sample("MessageBubble, theirs and mine") {
                VStack(spacing: Space.medium) {
                    MessageBubble(Text("What should the intro say about pure functions?"), author: Text("You"), side: .mine)
                    MessageBubble(
                        Text("Start from a bug a reader has had: a function that answered differently with the same input."),
                        author: Text("Assistant"),
                        side: .theirs
                    )
                    MessageBubble(Text("Good. Shorter?"), side: .mine)
                }
            }
            Sample("Composer, with a microphone") {
                Composer("Say something…", text: $model.chatDraft, sendLabel: "Send") {
                    Pill(isActive: model.chatListening, action: { model.chatListening.toggle() }) {
                        Image(systemName: model.chatListening ? "mic.fill" : "mic")
                            .frame(width: Size.controlSmall, height: Size.controlSmall)
                    }
                } send: {
                    model.chatDraft = ""
                }
            }
            Sample("Composer, waiting for a reply") {
                Composer("Say something…", text: .constant("Thanks!"), isBusy: true, sendLabel: "Send") {}
            }
        }
    }
}
