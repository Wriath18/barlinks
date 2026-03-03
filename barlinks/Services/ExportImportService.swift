import Foundation
import AppKit
import UniformTypeIdentifiers

class ExportImportService {
    static let shared = ExportImportService()

    private init() {}

    func export(appData: AppData) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(appData) else { return }

        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = "barlinks-export.json"
            panel.title = "Export barlinks Data"
            if panel.runModal() == .OK, let url = panel.url {
                try? data.write(to: url)
            }
        }
    }

    func importData(completion: @escaping (AppData?) -> Void) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.json]
            panel.title = "Import barlinks Data"
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false

            if panel.runModal() == .OK, let url = panel.url {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let appData = try decoder.decode(AppData.self, from: data)
                    completion(appData)
                } catch {
                    print("Error importing: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
}
