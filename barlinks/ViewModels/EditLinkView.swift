import SwiftUI

struct EditLinkView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    let link: LinkItem
    let listID: UUID

    @State private var itemType: ItemType
    @State private var content: String
    @State private var title: String

    init(link: LinkItem, listID: UUID) {
        self.link = link
        self.listID = listID
        _itemType = State(initialValue: link.type)
        _content = State(initialValue: link.content)
        _title = State(initialValue: link.title)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Edit Item")
                .font(.system(size: 14, weight: .semibold))

            // Link / Text toggle
            Picker("", selection: $itemType) {
                Text("Link").tag(ItemType.link)
                Text("Text").tag(ItemType.text)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            // Content field — changes shape based on type
            VStack(alignment: .leading, spacing: 4) {
                Text(itemType == .link ? "URL" : "Text")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                if itemType == .link {
                    TextField("https://", text: $content)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                } else {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .font(.system(size: 12))
                            .frame(height: 80)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(6)
                        if content.isEmpty {
                            Text("Paste or type text to save...")
                                .font(.system(size: 12))
                                .foregroundColor(Color(NSColor.placeholderTextColor))
                                .padding(.top, 8)
                                .padding(.leading, 8)
                                .allowsHitTesting(false)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                }
            }

            // Title (optional for both types)
            VStack(alignment: .leading, spacing: 4) {
                Text("Title")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                TextField("Optional", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    guard !content.isEmpty else { return }
                    let finalContent: String
                    if itemType == .link {
                        finalContent = content.hasPrefix("http") ? content : "https://\(content)"
                    } else {
                        finalContent = content
                    }
                    viewModel.updateLink(id: link.id, fromList: listID, title: title, content: finalContent, type: itemType)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(content.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 300)
    }
}
