import Foundation

struct AppData: Codable {
    var version: Int
    var lists: [LinkList]

    init() {
        self.version = 1
        self.lists = []
    }
}
