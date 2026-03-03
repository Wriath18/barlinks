import Foundation

enum ItemType: String, Codable {
    case link
    case text
}

struct LinkItem: Codable, Identifiable {
    var id: UUID
    var title: String
    var content: String  // URL when type == .link, plain text when type == .text
    var type: ItemType
    var favicon: String?
    var notes: String
    var addedAt: Date

    init(title: String, content: String, type: ItemType = .link) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.type = type
        self.favicon = nil
        self.notes = ""
        self.addedAt = Date()
    }

    // Custom decoder so old JSON without a "type" key defaults to .link
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        // Support old JSON that used "url" as the key
        content = try c.decodeIfPresent(String.self, forKey: .content)
            ?? c.decodeIfPresent(String.self, forKey: .url)
            ?? ""
        type = try c.decodeIfPresent(ItemType.self, forKey: .type) ?? .link
        favicon = try c.decodeIfPresent(String.self, forKey: .favicon)
        notes = try c.decode(String.self, forKey: .notes)
        addedAt = try c.decode(Date.self, forKey: .addedAt)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(content, forKey: .content)
        try c.encode(type, forKey: .type)
        try c.encodeIfPresent(favicon, forKey: .favicon)
        try c.encode(notes, forKey: .notes)
        try c.encode(addedAt, forKey: .addedAt)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, content, url, type, favicon, notes, addedAt
    }
}
