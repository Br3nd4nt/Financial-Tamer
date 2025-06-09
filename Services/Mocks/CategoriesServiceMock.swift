//
//  CategoriesServiceMock.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

final class CategoriesServiceMock: CategoriesProtocol {
    func getCategories() async throws -> [Category] {
        return [
            Category( id: 1, name: "Wage", emoji: Character("💸"), direction: .income ),
            Category( id: 2, name: "Clothes", emoji: Character("👔"), direction: .outcome ),
            Category( id: 3, name: "Pets", emoji: Character("🐶"), direction: .outcome)
        ]
    }
    
    func getCategoriesDyDirection(direction: Direction) async throws -> [Category] {
        switch direction {
            case .income:
            return [
                Category( id: 1, name: "Wage", emoji: Character("💸"), direction: .income )
            ]
            case .outcome:
            return [
                Category( id: 2, name: "Clothes", emoji: Character("👔"), direction: .outcome ),
                    Category( id: 3, name: "Pets", emoji: Character("🐶"), direction: .outcome)
            ]
        }
    }
    
    
}
