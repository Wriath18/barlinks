import SwiftUI

struct MainPopoverView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showAddLink = false
    @State private var showAddList = false
    @State private var searchText = ""

    var filteredLists: [LinkList] {
        guard !searchText.isEmpty else { return viewModel.appData.lists }
        return viewModel.appData.lists.compactMap { list in
            let matchingLinks = list.links.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
            let listMatches = list.name.localizedCaseInsensitiveContains(searchText)
            if matchingLinks.isEmpty && !listMatches { return nil }
            var updated = list
            updated.links = listMatches ? list.links : matchingLinks
            return updated
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            searchView
            Divider()
            listContent
            Divider()
            footerView
        }
        .frame(width: 320)
        .onChange(of: viewModel.pendingServiceURL) { url in
            if url != nil { showAddLink = true }
        }
        .sheet(isPresented: $showAddLink) {
            AddLinkView(preselectedListID: viewModel.appData.lists.first?.id)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showAddList) {
            AddListView()
                .environmentObject(viewModel)
        }
    }

    private var headerView: some View {
        HStack {
            Text("barlinks")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Button(action: { showAddLink = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.plain)
            .help("Add link")
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var searchView: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 11))
            TextField("Search...", text: $searchText)
                .font(.system(size: 12))
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.appData.lists.isEmpty {
                    emptyState
                } else if filteredLists.isEmpty {
                    Text("No results")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    ForEach(filteredLists) { list in
                        ListRowView(list: list)
                        if list.id != filteredLists.last?.id {
                            Divider().padding(.leading, 14)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 380)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 22))
                .foregroundColor(.secondary)
            Text("No lists yet")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Button("Create a list") { showAddList = true }
                .font(.system(size: 12))
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private var footerView: some View {
        HStack(spacing: 0) {
            Button("+ New List") { showAddList = true }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            Spacer()
            Button("Export") { viewModel.export() }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            Text("  ·  ")
                .foregroundColor(.secondary)
                .font(.system(size: 11))
            Button("Import") { viewModel.importData() }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            Text("  ·  ")
                .foregroundColor(.secondary)
                .font(.system(size: 11))
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}
