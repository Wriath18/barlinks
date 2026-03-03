import SwiftUI

struct ListRowView: View {
    let list: LinkList
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 10)
                    Text(list.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(list.links.count)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                if list.links.isEmpty {
                    Text("No links in this list")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 32)
                        .padding(.bottom, 6)
                } else {
                    ForEach(list.links) { link in
                        LinkRowView(link: link, listID: list.id)
                    }
                }
            }
        }
    }
}
