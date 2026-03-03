import SwiftUI

struct AddLinkView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    var preselectedListID: UUID?

    @State private var itemType: ItemType = .link
    @State private var content = ""
    @State private var title = ""
    @State private var selectedListID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Add Item")
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

            // List picker
            VStack(alignment: .leading, spacing: 4) {
                Text("List")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                if viewModel.appData.lists.isEmpty {
                    Text("No lists yet — create one first")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    Picker("", selection: $selectedListID) {
                        ForEach(viewModel.appData.lists) { list in
                            Text(list.name).tag(Optional(list.id))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    viewModel.pendingServiceURL = nil
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Add") {
                    guard let listID = selectedListID, !content.isEmpty else { return }
                    let finalContent: String
                    if itemType == .link {
                        finalContent = content.hasPrefix("http") ? content : "https://\(content)"
                    } else {
                        finalContent = content
                    }
                    viewModel.addLink(title: title, content: finalContent, type: itemType, toList: listID)
                    viewModel.pendingServiceURL = nil
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(content.isEmpty || selectedListID == nil)
            }
        }
        .padding(20)
        .frame(width: 300)
        .onAppear {
            selectedListID = preselectedListID ?? viewModel.appData.lists.first?.id
            if let serviceURL = viewModel.pendingServiceURL {
                content = serviceURL
                itemType = .link
            }
        }
    }
}
