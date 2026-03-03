import Foundation
import Combine

class AppViewModel: ObservableObject {
    @Published var appData: AppData
    @Published var pendingServiceURL: String? = nil

    init() {
        self.appData = StorageService.shared.load()
    }

    // MARK: - Lists

    func addList(name: String) {
        let newList = LinkList(name: name, order: appData.lists.count)
        appData.lists.append(newList)
        save()
    }

    func deleteList(id: UUID) {
        appData.lists.removeAll { $0.id == id }
        save()
    }

    // MARK: - Links

    func addLink(title: String, content: String, type: ItemType = .link, toList listID: UUID) {
        guard let index = appData.lists.firstIndex(where: { $0.id == listID }) else { return }
        let link = LinkItem(title: title, content: content, type: type)
        appData.lists[index].links.append(link)
        save()
    }

    func deleteLink(id: UUID, fromList listID: UUID) {
        guard let listIndex = appData.lists.firstIndex(where: { $0.id == listID }) else { return }
        appData.lists[listIndex].links.removeAll { $0.id == id }
        save()
    }

    func updateLink(id: UUID, fromList listID: UUID, title: String, content: String, type: ItemType) {
        guard let listIndex = appData.lists.firstIndex(where: { $0.id == listID }),
              let linkIndex = appData.lists[listIndex].links.firstIndex(where: { $0.id == id }) else { return }
        appData.lists[listIndex].links[linkIndex].title = title
        appData.lists[listIndex].links[linkIndex].content = content
        appData.lists[listIndex].links[linkIndex].type = type
        save()
    }

    // MARK: - Import / Export

    func export() {
        ExportImportService.shared.export(appData: appData)
    }

    func importData() {
        ExportImportService.shared.importData { [weak self] newData in
            guard let self, let newData else { return }
            DispatchQueue.main.async {
                self.appData = newData
                self.save()
            }
        }
    }

    // MARK: - Private

    private func save() {
        StorageService.shared.save(appData)
    }
}
