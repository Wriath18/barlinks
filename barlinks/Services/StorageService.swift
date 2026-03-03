import Foundation

class StorageService {
    static let shared = StorageService()

    private let barlinksDirectory: URL
    private let dataFileURL: URL

    private init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        barlinksDirectory = homeDir.appendingPathComponent(".barlinks")
        dataFileURL = barlinksDirectory.appendingPathComponent("data.json")
    }

    func load() -> AppData {
        ensureDirectoryExists()
        guard FileManager.default.fileExists(atPath: dataFileURL.path) else {
            return AppData()
        }
        do {
            let data = try Data(contentsOf: dataFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(AppData.self, from: data)
        } catch {
            print("Error loading data: \(error)")
            return AppData()
        }
    }

    func save(_ appData: AppData) {
        ensureDirectoryExists()
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(appData)
            try data.write(to: dataFileURL, options: .atomic)
        } catch {
            print("Error saving data: \(error)")
        }
    }

    private func ensureDirectoryExists() {
        if !FileManager.default.fileExists(atPath: barlinksDirectory.path) {
            try? FileManager.default.createDirectory(
                at: barlinksDirectory,
                withIntermediateDirectories: true
            )
        }
    }
}
