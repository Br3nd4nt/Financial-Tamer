//
//  CategoriesServiceMock.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

final class CategoriesServiceMock: CategoriesProtocol {
    
    private var mockCategories: [Category] = [
        Category( id: 1, name: "Wage", emoji: Character("💸"), direction: .income ),
        Category( id: 2, name: "Clothes", emoji: Character("👔"), direction: .outcome ),
        Category( id: 3, name: "Pets", emoji: Character("🐶"), direction: .outcome)
    ]
    
    func getCategories() async throws -> [Category] {
        return mockCategories
    }
    
    func getCategoriesDyDirection(direction: Direction) async throws -> [Category] {
        return mockCategories.filter { $0.direction == direction }
    }
    
}
