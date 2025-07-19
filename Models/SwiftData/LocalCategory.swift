import Foundation
import SwiftData

@Model
final class LocalCategory {
    var id: Int
    var name: String
    var emoji: String
    var direction: String
    
    init(id: Int, name: String, emoji: String, direction: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }
    
    convenience init(from category: Category) {
        self.init(
            id: category.id,
            name: category.name,
            emoji: String(category.emoji),
            direction: category.direction.rawValue
        )
    }
    
    func toCategory() -> Category {
        return Category(
            id: id,
            name: name,
            emoji: Character(emoji),
            direction: Direction(rawValue: direction) ?? .income
        )
    }
} 