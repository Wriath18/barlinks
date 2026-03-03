import SwiftUI

struct LinkRowView: View {
    let link: LinkItem
    let listID: UUID
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isHovered = false
    @State private var showCopied = false
    @State private var showEditSheet = false

    var displayTitle: String {
        link.title.isEmpty ? link.content : link.title
    }

    var body: some View {
        HStack(spacing: 8) {
            // Icon: logo for links, text icon for text snippets
            if link.type == .text {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .frame(width: 14, height: 14)
            } else {
                AsyncImage(url: logoURL(for: link.content)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(3)
                    default:
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(NSColor.quaternaryLabelColor))
                    }
                }
                .frame(width: 14, height: 14)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(displayTitle)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(link.content)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if showCopied {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.green)
            } else if isHovered {
                HStack(spacing: 4) {
                    Button(action: {
                        copyToClipboard()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Copy")
                    
                    Button(action: {
                        showEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Edit")
                    
                    Button(action: {
                        viewModel.deleteLink(id: link.id, fromList: listID)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Delete")
                }
            }
        }
        .padding(.leading, 30)
        .padding(.trailing, 12)
        .padding(.vertical, 5)
        .background(
            isHovered
                ? Color(NSColor.selectedContentBackgroundColor).opacity(0.12)
                : Color.clear
        )
        .cornerRadius(4)
        .onHover { isHovered = $0 }
        .onTapGesture { handleTap() }
        .contentShape(Rectangle())
        .sheet(isPresented: $showEditSheet) {
            EditLinkView(link: link, listID: listID)
                .environmentObject(viewModel)
        }
    }

    private func logoURL(for urlString: String) -> URL? {
        guard let host = URL(string: urlString)?.host, !host.isEmpty else { return nil }
        return URL(string: "https://img.logo.dev/\(host)?token=[INSERT_YOUR_TOKEN_HERE]")
    }

    private func handleTap() {
        switch link.type {
        case .link:
            if let url = URL(string: link.content) {
                NSWorkspace.shared.open(url)
            }
        case .text:
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(link.content, forType: .string)
            showCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCopied = false
            }
        }
    }
    
    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link.content, forType: .string)
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
}
