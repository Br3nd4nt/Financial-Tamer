//
//  CategoriesServiceMock.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

final class CategoriesServiceMock: CategoriesProtocol {
    
    private var mockCategories: [Category] = [
        Category( id: 1, name: "Зарплата", emoji: Character("💸"), direction: .income ),
        Category( id: 2, name: "Подработка", emoji: Character("🤑"), direction: .income ),
        Category( id: 3, name: "Аренда квартиры", emoji: Character("🏠"), direction: .outcome ),
        Category( id: 4, name: "Одежда", emoji: Character("👔"), direction: .outcome ),
        Category( id: 5, name: "Питомцы", emoji: Character("🐕"), direction: .outcome ),
        Category( id: 6, name: "Медицина", emoji: Character("😷"), direction: .outcome ),
        Category( id: 7, name: "Машина", emoji: Character("🏎️"), direction: .outcome )
    ]
    
    func getCategories() async throws -> [Category] {
        return mockCategories
    }
    
    func getCategoriesDyDirection(direction: Direction) async throws -> [Category] {
        return mockCategories.filter { $0.direction == direction }
    }
    
}
