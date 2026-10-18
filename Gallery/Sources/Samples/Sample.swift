import SwiftUI
import Vitral
import VitralTokens

/// A sample's code, as it is in the Gallery's source.
struct SampleCode: Identifiable, Hashable {
    let title: String
    let code: String

    var id: String { title }

    /// The code written for `title` in `file`, when the script found it.
    static func find(_ title: String, in file: String) -> SampleCode? {
        GeneratedSamples.code[key(title, in: file)].map { SampleCode(title: title, code: $0) }
    }

    /// How the script files a sample: its file's name and its title.
    static func key(_ title: String, in file: String) -> String {
        "\(file.split(separator: "/").last.map(String.init) ?? file)#\(title)"
    }
}

/// A titled sample with an ⓘ at its title's end that shows its code.
struct Sample<Content: View>: View {
    let title: String
    let file: String
    let content: Content

    init(_ title: String, file: String = #fileID, @ViewBuilder content: () -> Content) {
        self.title = title
        self.file = file
        self.content = content()
    }

    var body: some View {
        LabelledGroup(LocalizedStringKey(title)) {
            SampleInfoButton(title: title, file: file)
        } content: {
            content
        }
    }
}

/// The ⓘ that shows a sample's code, when there is code for it.
struct SampleInfoButton: View {
    let title: String
    let file: String

    @Environment(GalleryModel.self) private var model

    var body: some View {
        if let sample = SampleCode.find(title, in: file) {
            Button { model.shownSample = sample } label: {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundStyle(.accent)
                    .frame(minWidth: Size.hitTarget / 2, minHeight: Size.hitTarget / 2)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Code for \(title)"))
        }
    }
}

/// A sample's code on glass over the Gallery, with a way to close it.
struct SampleCodePanel: View {
    let sample: SampleCode
    let close: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.medium) {
            HStack(alignment: .top, spacing: Space.medium) {
                Text(verbatim: sample.title)
                    .font(.bodyStrong)
                    .foregroundStyle(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.ink)
                        .frame(width: Size.controlSmall, height: Size.controlSmall)
                        .glassCapsule()
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Close"))
            }
            ScrollView {
                CodeBlock(SwiftHighlighter.spans(sample.code))
            }
            .frame(maxHeight: 520)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Space.large)
        .frame(maxWidth: 680)
        .glassSurface(.regular, cornerRadius: Radius.sheet)
    }
}
