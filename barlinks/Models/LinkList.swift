import Foundation

struct LinkList: Codable, Identifiable {
    var id: UUID
    var name: String
    var order: Int
    var createdAt: Date
    var links: [LinkItem]

    init(name: String, order: Int = 0) {
        self.id = UUID()
        self.name = name
        self.order = order
        self.createdAt = Date()
        self.links = []
    }
}
